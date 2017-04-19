library(reshape2)
library(ggplot2)
library(dplyr)
library(tidyr)

mse_mat <- read.csv("./Output/sims_out/mse_mat2.csv")
auc_mat <- read.csv("./Output/sims_out/auc_mat2.csv")
cov_mat <- read.csv("./Output/sims_out/cov_mat2.csv")

good_names <- c("OLS", "RUV2", "RUV3", "RUV4", "RUV4c", "CATE",
                "CATEc", "RUVB")

colnames(cov_mat)[6:ncol(cov_mat)] <- good_names

colnames(auc_mat)[6:ncol(auc_mat)] <- good_names

## Coverage -------------------------------------------------------
longdat <- reshape2::melt(data = cov_mat, measure.vars = good_names)
longdat$Nsamp <- longdat$Nsamp * 2
longcov <- aggregate(value ~ variable + ncontrols + Nsamp + nullpi,
                     data = longdat, FUN = mean)
longcov$sd <- aggregate(value ~ variable + ncontrols + Nsamp + nullpi,
                        data = longdat, FUN = sd)$value
longcov$median <- aggregate(value ~ variable + ncontrols + Nsamp + nullpi,
                        data = longdat, FUN = median)$value
names(longcov) <- c("Method", "ncontrols", "Nsamp", "nullpi", "Mean", "SD", "Median")
longcov$Lower <- longcov$Mean - 2 * longcov$SD / sqrt(500)
longcov$Upper <- longcov$Mean + 2 * longcov$SD / sqrt(500)
final_cov <- dplyr::filter(longcov, nullpi == 0.5)
pl <- ggplot(final_cov, mapping = aes(x = Nsamp, y = Median, color = Method, lty = Method)) +
    geom_point(size = 0.7) +
    facet_grid(.~ncontrols) +
    geom_line() +
    geom_hline(yintercept = 0.95, lty = 2) +
    theme_bw() +
    ylab("Median Coverage") +
    xlab("Sample Size") +
    theme(strip.background = element_rect(fill="white")) +
    guides(color = guide_legend(keywidth = 4))
pdf(file = "./Output/figures/coverage_lines_5.pdf", family = "Times", height = 3.2, width = 6.5)
print(pl)
dev.off()

pl <- pl + theme(axis.title = element_text(size = 25)) + geom_line(lwd = 2)
pdf(file = "./Output/figures/coverage_lines_5_wide.pdf", family = "Times", height = 3.2, width = 10)
print(pl)
dev.off()

pl <- ggplot(longcov, mapping = aes(x = Nsamp, y = Mean, color = Method, lty = Method)) +
    geom_point(size = 0.7) +
    facet_grid(nullpi~ncontrols) +
    geom_line() +
    geom_hline(yintercept = 0.95, lty = 2) +
    theme_bw() +
    ylab("Mean Coverage") +
    xlab("Sample Size") +
    theme(strip.background = element_rect(fill="white")) +
    geom_errorbar(mapping = aes(ymax = Upper, ymin = Lower)) +
    guides(color = guide_legend(keywidth = 4))
pdf(file = "./Output/figures/coverage_lines.pdf", family = "Times", height = 7.5, width = 6.5)
print(pl)
dev.off()


## How often coverage is really bad -----------------------------------------
thresh <- 0.6
longdat$lessthresh <- longdat$value <= thresh * 1
longbad <- aggregate(lessthresh ~ variable + ncontrols + Nsamp + nullpi,
                     data = longdat, FUN = mean)
names(longbad)[1] <- "Method"
finalbad <- dplyr::filter(longbad, nullpi == 0.5)

pl <- ggplot(data = finalbad, mapping = aes(x = Nsamp, y = lessthresh, color = Method)) +
  geom_point(size = 0.7) +
  geom_line() +
  facet_grid(.~ncontrols) +
  ylab("Proportion of Times Below Threshold") +
  xlab("Sample Size") +
  theme_bw() +
  theme(strip.background = element_rect(fill="white")) +
  guides(color = guide_legend(keywidth = 4))
pdf(file = paste0("./Output/figures/prop_bad05_", thresh * 100, ".pdf"), family = "Times", height = 3.2, width = 6.5)
print(pl)
dev.off()

## AUC ------------------------------------------------------------
diff_mat <- cbind(auc_mat[, 1:5], auc_mat[, -c(1:5)] - auc_mat$RUVB)
diff_mat$Nsamp <- diff_mat$Nsamp * 2
longdat <- filter(melt(data = diff_mat, id.vars = 1:5), nullpi != 1)

