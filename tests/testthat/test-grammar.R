test_that("orb() builds a spec and validates its input", {
  p <- orb(mtcars, x = wt, y = mpg)
  expect_s3_class(p, "orb_spec")
  expect_named(p$mapping, c("x", "y"))
  expect_length(p$layers, 0)
  expect_error(orb(1:10))
})

test_that("`color` is accepted as a synonym for `colour`", {
  p <- orb(mtcars, x = wt, y = mpg, color = cyl)
  expect_true("colour" %in% names(p$mapping))
})

test_that("layers, labels, themes and scales are added with +", {
  p <- orb(mtcars, x = wt, y = mpg) + orb_points() + orb_line()
  expect_length(p$layers, 2)
  expect_equal(vapply(p$layers, function(l) l$geom, character(1)),
               c("points", "line"))

  p2 <- p + orb_labs(title = "T", x = "X") + orb_theme_dark() +
    orb_scale_y(limits = c(0, 40))
  expect_equal(p2$labs$title, "T")
  expect_equal(p2$theme$bg, "#14161A")
  expect_equal(p2$scales$y$limits, c(0, 40))
  expect_error(p + "not a layer")
})

test_that("a missing variable is reported clearly", {
  expect_error(orb_svg(orb(mtcars, x = wt, y = nope) + orb_points()),
               "nope")
})

test_that("themes differ and accept overrides", {
  expect_false(identical(orb_theme_light()$bg, orb_theme_dark()$bg))
  expect_equal(orb_theme_light(base_size = 20)$base_size, 20)
  expect_equal(orb_theme_light(panel = "#123456")$panel, "#123456")
})

test_that("palettes are listed and interpolate", {
  pl <- orb_palettes()
  expect_true(all(c("continuous", "discrete") %in% names(pl)))
  expect_true("viridis" %in% pl$continuous)
  cols <- orbis:::.ramp("viridis", n = 5)
  expect_length(cols, 5)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", cols)))
})

test_that("axis numbers keep their magnitude", {
  # a trailing-zero bug would render 100 as "1"
  expect_equal(orbis:::.fmt_num(c(10, 100, 30)), c("10", "100", "30"))
  expect_equal(orbis:::.fmt_num(1.50), "1.5")
  expect_equal(orbis:::.fmt_num(12000), "12k")
})
