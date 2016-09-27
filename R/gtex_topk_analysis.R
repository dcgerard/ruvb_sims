library(ggplot2)
tissue_vec <- c("adiposetissue", "bladder", "bloodvessel", "breast",
                "colon", "kidney", "lung", "nerve", "pancreas",
                "skin", "spleen", "adrenalgland", "blood", "brain",
                "esophagus", "heart", "liver", "muscle", "pituitary",
                "salivarygland", "smallintestine", "stomach", "thyroid")

num_sv_vec <- rep(NA, length = length(tissue_vec))
for (tissue_index in 1:length(tissue_vec)) {
    current_tissue <- tissue_vec[tissue_index]
    ## large dat ------------------------------------------------------------------
    dat <- readRDS(paste0("./Output/cleaned_gtex_data/", current_tissue, ".Rds"))
    onsex <- dat$chrom == "X" | dat$chrom == "Y"

    dat$ctl[onsex] <- FALSE

    num_sv <- sva::num.sv(dat = dat$Y, mod = dat$X)
    num_sv_vec[tissue_index] <- num_sv
    cat(num_sv, "\n")
    ruvbout <- vicar::ruvb(Y = t(dat$Y), X = dat$X, ctl = dat$ctl, k = num_sv,
                           cov_of_interest = ncol(dat$X), include_intercept = FALSE,
                           fa_func = vicar::bfa_gs_linked, return_mcmc = TRUE,
                           fa_args = list(use_code = "r", nsamp = 20000, thin = 20))
    saveRDS(object = ruvbout, file = paste0("./Output/ruvbout/ruvbout_", current_tissue, ".Rds"))
}

saveRDS(object = num_sv_vec, file = "./Output/ruvbout/num_sv.Rds")
