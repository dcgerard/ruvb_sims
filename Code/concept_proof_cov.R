#######
## This is a conceptual demonstration that the covariance with the grouping
## variable is r / 2pi.
#######
r <- 0.9
covmat <- matrix(c(1, r, r, 1), nrow = 2)
eout <- eigen(covmat)
halfmat <- eout$vectors %*% diag(sqrt(eout$values)) %*% t(eout$vectors)
bnormmat <- matrix(rnorm(2 * 100000), ncol = 2) %*% halfmat
w <- bnormmat[, 1]
x <- w > 0
u <- bnormmat[, 2]
cov(w, u) ## should be near r
cov(x, u) ## should be near r / sqrt(2*pi)
r / sqrt(2 * pi)
cor(x, u) ## should be r * sqrt(2 / pi)
r * sqrt(2 / pi)

######
## Group correlations used in simulation study.
######
c(0, 0.25, 0.5, 0.75) * sqrt(2 / pi)
