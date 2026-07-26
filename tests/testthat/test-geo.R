test_that("world_map has the expected structure", {
  expect_s3_class(world_map, "data.frame")
  expect_true(all(c("long", "lat", "group", "region") %in% names(world_map)))
  expect_true(all(world_map$long >= -180 & world_map$long <= 180))
  expect_true(all(world_map$lat >= -90 & world_map$lat <= 90))
  expect_gt(length(unique(world_map$region)), 100)
})

test_that("every projection returns finite coordinates", {
  long <- c(-180, -90, 0, 90, 180, 12.5)
  lat <- c(-85, -45, 0, 45, 85, 51.5)
  for (pr in c("equirectangular", "mercator", "robinson", "mollweide",
               "orthographic")) {
    co <- orb_coord_map(pr)
    p <- orbis:::.project(long, lat, co)
    expect_length(p$x, length(long))
    expect_true(all(is.finite(p$x)), info = pr)
    expect_true(all(is.finite(p$y)), info = pr)
  }
})

test_that("Mercator clips extreme latitudes instead of returning infinity", {
  p <- orbis:::.project(c(0, 0), c(89.999, -89.999), orb_coord_map("mercator"))
  expect_true(all(is.finite(p$y)))
})

test_that("the orthographic projection hides the far hemisphere", {
  co <- orb_coord_map("orthographic", centre = c(0, 0))
  p <- orbis:::.project(c(0, 180), c(0, 0), co)
  expect_true(p$visible[1])
  expect_false(p$visible[2])
})

test_that("an unknown projection is rejected", {
  expect_error(orb_coord_map("banana"))
})

test_that("every projection renders a world map", {
  for (pr in c("equirectangular", "mercator", "robinson", "mollweide",
               "orthographic")) {
    s <- orb_svg(orb_worldmap(projection = pr), interactive = FALSE)
    expect_true(grepl("<path", s, fixed = TRUE), info = pr)
    expect_gt(nchar(s), 10000)
  }
})

test_that("a choropleth colours regions and adds tooltips", {
  vals <- data.frame(region = c("Brazil", "India", "France"), v = c(1, 5, 9))
  p <- orb_worldmap(values = vals, value_col = "v")
  s <- orb_svg(p)
  expect_true(grepl("data-tip", s, fixed = TRUE))
  expect_true(grepl("Brazil", s, fixed = TRUE))
})

test_that("a map layer needs the right columns", {
  bad <- data.frame(a = 1, b = 2)
  expect_error(orb_svg(orb(bad) + orb_map(data = bad)), "long")
})

test_that("points can be placed on a map by longitude and latitude", {
  cities <- data.frame(long = c(2.35, 151.2), lat = c(48.86, -33.87),
                       pop = c(11, 5))
  p <- orb(cities, x = long, y = lat, size = pop) + orb_map() +
    orb_geo_points() + orb_coord_map("robinson")
  expect_true(grepl("<circle", orb_svg(p, interactive = FALSE), fixed = TRUE))
})

test_that("an ocean layer is drawn when requested", {
  s1 <- orb_svg(orb_worldmap(), interactive = FALSE)
  s2 <- orb_svg(orb_worldmap(ocean = "#0B1F33"), interactive = FALSE)
  expect_true(grepl("#0B1F33", s2, fixed = TRUE))
  expect_false(grepl("#0B1F33", s1, fixed = TRUE))
})
