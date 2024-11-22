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

.find_act <- function(s,P){
  sn = s+sum(P<=s)
  while (sn %in% P){
    sn = sn+1
  }
  return(sn)
}

spectral_simplex_null <- function(A, K){
  N <- nrow(A)
  
  svd_A <- RSpectra::svds(A, K)
  if (all(svd_A$u[,1]<=1e-14)){
    svd_A$u = -svd_A$u
    svd_A$v = -svd_A$v
  }
  U <- svd_A$u
  IK <- diag(rep(1,K))
  S <- c()
  for (k in 1:K) {
    l <- apply(U,1,norm,"2")
    S <- c(S,which.max(l))
    u <- U[S[k],]/norm(U[S[k],],"2")
    u <- data.matrix(u)
    U <- U%*%(IK-u%*%t(u))
  }
  Z_mixed <- svd_A$u%*%solve(svd_A$u[S,])
  kmeans_res <- KMeans_rcpp(Z_mixed, K, num_init = 10, max_iter = 100)
  clust_vec <- kmeans_res$clusters
  Z <- vec2mat(clust_vec)
  B_half <- solve(t(Z) %*% Z, t(Z) %*% svd_A$u)
  B <- t(B_half) %*% (svd_A$d * B_half)
  
  list(Z = Z, B = B)
}
