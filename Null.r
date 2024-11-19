# gibbs_sbm <- function(A, k, z_init, alpha, iterations, samples){
#     # Initialize parameters
#     z <- z_init

#     # Sample labels
#     for (iter in 1:iterations){
#         for (i in 1:nrow(A)){
#             # Compute nk, nkl, Akl
#             n_r <- sapply(1:k, function(c) sum(z == c))
#             n_rs <- n_r %*% t(n_r) - diag(n_r)
#             A_rs <- matrix(0, k, k)
#                 for (r in 1:k) {
#                     for (s in 1:k) {
#                         A_rs[r, s] <- sum(A[z == r, z == s])
#                     }
#                 }
#             posterior <- matrix(0, samples, k)
#             for (j in 1:samples){
#                 pi <- rdirichlet(1, alpha + n_r)
#                 Q <- matrix(rbeta(k * k, 1 + A_rs, 1 + n_rs - A_rs), k, k)
#                 # Compute posterior for z_i
#                 z_temp <- z[-i]
#                 index_temp <- (1:n)[-i]
#                 term2 <- prod(Q[z[i], z_temp]^A[i, index_temp] * (1 - Q[z[i], z_temp])^(1 - A[i, index_temp]))
#                 term3 <- prod(Q[z_temp, z[i]]^(A[index_temp, i]) * (1 - Q[z_temp, z[i]])^(1 - A[index_temp, i]))
#                 posterior[j, ] <- pi * term2 * term3
#             }
#             # Update z_i
#             posterior <- colMeans(posterior)
#             posterior <- posterior / sum(posterior)
#             z[i] <- sample(1:k, 1, prob = posterior)
#         }
#     }
#     return(z)
# }

# z_init <- sample(1:k, 100, replace = TRUE)   # Initial labels
# alpha <- rep(1, k)                          # Dirichlet prior
# iterations <- 100                         # Number of iterations
# samples <- 1000

# z1 <- gibbs_sbm(A, k, z_init, alpha, iterations, samples)