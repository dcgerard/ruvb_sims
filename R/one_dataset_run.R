library(ggplot2)
library(reshape2)
library(gridExtra)
source("./Code/data_generators.R")
source("./Code/adjustment_methods.R")
source("./Code/summary_stat_methods.R")
source("./Code/evaluations.R")

fill_color <- "white"
seed_seq <- 117:119
for (index in 1:length(seed_seq)) {
    current_seed <- seed_seq[index]
    set.seed(current_seed)
    dout <- pois_thin(Nsamp = 10, nullpi = 1, path = "./Output/gtex_tissue_gene_reads_v6p/",
                      ncontrol = 300, Ngene = 10000)
    Y <- dout$Y
    X <- dout$X
    olsout <- ols(Y = Y, X = X)

    pmat_temp <- data.frame(pvalues = olsout$pvalues)
    pmat_temp$seed <- current_seed

    if (index == 1) {
        pmat <- pmat_temp
    } else {
        pmat <- rbind(pmat, pmat_temp)
    }
}

pdf(file = "./Output/figures/all_null.pdf", height = 2, width = 6, family = "Times", colormodel = "cmyk")
longdat <- melt(pmat[pmat$seed == seed_seq[1], ], id.vars = "seed")
p1 <- ggplot(data = longdat, mapping = aes(x = value, color = I("black"), fill = I(fill_color))) +
    geom_histogram(bins = 15) +
    ylab("Counts") +
    xlab("P-values") +
    theme_bw() +
    theme(strip.background = element_blank(),
          strip.text.y = element_blank())

longdat <- melt(pmat[pmat$seed == seed_seq[2], ], id.vars = "seed")
p2 <- ggplot(data = longdat, mapping = aes(x = value, color = I("black"), fill = I(fill_color))) +
    geom_histogram(bins = 15) +
    ylab("") +
    xlab("P-values") +
    theme_bw() +
    theme(strip.background = element_rect(fill = fill_color),
          strip.text.y = element_text(size = 9))

longdat <- melt(pmat[pmat$seed == seed_seq[3], ], id.vars = "seed")
p3 <- ggplot(data = longdat, mapping = aes(x = value, color = I("black"), fill = I(fill_color))) +
    geom_histogram(bins = 15) +
    ylab("") +
    xlab("P-values") +
    theme_bw() +
    theme(strip.background = element_rect(fill = fill_color),
          strip.text.y = element_text(size = 9))

gridExtra::grid.arrange(p1, p2, p3, ncol = 3, nrow = 1, padding = 0)
dev.off()


pdf(file = "./Output/figures/all_null_wide.pdf", height = 2, width = 10, family = "Times", colormodel = "cmyk")
longdat <- melt(pmat[pmat$seed == seed_seq[1], ], id.vars = "seed")
p1 <- ggplot(data = longdat, mapping = aes(x = value, color = I("black"), fill = I(fill_color))) +
  geom_histogram(bins = 15) +
  ylab("Counts") +
  xlab("P-values") +
  theme_bw() +
  theme(strip.background = element_blank(),
        strip.text.y = element_blank(), axis.title = element_text(size = 25),
        axis.text = element_text(size = 15))

longdat <- melt(pmat[pmat$seed == seed_seq[2], ], id.vars = "seed")
p2 <- ggplot(data = longdat, mapping = aes(x = value, color = I("black"), fill = I(fill_color))) +
  geom_histogram(bins = 15) +
  ylab("") +
  xlab("P-values") +
  theme_bw() +
  theme(strip.background = element_rect(fill = fill_color),
        strip.text.y = element_text(size = 9), axis.title = element_text(size = 25),
        axis.text = element_text(size = 15))

longdat <- melt(pmat[pmat$seed == seed_seq[3], ], id.vars = "seed")
p3 <- ggplot(data = longdat, mapping = aes(x = value, color = I("black"), fill = I(fill_color))) +
  geom_histogram(bins = 15) +
  ylab("") +
  xlab("P-values") +
  theme_bw() +
  theme(strip.background = element_rect(fill = fill_color),
        strip.text.y = element_text(size = 9), axis.title = element_text(size = 25),
        axis.text = element_text(size = 15))

gridExtra::grid.arrange(p1, p2, p3, ncol = 3, nrow = 1, padding = 0)
dev.off()

