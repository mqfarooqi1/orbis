## Extract + simplify a world polygon dataset for the orbis package.
## Source: maps::world, whose polygons derive from Natural Earth (public domain).
suppressMessages(library(maps))

m <- maps::map("world", plot = FALSE, fill = TRUE)

# Douglas-Peucker simplification (base R, no deps)
dp <- function(x, y, tol) {
  n <- length(x)
  if (n < 3) return(rep(TRUE, n))
  keep <- rep(FALSE, n); keep[1] <- TRUE; keep[n] <- TRUE
  stack <- list(c(1L, n))
  while (length(stack)) {
    seg <- stack[[length(stack)]]; stack[[length(stack)]] <- NULL
    i <- seg[1]; j <- seg[2]
    if (j <= i + 1) next
    idx <- (i + 1):(j - 1)
    dx <- x[j] - x[i]; dy <- y[j] - y[i]
    den <- sqrt(dx^2 + dy^2)
    d <- if (den == 0) sqrt((x[idx] - x[i])^2 + (y[idx] - y[i])^2)
         else abs(dy * x[idx] - dx * y[idx] + x[j] * y[i] - y[j] * x[i]) / den
    k <- which.max(d)
    if (d[k] > tol) {
      p <- idx[k]; keep[p] <- TRUE
      stack[[length(stack) + 1]] <- c(i, p)
      stack[[length(stack) + 1]] <- c(p, j)
    }
  }
  keep
}

# split at NA separators into individual rings
na_idx <- which(is.na(m$x))
starts <- c(1, na_idx + 1)
ends   <- c(na_idx - 1, length(m$x))
ok <- starts <= ends
starts <- starts[ok]; ends <- ends[ok]

# region name per ring (maps orders names to match ring order)
names_all <- m$names
tol <- 0.06  # degrees (high detail; dataset stays small)

xs <- list(); ys <- list(); reg <- character(); grp <- integer()
g <- 0L
for (i in seq_along(starts)) {
  ii <- starts[i]:ends[i]
  if (length(ii) < 4) next
  x <- m$x[ii]; y <- m$y[ii]
  k <- dp(x, y, tol)
  if (sum(k) < 4) next
  g <- g + 1L
  xs[[g]] <- round(x[k], 4)
  ys[[g]] <- round(y[k], 4)
  nm <- if (i <= length(names_all)) names_all[i] else NA_character_
  reg[g] <- sub(":.*$", "", nm)
  grp[g] <- g
}

## Some source rings (Russia's Chukotka, Fiji) run past +180 instead of being
## split at the antimeridian; left alone they would stretch a polygon across
## the whole map. Wrap those vertices to the western hemisphere and give them
## their own ring so each piece is drawn where it belongs.
X2 <- list(); Y2 <- list(); R2 <- character(); G2 <- integer(); gg <- 0L
for (i in seq_along(xs)) {
  x <- xs[[i]]; y <- ys[[i]]
  over <- x > 180
  if (!any(over)) {
    gg <- gg + 1L
    X2[[gg]] <- x; Y2[[gg]] <- y; R2[gg] <- reg[i]; G2[gg] <- gg
  } else {
    if (sum(!over) >= 4) {
      gg <- gg + 1L
      X2[[gg]] <- x[!over]; Y2[[gg]] <- y[!over]; R2[gg] <- reg[i]; G2[gg] <- gg
    }
    if (sum(over) >= 4) {
      gg <- gg + 1L
      X2[[gg]] <- x[over] - 360; Y2[[gg]] <- y[over]
      R2[gg] <- reg[i]; G2[gg] <- gg
    }
  }
}
xs <- X2; ys <- Y2; reg <- R2; grp <- G2

world_map <- data.frame(
  long   = unlist(xs),
  lat    = unlist(ys),
  group  = rep(grp, lengths(xs)),
  region = rep(reg, lengths(xs)),
  stringsAsFactors = FALSE
)
stopifnot(all(world_map$long >= -180 & world_map$long <= 180))

cat("rings:", g, " points:", nrow(world_map),
    " regions:", length(unique(world_map$region)), "\n")

dir.create("data", showWarnings = FALSE)
save(world_map, file = "data/world_map.rda", compress = "xz")
cat("size KB:", round(file.size("data/world_map.rda") / 1024, 1), "\n")
