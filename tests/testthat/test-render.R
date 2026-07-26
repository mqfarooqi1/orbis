test_that("every layer type renders to SVG", {
  df <- data.frame(x = 1:20, y = cumsum(stats::rnorm(20)),
                   g = rep(c("a", "b"), 10))
  layers <- list(orb_points(), orb_line(), orb_area(), orb_bars(),
                 orb_line(smooth = TRUE))
  for (l in layers) {
    s <- orb_svg(orb(df, x = x, y = y) + l, interactive = FALSE)
    expect_true(startsWith(s, "<svg"))
    expect_true(nchar(s) > 500)
  }
})

test_that("discrete x is used for bars and gives one rect per row", {
  bd <- data.frame(g = c("a", "b", "c"), v = c(3, 7, 5))
  s <- orb_svg(orb(bd, x = g, y = v) + orb_bars(), interactive = FALSE)
  expect_true(grepl("<rect", s))
  expect_true(all(vapply(c("a", "b", "c"), grepl, logical(1), x = s)))
})

test_that("interactive output embeds the script and static output does not", {
  p <- orb(mtcars, x = wt, y = mpg, colour = factor(cyl)) + orb_points()
  si <- orb_svg(p, interactive = TRUE)
  ss <- orb_svg(p, interactive = FALSE)
  expect_true(grepl("addEventListener", si, fixed = TRUE))
  expect_true(grepl("data-tip", si, fixed = TRUE))
  expect_false(grepl("<script>", ss, fixed = TRUE))
  expect_true(startsWith(ss, "<svg"))
})

test_that("orb_options(interactive = FALSE) is respected", {
  p <- orb(mtcars, x = wt, y = mpg) + orb_points() +
    orb_options(interactive = FALSE)
  expect_false(grepl("<script>", orb_svg(p), fixed = TRUE))
})

test_that("discrete colour tags series so the legend can toggle them", {
  p <- orb(mtcars, x = wt, y = mpg, colour = factor(cyl)) + orb_points()
  s <- orb_svg(p)
  expect_true(grepl("data-series", s, fixed = TRUE))
  expect_true(grepl("data-key", s, fixed = TRUE))
})

test_that("scales change the output", {
  p <- orb(mtcars, x = wt, y = mpg, colour = hp) + orb_points()
  expect_false(identical(orb_svg(p, interactive = FALSE),
                         orb_svg(p + orb_scale_colour("magma"),
                                 interactive = FALSE)))
})

test_that("log transformation drops non-positive values without error", {
  d <- data.frame(x = 1:10, y = c(-1, 0, 1:8))
  expect_silent(orb_svg(orb(d, x = x, y = y) + orb_points() +
                          orb_scale_y(trans = "log10"), interactive = FALSE))
})

test_that("text is escaped so titles cannot break the SVG", {
  p <- orb(mtcars, x = wt, y = mpg) + orb_points() +
    orb_labs(title = "a < b & c > d")
  s <- orb_svg(p, interactive = FALSE)
  expect_true(grepl("&lt;", s, fixed = TRUE))
  expect_true(grepl("&amp;", s, fixed = TRUE))
})

test_that("files are written in every supported format", {
  p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
  for (ext in c("png", "pdf", "svg", "html")) {
    f <- tempfile(fileext = paste0(".", ext))
    orb_save(p, f, width = 400, height = 300, dpi = 96)
    expect_true(file.exists(f))
    expect_gt(file.size(f), 500)
    unlink(f)
  }
  expect_error(orb_save(p, tempfile(fileext = ".xyz")), "Unsupported")
})

test_that("higher dpi produces a larger raster", {
  p <- orb(mtcars, x = wt, y = mpg) + orb_points()
  f1 <- tempfile(fileext = ".png"); f2 <- tempfile(fileext = ".png")
  orb_save(p, f1, width = 400, height = 300, dpi = 96)
  orb_save(p, f2, width = 400, height = 300, dpi = 300)
  expect_gt(file.size(f2), file.size(f1))
  unlink(c(f1, f2))
})

test_that("orb_draw works on an open device", {
  f <- tempfile(fileext = ".png")
  grDevices::png(f, width = 400, height = 300)
  expect_silent(orb_draw(orb(mtcars, x = wt, y = mpg) + orb_points()))
  grDevices::dev.off()
  expect_true(file.size(f) > 500)
  unlink(f)
})
