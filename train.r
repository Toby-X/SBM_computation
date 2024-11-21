# function for training the model with data
# N: number of samples
# b: power for rho, i.e., the connection probability
# K: community number
# beta: power parameter for imbalance (heterogeneity) of the community sizes
# M: parameter of the connection probability
# methods: methods to be compared

# return: selected metrics, now is Accuracy, Macro-F1, Micro-F1, NMI, ARI
train <- function(N, b, K, beta, M, methods=c("Spectral1", "Spectral2", "Spectral3", "Spectral4", "Gibbs", "VB", "VEM", "HMC")) {
    # Data generation

    # training model

    # compute the metrics and return

}