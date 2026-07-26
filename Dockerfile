# R with the orbis graphics package preinstalled.
#
# Build:  docker build -t orbis .
# Run:    docker run --rm -it ghcr.io/mqfarooqi1/orbis
#
# The image is published to the GitHub Container Registry by
# .github/workflows/docker.yaml.
FROM rocker/r-ver:4.5.2

LABEL org.opencontainers.image.title="orbis"
LABEL org.opencontainers.image.description="R with the orbis graphics package preinstalled: layered grammar, interactive SVG, high-resolution output and built-in world maps."
LABEL org.opencontainers.image.source="https://github.com/mqfarooqi1/orbis"
LABEL org.opencontainers.image.url="https://mqfarooqi1.github.io/orbis/"
LABEL org.opencontainers.image.licenses="MIT"

# orbis needs only htmltools beyond the base R packages
RUN Rscript -e 'install.packages("htmltools", repos = "https://cloud.r-project.org")' \
    && Rscript -e 'stopifnot(requireNamespace("htmltools", quietly = TRUE))'

COPY . /build/orbis
RUN R CMD INSTALL --clean /build/orbis && rm -rf /build

# fail the build early if the package cannot render
RUN Rscript -e 'library(orbis); s <- orb_svg(orb(mtcars, x = wt, y = mpg) + orb_points()); stopifnot(nchar(s) > 1000); cat("orbis installed and rendering\n")'

WORKDIR /work
CMD ["R"]
