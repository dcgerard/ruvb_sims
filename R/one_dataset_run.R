library(tidyverse)
library(seqgendiff)
library(limma)
source("./Code/nc_adjustment_methods.R")

fill_color <- "white"
seed_seq <- 117:119
mat <- t(as.matrix(read.csv("./Output/gtex_tissue_gene_reads_v6p/muscle.csv",
                            header = TRUE)[, -c(1,2)]))
for (index in 1:length(seed_seq)) {
    current_seed <- seed_seq[index]
    set.seed(current_seed)
    dout <- seqgendiff::poisthin(mat = mat, nsamp = 20, ngene = 10000, prop_null = 1,
                                 gselect = "mean_max")

    Y <- log2(dout$Y + 1)
    X <- dout$X
    lmout <- limma::lmFit(object = t(Y), design = X)
    sebetahat <- lmout$stdev.unscaled[, 2, drop = TRUE] * lmout$sigma
    pvalues <- 2 * stats::pt(-abs(lmout$coefficients[, 2] / sebetahat), df = lmout$df.residual)

    ## Sanity check
    tempdat <- data.frame(resp = Y[, 1], trt = X[, 2])
    stopifnot(abs(coef(summary(lm(resp ~ trt, data = tempdat)))[2, 4] - pvalues[1]) < 10 ^ -6)

    pmat_temp <- data.frame(pvalues = pvalues)
    pmat_temp$seed <- current_seed

    if (index == 1) {
        pmat <- pmat_temp
    } else {
        pmat <- rbind(pmat, pmat_temp)
    }
}

pmat <- as_data_frame(pmat)

pdf(file = "./Output/figures/all_null.pdf", height = 2, width = 6.5, family = "Times", colormodel = "cmyk")
pl <- ggplot(data = pmat, mapping = aes(x = pvalues)) +
  geom_histogram(bins = 15, color = "black", fill = fill_color) +
  facet_wrap(~seed, scales = "free_y") +
  ylab("Counts") +
  xlab("P-values") +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text = element_blank())
print(pl)
dev.off()
