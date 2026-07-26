suppressMessages(library(orbis))
set.seed(42)
out <- "C:/Users/faroo/Desktop/python_code/orbis/man/figures"
dir.create(out, showWarnings = FALSE, recursive = TRUE)

## 1. scatter
p1 <- orb(mtcars, x = wt, y = mpg, colour = hp, size = disp) +
  orb_points(alpha = .9) +
  orb_labs(title = "Fuel economy", subtitle = "Bubble size = displacement",
           x = "Weight (1000 lbs)", y = "Miles per gallon", colour = "Horsepower")
orb_save(p1, file.path(out, "scatter.png"), dpi = 160)

## 2. choropleth, robinson
set.seed(7)
regs <- unique(orbis::world_map$region)
vals <- data.frame(region = regs, v = round(runif(length(regs), 0, 100)))
p2 <- orb_worldmap(values = vals, value_col = "v", projection = "robinson",
                   palette = "mako") +
  orb_labs(title = "World choropleth", subtitle = "Robinson projection",
           fill = "Index") + orb_theme_light()
orb_save(p2, file.path(out, "choropleth.png"), width = 980, height = 560, dpi = 160)

## 3. orthographic globe, dark
p3 <- orb_worldmap(values = vals, value_col = "v", projection = "orthographic",
                   palette = "ember", ocean = "#0B1F33") +
  orb_coord_map("orthographic", centre = c(25, 20)) +
  orb_labs(title = "Orthographic globe") + orb_theme_dark()
orb_save(p3, file.path(out, "globe.png"), width = 640, height = 640, dpi = 160)

## 4. time series
df <- data.frame(t = 1:120, v = cumsum(rnorm(120, .05)))
p4 <- orb(df, x = t, y = v) + orb_area(alpha = .3) +
  orb_line(width = 2.2, smooth = TRUE) +
  orb_labs(title = "Smoothed series", x = "Day", y = "Value") +
  orb_theme_dark()
orb_save(p4, file.path(out, "series.png"), dpi = 160)

## 5. bars
bd <- data.frame(g = c("alpha","beta","gamma","delta","epsilon"),
                 v = c(23, 41, 17, 35, 29))
p5 <- orb(bd, x = g, y = v, fill = g) + orb_bars() +
  orb_labs(title = "Categories", y = "Count") + orb_theme_ink() +
  orb_options(legend = FALSE, grid = "y")
orb_save(p5, file.path(out, "bars.png"), width = 700, height = 440, dpi = 160)

cat("figures written\n")
