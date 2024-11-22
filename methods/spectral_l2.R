if (!require(gtools)) {
  install.packages("gtools")
}
if (!require(RSpectra)) {
  install.packages("RSpectra")
}
if (!require(e1071)) {
  install.packages("e1071")
}
if (!require(ClusterR)) {
  install.packages("ClusterR")
})

library(gtools)
library(RSpectra)
library(e1071)
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

# L2 normalization
svm_cone <- function(U, beta=0, max.it=50, eps=1e-12, cond_tre=150){
  # U is the top eigenvectors
  # K is the dimension of the data point
  # beta is a "stablize" parameter, delete points with less norm than beta quantile
  K = ncol(U)
  row_norm = apply(U, 1, norm, "2")
  if (beta != 0){
    qbeta = as.numeric(quantile(row_norm,beta))
    del_idx = which(row_norm<qbeta)
    U = U[-del_idx,]
    row_norm = row_norm[-del_idx]
  }
  Us = U/row_norm
  
  # This param is chosen by the code of Xueyu Mao et. al.
  if (K > 10){
    nu = 2*K/nrow(U)
  } else {
    nu = K/nrow(U)
  }
  # One Class SVM
  one_svm = e1071::svm(rep(1, nrow(Us)) ~ Us, kernel="linear", type="one-classification", 
                       nu = nu, scale = F)
  w = t(one_svm$coefs) %*% one_svm$SV
  b = one_svm$rho
  SVs = one_svm$SV
  SV_idx = one_svm$index[rowSums(abs(SVs))>0]
  b_y = Us %*% t(w)
  
  # eps0 and eps1 are actually tuning parameters
  eps0 = 0
  eps1 = .02
  flag = T
  iter = 0
  
  while (flag & iter < max.it) {
    pure_idx = which(b_y<=b*(1+eps0))
    SV_idx.new = unique(c(SV_idx,pure_idx))
    SVs.new = Us[SV_idx.new,]
    
    ## Use Vertex Hunting instead of K-means
    IK = diag(rep(1,K))
    pure_idx = c()
    Y0 = SVs.new
    Y = Y0
    for (k in 1:K) {
      l = apply(Y,1,norm,"2")
      pure_idx = c(pure_idx,which.max(l))
      u = Y[pure_idx[k],]/norm(Y[pure_idx[k],],"2")
      u = data.matrix(u)
      Y = Y%*%(IK-u%*%t(u))
    }
    pure_idx = SV_idx.new[pure_idx]
    
    vp = U[pure_idx,]
    np = 1/apply(vp,1,norm,"2")
    yp = np*vp
    
    if (kappa(yp)>cond_tre){
      flag = T
      eps0 = eps0 + eps1
    } else {
      flag = F
    }
    iter <- iter + 1
  }
  
  return(pure_idx)
}

spectral_simplex_l2 <- function(A, K){
  svd_A <- RSpectra::svds(A, K)
  if (all(svd_A$u[,1]<=1e-14)){
    svd_A$u = -svd_A$u
    svd_A$v = -svd_A$v
  }
  S <- svm_cone(svd_A$u)
  
  Z_mixed <- svd_A$u%*%solve(svd_A$u[S,])
  kmeans_res <- KMeans_rcpp(Z_mixed, K, num_init = 10, max_iter = 100)
  clust_vec <- kmeans_res$clusters
  Z <- vec2mat(clust_vec)
  B_half <- solve(t(Z) %*% Z, t(Z) %*% svd_A$u)
  B <- t(B_half) %*% (svd_A$d * B_half)
  
  list(Z = Z, B = B)
}
