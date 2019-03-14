library(tidyverse)
library(stringr)

pal_vec <- c("#999999", "#E69F00", "#56B4E9", "#000000", "#009E73",  "#CC79A7", "#0072B2", "#F0E442", "#D55E00")
small_pal_vec <- pal_vec[c(4, 6, 7)]

## First, AUC -------------------------------------------------------------------------
aucdat <- read_csv(file = "./Output/sims_out/auc_mat2.csv")
left_vals <- toupper(str_replace(str_extract(names(aucdat)[-(1:5)], "^.+_"), "_", ""))
right_vals <- str_replace(str_extract(names(aucdat)[-(1:5)], "_.+$"), "_", "")
name_vec <- c("Seed", "Pi0", "SampleSize", "NControls", "Poisthin",
              paste0(left_vals, right_vals))
name_vec[(length(name_vec) - 3):length(name_vec)] <-
  paste0("RUVB", stringr::str_replace(string = names(aucdat)[(length(name_vec) - 3):length(name_vec)],
                                      pattern = "(ruvb)(.*+)", replace = "\\2"))
names(aucdat) <- name_vec

keep_vec <- c("Pi0", "SampleSize", "NControls", "OLSo", "OLSl", "RUV2o", "RUV2l",
              "RUV3o", "RUV3la", "RUV3lb", "RUV4o", "RUV4l", "CATEo", "CATEd",
              "CATEla", "CATElb", "CATEdl", "RUVB", "RUVBnl" )

ddat <- select_(aucdat, .dots = keep_vec)
diff_mat <- bind_cols(ddat[, 1:3], ddat[, -c(1:3)] - c(ddat$RUVBnl))
diff_mat <- select(diff_mat, -RUVBnl)

longdat <- gather(data = diff_mat, key = "Method", value = "AUC", -(1:3)) %>%
  filter(Pi0 != 1)
pl <- ggplot(data = longdat, mapping = aes(y = AUC, x = Method)) +
  geom_boxplot(outlier.size = 0.2, size = 0.2) +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  geom_hline(yintercept = 0, lty = 2) +
  xlab("Method") + ylab("Difference in AUC from RUVB (with EVBM)") +
  theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  theme(strip.background = element_rect(fill="white"),
        axis.text.x = element_text(size = 7))
pdf(file = "./Output/figures/auc_boxplots.pdf", family = "Times", colormodel = "cmyk",
    height = 7.5, width = 6.5)
print(pl)
dev.off()


med_dat <- group_by(.data = longdat, Pi0, SampleSize, NControls, Method) %>%
  summarise(Mean = mean(AUC), Median = median(AUC), SD = sd(AUC)) %>%
  ungroup()
med_dat$Lower <- med_dat$Mean - 1.96 * med_dat$SD / sqrt(500)
med_dat$Upper <- med_dat$Mean + 1.96 * med_dat$SD / sqrt(500)

dat <- filter(med_dat, Pi0 == 0.5, Method %in% c("RUV2l", "RUV3lb", "CATEdl"))
dat$Method[dat$Method == "RUV2l"] <- "RUV2"
dat$Method[dat$Method == "RUV3lb"] <- "RUV3"
dat$Method[dat$Method == "CATEdl"] <- "RUV4/CATE"
pl_auc <- ggplot(data = dat,
             mapping = aes(x = SampleSize, y = Mean, color = Method)) +
  facet_grid(NControls ~.) +
  geom_line() +
  theme_bw() +
  geom_hline(yintercept = 0, lty = 2) +
  theme(strip.background = element_rect(fill = "white"),
        axis.title = element_text(size = 10),
        legend.position = "none") +
  ylab("Mean AUC Difference from RUVB (with EBVM)") +
  xlab("Sample Size") +
  geom_linerange(mapping = aes(ymin = Lower, ymax = Upper)) +
  scale_color_manual(values = small_pal_vec, name = "Best\nMethods") +
  scale_linetype_discrete(name = "Best\nMethods")
