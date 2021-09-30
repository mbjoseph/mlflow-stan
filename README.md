# Tracking experiments in a Bayesian workflow: MLFlow + Stan

Get the code

```bash
git clone https://github.com/mbjoseph/mlflow-stan.git
cd mlflow-stan
```

## Building the container

```bash
docker build -t mlflow-stan .
```

## Running the container

```bash
docker run --rm -p 8787:8787 -e PASSWORD=yourpasswordhere mlflow-stan
```

Then, open `localhost:8787` in a web browser, and input `rstudio` as the username, and your password specified in your call to `docker run`.

## Examples

- `lm-example.R` just uses lm (no Stan)
- `brms-example.R` uses brms (doesn't work with Docker image, but may be useful)
- `cmdstanr-example.R` provides a generic example for bespoke models, using cmdstanr
