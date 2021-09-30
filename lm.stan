data {
  int<lower = 0> n;
  vector[n] y;
  int<lower = 1> m;
  matrix[n, m] X;
}

parameters {
  vector[m] beta;
  real<lower=0> sigma;
}

model {
  beta ~ normal(0, 10);
  sigma ~ normal(1, 1);
  y ~ normal(X * beta, sigma);
}

generated quantities {
  vector[n] log_lik;
  for (i in 1:n)
    log_lik[i] = normal_lpdf(y[i] | X * beta, sigma);
}
