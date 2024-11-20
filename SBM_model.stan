// data {
//   int<lower=0> N;
//   int<lower=0> K;
//   matrix[N, N] A;
// }
// 
// parameters {
//   vector<lower=0>[K] alpha;
//   simplex[K] Pi;
//   real<lower=0> a;
//   real<lower=0> b;
//   int<lower=1,upper=K> Z[N];
//   matrix<lower=0>[K, K] B_lower;
// }
// 
// transformed parameters {
//   matrix[K, K] B;
//   B = B_lower + B_lower' - diag_matrix(diagonal(B_lower));
// }
// 
// model {
//   for (i in 1:N) {
//     for (j in 1:i){
//       int Z1 = Z[i];
//       int Z2 = Z[j];
//       A[i,j] ~ bernoulli(B[Z1, Z2]);
//     }
//   }
//   Z ~ categorical(Pi);
//   Pi ~ dirichlet(alpha);
//   for (i in 1:K){
//     for (j in 1:i){
//       B_lower[i,j] ~ beta(a,b);
//     }
//   }
// }

// data {
//   int<lower=0> N;
//   int<lower=0> K;
//   matrix[N, N] A;
// }
// 
// parameters {
//   vector<lower=0>[K] alpha;
//   simplex[K] Pi;
//   real<lower=0> a;
//   real<lower=0> b;
//   int<lower=1,upper=K> Z[N];
//   matrix<lower=0>[K, K] B_lower;
// }
// 
// transformed parameters {
//   matrix[K, K] B;
//   B = B_lower + B_lower' - diag_matrix(diagonal(B_lower));
// }
// 
// model {
//   for (i in 1:N) {
//     for (j in 1:i){
//       int Z1 = Z[i];
//       int Z2 = Z[j];
//       A[i,j] ~ bernoulli(B[Z1, Z2]);
//     }
//   }
//   Z ~ categorical(Pi);
//   Pi ~ dirichlet(alpha);
//   for (i in 1:K){
//     for (j in 1:i){
//       B_lower[i,j] ~ beta(a,b);
//     }
//   }
// }

data {
  int<lower=0> N; // Number of nodes
  int<lower=1> K; // Number of clusters
  array[N, N] int<lower=0, upper=1> A; // Adjacency matrix
}
parameters {
  vector<lower=0>[K] alpha; // Dirichlet parameters for Pi
  simplex[K] Pi; // Cluster probabilities
  real<lower=0> a; // Beta parameter
  real<lower=0> b; // Beta parameter
  matrix<lower=0>[K, K] B_lower; // Lower triangular part of B
}
transformed parameters {
  matrix[K, K] B;
  // Make B symmetric
  B = B_lower + B_lower' - diag_matrix(diagonal(B_lower));
}
model {
  // Priors
  Pi ~ dirichlet(alpha);
  for (i in 1 : K) {
    for (j in 1 : i) {
      B_lower[i, j] ~ beta(a, b);
    }
  }
  
  // Marginalize over Z
  for (i in 1 : N) {
    for (j in 1 : i) {
      real prob = 0;
      for (k1 in 1 : K) {
        for (k2 in 1 : k1) {
          prob += Pi[k1] * Pi[k2] * bernoulli_lpmf(A[i, j] | B_lower[k1, k2]);
        }
      }
      target += log(prob); // Add the marginalized likelihood
    }
  }
}
generated quantities {
  array[N] int<lower=1, upper=K> Z; // Cluster assignments
  
  for (n in 1 : N) {
    Z[n] = categorical_rng(Pi); // Sample Z from the posterior Pi
  }
}

