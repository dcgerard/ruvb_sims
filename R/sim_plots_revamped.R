## Revamped coverage plots.

library(tidyverse)
library(stringr)
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

pdf(file = "./Output/figures/horizontal_bp.pdf", height = 9, width = 8)
pl <- ggplot(data = longdat,
             mapping = aes(x = Coverage, y = Method,
                           color = var_method)) +
  geom_boxplot(size = 0.2, notch = FALSE, position = "identity") +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  geom_vline(xintercept = 0.95, lty = 2) +
  xlab("Coverage") + ylab("Method") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        axis.text.y = element_text(size = 5),
        axis.ticks.y = element_blank(),
        strip.background = element_rect(fill="white"))
print(pl)
dev.off()

## just the interquartiles
sumdat <- group_by(longdat, Pi0, SampleSize, NControls, Method) %>%
  summarise(lower = quantile(Coverage, probs = 0.025),
            upper = quantile(Coverage, probs = 0.975)) %>%
  ungroup()

mean_method <- rep(NA, length = nrow(sumdat))
mean_method[stringr::str_detect(sumdat$Method, "OLS")] <- "OLS"
mean_method[stringr::str_detect(sumdat$Method, "RUV2")] <- "RUV2"
mean_method[stringr::str_detect(sumdat$Method, "RUV3")] <- "RUV3"
mean_method[stringr::str_detect(sumdat$Method, "RUV4")] <- "RUV4"
mean_method[stringr::str_detect(sumdat$Method, "CATE")] <- "CATE"
mean_method[stringr::str_detect(sumdat$Method, "RUVB")] <- "RUVB"
mean_method <- factor(mean_method, levels = c("OLS", "RUV2", "RUV3",
                                              "RUV4", "CATE", "RUVB"))
sumdat$mean_method <- mean_method

var_method <- rep("o", length = nrow(sumdat))
var_method[stringr::str_detect(sumdat$Method, "c$")] <- "c"
var_method[stringr::str_detect(sumdat$Method, "(lc$|lac$|lbc$)")] <- "lc"
var_method[stringr::str_detect(sumdat$Method, "m$")] <- "m"
var_method[stringr::str_detect(sumdat$Method, "(lm$|lam$|lbm$)")] <- "lm"
var_method[stringr::str_detect(sumdat$Method, "l$|la$|lb$")] <- "l"
var_method <- factor(var_method, levels = c("o", "l", "c",
                                            "lc", "m", "lm"))

sumdat$var_method <- var_method

thresh <- 0.7
sumdat$lty_vec <- sumdat$lower < thresh


pdf(file = "./Output/figures/horizontal_lines.pdf",
    height = 9, width = 7, family = "Times", colormodel = "cmyk")
pl <- ggplot(data = sumdat, mapping = aes(color = mean_method,
                                          group = Method,
                                          x = var_method,
                                          lty = lty_vec)) +
  geom_linerange(mapping = aes(ymin = lower, ymax = upper),
                 position = position_dodge(width = 0.8)) +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5)) +
  scale_color_discrete(name = "Mean Method") +
  geom_hline(yintercept = 0.95, lty = 2) +
  coord_cartesian(ylim = c(thresh, 1)) +
  ylab("Quantiles of Coverage") +
  xlab("Variance Method") +
  scale_linetype_discrete(name = paste0("Below ", thresh))
print(pl)
dev.off()


## Now the loss function plot
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
factor_vec[stringr::str_detect(combdat$Method, "c$")] <- "Control Adjustment"
factor_vec[stringr::str_detect(combdat$Method, "m$")] <- "MAD Adjustment"
factor_vec[stringr::str_detect(combdat$Method, "OLS")] <- "OLS"
factor_vec[combdat$Method == "RUVB" | combdat$Method == "RUVBnn"] <- "RUVB"
combdat$categories <- as.factor(factor_vec)


#' gg_color_hue copied from http://stackoverflow.com/questions/8197559/emulate-ggplot2-default-color-palette
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
alpha_vec[stringr::str_detect(combdat$Method, "OLS")] <- 1
combdat$alpha <- alpha_vec

pdf(file = "./Output/figures/loss_plots.pdf", height = 9, width = 8,
    family = "Times", colormodel = "cmyk")
pl <- ggplot(data = combdat, mapping = aes(x = Loss, y = Proportion,
                                     group = Method,
                                     color = categories,
                                     alpha = alpha_vec)) +
  geom_line() +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  theme_bw() +
  theme(strip.background = element_rect(fill="white")) +
  coord_cartesian(xlim = c(1.45, 1.55)) +
  xlab("Loss Type") +
  ylab("Loss") +
  scale_color_manual(name = "Category", values = myColors) +
  scale_alpha_continuous(range = c(.3, 1), guide = FALSE)
print(pl)
dev.off()




