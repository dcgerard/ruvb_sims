library(reshape2)
library(ggplot2)
library(dplyr)

mse_mat <- read.csv("../Output/sims_out/mse_mat2.csv")
auc_mat <- read.csv("../Output/sims_out/auc_mat2.csv")
cov_mat <- read.csv("../Output/sims_out/cov_mat2.csv")

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
pdf(file = "../Output/figures/coverage_lines_5.pdf", family = "Times", height = 3.2, width = 6.5)
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
pdf(file = "../Output/figures/coverage_lines.pdf", family = "Times", height = 7.5, width = 6.5)
print(pl)
dev.off()

## AUC ------------------------------------------------------------
diff_mat <- cbind(auc_mat[, 1:5], auc_mat[, -c(1:5)] - auc_mat$RUVB)
diff_mat$Nsamp <- diff_mat$Nsamp * 2
longdat <- filter(melt(data = diff_mat, id.vars = 1:5), nullpi != 1)
long_diff <- aggregate(value ~ variable + nullpi + Nsamp + ncontrols, data = longdat, FUN = "median")
long_diff$mean <- aggregate(value ~ variable + nullpi + Nsamp + ncontrols, data = longdat, FUN = "mean")$value
long_diff$sd <- aggregate(value ~ variable + nullpi + Nsamp + ncontrols, data = longdat, FUN = "sd")$value
long_diff$lower <- long_diff$mean - 2 * long_diff$sd / sqrt(500)
long_diff$upper <- long_diff$mean + 2 * long_diff$sd / sqrt(500)

names(long_diff) <- c("Method", "nullpi", "Nsamp", "ncontrols", "Median",
                      "Mean", "SD", "Lower", "Upper")
final_diff <- dplyr::filter(long_diff, nullpi == 0.5 & Method != "RUVB")
pl <- ggplot(final_diff, mapping = aes(x = Nsamp, y = Mean, color = Method, lty = Method)) +
    geom_point(size = 0.7) +
    facet_grid(.~ncontrols) +
    geom_line() +
    theme_bw() +
    geom_hline(yintercept = 0, lty = 2) +
    ylab("Difference in Mean AUC") +
    xlab("Sample Size") +
    theme(strip.background = element_rect(fill="white")) +
    guides(color = guide_legend(keywidth = 4))
pdf(file = "../Output/figures/diff_lines_5.pdf", family = "Times", height = 3.2, width = 6.5)
print(pl)
dev.off()

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
pdf(file = "../Output/figures/diff_lines.pdf", family = "Times", height = 7.5, width = 6.5)
print(pl)
dev.off()
