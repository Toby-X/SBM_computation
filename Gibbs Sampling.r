# Check if the package is installed
if (!require(gtools)) {
  install.packages("gtools")
}
if (!require(mlsbm)) {
  install.packages("mlsbm")
}
# Load required package
library(gtools)  # For Dirichlet distribution
library(mlsbm)   # For SBM

# Example usage:
# Set the parameters for the algorithm
set.seed(53)
# true model
B <- matrix(c(1, 0.8, 0.25, 0.8, 1, 0, 0.25, 0, 0), nrow = 3)
# generate data of Z, where the true community is 1112223333, z is 10*3 matrix
z <- c(rep(1, 30), rep(2, 30), rep(3, 40))
# sample an A based on B and z
A <- matrix(0, nrow = 100, ncol = 100)
for (i in 1:100) {
  for (j in i:100) {
    if (i != j) {
      A[i, j] <- rbinom(1, 1, B[z[i], z[j]])
    }
  }
}
A <- A + t(A)
k <- 3                                      # Number of clusters

fit <- fit_sbm(A, k)
fit$P
print(fit$z)

