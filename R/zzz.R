## Register the knitr method only if knitr is available, so knitr can remain a
## suggested (not required) dependency.
.onLoad <- function(libname, pkgname) {
  if (requireNamespace("knitr", quietly = TRUE)) {
    registerS3method("knit_print", "orb_spec", knit_print.orb_spec,
                     envir = asNamespace("knitr"))
  }
  invisible()
}
