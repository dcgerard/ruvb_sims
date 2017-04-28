## First do coverage
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

pdf(file = "./Output/figures/coverage_boxplots.pdf", height = 9, width = 7)
pl <- ggplot(data = longdat, mapping = aes(x = Coverage, y = Method)) +
  geom_boxplot(outlier.size = 0.2, size = 0.2) +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  geom_vline(xintercept = 0.95, lty = 2) +
  xlab("Method") + ylab("Coverage") +
  theme_bw() + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  theme(strip.background = element_rect(fill="white"))
print(pl)
dev.off()

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
factor_vec <- rep("other", length = nrow(combdat))
factor_vec[stringr::str_detect(combdat$Method, "c$")] <- "c"
factor_vec[stringr::str_detect(combdat$Method, "m$")] <- "m"
factor_vec[combdat$Method == "RUVB" | combdat$Method == "RUVBnn"] <- "RUVB"
combdat$categories <- as.factor(factor_vec)

pdf(file= "./Output/figures/coverage_loss.pdf", width = 7, height = 9)
pl <- ggplot(data = combdat, mapping = aes(x = Loss, y = Proportion,
                                           group = Method, color = factor_vec)) +
  geom_line() +
  facet_grid(Pi0 + NControls ~ SampleSize) +
  theme_bw() +
  theme(strip.background = element_rect(fill="white")) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
  guides(color = guide_legend(title = "Method")) +
  xlab("Loss Type")
print(pl)
dev.off()

## Now AUC
