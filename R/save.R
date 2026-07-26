#' Save a plot at any resolution
#'
#' Writes a plot to disk. The format is taken from the file extension:
#'
#' \describe{
#'   \item{`.svg`}{Vector output from the built-in SVG writer. Being a vector
#'     format it is resolution independent - it stays sharp at any size.}
#'   \item{`.html`}{A self-contained interactive page (see [orb_interactive()]).}
#'   \item{`.pdf`}{Vector output through R's PDF device.}
#'   \item{`.png`, `.tiff`, `.jpeg`}{Raster output at the requested `dpi`; use
#'     300 or more for print.}
#' }
#'
#' @param plot An `orb_spec` object.
#' @param file Output path. The extension selects the format.
#' @param width,height Logical size in pixels (the drawing is laid out at this
#'   size, then rendered at `dpi`).
#' @param dpi Resolution for raster formats. 96 is screen resolution; 300 is a
#'   common print requirement; 600 gives very high resolution output.
#' @param interactive For `.html` and `.svg`, embed interactive behaviour.
#' @return The file path, invisibly.
#' @seealso [orb_svg()], [orb_interactive()], [orb_draw()]
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
#' f <- tempfile(fileext = ".png")
#' orb_save(p, f, dpi = 300)
#' file.exists(f)
#' unlink(f)
#' @export
orb_save <- function(plot, file, width = 820, height = 520, dpi = 300,
                     interactive = TRUE) {
  if (!inherits(plot, "orb_spec")) .stop("`plot` must be an orb_spec object.")
  ext <- tolower(tools::file_ext(file))
  if (ext == "svg") {
    writeLines(orb_svg(plot, width, height, interactive = interactive), file)
    return(invisible(file))
  }
  if (ext == "html") {
    return(invisible(orb_interactive(plot, file = file, width = width,
                                     height = height)))
  }
  s <- dpi / 96
  if (ext == "pdf") {
    grDevices::pdf(file, width = width / 96, height = height / 96)
  } else if (ext %in% c("png", "tif", "tiff", "jpg", "jpeg")) {
    dev <- switch(ext, png = grDevices::png, tif = , tiff = grDevices::tiff,
                  grDevices::jpeg)
    dev(file, width = width * s, height = height * s, res = 96 * s)
  } else {
    .stop("Unsupported file type: ", ext,
          ". Use svg, html, pdf, png, tiff or jpeg.")
  }
  on.exit(grDevices::dev.off(), add = TRUE)
  .render_grid(.build(plot, width, height))
  invisible(file)
}

#' Open or write an interactive plot
#'
#' Builds a self-contained HTML document containing the plot as inline SVG plus
#' a small embedded script. The result works offline, needs no JavaScript
#' library, and supports tooltips, hover highlighting, mouse-wheel zoom,
#' dragging to pan, double-click to reset, and clicking legend keys to show or
#' hide series.
#'
#' @param plot An `orb_spec` object.
#' @param file Optional output path. If `NULL`, an object suitable for the
#'   RStudio viewer or an R Markdown document is returned instead.
#' @param width,height Size in pixels.
#' @param title Title of the HTML document.
#' @return If `file` is given, the path (invisibly); otherwise an
#'   `htmltools` tag object.
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
#' f <- tempfile(fileext = ".html")
#' orb_interactive(p, file = f)
#' file.exists(f)
#' unlink(f)
#' @export
orb_interactive <- function(plot, file = NULL, width = 820, height = 520,
                            title = "orbis plot") {
  html <- orb_svg(plot, width, height, interactive = TRUE)
  if (is.null(file)) {
    return(htmltools::browsable(htmltools::HTML(html)))
  }
  th <- plot$theme
  doc <- paste0(
    "<!DOCTYPE html><html><head><meta charset=\"utf-8\">",
    "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">",
    "<title>", .xml_escape(title), "</title>",
    "<style>body{margin:0;padding:18px;background:", th$bg,
    ";font-family:", th$font, ";}</style></head><body>", html,
    "</body></html>")
  writeLines(doc, file)
  invisible(file)
}

#' @keywords internal
#' @noRd
.display <- function(x) {
  if (interactive() && !is.null(getOption("viewer"))) {
    tmp <- tempfile(fileext = ".html")
    orb_interactive(x, file = tmp)
    getOption("viewer")(tmp)
  } else {
    .render_grid(.build(x, 820, 520))
  }
  invisible(x)
}

## Registered with knitr at load time (see zzz.R) so that knitr can stay in
## Suggests. HTML output gets the interactive version, other formats a
## high-resolution image.
#' @keywords internal
#' @noRd
knit_print.orb_spec <- function(x, ...) {
  fmt <- tryCatch(knitr::opts_knit$get("rmarkdown.pandoc.to"),
                  error = function(e) NULL)
  if (!is.null(fmt) && !grepl("html", fmt)) {
    f <- knitr::fig_path(".png")
    dir.create(dirname(f), showWarnings = FALSE, recursive = TRUE)
    orb_save(x, f, dpi = 300)
    return(knitr::asis_output(paste0("![](", f, ")")))
  }
  knitr::asis_output(orb_svg(x, interactive = TRUE))
}
