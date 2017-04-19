# I always assume that the variable of interest is the second one.

## Five methods to look at ---------------------------------------------------
cate_simp_nc_correction <- function(Y, X, num_sv, control_genes) {
  cate_nc <- cate::cate.fit(Y = Y, X.primary = X[, 2, drop = FALSE],
                            X.nuis = X[, -2, drop = FALSE],
                            r = num_sv, adj.method = "nc",
                            fa.method = "pc",
                            nc = as.logical(control_genes),
                            calibrate = FALSE,
                            nc.var.correction = TRUE)

  betahat   <- c(cate_nc$beta)
  sebetahat <- c(sqrt(cate_nc$beta.cov.row * cate_nc$beta.cov.col) /
                   sqrt(nrow(X)))
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

ruv4_simp <- function(Y, X, num_sv, control_genes) {
  vout <- vicar::vruv4(Y = Y, X = X, ctl = control_genes, k = num_sv, cov_of_interest = 2,
                       likelihood = "normal", limmashrink = FALSE, gls = FALSE,
                       include_intercept = FALSE)
  betahat   <- vout$betahat
  sebetahat <- vout$sebetahat_ols
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

cate_simp <- function(Y, X, num_sv, control_genes) {
  vout <- vicar::vruv4(Y = Y, X = X, ctl = control_genes, k = num_sv, cov_of_interest = 2,
                       likelihood = "normal", limmashrink = FALSE, include_intercept = FALSE,
                       gls = TRUE)
  betahat   <- vout$betahat
  sebetahat <- vout$sebetahat_ols
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

ruv3_simp <- function(Y, X, num_sv, control_genes) {
  vout <- vicar::ruv3(Y = Y, X = X, ctl = control_genes, k = num_sv, cov_of_interest = 2,
                      limmashrink = FALSE, include_intercept = FALSE, gls = TRUE)
  betahat   <- vout$betahat
  sebetahat <- vout$sebetahat_unadjusted
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

ruv2_simp <- function(Y, X, num_sv, control_genes) {
  vout <- ruv::RUV2(Y = Y, X = X[, 2, drop = FALSE],
                    ctl = control_genes, k = num_sv, Z = X[, -2, drop = FALSE])
  betahat   <- vout$betahat
  sebetahat <- sqrt(vout$sigma2 * vout$multiplier)
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

## Limma before gls for RUV3 and RUV4 ----------------------------------------
cate_limma <- function(Y, X, num_sv, control_genes) {
  vout <- vicar::vruv4(Y = Y, X = X, ctl = control_genes, k = num_sv, cov_of_interest = 2,
                       likelihood = "normal", limmashrink = TRUE, gls = TRUE,
                       include_intercept = FALSE)
  betahat   <- vout$betahat
  sebetahat <- vout$sebetahat_ols
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

ruv3_limma_pre <- function(Y, X, num_sv, control_genes) {
  vout <- vicar::ruv3(Y = Y, X = X, ctl = ctl, k = q, cov_of_interest = 2, likelihood = "normal",
                      limmashrink = TRUE, include_intercept = FALSE, gls = TRUE)
  betahat   <- vout$betahat
  sebetahat <- vout$sebetahat_unadjusted
  df        <- nrow(Y) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}

## Limma after gls for RUV3 --- since sebetahat is NA for control genes
ruv3_limma_post <- function(Y, X, num_sv, control_genes) {
  vout <- vicar::ruv3(Y = Y, X = X, ctl = control_genes, k = num_sv, cov_of_interest = 2,
                      limmashrink = FALSE, include_intercept = FALSE, gls = TRUE)

  lmout <- limma::squeezeVar(vout$simga2_unadjusted, df = nrow(Y) - ncol(X) - num_sv)
  betahat   <- vout$betahat
  sebetahat <- sqrt(vout$mult_matrix * lmout$var.post)

  # Check
  # sqrt(vout$mult_matrix * vout$simga2_unadjusted)
  # vout$sebetahat_unadjusted
  df        <- lmout$df.prior + nrow(X) - ncol(X) - num_sv
  return(list(betahat = betahat, sebetahat = sebetahat, df = df))
}


## Limma shrinking variances (after gls for ruv3 and ruv4)----------------------------------
## Apply or not apply to all "simp" functions

limma_adjust <- function(sebetahat, df) {
  lmout <- limma::squeezeVar(var = sebetahat ^ 2, df = df)
  return(sebetahat = sqrt(lmout$var.post), df = df + lmout$df.prior)
}


## Adjustment of variances ------------------------------------
ctl_adjust <- function(betahat, sebetahat, control_genes) {
  mult_val <- mean(betahat[control_genes] ^ 2 / sebetahat[control_genes] ^ 2)
  sebetahat_adjusted <- sqrt(mult_val) * sebetahat
  return(sebetahat_adjusted)
}

mad_adjust <- function(betahat, sebetahat) {
  mult_val <- stats::mad(betahat ^ 2 / sebetahat ^ 2, center = 0)
  sebetahat_adjusted <- sqrt(mult_val) * sebetahat
  return(sebetahat_adjusted)
}

