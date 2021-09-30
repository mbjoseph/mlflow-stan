library(brms)
library(palmerpenguins)
library(mlflow)
library(tibble)
library(ggplot2)
library(dplyr)

clean_penguins <- na.omit(penguins)


ggplot(clean_penguins, aes(x = bill_length_mm, y = body_mass_g)) +
  geom_point(aes(color = species))




mlflow_start_run()
mlflow_set_tag("mlflow.runName", "penguin_brms")

# Fit model
model <- brm(body_mass_g ~ bill_length_mm * species, data = clean_penguins, backend = "cmdstanr")

# log "parameters" of the run
mlflow_log_param("formula", as.character(model$formula)[1])

# log real-valued metrics
loo_metrics <- loo(model)
mlflow_log_metric("elpd_loo", loo_metrics$estimates["elpd_loo", "Estimate"])
mlflow_log_metric("se_elpd_loo", loo_metrics$estimates["elpd_loo", "SE"])

rsq_metrics <- bayes_R2(model)
mlflow_log_metric("r2", rsq_metrics[, "Estimate"])
mlflow_log_metric("r2_lo", rsq_metrics[, "Q2.5"])
mlflow_log_metric("r2_hi", rsq_metrics[, "Q97.5"])

lp__rhat <- posterior::summarize_draws(model) %>%
  filter(variable == "lp__") %>%
  pull(rhat)
mlflow_log_metric("lp__rhat", lp__rhat)


# save artifacts
p <- plot(model)
p
pdf("plot.pdf", height = 5, width = 8)
p
dev.off()
mlflow_log_artifact("plot.pdf")


# log the model object
mlflow::mlflow_log_model(
  carrier::crate(function() model, model = model),
  'model.crate'
)
# you can read a logged model later on via this command: (note parens at end)
# mlflow_load_model("path/to/model.crate")()

mlflow_end_run()

mlflow_ui()

