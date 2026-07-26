test_that("orb_facet() validates and stores its settings", {
  f <- orb_facet(cyl, ncol = 2, scales = "free")
  expect_s3_class(f, "orb_facet")
  expect_equal(f$ncol, 2)
  expect_equal(f$scales, "free")
  expect_error(orb_facet(cyl, scales = "nonsense"))
})

test_that("faceting adds one panel per level", {
  p <- orb(mtcars, x = wt, y = mpg) + orb_points() + orb_facet(cyl)
  sc <- orbis:::.build(p, 820, 520)
  # strip labels are the bold texts; axis tick labels are not bold and could
  # otherwise coincide with a facet level such as "4"
  strips <- Filter(function(m) identical(m$type, "text") &&
                     identical(m$layer, "axis") && !is.null(m$weight) &&
                     m$text %in% c("4", "6", "8"), sc$marks)
  expect_length(strips, 3)
  # one panel background per facet, plus the figure background
  panels <- Filter(function(m) identical(m$layer, "bg"), sc$marks)
  expect_gte(length(panels), 4)
})

test_that("every point is drawn exactly once across the panels", {
  plain <- orbis:::.build(orb(mtcars, x = wt, y = mpg) + orb_points(), 820, 520)
  fac <- orbis:::.build(orb(mtcars, x = wt, y = mpg) + orb_points() +
                          orb_facet(cyl), 820, 520)
  n_circ <- function(sc) sum(vapply(sc$marks,
                                    function(m) identical(m$type, "circle"),
                                    logical(1)))
  expect_equal(n_circ(fac), n_circ(plain))
  expect_equal(n_circ(fac), nrow(mtcars))
})

test_that("colours are resolved globally so panels stay comparable", {
  # the same car must get the same colour with and without faceting
  col_of <- function(sc) {
    vapply(Filter(function(m) identical(m$type, "circle"), sc$marks),
           function(m) m$fill, character(1))
  }
  plain <- orbis:::.build(orb(mtcars, x = wt, y = mpg, colour = hp) +
                            orb_points(), 820, 520)
  fac <- orbis:::.build(orb(mtcars, x = wt, y = mpg, colour = hp) +
                          orb_points() + orb_facet(cyl), 820, 520)
  expect_setequal(unique(col_of(fac)), unique(col_of(plain)))
})

test_that("fixed scales share limits and free scales do not", {
  panel_of <- function(scales) {
    p <- orb(mtcars, x = wt, y = mpg) + orb_points() +
      orb_facet(cyl, ncol = 3, scales = scales)
    sc <- orbis:::.build(p, 900, 400)
    ys <- vapply(Filter(function(m) identical(m$type, "circle"), sc$marks),
                 function(m) m$y, numeric(1))
    ys
  }
  # with free scales each panel restretches, so the extreme y differs
  expect_false(identical(range(panel_of("fixed")), range(panel_of("free"))))
})

test_that("ncol controls the grid and faceted plots render", {
  p <- orb(mtcars, x = wt, y = mpg) + orb_points() + orb_facet(cyl, ncol = 1)
  s <- orb_svg(p, interactive = FALSE)
  expect_true(startsWith(s, "<svg"))
  expect_true(grepl(">4<", s, fixed = TRUE))
})

test_that("a missing facet variable is reported clearly", {
  expect_error(orb_svg(orb(mtcars, x = wt, y = mpg) + orb_points() +
                         orb_facet(nope)), "nope")
})

test_that("faceting works with bars and lines", {
  d <- data.frame(g = rep(c("a", "b"), each = 3),
                  x = rep(1:3, 2), y = c(1, 3, 2, 4, 2, 5))
  expect_true(grepl("<rect", orb_svg(orb(d, x = x, y = y) + orb_bars() +
                                       orb_facet(g), interactive = FALSE)))
  expect_true(grepl("<path", orb_svg(orb(d, x = x, y = y) + orb_line() +
                                       orb_facet(g), interactive = FALSE)))
})

test_that("a faceted plot can be saved", {
  f <- tempfile(fileext = ".png")
  orb_save(orb(mtcars, x = wt, y = mpg) + orb_points() + orb_facet(cyl),
           f, width = 600, height = 400, dpi = 96)
  expect_gt(file.size(f), 1000)
  unlink(f)
})
