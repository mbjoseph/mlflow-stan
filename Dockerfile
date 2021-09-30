FROM rocker/rstudio:latest

## R's X11 runtime dependencies
# from https://github.com/rocker-org/rocker-versioned/tree/master/X11
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libx11-6 \
    libxss1 \
    libxt6 \
    libxext6 \
    libsm6 \
    libice6 \
    xdg-utils \
  && rm -rf /var/lib/apt/lists/*

USER rstudio

RUN install2.r reticulate

RUN Rscript -e 'reticulate::install_miniconda()'

RUN install2.r mlflow

RUN Rscript -e 'mlflow::install_mlflow(python_version = "3.9")'

RUN install2.r bayesplot carrier dplyr janitor palmerpenguins

RUN Rscript -e 'install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))'

RUN Rscript -e 'cmdstanr::install_cmdstan(); cmdstanr::cmdstan_version()'

COPY --chown=rstudio . /home/rstudio

USER root