pdf(file = "./Output/figures/auc_means.pdf", family = "Times", colormodel = "cmyk",
    height = 3.2, width = 6.5)
print(pl_auc)
dev.off()

pl_auc <- pl_auc + ggtitle("(a)")

## Tabulate mean AUC for RUVB ----------------------------------------------------------
ruvbdat <- ddat %>% select(Pi0, SampleSize, NControls, RUVBnl) %>%
  group_by(Pi0, SampleSize, NControls) %>%
  summarize(mean_ruvb = mean(RUVBnl)) %>%
  ungroup() %>%
  filter(Pi0 != 1)
ruvbdat$NControls <- as.factor(ruvbdat$NControls)
pl_ruvb <- ggplot(data = ruvbdat, mapping = aes(x = SampleSize, y = mean_ruvb, lty = NControls)) +
  geom_line() +
  facet_grid(~Pi0) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  ylab("Mean AUC") +
  xlab("Sample Size") +
  scale_linetype_discrete(name = "Number\nof\nControls")

pdf(file = "./Output/figures/ruvb_auc_means.pdf", family = "Times", colormodel = "cmyk",
    height = 3.2, width = 6.5)
print(pl_ruvb)
dev.off()

########################################################################################
## Now Coverage ------------------------------------------------------------------------
########################################################################################

covdat <- read_csv(file = "./Output/sims_out/cov_mat2.csv")
left_vals <- toupper(str_replace(str_extract(names(covdat)[-(1:5)], "^.+_"), "_", ""))
right_vals <- str_replace(str_extract(names(covdat)[-(1:5)], "_.+$"), "_", "")
name_vec <- c("Seed", "Pi0", "SampleSize", "NControls", "Poisthin",
              paste0(left_vals, right_vals))
name_vec[(length(name_vec) - 3):length(name_vec)] <-
  paste0("RUVB", stringr::str_replace(string = names(covdat)[(length(name_vec) - 3):length(name_vec)],
                                      pattern = "(ruvb)(.*+)", replace = "\\2"))
names(covdat) <- name_vec
covdat <- select(covdat, -Seed, -Poisthin)
longdat <- gather(data = covdat, key = "Method", value = "Coverage", -(1:3))

mean_method <- rep(NA, length = nrow(longdat))
mean_method[stringr::str_detect(longdat$Method, "OLS")] <- "OLS"
mean_method[stringr::str_detect(longdat$Method, "RUV2")] <- "RUV2"
mean_method[stringr::str_detect(longdat$Method, "RUV3")] <- "RUV3"
mean_method[stringr::str_detect(longdat$Method, "RUV4")] <- "RUV4"
mean_method[stringr::str_detect(longdat$Method, "CATE")] <- "CATE"
mean_method[stringr::str_detect(longdat$Method, "RUVB")] <- "RUVB"
mean_method <- factor(mean_method, levels = c("OLS", "RUV2", "RUV3",
                                              "RUV4", "CATE", "RUVB"))
longdat$mean_method <- mean_method

var_method <- rep("o", length = nrow(longdat))
var_method[stringr::str_detect(longdat$Method, "c$")] <- "c"
var_method[stringr::str_detect(longdat$Method, "(lc$|lac$|lbc$)")] <- "lc"
var_method[stringr::str_detect(longdat$Method, "m$")] <- "m"
var_method[stringr::str_detect(longdat$Method, "(lm$|lam$|lbm$)")] <- "lm"
var_method[stringr::str_detect(longdat$Method, "l$|la$|lb$")] <- "l"
var_method <- factor(var_method, levels = c("o", "l", "c",
                                            "lc", "m", "lm"))
longdat$var_method <- var_method

## Loss Functions ---------------------------------------------
less9 <- function(x) {
  s1 <- mean(x < 0.9)
}

