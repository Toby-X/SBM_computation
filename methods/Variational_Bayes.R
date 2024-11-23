variational_sbm <- function(A, k, z_init, M, epsilon, beta, D) {
  # Number of nodes
  n <- nrow(A)
  
  # Initialize variables
  t <- 0
  L_t <- Inf
  delta_L <- Inf
  a <- n^2
  delta <- 1 + sqrt(2 * beta / n^2)
  
  # Initialize z, mu, and Sigma
  z <- z_init
  # note here n_c is a vector with length k, and n_c[c] is the thing used in the paper for n_c
  n_c <- sapply(1:k, function(c) sum(z == c))
  
  mu <- array(0, dim = c(k, k))
  Sigma <- array(0, dim = c(k, k))
  
  for (c in 1:k) {
    for (d in 1:k) {
      mu[c, d] <- (delta)^(-1) * (n_c[c])^(-1) * (n_c[d])^(-1) *
        sum(A[z == c, z == d])
      Sigma[c, d] <- (delta)^(-1) * (n_c[c])^(-1) * (n_c[d])^(-1)
    }
  }
  print(mu)
  
  # Iterative algorithm
  while (t < M && delta_L > epsilon) {
    t <- t + 1
    z_new <- z
    
    # Update z
    for (i in sample(1:n)) {
      v_ic <- numeric(k)
      for (c in 1:k) {
        # a little trick to let or summation terms skip z_temp[i]
        z_temp <- z_new[-i]
        n_c_temp <- sapply(1:k, function(c) sum(z_temp == c))
        mu_temp <- mu

        v_ic[c] <- -k * log(1 + 1 / n_c_temp[c]) -
          2 * sum(A[i, -i] * mu_temp[c, z_temp]) +
          delta * (sum(mu_temp[c, z_temp]^2) + 0.5 * mu_temp[c, c]^2) +
          0.5 * (sum(n_c_temp / n_c) + 1 / n_c[c])^2
      }
      z_new[i] <- which.min(v_ic)
    }
    z <- z_new
    
    # Update n_c, a, and delta
    n_c_new <- sapply(1:k, function(c) sum(z == c))
    a <- sum(mu[z, z]^2) + delta^(-1) * sum(n_c_new / n_c)^2
    delta <- 1 + sqrt(2 * beta / a)
    n_c <- n_c_new
    
    # Update mu and Sigma
    for (c in 1:k) {
      for (d in 1:k) {
        mu[c, d] <- (delta)^(-1) * (n_c[c])^(-1) * (n_c[d])^(-1) *
          sum(A[z == c, z == d])
        Sigma[c, d] <- (delta)^(-1) * (n_c[c])^(-1) * (n_c[d])^(-1)
      }
    }
    
    # Update L_t and delta_L
    L_t_new <- (k * (k + 1) / 4) * log(delta / (4 * beta * exp(2))) +
      sqrt(a * beta / 2) -
      0.5 * sum(A * mu[z, z]) +
      (D + 1) * (0.5 * k * (k + 1) + n * log(k))
    delta_L <- abs(L_t - L_t_new)
    L_t <- L_t_new
  }
  
  # Output results
  list(
    z_hat = z,
    a_hat = a,
    mu_hat = mu,
    Sigma_hat = Sigma,
    L_hat = L_t
  )
}

# Example usage:
# Set the parameters for the algorithm
# set.seed(53)
# # true model
# B <- matrix(c(1, 0.8, 0.25, 0.8, 1, 0, 0.25, 0, 0), nrow = 3)
# # generate data of Z, where the true community is 1112223333, z is 10*3 matrix
# z <- c(rep(1, 30), rep(2, 30), rep(3, 40))
# # sample an A based on B and z
# A <- matrix(0, nrow = 100, ncol = 100)
# for (i in 1:100) {
#   for (j in i:100) {
#     if (i != j) {
#       A[i, j] <- rbinom(1, 1, B[z[i], z[j]])
#     }
#   }
# }
# A <- A + t(A)

# k <- 3                                      # Number of clusters
# z_init <- sample(1:k, 100, replace = TRUE)   # Initial labels
# M <- 10000                                    # Maximum iterations
# epsilon <- 1e-6                            # Tolerance level
# beta <- 5                                   # Prior parameter
# D <- 1                                      # Prior factor

# result <- variational_sbm(A, k, z_init, M, epsilon, beta, D)
# print(result)
