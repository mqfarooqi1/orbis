# R with the orbis graphics package preinstalled.
#
# Build:  docker build -t orbis .
# Run:    docker run --rm -it ghcr.io/mqfarooqi1/orbis
#
# The image is published to the GitHub Container Registry by
# .github/workflows/docker.yaml whenever a release is published.
FROM rocker/r-ver:4.5.2

LABEL org.opencontainers.image.title="orbis" \
      org.opencontainers.image.description="R with the orbis graphics package preinstalled: layered grammar, interactive SVG, high-resolution output and built-in world maps." \
      org.opencontainers.image.source="https://github.com/mqfarooqi1/orbis" \
      org.opencontainers.image.url="https://mqfarooqi1.github.io/orbis/" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.authors="Muhammad Farooqi <mqfarooqi@gmail.com>"

# orbis needs only htmltools beyond the base R packages
RUN install2.r --error --skipinstalled htmltools

COPY . /build/orbis
RUN R CMD INSTALL --clean /build/orbis \
    && Rscript -e 'library(orbis); stopifnot(nchar(orb_svg(orb(mtcars, x = wt, y = mpg) + orb_points())) > 1000); cat("orbis installed and rendering\n")' \
    && rm -rf /build

WORKDIR /work
CMD ["R"]
