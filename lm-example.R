
library(palmerpenguins)
library(mlflow)
library(tibble)
library(ggplot2)


ggplot(penguins, aes(x = bill_length_mm, y = penguins$body_mass_g)) +
  geom_point(aes(color = species))




mlflow_start_run()
mlflow_set_tag("mlflow.runName", "penguin_lm")

# Fit model
model <- lm(bill_length_mm ~ body_mass_g, data = penguins)

# log "parameters" of the run
mlflow_log_param("formula", as.character(model$call)[2])

# log real-valued metrics
mlflow_log_metric("rsq", summary(model)$adj.r.squared)
mlflow_log_metric("sigma", summary(model)$sigma)

# mlflow_log_batch handles vector-valued metrics using a dataframe with
# key, value, step, and timestamp as columns
mlflow_log_batch(
  metrics = tibble(
    key = janitor::make_clean_names(names(model$coefficients)),
    value = model$coefficients,
    step = 1,
    timestamp = 1
  )
)

# save artifacts
resid_plot <- qplot(x = fitted(model), y = resid(model)) + geom_smooth()
resid_plot
ggsave("diagnostics.png", plot = resid_plot)
mlflow_log_artifact("diagnostics.png")


# log the model object
mlflow::mlflow_log_model(
  carrier::crate(function() model, model = model),
  'model.crate'
)
# you can read a model later on via
# mlflow_load_model("path/to/model.crate")()


mlflow_end_run()

mlflow_ui()

