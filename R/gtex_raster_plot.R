library(reshape2)
library(ggplot2)
library(stringr)

ols <- function(Y, X, quant = 0.95) {
    limma_out <- limma::lmFit(object = t(Y), design = X)
    betahat   <- limma_out$coefficients[, 2]
    sebetahat <- limma_out$stdev.unscaled[, 2] * limma_out$sigma
    df        <- limma_out$df.residual[1]
    tstats    <- betahat / sebetahat
    pvalues   <- 2 * pt(-abs(tstats), df = df)

    alpha <- 1 - quant
    tval  <- qt(p = 1 - alpha / 2, df = df)
    lower <- betahat - tval * sebetahat
    upper <- betahat + tval * sebetahat
    return(list(betahat = betahat, sebetahat = sebetahat, df = df,
                pvalues = pvalues, upper = upper, lower = lower))
}

proc_wrapper <- function(predictor, response) {
    pROC::roc(predictor = predictor, response = response)$auc
}

topk <- function(predictor, response, num_look = 100) {
    sum(response[order(predictor)[1:num_look]])
}

tissue_vec <- c("adiposetissue", "bladder", "bloodvessel", "breast",
                "colon", "kidney", "lung", "nerve", "pancreas",
                "skin", "spleen", "adrenalgland", "blood", "brain",
                "esophagus", "heart", "liver", "muscle", "pituitary",
                "salivarygland", "smallintestine", "stomach", "thyroid")
method_names <- c("OLS", "RUV2", "RUV3", "RUV4", "RUV4c", "CATE", "CATEc", "RUVB")
num_sv_seq <- readRDS("./Output/ruvbout/num_sv.Rds")
num_look_seq <- c(100, 300, 500)

auc_mat  <- matrix(NA, nrow = length(tissue_vec), ncol = length(method_names))
topk_array <- array(NA, dim = c(length(tissue_vec), length(method_names), length(num_look_seq)))
nseq <- rep(NA, length = length(tissue_vec))


for(tissue_index in 1:length(tissue_vec)) {
    current_tissue <- tissue_vec[tissue_index]
    num_sv <- num_sv_seq[tissue_index]

    dat <- readRDS(paste0("./Output/cleaned_gtex_data/", current_tissue, ".Rds"))
    onsex <- dat$chrom == "X" | dat$chrom == "Y"
    onsex[is.na(onsex)] <- FALSE
    dat$ctl[onsex] <- FALSE
    nseq[tissue_index] <- ncol(dat$Y)

    cat(tissue_index, "\n")


    ruvbout  <- readRDS(paste0("./Output/ruvbout/ruvbout_", current_tissue, ".Rds"))
    olsout   <- ols(Y = t(dat$Y), X = dat$X)
    ruv2out  <- ruv::RUV2(Y = t(dat$Y), X = dat$X[, 2, drop = FALSE], ctl = dat$ctl,
                          k = num_sv, Z = dat$X[, -2, drop = FALSE])
    ruv3out  <- vicar::ruv3(Y = t(dat$Y), X = dat$X, ctl = dat$ctl, cov_of_interest = ncol(dat$X),
                            k = num_sv, include_intercept = FALSE)
    ruv4out  <- ruv::RUV4(Y = t(dat$Y), X = dat$X[, 2, drop = FALSE], ctl = dat$ctl,
                          k = num_sv, Z = dat$X[, -2, drop = FALSE])
    ruv4cout <- ruv::variance_adjust(ruv4out)
    cateout  <- cate::cate.fit(X.primary = dat$X[, 2, drop = FALSE],
                               X.nuis = dat$X[, -2, drop = FALSE],
                               Y = t(dat$Y), r = num_sv,
                               adj.method = "nc",
                               nc = dat$ctl, calibrate = FALSE)
    catecout <- vicar::vruv4(Y = t(dat$Y), X = dat$X, ctl = dat$ctl,
                             k = num_sv, cov_of_interest = 2,
                             likelihood = "normal",
                             include_intercept = FALSE)


    pdat <- cbind(OLS = c(olsout$pvalues)[!dat$ctl],
                  RUV2 = c(ruv2out$p)[!dat$ctl],
                  RUV3 = c(ruv3out$pvalues_unadjusted)[!dat$ctl],
                  RUV4 = c(ruv4out$p)[!dat$ctl],
                  RUV4c = ruv4cout$p.rsvar.ebayes[!dat$ctl],
                  CATE = c(cateout$beta.p.value)[!dat$ctl],
                  CATEc = c(catecout$pvalues)[!dat$ctl],
                  RUVB = c(ruvbout$lfsr2))

    if (any(colSums(pdat == 0) > 100)) {
        cat("LOOK HERE:", tissue_index, "\n")
    }

    ## auc_out <- apply(pdat, 2, proc_wrapper, response = onsex[!dat$ctl])
    for(num_look_index in 1:length(num_look_seq)) {
        topk_out <- apply(pdat, 2, topk, response = onsex[!dat$ctl],
                          num_look = num_look_seq[num_look_index])
        topk_array[tissue_index, , num_look_index] <- topk_out
    }
}

## be fair to CATE by giving it the maximum number of sex genes
## possible among p-values that are equal to zero.
topk_array[4, 6, 2] <- 46


good_tissue_labels <- c("Adipose Tissue", "Bladder", "Blood Vessel", "Breast",
                        "Colon", "Kidney", "Lung", "Nerve", "Pancreas",
                        "Skin", "Spleen", "Adrenal Gland", "Blood", "Brain",
                        "Esophagus", "Heart", "Liver", "Muscle", "Pituitary",
                        "Salivary Gland", "Small Intestine", "Stomach", "Thyroid")
good_tissue_labels <- paste0(good_tissue_labels, " (", nseq, ")")

dimnames(topk_array) <- list(good_tissue_labels, method_names, num_look_seq)

prop_array <- topk_array
for (numlookindex in 1:length(num_look_seq)) {

    topk_mat <- topk_array[, , numlookindex]

    colnames(topk_mat) <- method_names
    ## topkrank <- t(apply(topk_mat, 1, rank))

    topkrank <- topk_mat / apply(topk_mat, 1, max)
    prop_array[, , numlookindex] <- topkrank
}


prop_array2 <- prop_array[order(nseq, decreasing = TRUE), , ]

longdat <- melt(prop_array2)
names(longdat) <- c("Tissue", "Method", "K", "Proportion")
longdat <- dplyr::filter(longdat, Method != "OLS")
which_bad <- longdat$Method == "CATE" & longdat$Tissue == "Breast (214)" & longdat$K == 100
longdat$Proportion[which_bad] <- NA
longdat$na <- FALSE
longdat$na[which_bad] <- TRUE
pgd <- ggplot(data = longdat, mapping = aes(x = Method, y = Tissue, fill = Proportion)) +
    geom_raster() +
    scale_fill_gradient(high = "#ffffff",
                        low = "#000000",
                        na.value = "black",
                        guide = guide_colourbar(title = "Proportion\nfrom\nMaximum")) +
    theme_bw() +
    geom_point(aes(size=ifelse(na, "dot", "no_dot")), color = "white") +
    scale_size_manual(values=c(dot=2, no_dot=NA), guide="none") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    facet_grid(.~K) + theme(strip.background = element_rect(fill="white"))

pdf(file = "./Output/figures/propk.pdf", family = "Times", height = 5, width = 6.5)
print(pgd)
dev.off()
