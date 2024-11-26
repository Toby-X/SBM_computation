## method for Variational EM
if (!require(blockmodels)) {
  devtools::install_github("keanson/blockmodels")
}
library(blockmodels)
# devtools::install_github("keanson/blockmodels")


# generation of one SBM network
# npc <- 30 # nodes per class
# Q <- 10 # classes
# n <- npc * Q # nodes
# Z<-diag(Q)%x%matrix(1,npc,1)
# P<-matrix(runif(Q*Q),Q,Q)
# M<-1*(matrix(runif(n*n),n,n)<Z%*%P%*%t(Z)) ## adjacency matrix
# ## estimation
# my_model <- BM_bernoulli("SBM",M, explore_min=1, explore_max=2)
# my_model <- BM_bernoulli("SBM",M, explore_min=Q-1, explore_max=Q)
# my_model$estimate()
# my_model$memberships[[10]]$Z

