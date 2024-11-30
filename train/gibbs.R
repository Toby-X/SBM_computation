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
if(!require(optparse)){
  install.packages("optparse")
}
library("optparse")
 
option_list = list(
  make_option(c("-s", "--seed"), type="integer", default=1, help="random seed ", metavar="integer"),
  make_option(c("-l", "--length"), type="integer", default=4, help="length of the seed", metavar="integer")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)
print(paste0("seed: ", opt$seed, " length: ", opt$length))

library(doSNOW)
library(tictoc)

# wd set as the directory above
source("./utils.r")
source("./methods/Gibbs_Sampling.R")
source("./metrics.r")

train_gibbs <- function(N, K, beta, b, seed){
  # generate data
  print(paste0("N: ", N, " K: ", K, " beta: ", beta, " b: ", b, " seed: ", seed))
  data <- sbm_gen_diagdom(N, K, beta, b, seed)
  A <- data$A
  Z <- data$Z
  B <- data$B
  
  # spectral clustering
  spectral_clustering <- function(A, K){
    library(RSpectra)
    library(ClusterR)
    svd_A <- RSpectra::svds(A, K)
    kmeans_res <- KMeans_rcpp(svd_A$u, K, num_init = 10, max_iter = 100)
    clust_vec <- kmeans_res$clusters
    Z <- clust_vec
  } 
  tic()
  zinit <- spectral_clustering(A, K)
  res <- fit_sbm(A, K, verbose = FALSE, z_init = zinit, burn = 10, n_iter = 100)
  time <- toc()
  time <- time$toc - time$tic
  Z_hat <- res$z
  B_hat <- res$P
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

# numCores <- 5L
# cl <- makeCluster(numCores, outfile=paste0("./sbm_gibbs_seed_", opt$seed, ".out"))
# registerDoSNOW(cl)

# pb <- txtProgressBar(max = 100, style = 3)
# progress <- function(n) setTxtProgressBar(pb,n)
# opts <- list(progress=progress)

# res_gibbs <- foreach(i=opt$seed:opt$seed+opt$length,.combine=rbind,
#                   .packages = c("RSpectra","gtools","tictoc","clue",
#                                 "MLmetrics","aricode","mlsbm")) %dopar% {
#                                   N_list <- c(1000)
#                                   b_list <- c(0.1, 0.5, 1)
#                                   K_list <- c(5, 10, 20)
#                                   beta_list <- c(0, 5, 10)
#                                   res <- list()
#                                   for (N in N_list) {
#                                     for (b in b_list) {
#                                       for (K in K_list) {
#                                         for (beta in beta_list) {
#                                           res <- rbind(res, train_gibbs(N, K, beta, b, i))
#                                         }
#                                       }
#                                     }
#                                   }
#                                   res
#                                 }
res <- list()
for (i in opt$seed:(opt$seed+opt$length)){
  N_list <- c(2000)
  b_list <- c(0.1, 0.5, 1)
  K_list <- c(5, 10, 20)
  beta_list <- c(0, 5, 10)
  for (N in N_list) {
    for (b in b_list) {
      for (K in K_list) {
        for (beta in beta_list) {
          res <- rbind(res, train_gibbs(N, K, beta, b, i))
        }
      }
    }
  }
}

save.image(paste0("./sbm_gibbs_seed_", opt$seed, ".RData"))