g0975 <- function(x) {
  s2 <- mean(x > 0.975)
}

sumdat <- longdat %>% group_by(Pi0, SampleSize, NControls, Method) %>%
  summarise(Less = less9(Coverage), Greater = g0975(Coverage)) %>%
  ungroup() %>%
  mutate(Loss = Less + Greater)
combdat <- select(sumdat, Pi0, SampleSize, NControls, Method, Less, Greater) %>%
  gather(key = "Loss", value = "Proportion", Less, Greater)

factor_vec <- rep("Other", length = nrow(combdat))
factor_vec[stringr::str_detect(combdat$Method, "c$")] <- "Control Calibration"
factor_vec[stringr::str_detect(combdat$Method, "m$")] <- "MAD Calibration"
factor_vec[combdat$Method == "RUVB" | combdat$Method == "RUVBnn"] <- "RUVB"
combdat$categories <- as.factor(factor_vec)

gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

myColors <- gg_color_hue(length(unique(factor_vec)))
names(myColors) <- levels(combdat$categories)
myColors[names(myColors) == "RUVB"] <- "black"
myColors[names(myColors) == "OLS"] <- "purple"
alpha_vec <- rep(0.7, length = nrow(combdat))
alpha_vec[combdat$Method == "RUVB" | combdat$Method == "RUVBnn"] <- 1
combdat$alpha <- alpha_vec


pl <- ggplot(data = combdat, mapping = aes(x = Loss, y = Proportion,
                                           group = Method,
                                           color = categories,
                                           alpha = alpha_vec)) +
  geom_line() +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  theme_bw() +
  theme(strip.background = element_rect(fill="white"),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  coord_cartesian(xlim = c(1.45, 1.55)) +
  xlab("Loss Type") +
  ylab("Loss") +
  scale_color_manual(name = "Category", values = myColors) +
  scale_alpha_continuous(range = c(.4, 1), guide = FALSE)
pdf(file = "./Output/figures/loss_plots.pdf", height = 5.5, width = 6.5,
    family = "Times", colormodel = "cmyk")
print(pl)
dev.off()


## Now just look at the best methods ------------------------------------------
subdat <- filter(longdat, Method == "OLSo" | Method == "OLSl" |
                   Method == "RUVB" | Method == "RUVBnn" | Method == "RUV2o" |
                   Method == "RUV2l" | Method == "RUV3o" | Method == "RUV3la" |
                   Method == "CATEd", Pi0 == 0.5) %>%
  select(-var_method, -mean_method)

pl <- ggplot(data = subdat, mapping = aes(x = Method, y = Coverage)) +
  geom_boxplot(outlier.size = 0.2, size = 0.2) +
  facet_grid(NControls ~ SampleSize) +
  geom_hline(yintercept = 0.95, lty = 2) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5))
pdf(file = "./Output/figures/coverage_best_boxplots.pdf", height = 7.5, width = 6.5,
    family = "Times", colormodel = "cmyk")
print(pl)
dev.off()



boot_med <- function(x, bootmax = 10000) {
  bvec <- rep(NA, length = bootmax)
  for(index in 1:bootmax) {
    bvec[index] <- median(sample(x, replace = TRUE))
  }
  return(c(median(x), quantile(bvec, probs = c(0.025, 0.975))))
}

meddat <- as_data_frame(expand.grid(unique(subdat$Pi0),
                                    unique(subdat$SampleSize),
                                    unique(subdat$NControls),
                                    unique(subdat$Method)))
names(meddat) <- c("Pi0", "SampleSize", "NControls", "Method")
meddat$Median <- rep(NA, length = nrow(meddat))
meddat$Lower  <- rep(NA, length = nrow(meddat))
meddat$Upper  <- rep(NA, length = nrow(meddat))
for (index in 1:nrow(meddat)) {
  x <- filter(subdat, Pi0 == meddat$Pi0[index],
              SampleSize == meddat$SampleSize[index],
              NControls == meddat$NControls[index],
              Method == meddat$Method[index])$Coverage
  bout <- boot_med(x)
  meddat$Median[index] <- bout[1]
  meddat$Lower[index]  <- bout[2]
  meddat$Upper[index]  <- bout[3]
}


