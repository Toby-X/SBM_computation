if (!require(RSpectra)) {
  install.packages("RSpectra")
}
if (!require(ClusterR)) {
  install.packages("ClusterR")
}


library(RSpectra)
library(ClusterR)


# Index Vector 2 0-1 matrix
vec2mat <- function(x){
  K <- max(x)
  N <- length(x)
  Z <- matrix(0, nrow = N, ncol = K)
  Z[cbind(1:N, x)] <- 1
  Z
}

# 0-1 matrix 2 index vector
mat2vec <- function(Z){
  apply(Z, 1, which.max)
}

# Spectral Estimation Algorithms
regularized_spectral_clustering <- function(A, K){
  N <- nrow(A)
  d <- rowSums(A)
  tau <- mean(d)
  L <- (d+tau)^(1/2)*t(t(A)*(d+tau)^(1/2))
  svd_A <- RSpectra::svds(L, K)
  kmeans_res <- KMeans_rcpp(svd_A$u, K, num_init = 10, max_iter = 100)
  clust_vec <- kmeans_res$clusters
  Z <- vec2mat(clust_vec)
  if (any(colSums(Z) == 0)){
    idx_zero <- which(colSums(Z) == 0)
    Z <- Z[, -idx_zero]
    B_half <- solve(t(Z) %*% Z, t(Z) %*% svd_A$u)
    B <- t(B_half) %*% (svd_A$d * B_half)
    Z <- cbind(Z, matrix(0, nrow = nrow(Z), ncol = length(idx_zero)))
    B <- cbind(B, matrix(0, nrow = nrow(B), ncol = length(idx_zero)))
    B <- rbind(B, matrix(0, nrow = length(idx_zero), ncol = ncol(B)))
  } else {
    B_half <- solve(t(Z) %*% Z, t(Z) %*% svd_A$u)
    B <- t(B_half) %*% (svd_A$d * B_half)
  }
  list(Z = Z, B = B)
}
