if (!require(gtools)) {
  install.packages("gtools")
}
if (!require(RSpectra)) {
  install.packages("RSpectra")
}
if (!require(ClusterR)) {
  install.packages("ClusterR")
}

library(gtools)
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

# SCORE function
.find_act <- function(s,P){
  sn = s+sum(P<=s)
  while (sn %in% P){
    sn = sn+1
  }
  return(sn)
}

SCORE <- function(U){
  K = ncol(U)
  P = NA
  ## pseudo-pruning
  if (any(U[,1]<=1e-32)){
    P = which(U[,1]<=1e-32)
    U0 = U[-P,]
    Us = U0/U0[,1]
  } else {
    Us = U/U[,1]
  }
  
  IK = diag(rep(1,K))
  S = c()
  Y0 = Us
  Y = Y0
  for (k in 1:K) {
    l = apply(Y,1,norm,"2")
    S = c(S,which.max(l))
    u = Y[S[k],]/norm(Y[S[k],],"2")
    u = data.matrix(u)
    Y = Y%*%(IK-u%*%t(u))
  }
  
  if (!any(is.na(P))){
    S = sapply(S,.find_act,P)
  }
  return(S)
}

spectral_simplex_score <- function(A, K){
  svd_A <- RSpectra::svds(A, K)
  if (all(svd_A$u[,1]<=1e-14)){
    svd_A$u = -svd_A$u
    svd_A$v = -svd_A$v
  }
  S <- SCORE(svd_A$u)
  
  svd_K <- svd(svd_A$u[S,])
  Us_inv <- svd_K$v %*% (svd_K$d^(-1) * t(svd_K$u))
  
  Z_mixed <- svd_A$u%*%Us_inv
  kmeans_res <- KMeans_rcpp(Z_mixed, K, num_init = 10, max_iter = 100)
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
