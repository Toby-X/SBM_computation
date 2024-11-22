if (!require("clue")){
  install.packages("clue")
}

library(clue)

# Data generation function here
sbm_gen_diagdom <- function(N, K, beta, b, seed){
  set.seed(seed)
  rho <- N^(-b)
  v <- runif(K, 0, 1)
  alpha <- v^beta
  alpha <- alpha/sum(alpha)
  B <- matrix(rho/2, K, K)
  ## change the diagonal element of B to 3*rho/2
  B <- B + diag(rho, K)
  Z <- t(rmultinom(N, 1, alpha))
  EA <- Z%*%B%*%t(Z)
  A_lower <- rbinom(N*(N+1)/2, 1,EA[lower.tri(EA, diag = TRUE)])
  A <- matrix(0, N, N)
  A[lower.tri(A, diag = TRUE)] <- A_lower
  A <- A + t(A)
  A <- A - diag(diag(A))
  list(A = A, Z = Z, B = B)
}

# find corresponding index for the block
find_best_idx <- function(EX,X){
  loss.mad <- t(apply(X, 2, function(x) colMeans(abs(x - EX))))
  od <- clue::solve_LSAP(loss.mad)
  od
}

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

