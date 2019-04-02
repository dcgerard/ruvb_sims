#############
## Plot the results from misspecified_sims.R
#############

suppressPackageStartupMessages(library(tidyverse))
library(broom)
library(ggthemes)

## Read in and clean data ------------------------------------------------------
mismat <- readRDS("./Output/mis_sims_out/mis_sims.RDS")

subnamevec <- colnames(mismat)[-(1:10)]
num_method <- length(subnamevec) / 3
subnamevec[1:num_method] <- str_c("mse_", subnamevec[1:num_method])
subnamevec[(num_method + 1):(2 * num_method)] <- str_c("auc_", subnamevec[(num_method + 1):(2 * num_method)])
subnamevec[(2*num_method + 1):(3*num_method)] <- str_c("cov_", subnamevec[(2*num_method + 1):(3*num_method)])

colnames(mismat)[-(1:10)] <- subnamevec

misdf <- as_tibble(mismat)


misdf %>%
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
  select(iternum, everything()) %>%
  gather(-iternum,
         -log2foldsd,
         -Ngene,
         -log2foldmean,
         -skip_gene,
         -current_seed,
         -nullpi,
         -Nsamp,
         -ncontrols,
         -prop_cont,
         -poisthin,
         key = "metric_method_var",
         value = "value") %>%
  select(iternum, Nsamp, prop_cont, metric_method_var, value) %>%
  separate(metric_method_var, into = c("metric", "method", "var"), sep = "_") ->
  misdf_long


## Calculate difference between RUVB auc and other auc
misdf_long %>%
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
  select(Nsamp, prop_cont, method, var, estimate, conf.low, conf.high) ->
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
  facet_wrap(.~prop_cont) +
  geom_line() +
  geom_hline(yintercept = 0, lty = 2) +
  geom_segment(aes(y = conf.low, yend = conf.high, xend = Nsamp)) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Sample Size") +
  ylab("Mean AUC Difference from RUVB (with EBVM)") +
  scale_color_colorblind() ->
  pl



ggsave("./Output/figures/mis_sims_auc.pdf", plot = pl, width = 6, height = 4)



## Make boxplots of coverage
misdf_long %>%
  filter(metric == "cov") %>%
  group_by(Nsamp, prop_cont, method, var) %>%
  summarize(msecov = mean((value - 0.95)^2)) %>%
  ungroup() %>%
  group_by(method) %>%
  filter(msecov == min(msecov)) %>%
  sample_n(1) %>%
  select(method, var) %>%
  filter(method %in% c("ruv2", "ruv3", "cate", "ruvbnl", "ruvb")) ->
  chosen_meth

## choose methods with smallest mse from 0.95
misdf_long %>%
  filter(metric == "cov") %>%
  semi_join(chosen_meth, by = "method", "var") %>%
  mutate(method = recode(method,
                         ruv2 = "RUV2",
                         ruv3 = "RUV3",
                         cate = "RUV4/CATE",
                         ruvb = "RUVB-sample",
                         ruvbnl = "RUVB-normal")) %>%
  ggplot(aes(x = method, y = value, color = method)) +
  facet_grid(prop_cont ~ Nsamp) +
  geom_boxplot() +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
  geom_hline(yintercept = 0.95, lty = 2) +
  xlab("Method") +
  ylab("Coverage") ->
  pl

ggsave(filename = "./Output/figures/mis_box.pdf", plot = pl, height = 9, width = 6.5)








