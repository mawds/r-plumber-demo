FROM rstudio/plumber
MAINTAINER David Mawdsley <david.mawdsley@manchester.ac.uk>

RUN R -e "install.packages(c('magrittr', 'tibble', 'dplyr' ))"

COPY plumber.R /
COPY data /data


CMD ["/plumber.R"]

