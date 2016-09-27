#########################
## Synopsis: plot simulations from ruv3paper_sims.R
########################
library(reshape2)
library(ggplot2)
library(dplyr)

mse_mat <- read.csv("../Output/sims_out/mse_mat2.csv")
auc_mat <- read.csv("../Output/sims_out/auc_mat2.csv")
cov_mat <- read.csv("../Output/sims_out/cov_mat2.csv")

colnames(cov_mat)[6:ncol(cov_mat)] <- c("OLS", "RUV2", "RUV3", "RUV4",
                                        "RUV4c", "CATE", "CATEc",
                                        "RUVB")

colnames(auc_mat)[6:ncol(auc_mat)] <- c("OLS", "RUV2", "RUV3", "RUV4",
                                        "RUV4c", "CATE", "CATEc",
                                        "RUVB")
## Coverage Plot -------------------------------------------------

longdat <- melt(data = cov_mat, id.vars = 1:5)
longdat$Nsamp <- longdat$Nsamp * 2
pdf(file = "../Output/figures/coverage.pdf", height = 8, width = 6.5, family = "Times")
p <- ggplot(data = longdat, mapping = aes(y = value, x = variable)) +
    geom_boxplot(outlier.size = 0.2, size = 0.2) +
    facet_grid(nullpi + ncontrols ~ Nsamp) +
    geom_hline(yintercept = 0.95, lty = 2) +
    xlab("Method") + ylab("Coverage")  +
    theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.background = element_rect(fill="white"))
print(p)
dev.off()


## Coverage plot just nullpi = 0.5 ---------------------------------------
longdat <- melt(data = cov_mat, id.vars = 1:5)
longdat$Nsamp <- longdat$Nsamp * 2
longdat <- filter(longdat, nullpi == 0.5)
pdf(file = "../Output/figures/coverage_5.pdf", height = 3.2, width = 6.5, family = "Times")
p <- ggplot(data = longdat, mapping = aes(y = value, x = variable)) +
    geom_boxplot(outlier.size = 0.2, size = 0.2) +
    facet_grid(ncontrols ~ Nsamp) +
    geom_hline(yintercept = 0.95, lty = 2) +
    xlab("Method") + ylab("Coverage")  +
    theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.background = element_rect(fill="white"))
print(p)
dev.off()


## AUC plot ------------------------------------------------------
nullpi_seq <- unique(auc_mat$nullpi)
nsamp_seq <- unique(auc_mat$Nsamp)
ncontrol_seq <- unique(auc_mat$ncontrols)
dummy_dat <- expand.grid(nullpi_seq, nsamp_seq, ncontrol_seq)
colnames(dummy_dat) <- c("nullpi", "Nsamp", "ncontrols")
med_mat <- matrix(NA, nrow = (length(nullpi_seq) - 1) * length(nsamp_seq) * length(ncontrol_seq),
                  ncol = ncol(auc_mat) - 5)
for (index in 6:ncol(auc_mat)) {
    form1 <- as.formula(paste(colnames(auc_mat)[index], "~ nullpi + Nsamp + ncontrols"))
    out1 <- aggregate(form1, FUN = median, na.rm = TRUE,
                      data = auc_mat)
    med_mat[, index - 5] <- out1[, 4]
}
dummy_dat <- cbind(expand.grid(nullpi_seq[nullpi_seq != 1], nsamp_seq, ncontrol_seq),
                   apply(med_mat, 1, max))
colnames(dummy_dat) <- c("nullpi", "Nsamp", "ncontrols", "max_med")

longdat <- filter(melt(data = auc_mat, id.vars = 1:5), nullpi != 1)
longdat$Nsamp <- longdat$Nsamp * 2
dummy_dat$Nsamp <- dummy_dat$Nsamp * 2
pdf(file = "../Output/figures/auc.pdf", height = 8, width = 6.5, family = "Times")
p <- ggplot(data = longdat, mapping = aes(y = value, x = variable)) +
    geom_boxplot(outlier.size = 0.2, size = 0.2) +
    facet_grid(nullpi + ncontrols ~ Nsamp) +
    geom_hline(data = dummy_dat, mapping = aes(yintercept = max_med), lty = 2) +
    xlab("Method") + ylab("AUC") +
    theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.background = element_rect(fill="white"))
print(p)
dev.off()

## Diff AUC Plot ------------------------------------------------------------
diff_mat <- cbind(auc_mat[, 1:5], auc_mat[, -c(1:5)] - auc_mat$RUVB)
diff_mat <- select(diff_mat, -RUVB)

