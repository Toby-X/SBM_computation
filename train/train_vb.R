# function for training the model with data
# N: number of samples 250, 500, 1000, 2000
# b: power for rho, i.e., the connection probability, 0.5, 1, 1.5
# K: community number 5, 10, 20
# beta: power parameter for imbalance (heterogeneity) of the community sizes 0, 5, 10
# M: parameter of the connection probability temporaly no

if(!require(doSNOW)){
  install.packages("doSNOW")
}
if(!require(tictoc)){
  install.packages("tictoc")
}

library(doSNOW)
library(tictoc)

# wd set as the directory above
source("./utils.r")
source("./methods/Variational_Bayes.R")
source("./metrics.r")

train_vb <- function(N, K, beta, b, seed){
  # generate data
  data <- sbm_gen_diagdom(N, K, beta, b, seed)
  A <- data$A
  Z <- data$Z
  B <- data$B
  
  # spectral clustering
  tic()
  ###### this line should fit the model
  z_init <- sample(1:K, N, replace = TRUE)   # Initial labels
  M <- 10000                                    # Maximum iterations
  epsilon <- 1e-6                            # Tolerance level
  betaparam <- 5                                   # Prior parameter
  D <- 1                                      # Prior factor
  res <- variational_sbm(A, K, z_init, M, epsilon, betaparam, D)
  cat('Fitted for N =', N, 'K =', K, 'beta =', beta, 'b =', b, 'seed =', seed)
  time <- toc()
  time <- time$toc - time$tic
  ###### To motivate the following steps, Z_hat should be a matrix; if cluster vector, call vec2mat to become a matrix
  Z_hat <- res$z_hat
  B_hat <- res$mu_hat
  Z_hat <- vec2mat(Z_hat, K)
  
  # find the best permutation
  idx <- find_best_idx(Z, Z_hat)
  Z_hat <- Z_hat[, idx]
  
  z_clust <- mat2vec(Z)
  z_hat_clust <- mat2vec(Z_hat)
  
  # calculate the metrics
  Z_ARI <- ARI(z_clust, z_hat_clust)
  Z_NMI <- NMI(z_clust, z_hat_clust)
  Z_F1_Score <- F1_Score(z_clust, z_hat_clust)
  Z_Accuracy <- ERROR(z_clust, z_hat_clust)
  
  B_lower <- B[lower.tri(B, diag = TRUE)]
  B_hat_lower <- B_hat[lower.tri(B_hat, diag = TRUE)]
  B_MAE <- MAE(B_lower, B_hat_lower)
  B_MSE <- MSE(B_lower, B_hat_lower)
  
  list(Z_ARI = Z_ARI, Z_NMI = Z_NMI, Z_F1_Score = Z_F1_Score,
       Z_Accuracy = Z_Accuracy, B_MAE = B_MAE, B_MSE = B_MSE, time = time,
       N = N, K = K, beta = beta, b = b, seed = seed)
}

numCores <- 24L
cl <- makeCluster(numCores)
registerDoSNOW(cl)

pb <- txtProgressBar(max = 100, style = 3)
progress <- function(n) setTxtProgressBar(pb,n)
opts <- list(progress=progress)

m <- 100

##### the packages change to packages for variational bayes
res_vb <- foreach(i=1:m,.combine=rbind,
                     .packages = c("RSpectra","gtools","tictoc","clue",
                                   "MLmetrics","aricode","mlsbm")) %dopar% {
                                     N_list <- c(250, 500, 1000, 2000)
                                     b_list <- c(0.1, 0.5, 1)
                                     K_list <- c(5, 10, 20)
                                     beta_list <- c(0, 5, 10)
                                     res <- list()
                                     for (N in N_list) {
                                       for (b in b_list) {
                                         for (K in K_list) {
                                           for (beta in beta_list) {
                                             res <- rbind(res, train_vb(N, K, beta, b, i))
                                           }
                                         }
                                       }
                                     }
                                     res
                                   }

save.image("sbm_vb.RData")
