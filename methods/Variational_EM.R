## method for Variational EM
if(!require(sbm)){
  install.packages("sbm")
}

library(sbm)

## Example
## A is the adjacency matrix
## Est
# sbm_fit <- estimateSimpleSBM(A, model = "bernoulli",
#                              estimOptions = list(nbCores=1, plot=F, 
#                                                  nbBlocksRange=c(K,K),
#                                                  exploreMin=K,
#                                                  exploreMax=K))
# # Z matrix
# sbm_fit$indMemberships
# # B connectivity
# sbm_fit$connectParam
