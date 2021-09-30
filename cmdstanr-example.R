library(cmdstanr)
library(palmerpenguins)
library(mlflow)
library(tibble)
library(ggplot2)
library(dplyr)

clean_penguins <- na.omit(penguins) %>%
  mutate(
    bill_length = c(scale(bill_length_mm)),
    body_mass_kg = body_mass_g / 1000
  )


ggplot(clean_penguins, aes(x = bill_length, y = body_mass_kg)) +
  geom_point(aes(color = species))

# set up data
formula <- body_mass_kg ~ bill_length
X <- model.matrix(formula, data = clean_penguins)

stan_data <- list(
  n = nrow(X),
  m = ncol(X),
  X = X,
  y = clean_penguins$body_mass_kg
)

mlflow_start_run()
mlflow_set_tag("mlflow.runName", "penguin_cmdstanr")

# Fit model
mod <- cmdstan_model("lm.stan")
fit <- mod$sample(data = stan_data)
fit

# log "parameters" of the run
mlflow_log_param("formula", format(formula))

# log real-valued metrics
loo_metrics <- fit$loo()
mlflow_log_metric("elpd_loo", loo_metrics$estimates["elpd_loo", "Estimate"])
mlflow_log_metric("se_elpd_loo", loo_metrics$estimates["elpd_loo", "SE"])

fit_summary <- fit$summary()

lp__rhat <- fit_summary %>%
  filter(variable == "lp__") %>%
  pull(rhat)
mlflow_log_metric("lp__rhat", lp__rhat)

mlflow_log_metric("max_rhat", max(fit_summary$rhat))


# save artifacts
p <- bayesplot::mcmc_trace(fit$draws(c("beta", "sigma", "lp__")))
p
ggsave("traceplot.png", p)
mlflow_log_artifact("traceplot.png")


# log the model object
mlflow::mlflow_log_model(
  carrier::crate(function() fit, fit = fit),
  'model.crate'
)
# you can read a logged model later on via this command: (note parens at end)
# mlflow_load_model("path/to/model.crate")()

mlflow_end_run()

mlflow_ui()