long_diff <- longdat %>% group_by(variable, nullpi, Nsamp, ncontrols) %>%
  summarise(median = median(value))
long_diff <- longdat %>% group_by(variable, nullpi, Nsamp, ncontrols) %>%
  summarise(mean = mean(value)) %>%
  full_join(long_diff, by = c("variable", "nullpi", "Nsamp", "ncontrols"))
long_diff <- longdat %>% group_by(variable, nullpi, Nsamp, ncontrols) %>%
  summarise(sd = sd(value)) %>%
  full_join(long_diff, by = c("variable", "nullpi", "Nsamp", "ncontrols"))
long_diff$lower <- long_diff$mean - 2 * long_diff$sd / sqrt(500)
long_diff$upper <- long_diff$mean + 2 * long_diff$sd / sqrt(500)

final_diff <- filter(long_diff, nullpi == 0.5, variable != "RUVB")
names(final_diff)[names(final_diff) == "variable"] <- "Method"

pl <- ggplot(final_diff, mapping = aes(x = Nsamp, y = mean, color = Method, lty = Method)) +
    geom_point(size = 0.7) +
    facet_grid(.~ncontrols) +
    geom_line() +
    theme_bw() +
    geom_hline(yintercept = 0, lty = 2) +
    ylab("Difference in Mean AUC") +
    xlab("Sample Size") +
    theme(strip.background = element_rect(fill="white")) +
    guides(color = guide_legend(keywidth = 4))
pdf(file = "./Output/figures/diff_lines_5.pdf", family = "Times", height = 3.2, width = 6.5)
print(pl)
dev.off()

pl <- pl + theme(axis.title.y = element_text(size = 20), axis.title.x = element_blank()) +
  geom_line(lwd = 2)
pdf(file = "./Output/figures/diff_lines_5_wide.pdf", family = "Times", height = 3.2, width = 10)
print(pl)
dev.off()

### combine results from final_diff and final_cov ----------------------------
final_diff$Type = "AUC Difference"
final_cov$Type = "Coverage"
order_vec <- match(stringr::str_to_upper(names(final_diff)), stringr::str_to_upper(names(final_cov)))

capwords <- function(s, strict = TRUE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
                           {s <- substring(s, 2); if(strict) tolower(s) else s},
                           sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}

names(final_diff) <- capwords(names(final_diff))
names(final_cov) <- capwords(names(final_cov))

stopifnot(names(final_cov[, order_vec]) == names(final_diff))
combdat <- as_data_frame(bind_rows(final_cov[, order_vec], final_diff))

combdat$Method <- as.character(combdat$Method)
combdat$Method[combdat$Method == "RUVB"] <- "RUV*"

dummydat <- expand.grid(unique(combdat$Ncontrols), unique(combdat$Type))
names(dummydat) <- c("Ncontrols", "Type")
dummydat$h <- 0
dummydat$h[dummydat$Type == "Coverage"] <- 0.95
pl <- ggplot(data = combdat, mapping = aes(x = Nsamp, y = Median, color = Method, linetype = Method)) +
  geom_line(lwd = 1) +
  facet_grid(Type ~ Ncontrols, scales = "free") +
  xlab("Sample Size") +
  ylab("Median") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.title = element_text(size = 25), axis.text = element_text(size = 20),
        legend.text = element_text(size = 20), legend.title = element_text(size = 20),
        strip.text = element_text(size = 20)) +
  geom_hline(data = dummydat, mapping = aes(yintercept = h), lty = 2) +
  guides(color = guide_legend(keywidth = 4))
pdf(file = "./Output/figures/combined_diff_cov.pdf", family = "Times", height = 6.4, width = 10)
print(pl)
dev.off()

## END COMBINE ---------------------------------------------------------------

final_diff <- dplyr::filter(long_diff, Method != "RUVB")
pl <- ggplot(final_diff, mapping = aes(x = Nsamp, y = Mean, color = Method, lty = Method)) +
    geom_point(size = 0.7) +
    facet_grid(nullpi~ncontrols) +
    geom_line() +
    theme_bw() +
    geom_hline(yintercept = 0, lty = 2) +
    ylab("Difference in Mean AUC") +
    xlab("Sample Size") +
    theme(strip.background = element_rect(fill="white")) +
    geom_errorbar(mapping = aes(ymin = Lower, ymax = Upper)) +
    guides(color = guide_legend(keywidth = 4))
pdf(file = "./Output/figures/diff_lines.pdf", family = "Times", height = 7.5, width = 6.5)
print(pl)
dev.off()
