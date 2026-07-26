#' @keywords internal
#' @noRd
`%||%` <- function(a, b) if (is.null(a)) b else a

#' @keywords internal
#' @noRd
.stop <- function(...) stop(..., call. = FALSE)

## Normalise any R colour to "#rrggbb", keeping alpha separate.
#' @keywords internal
#' @noRd
.as_hex <- function(col) {
  if (is.null(col)) return(NULL)
  out <- vapply(col, function(cc) {
    if (is.na(cc)) return(NA_character_)
    v <- grDevices::col2rgb(cc)
    grDevices::rgb(v[1], v[2], v[3], maxColorValue = 255)
  }, character(1), USE.NAMES = FALSE)
  out
}

## Pretty breaks inside a range, always within [lo, hi].
#' @keywords internal
#' @noRd
.breaks <- function(lo, hi, n = 5) {
  if (!is.finite(lo) || !is.finite(hi)) return(numeric(0))
  if (lo == hi) return(lo)
  b <- pretty(c(lo, hi), n = n)
  b[b >= lo - 1e-9 & b <= hi + 1e-9]
}

## Format axis labels compactly (1200 -> "1.2k").
#' @keywords internal
#' @noRd
.fmt_num <- function(x) {
  vapply(x, function(v) {
    if (!is.finite(v)) return("")
    a <- abs(v)
    if (a >= 1e9) return(paste0(.trim(v / 1e9), "B"))
    if (a >= 1e6) return(paste0(.trim(v / 1e6), "M"))
    if (a >= 1e4) return(paste0(.trim(v / 1e3), "k"))
    .trim(v)
  }, character(1), USE.NAMES = FALSE)
}

#' @keywords internal
#' @noRd
.trim <- function(v) {
  s <- format(round(v, 4), trim = TRUE, scientific = FALSE)
  # strip trailing zeros only in the fractional part: 1.50 -> 1.5, 100 -> 100
  s <- if (grepl(".", s, fixed = TRUE)) sub("0+$", "", s) else s
  sub("\\.$", "", s)
}

## Approximate text width in px, good enough for layout.
#' @keywords internal
#' @noRd
.text_w <- function(s, size) nchar(s) * size * 0.55

## Escape text for inclusion in XML/SVG.
#' @keywords internal
#' @noRd
.xml_escape <- function(s) {
  s <- gsub("&", "&amp;", s, fixed = TRUE)
  s <- gsub("<", "&lt;", s, fixed = TRUE)
  s <- gsub(">", "&gt;", s, fixed = TRUE)
  s <- gsub("\"", "&quot;", s, fixed = TRUE)
  s
}

## Round numbers for compact SVG output.
#' @keywords internal
#' @noRd
.r2 <- function(x) formatC(x, digits = 2, format = "f", drop0trailing = TRUE)
