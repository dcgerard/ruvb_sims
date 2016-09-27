###############################
## Synopsis: read in the posterior samples, make qq plots of the most significant betas
###############################

library(ggplot2)
tissue_vec <- c("adiposetissue", "bladder", "bloodvessel", "breast",
                "colon", "kidney", "lung", "nerve", "pancreas",
                "skin", "spleen", "adrenalgland", "blood", "brain",
                "esophagus", "heart", "liver", "muscle", "pituitary",
                "salivarygland", "smallintestine", "stomach", "thyroid")

good_tissue_labels <- c("Adipose Tissue", "Bladder", "Blood Vessel", "Breast",
                        "Colon", "Kidney", "Lung", "Nerve", "Pancreas",
                        "Skin", "Spleen", "Adrenal Gland", "Blood", "Brain",
                        "Esophagus", "Heart", "Liver", "Muscle", "Pituitary",
                        "Salivary Gland", "Small Intestine", "Stomach", "Thyroid")

num_sv_vec <- rep(NA, length = length(tissue_vec))
for (tissue_index in 1:length(tissue_vec)) {
    current_tissue <- tissue_vec[tissue_index]
    ruvbout <- readRDS(file = paste0("../Output/ruvbout/ruvbout_", current_tissue, ".Rds"))

    obs_num <- which.min(c(ruvbout$lfsr2))

    if (tissue_index > 1) {
        beta_current <- ruvbout$betahat_post[1, obs_num, ]
        quants <- qnorm(seq(1 / length(beta_current), 1 - 1 / length(beta_current),
                            length = length(beta_current)))[rank(beta_current)]

        temp_dat <- data.frame(beta = beta_current,
                               tissue = good_tissue_labels[tissue_index],
                               quants = quants)

        bdat <- rbind(bdat, temp_dat)
    } else if (tissue_index == 1) {
        beta_current <- ruvbout$betahat_post[1, obs_num, ]
        quants <- qnorm(seq(1 / length(beta_current), 1 - 1 / length(beta_current),
                            length = length(beta_current)))[rank(beta_current)]
        bdat <- data.frame(beta = beta_current,
                           tissue = good_tissue_labels[tissue_index],
                           quants = quants)
    }
    cat(tissue_index, "\n")
}

pdf(file = "../Output/qqplot.pdf", family = "Times", height = 8, width = 6)
ggplot(data = bdat, mapping = aes(x = quants, y = beta)) +
    geom_point(size = 0.1, pch = ".") +
    facet_wrap(~tissue, scales = "free_y", ncol = 4) +
    xlab("Theoretical Quantiles") + ylab("Sample Quantiles") +
    theme_bw() + theme(strip.background = element_rect(fill="white")) +
    geom_line(stat = "smooth", method = "lm", lty = 2, alpha = 0.4, color = "black")
dev.off()