longdat <- filter(melt(data = diff_mat, id.vars = 1:5), nullpi != 1)
longdat$Nsamp <- longdat$Nsamp * 2
dummy_dat$Nsamp <- dummy_dat$Nsamp * 2
pdf(file = "../Output/figures/diff.pdf", height = 7.5, width = 6.5, family = "Times")
p <- ggplot(data = longdat, mapping = aes(y = value, x = variable)) +
    geom_boxplot(outlier.size = 0.2, size = 0.2) +
    facet_grid(nullpi + ncontrols ~ Nsamp) +
    geom_hline(yintercept = 0, lty = 2) +
    xlab("Method") + ylab("Difference in AUC") +
    ylim(-0.2, 0.1) +
    theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.background = element_rect(fill="white"))
print(p)
dev.off()

## Diff AUC Plot at nullpi = 0.5 ----------------------------------------------
diff_mat <- cbind(auc_mat[, 1:5], auc_mat[, -c(1:5)] - auc_mat$RUVB)
diff_mat <- select(diff_mat, -RUVB)

longdat <- filter(melt(data = diff_mat, id.vars = 1:5), nullpi != 1)
longdat$Nsamp <- longdat$Nsamp * 2
longdat <- filter(longdat, nullpi == 0.5)
dummy_dat$Nsamp <- dummy_dat$Nsamp * 2
pdf(file = "../Output/figures/diff_5.pdf", height = 3.2, width = 6.5, family = "Times")
p <- ggplot(data = longdat, mapping = aes(y = value, x = variable)) +
    geom_boxplot(outlier.size = 0.2, size = 0.2) +
    facet_grid(ncontrols ~ Nsamp) +
    geom_hline(yintercept = 0, lty = 2) +
    xlab("Method") + ylab("Difference in AUC") +
    ylim(-0.2, 0.1) +
    theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(strip.background = element_rect(fill="white"))
print(p)
dev.off()

## Other Plots ----------------------------------------------------------------



auc_mat$bm2 <- auc_mat$RUVB - auc_mat$RUV2
auc_mat$threem2 <-auc_mat$RUV3 - auc_mat$RUV2
auc_mat$bmc <- auc_mat$RUVB - auc_mat$CATE
auc_mat$bm3 <- auc_mat$RUVB - auc_mat$RUV3


temp <- filter(auc_mat, nullpi != 1)

pdf(file = "../Output/figures/bm2.pdf", family = "Times", height = 3, width = 3)
p1 <- ggplot(data = temp, mapping = aes(y = bm2, x = as.factor(Nsamp))) +
    facet_grid(nullpi ~ ncontrols) +
    geom_boxplot(outlier.size = 0.3, size = 0.2) +
    geom_hline(yintercept = 0, lty = 2) +
    xlab("Sample Size") + ylab("RUVB - RUV2") +
    theme_bw() +
    theme(strip.background = element_rect(fill="white"))
print(p1)
dev.off()

pdf(file = "../Output/figures/tm2.pdf", family = "Times", height = 3, width = 3)
p2 <- ggplot(data = temp, mapping = aes(y = threem2, x = as.factor(Nsamp))) +
    facet_grid(nullpi ~ ncontrols) +
    geom_boxplot(outlier.size = 0.2, size = 0.2) +
    geom_hline(yintercept = 0, lty = 2) +
    xlab("Sample Size") + ylab("RUV3 - RUV2") +
    theme_bw() +
    theme(strip.background = element_rect(fill="white"))
print(p2)
dev.off()


ggplot(data = temp, mapping = aes(y = bm3, x = as.factor(Nsamp))) +
    facet_grid(nullpi ~ ncontrols) +
    geom_boxplot() +
    geom_hline(yintercept = 0, lty = 2) +
    xlab("Sample Size") + ylab("RUVB - RUV2")

ggplot(data = temp, mapping = aes(y = bmc, x = as.factor(Nsamp))) +
    facet_grid(nullpi ~ ncontrols) +
    geom_boxplot() +
    geom_hline(yintercept = 0, lty = 2) +
    xlab("Sample Size") + ylab("RUVB - RUV2")

## check methods
## source("../code/adjustment_methods.R")
## n <- 10
## p <- 100
## ncov <- 2
## Y <- matrix(rnorm(n * p), nrow = n)
## X <- matrix(rnorm(n * ncov), nrow = n)
## num_sv <- 2
## ncontrols <- 13
## ctl <- rep(FALSE, length = p)
## ctl[1:ncontrols] <- TRUE
## ruv4out <- ruv4(Y = Y, X = X, num_sv = num_sv, control_genes = ctl)
## ruv4ebayes_out <- ruv4_rsvar_ebayes(Y = Y, X = X, num_sv = num_sv, control_genes = ctl)

## plot(ruv4out$pvalues, ruv4ebayes_out$pvalues)

## tstat1 <- ruv4out$betahat / ruv4out$sebetahat
## tstat2 <- ruv4out$betahat / sqrt(limma::squeezeVar(ruv4out$sebetahat ^ 2, df = ruv4out$df)$var.post)
## plot(tstat1, tstat2)
