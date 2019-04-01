#############
## Plot the results from correlation_sims.R
#############

library(tidyverse)
library(broom)
library(ggthemes)

## Read in and clean data ------------------------------------------------------
corlist <- readRDS("./Output/cor_sims_out/cor_sims.RDS")

stopifnot(all(map_lgl(corlist[, 2], ~is.null(.))))

sout <- do.call(rbind, corlist[, 1])

subnamevec <- colnames(sout)[-(1:10)]

num_method <- length(subnamevec) / 3
subnamevec[1:num_method] <- str_c("mse_", subnamevec[1:num_method])
subnamevec[(num_method + 1):(2 * num_method)] <- str_c("auc_", subnamevec[(num_method + 1):(2 * num_method)])
subnamevec[(2*num_method + 1):(3*num_method)] <- str_c("cov_", subnamevec[(2*num_method + 1):(3*num_method)])

colnames(sout)[-(1:10)] <- subnamevec

sout <- as_tibble(sout)

lvec <- c("0", "0.25", "0.5", "0.75", "(0.25, 0.25)", "(0.5, 0.5)")
sout %>%
  rename(auc_ruvbn_  = auc_ruvbn,
         auc_ruvbnl_ = auc_ruvbnl,
         auc_ruvbnn_ = auc_ruvbnn,
         auc_ruvb_   = auc_ruvb,
         mse_ruvbn_  = mse_ruvbn,
         mse_ruvbnl_ = mse_ruvbnl,
         mse_ruvbnn_ = mse_ruvbnn,
         mse_ruvb_   = mse_ruvb,
         cov_ruvbn_  = cov_ruvbn,
         cov_ruvbnl_ = cov_ruvbnl,
         cov_ruvbnn_ = cov_ruvbnn,
         cov_ruvb_   = cov_ruvb) %>%
  mutate(iternum = row_number()) %>%
  gather(-iternum,
         -log2foldsd,
         -log2foldmean,
         -Ngene,
         -skip_gene,
         -current_seed,
         -nullpi,
         -Nsamp,
         -ncontrols,
         -cor,
         -poisthin,
         key = "method",
         value = "value") %>%
  separate(method, into = c("metric", "method", "var"), sep = "_") %>%
  mutate(corname = recode(cor,
                          `1` = "0",
                          `2` = "0.25",
                          `3` = "0.5",
                          `4` = "0.75",
                          `5` = "(0.25, 0.25)",
                          `6` = "(0.5, 0.5)"),
         corname = parse_factor(corname, levels = lvec)) %>%
  select(Nsamp, corname, iternum, metric, method, var, value)->
  slong


## Calculate difference between RUVB auc and other auc
slong %>%
  filter(metric == "auc") %>%
  group_by(iternum) %>%
  mutate(current_ruvb_auc = value[method == "ruvbnl"],
         diff_auc = value - current_ruvb_auc)  %>%
  ungroup() ->
  aucdf


aucdf %>%
  select(-metric, -iternum, -value, -current_ruvb_auc) %>%
  nest(diff_auc) %>%
  mutate(t_test = map(data, ~t.test(.$diff_auc)),
         tidied = map(t_test, tidy)) %>%
  unnest(tidied, .drop = TRUE) %>%
  select(Nsamp, corname, method, var, estimate, conf.low, conf.high) ->
  stest

## Select one of the best performing methods.
## get rid of ruv4 since that always performs worse than cate and
## is in the same family
stest %>%
  group_by(method, var) %>%
  summarize(meddiff = median(estimate)) %>%
  ungroup() %>%
  group_by(method) %>%
  filter(meddiff == max(meddiff)) %>%
  sample_n(1) %>%
  ungroup() %>%
  filter(method %in% c("cate", "ruv2", "ruv3")) %>%
  select(-meddiff) ->
  which_keep_df

stest %>%
  semi_join(which_keep_df, by = c("method", "var")) %>%
  mutate(method = recode(method,
                         "cate" = "RUV4/CATE",
                         "ruv2" = "RUV2+EBVM",
                         "ruv3" = "RUV3+EBVM")) %>%
  ggplot(aes(x = Nsamp, y = estimate, color = method)) +
  facet_wrap(.~corname) +
  geom_line() +
  geom_hline(yintercept = 0, lty = 2) +
  geom_segment(aes(y = conf.low, yend = conf.high, xend = Nsamp)) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Sample Size") +
  ylab("Mean AUC Difference from RUVB (with EBVM)") +
  scale_color_colorblind() ->
  pl

ggsave("./Output/figures/cor_sims_auc.pdf", plot = pl, width = 6, height = 4)


## Make boxplots of coverage
slong %>%
  filter(metric == "cov") %>%
  group_by(Nsamp, corname, method, var) %>%
  summarize(msecov = mean((value - 0.95)^2)) %>%
  ungroup() %>%
  group_by(method) %>%
  filter(msecov == min(msecov)) %>%
  sample_n(1) %>%
  select(method, var) %>%
  filter(method %in% c("ruv2", "ruv3", "cate", "ruvbnl", "ruvb")) ->
  chosen_meth

## choose methods with smallest mse from 0.95
slong %>%
  filter(metric == "cov") %>%
  semi_join(chosen_meth, by = "method", "var") %>%
  mutate(method = recode(method,
                         ruv2 = "RUV2",
                         ruv3 = "RUV3",
                         cate = "RUV4/CATE",
                         ruvb = "RUVB-sample",
                         ruvbnl = "RUVB-normal")) %>%
  ggplot(aes(x = method, y = value, color = method)) +
  facet_grid(corname ~ Nsamp) +
  geom_boxplot() +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  geom_hline(yintercept = 0.95, lty = 2) +
  xlab("Method") +
  ylab("Coverage") ->
  pl

ggsave(filename = "./Output/figures/cov_box.pdf", plot = pl, height = 9, width = 6.5)


