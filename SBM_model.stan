data {
  int<lower=0> N;
  int<lower=0> K;
  matrix[N, N] A;
}

parameters {
  vector<lower=0>[K] alpha;
  simplex[K] Pi;
  real<lower=0> a;
  real<lower=0> b;
  int<lower=1,upper=K> Z[N];
  matrix<lower=0>[K, K] B_lower;
}

transformed parameters {
  matrix[K, K] B;
  B = B_lower + B_lower' - diag_matrix(diagonal(B_lower));
}

model {
  for (i in 1:N) {
    for (j in 1:i){
      A[i,j] ~ bernoulli(B[Z[i], Z[j]]);
    }
  }
  Z ~ categorical(Pi);
  Pi ~ dirichlet(alpha);
  for (i in 1:K){
    for (j in 1:i){
      B_lower[i,j] ~ beta(a,b);
    }
  }
}