meddat$Method <- as.character(meddat$Method)
meddat$Method[meddat$Method == "OLSo"] <- "OLS"
meddat$Method[meddat$Method == "OLSl"] <- "OLS+EBVM"
meddat$Method[meddat$Method == "RUV2o"] <- "RUV2"
meddat$Method[meddat$Method == "RUV2l"] <- "RUV2+EBVM"
meddat$Method[meddat$Method == "RUV3o"] <- "RUV3"
meddat$Method[meddat$Method == "RUV3la"] <- "RUV3+EBVM"
meddat$Method[meddat$Method == "CATEd"] <- "RUV4/CATE"
meddat$Method[meddat$Method == "RUVBnn"] <- "RUVB-normal"
meddat$Method[meddat$Method == "RUVB"] <- "RUVB-sample"
pl_cov <- ggplot(data = meddat, mapping = aes(y = Median, x = SampleSize, group = Method, color = Method)) +
  geom_line(alpha = 1) +
  facet_grid(NControls ~ .) +
  geom_hline(yintercept = 0.95, lty = 2) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Sample Size") +
  ylab("Median Coverage") +
  geom_linerange(mapping = aes(ymin = Lower, ymax = Upper),
                 position = position_dodge(width = 3)) +
  ggtitle("(b)") +
  scale_color_manual(values = pal_vec)
pdf(file = "./Output/figures/coverage_medians.pdf", family = "Times", colormodel = "cmyk",
    height = 3.2, width = 6.5)
print(pl_cov)
dev.off()


## Now coverage at n = 40 and meddat plot
library(gridExtra)
subdat$Method <- as.character(subdat$Method)
subdat$Method[subdat$Method == "OLSo"] <- "OLS"
subdat$Method[subdat$Method == "OLSl"] <- "OLS+EBVM"
subdat$Method[subdat$Method == "RUV2o"] <- "RUV2"
subdat$Method[subdat$Method == "RUV2l"] <- "RUV2+EBVM"
subdat$Method[subdat$Method == "RUV3o"] <- "RUV3"
subdat$Method[subdat$Method == "RUV3la"] <- "RUV3+EBVM"
subdat$Method[subdat$Method == "CATEd"] <- "RUV4/CATE"
subdat$Method[subdat$Method == "RUVBnn"] <- "RUVB-normal"
subdat$Method[subdat$Method == "RUVB"] <- "RUVB-sample"
plbox <- ggplot(data = filter(subdat, SampleSize == 40), mapping = aes(x = Method, y = Coverage, fill = Method)) +
  geom_boxplot(outlier.size = 0.2, size = 0.2) +
  facet_grid(SampleSize ~ NControls) +
  geom_hline(yintercept = 0.95, lty = 2) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  guides(fill = FALSE) +
  ggtitle("(c)") +
  scale_fill_manual(values = pal_vec)

lay <- rbind(c(1, 1, 1, 2, 2, 2, 2, 2, 2, 2),
             c(3, 3, 3, 3, 3, 3, 3, 3, 3, 3))
pdf(file = "./Output/figures/combo_cov.pdf", family = "Times", colormodel = "cmyk",
    width = 6.5, height = 4.9)
gridExtra::grid.arrange(pl_auc + theme(axis.title = element_text(size = 8),
                                       text = element_text(size = 8)),
                        pl_cov + theme(axis.title = element_text(size = 8),
                                       text = element_text(size = 8)),
                        plbox + theme(axis.title = element_text(size = 8),
                                      text = element_text(size = 8)),
                        layout_matrix = lay)
dev.off()





