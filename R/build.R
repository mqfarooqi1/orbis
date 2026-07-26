## Compile an orb_spec into a scene: a flat list of drawing primitives in
## device (pixel) coordinates, plus the metadata renderers need.

#' @keywords internal
#' @noRd
.mk <- function(type, ...) c(list(type = type), list(...))

#' @keywords internal
#' @noRd
.layer_frame <- function(spec, layer) {
  dat <- layer$data %||% spec$data
  map <- utils::modifyList(spec$mapping, layer$mapping)
  vals <- list()
  for (nm in names(map)) {
    v <- try(eval(map[[nm]], dat, baseenv()), silent = TRUE)
    if (inherits(v, "try-error") || is.null(v)) {
      .stop("Cannot find `", deparse(map[[nm]]), "` in the data for the ",
            layer$geom, " layer.")
    }
    vals[[nm]] <- v
  }
  if (length(vals) == 0) return(data.frame())
  n <- max(lengths(vals))
  vals <- lapply(vals, function(v) rep(v, length.out = n))
  as.data.frame(vals, stringsAsFactors = FALSE)
}

#' @keywords internal
#' @noRd
.is_discrete <- function(v) is.character(v) || is.factor(v) || is.logical(v)

## Resolve a colour channel to per-observation colours + a legend description.
#' @keywords internal
#' @noRd
.resolve_colour <- function(v, sc, default, palette_default = "viridis") {
  if (is.null(v)) return(list(cols = default, legend = NULL))
  pal <- sc$palette %||% palette_default
  if (.is_discrete(v)) {
    f <- factor(v)
    lv <- levels(f)
    cols <- .discrete_cols(length(lv),
                           if (is.character(pal) && length(pal) == 1 &&
                               pal %in% names(.pal_discrete)) pal
                           else if (length(pal) > 1) pal else "orbis")
    if (isTRUE(sc$reverse)) cols <- rev(cols)
    list(cols = cols[as.integer(f)],
         legend = list(type = "discrete", levels = lv, colours = cols))
  } else {
    v <- as.numeric(v)
    lim <- sc$limits %||% range(v, na.rm = TRUE, finite = TRUE)
    if (!is.finite(lim[1]) || lim[1] == lim[2]) lim <- lim[1] + c(-0.5, 0.5)
    at <- (v - lim[1]) / (lim[2] - lim[1])
    if (isTRUE(sc$reverse)) at <- 1 - at
    list(cols = .ramp(pal, at = at),
         legend = list(type = "continuous", limits = lim, palette = pal,
                       reverse = isTRUE(sc$reverse)))
  }
}

#' @keywords internal
#' @noRd
.resolve_size <- function(v, sc, default) {
  if (is.null(v)) return(list(sizes = default, legend = NULL))
  v <- as.numeric(v)
  rg <- sc$range %||% c(2, 14)
  lim <- sc$limits %||% range(v, na.rm = TRUE, finite = TRUE)
  if (!is.finite(lim[1]) || lim[1] == lim[2]) {
    return(list(sizes = rep(mean(rg), length(v)), legend = NULL))
  }
  t <- (v - lim[1]) / (lim[2] - lim[1])
  # area-proportional: perceptually correct for bubbles
  r <- sqrt(rg[1]^2 + t * (rg[2]^2 - rg[1]^2))
  list(sizes = r, legend = list(type = "size", limits = lim, range = rg))
}

#' @keywords internal
#' @noRd
.build <- function(spec, width = 820, height = 520) {
  th <- spec$theme
  bs <- th$base_size
  opts <- spec$opts
  is_geo <- identical(spec$coord$type, "map")
  coord <- spec$coord

  ## ---- gather layer data -------------------------------------------------
  L <- list()
  for (i in seq_along(spec$layers)) {
    lay <- spec$layers[[i]]
    if (lay$geom == "map") {
      md <- lay$data %||% orbis::world_map
      if (!all(c("long", "lat", "group") %in% names(md))) {
        .stop("A map layer needs columns `long`, `lat` and `group`.")
      }
      L[[i]] <- list(layer = lay, df = md, geo = TRUE)
    } else {
      L[[i]] <- list(layer = lay, df = .layer_frame(spec, lay),
                     geo = lay$geom == "geo_points" || is_geo)
    }
  }

  ## ---- discrete x handling ----------------------------------------------
  x_levels <- NULL
  for (l in L) {
    if (!is.null(l$df$x) && .is_discrete(l$df$x)) {
      x_levels <- union(x_levels, levels(factor(l$df$x)))
    }
  }

  ## ---- compute x/y ranges ------------------------------------------------
  xs_all <- numeric(0); ys_all <- numeric(0)
  sx <- spec$scales$x; sy <- spec$scales$y
  for (i in seq_along(L)) {
    d <- L[[i]]$df
    if (L[[i]]$layer$geom == "map") {
      pr <- .project(d$long, d$lat, coord)
      keep <- pr$visible
      L[[i]]$px <- pr$x; L[[i]]$py <- pr$y; L[[i]]$vis <- keep
      xs_all <- c(xs_all, range(pr$x[keep], na.rm = TRUE))
      ys_all <- c(ys_all, range(pr$y[keep], na.rm = TRUE))
    } else if (nrow(d) > 0) {
      xv <- d$x; yv <- d$y
      if (!is.null(xv) && L[[i]]$geo && is_geo) {
        pr <- .project(as.numeric(xv), as.numeric(yv), coord)
        L[[i]]$px <- pr$x; L[[i]]$py <- pr$y; L[[i]]$vis <- pr$visible
        xs_all <- c(xs_all, range(pr$x[pr$visible], na.rm = TRUE))
        ys_all <- c(ys_all, range(pr$y[pr$visible], na.rm = TRUE))
      } else {
        if (!is.null(xv)) {
          xn <- if (.is_discrete(xv)) match(as.character(xv), x_levels)
                else .apply_trans(as.numeric(xv), sx$trans)
          L[[i]]$px <- xn
          xs_all <- c(xs_all, range(xn, na.rm = TRUE, finite = TRUE))
        }
        if (!is.null(yv)) {
          yn <- .apply_trans(as.numeric(yv), sy$trans)
          L[[i]]$py <- yn
          ys_all <- c(ys_all, range(yn, na.rm = TRUE, finite = TRUE))
          if (L[[i]]$layer$geom %in% c("bars", "area")) {
            ys_all <- c(ys_all, L[[i]]$layer$params$baseline %||% 0)
          }
        }
      }
    }
  }
  xs_all <- xs_all[is.finite(xs_all)]; ys_all <- ys_all[is.finite(ys_all)]
  if (!length(xs_all)) xs_all <- c(0, 1)
  if (!length(ys_all)) ys_all <- c(0, 1)
  xlim <- sx$limits %||% range(xs_all)
  ylim <- sy$limits %||% range(ys_all)
  if (!is.null(x_levels)) xlim <- c(0.5, length(x_levels) + 0.5)
  if (xlim[1] == xlim[2]) xlim <- xlim + c(-0.5, 0.5)
  if (ylim[1] == ylim[2]) ylim <- ylim + c(-0.5, 0.5)
  ex <- if (is.null(x_levels)) (sx$expand %||% 0.04) else 0
  ey <- sy$expand %||% 0.04
  if (is_geo) { ex <- 0.01; ey <- 0.01 }
  xlim <- xlim + c(-1, 1) * diff(xlim) * ex
  ylim <- ylim + c(-1, 1) * diff(ylim) * ey

  ## ---- legend requirements ----------------------------------------------
  legend <- NULL; legend_title <- NULL
  for (i in seq_along(L)) {
    d <- L[[i]]$df
    lay <- L[[i]]$layer
    if (lay$geom == "map" && !is.null(lay$params$value_col)) {
      vv <- lay$params$values[[lay$params$value_col]]
      legend <- list(type = "continuous",
                     limits = range(vv, na.rm = TRUE),
                     palette = lay$params$palette, reverse = FALSE)
      legend_title <- spec$labs$fill %||% lay$params$value_col
      next
    }
    ch <- if (!is.null(d$colour)) "colour" else if (!is.null(d$fill)) "fill" else NULL
    if (!is.null(ch) && is.null(legend)) {
      r <- .resolve_colour(d[[ch]], spec$scales[[ch]], NULL)
      legend <- r$legend
      legend_title <- spec$labs[[ch]] %||% deparse(
        utils::modifyList(spec$mapping, lay$mapping)[[ch]])
    }
    if (is.null(legend) && !is.null(d$size)) {
      r <- .resolve_size(d$size, spec$scales$size, 4)
      legend <- r$legend
      legend_title <- spec$labs$size %||% deparse(
        utils::modifyList(spec$mapping, lay$mapping)$size)
    }
  }
  show_legend <- !is.null(legend) && !identical(opts$legend, FALSE)

  ## ---- layout ------------------------------------------------------------
  has_title <- !is.null(spec$labs$title)
  has_sub <- !is.null(spec$labs$subtitle)
  has_cap <- !is.null(spec$labs$caption)
  top <- 14 + (if (has_title) bs * 1.9 else 0) + (if (has_sub) bs * 1.5 else 0)
  bottom <- 16 + (if (is_geo) 0 else bs * 2.4) +
    (if (!is.null(spec$labs$x)) bs * 1.6 else 0) + (if (has_cap) bs * 1.6 else 0)

  ybr <- if (is_geo) numeric(0) else
    (sy$breaks %||% .breaks(ylim[1], ylim[2], 6))
  ylab_txt <- if (length(ybr))
    .fmt_num(.invert_trans(ybr, sy$trans)) else character(0)
  left <- 14 + (if (is_geo) 0 else
    max(c(24, .text_w(ylab_txt, bs * 0.85) + 10))) +
    (if (!is.null(spec$labs$y)) bs * 1.6 else 0)

  legend_w <- 0
  if (show_legend) {
    if (legend$type == "discrete") {
      legend_w <- max(60, max(.text_w(legend$levels, bs * 0.85)) + 34)
    } else {
      legend_w <- max(64, max(.text_w(.fmt_num(legend$limits), bs * 0.8)) + 40)
    }
    ## the legend title sits above the keys and must also fit
    if (!is.null(legend_title) && nzchar(legend_title)) {
      legend_w <- max(legend_w, .text_w(legend_title, bs * 0.9) + 8)
    }
    legend_w <- min(legend_w, width * 0.34)
  }
  right <- 16 + legend_w

  px0 <- left; px1 <- width - right
  py0 <- top;  py1 <- height - bottom
  if (px1 - px0 < 40) px1 <- px0 + 40
  if (py1 - py0 < 40) py1 <- py0 + 40

  ## preserve aspect for maps so the world is not stretched
  if (is_geo || !is.null(spec$coord$ratio)) {
    ratio <- spec$coord$ratio %||% 1
    dx <- diff(xlim); dy <- diff(ylim)
    avail_w <- px1 - px0; avail_h <- py1 - py0
    sc <- min(avail_w / dx, avail_h / (dy * ratio))
    w_used <- dx * sc; h_used <- dy * ratio * sc
    cx <- (px0 + px1) / 2; cy <- (py0 + py1) / 2
    px0 <- cx - w_used / 2; px1 <- cx + w_used / 2
    py0 <- cy - h_used / 2; py1 <- cy + h_used / 2
  }

  X <- function(v) px0 + (v - xlim[1]) / (xlim[2] - xlim[1]) * (px1 - px0)
  Y <- function(v) py1 - (v - ylim[1]) / (ylim[2] - ylim[1]) * (py1 - py0)

  marks <- list()
  add <- function(m) marks[[length(marks) + 1L]] <<- m

  ## ---- background, grid, axes -------------------------------------------
  add(.mk("rect", x = 0, y = 0, w = width, h = height, fill = th$bg,
          stroke = NA, layer = "bg"))
  add(.mk("rect", x = px0, y = py0, w = px1 - px0, h = py1 - py0,
          fill = th$panel, stroke = NA, layer = "bg"))

  gridmode <- opts$grid %||% (if (is_geo) "none" else "both")
  xbr <- if (!is.null(x_levels)) seq_along(x_levels) else
    if (is_geo) numeric(0) else (sx$breaks %||% .breaks(xlim[1], xlim[2], 7))
  xlab_txt <- if (!is.null(x_levels)) x_levels else
    if (length(xbr)) .fmt_num(.invert_trans(xbr, sx$trans)) else character(0)

  if (gridmode %in% c("both", "y")) {
    for (b in ybr) add(.mk("line", x1 = px0, y1 = Y(b), x2 = px1, y2 = Y(b),
                           stroke = th$grid, sw = 1, layer = "grid"))
  }
  if (gridmode %in% c("both", "x") && is.null(x_levels)) {
    for (b in xbr) add(.mk("line", x1 = X(b), y1 = py0, x2 = X(b), y2 = py1,
                           stroke = th$grid, sw = 1, layer = "grid"))
  }
  if (!is_geo) {
    for (i in seq_along(ybr)) {
      add(.mk("text", x = px0 - 8, y = Y(ybr[i]) + bs * 0.32, text = ylab_txt[i],
              size = bs * 0.85, fill = th$axis, anchor = "end", layer = "axis"))
    }
    for (i in seq_along(xbr)) {
      add(.mk("text", x = X(xbr[i]), y = py1 + bs * 1.4, text = xlab_txt[i],
              size = bs * 0.85, fill = th$axis, anchor = "middle", layer = "axis"))
    }
    add(.mk("line", x1 = px0, y1 = py1, x2 = px1, y2 = py1,
            stroke = th$axis, sw = 1, layer = "axis"))
  }

  ## ---- data layers -------------------------------------------------------
  for (i in seq_along(L)) {
    lay <- L[[i]]$layer; d <- L[[i]]$df; pm <- lay$params
    geom <- lay$geom

    if (geom == "map") {
      vals <- pm$values
      fillmap <- NULL
      if (!is.null(vals) && !is.null(pm$value_col)) {
        key <- as.character(vals[[pm$region_col]])
        num <- as.numeric(vals[[pm$value_col]])
        lim <- range(num, na.rm = TRUE)
        if (!is.finite(lim[1]) || lim[1] == lim[2]) lim <- lim[1] + c(-.5, .5)
        cols <- .ramp(pm$palette, at = (num - lim[1]) / (lim[2] - lim[1]))
        fillmap <- stats::setNames(cols, key)
        valmap <- stats::setNames(num, key)
      }
      gsplit <- split(seq_len(nrow(d)), d$group)
      globe <- identical(coord$projection, "orthographic")
      if (!is.null(pm$ocean)) {
        ## sea behind the land: a disc for the globe, the panel otherwise
        if (globe) {
          ang <- seq(0, 2 * pi, length.out = 181)
          add(.mk("path", xs = X(.globe_r * cos(ang)), ys = Y(.globe_r * sin(ang)),
                  fill = pm$ocean, stroke = NA, sw = 0, closed = TRUE,
                  layer = "data", tooltip = NA))
        } else {
          add(.mk("rect", x = px0, y = py0, w = px1 - px0, h = py1 - py0,
                  fill = pm$ocean, stroke = NA, layer = "data"))
        }
      }
      for (g in gsplit) {
        if (!any(L[[i]]$vis[g])) next
        gx <- L[[i]]$px[g]; gy <- L[[i]]$py[g]
        vv <- L[[i]]$vis[g]
        if (globe) {
          ## On a globe a ring may straddle the horizon. Dropping the hidden
          ## vertices would break the ring and leave slivers, so instead push
          ## them radially onto the limb: the polygon then hugs the horizon.
          if (any(!vv)) {
            rr <- sqrt(gx^2 + gy^2); rr[rr < 1e-9] <- 1e-9
            f <- ifelse(vv, 1, .globe_r / rr)
            gx <- gx * f; gy <- gy * f
          }
        } else {
          gx <- gx[vv]; gy <- gy[vv]
        }
        if (length(gx) < 3) next
        reg <- if (!is.null(d$region)) as.character(d$region[g[1]]) else NA
        fl <- pm$fill
        tip <- reg
        if (!is.null(fillmap)) {
          fl <- if (!is.na(reg) && reg %in% names(fillmap)) fillmap[[reg]]
                else pm$na_fill
          if (!is.na(reg) && reg %in% names(valmap)) {
            tip <- paste0(reg, ": ", .fmt_num(valmap[[reg]]))
          }
        }
        add(.mk("path", xs = X(gx), ys = Y(gy), fill = fl, stroke = pm$colour,
                sw = pm$width, alpha = pm$alpha, closed = TRUE,
                tooltip = tip, layer = "data", series = reg))
      }
      next
    }

    if (nrow(d) == 0) next
    xv <- L[[i]]$px; yv <- L[[i]]$py
    vis <- L[[i]]$vis %||% rep(TRUE, length(xv))
    ch <- if (!is.null(d$colour)) "colour" else if (!is.null(d$fill)) "fill" else NULL
    defcol <- pm$colour %||% pm$fill %||% th$accent
    rc <- .resolve_colour(if (!is.null(ch)) d[[ch]] else NULL,
                          spec$scales[[ch %||% "colour"]], defcol)
    cols <- rep(rc$cols, length.out = nrow(d))
    series <- if (!is.null(ch) && .is_discrete(d[[ch]]))
      as.character(d[[ch]]) else rep(NA_character_, nrow(d))
    tips <- if (!is.null(d$tooltip)) as.character(d$tooltip) else {
      lbl <- if (!is.null(d$label)) paste0(as.character(d$label), " | ") else ""
      paste0(lbl, .fmt_num(as.numeric(if (is.numeric(d$x)) d$x else xv)), ", ",
             .fmt_num(as.numeric(d$y %||% yv)))
    }

    if (geom %in% c("points", "geo_points")) {
      rs <- .resolve_size(d$size, spec$scales$size, pm$size)
      radii <- rep(rs$sizes, length.out = nrow(d))
      ok <- which(is.finite(xv) & is.finite(yv) & vis)
      for (k in ok) {
        add(.mk("circle", x = X(xv[k]), y = Y(yv[k]), r = radii[k],
                fill = cols[k], stroke = th$panel, sw = pm$stroke,
                alpha = pm$alpha, tooltip = tips[k], layer = "data",
                series = series[k]))
      }
    } else if (geom == "line") {
      gvar <- d$group %||% (if (!is.null(ch)) d[[ch]] else NULL)
      idx <- if (is.null(gvar)) list(seq_len(nrow(d))) else
        split(seq_len(nrow(d)), gvar)
      for (g in idx) {
        g <- g[order(xv[g])]
        g <- g[is.finite(xv[g]) & is.finite(yv[g])]
        if (length(g) < 2) next
        add(.mk("path", xs = X(xv[g]), ys = Y(yv[g]), fill = NA,
                stroke = cols[g[1]], sw = pm$width, alpha = pm$alpha,
                closed = FALSE, smooth = isTRUE(pm$smooth), layer = "data",
                series = series[g[1]], tooltip = NA))
      }
    } else if (geom == "area") {
      base <- Y(pm$baseline %||% 0)
      gvar <- d$group %||% (if (!is.null(ch)) d[[ch]] else NULL)
      idx <- if (is.null(gvar)) list(seq_len(nrow(d))) else
        split(seq_len(nrow(d)), gvar)
      for (g in idx) {
        g <- g[order(xv[g])]
        g <- g[is.finite(xv[g]) & is.finite(yv[g])]
        if (length(g) < 2) next
        ax <- c(X(xv[g]), rev(X(xv[g])))
        ay <- c(Y(yv[g]), rep(base, length(g)))
        add(.mk("path", xs = ax, ys = ay, fill = pm$fill %||% cols[g[1]],
                stroke = NA, sw = 0, alpha = pm$alpha, closed = TRUE,
                smooth = isTRUE(pm$smooth), layer = "data",
                series = series[g[1]], tooltip = NA))
      }
    } else if (geom == "bars") {
      slot <- if (!is.null(x_levels)) 1 else
        (if (length(unique(xv)) > 1) min(diff(sort(unique(xv)))) else 1)
      bw <- abs(X(xlim[1] + slot) - X(xlim[1])) * pm$width
      base <- Y(pm$baseline %||% 0)
      for (k in seq_len(nrow(d))) {
        if (!is.finite(xv[k]) || !is.finite(yv[k])) next
        yy <- Y(yv[k])
        add(.mk("rect", x = X(xv[k]) - bw / 2, y = min(yy, base), w = bw,
                h = abs(base - yy), fill = pm$fill %||% cols[k],
                stroke = pm$colour %||% NA, sw = 0.6, alpha = pm$alpha,
                tooltip = tips[k], layer = "data", series = series[k], r = 2))
      }
    } else if (geom == "text") {
      lbl <- as.character(d$label %||% d$y)
      for (k in seq_len(nrow(d))) {
        if (!is.finite(xv[k]) || !is.finite(yv[k])) next
        add(.mk("text", x = X(xv[k]), y = Y(yv[k]) + pm$dy, text = lbl[k],
                size = pm$size, fill = pm$colour %||% cols[k],
                anchor = "middle", alpha = pm$alpha, layer = "data"))
      }
    }
  }

  ## ---- titles ------------------------------------------------------------
  ty <- 10 + bs * 1.35
  if (has_title) {
    add(.mk("text", x = 14, y = ty, text = spec$labs$title, size = bs * 1.45,
            fill = th$title, anchor = "start", weight = "600", layer = "anno"))
    ty <- ty + bs * 1.45
  }
  if (has_sub) {
    add(.mk("text", x = 14, y = ty, text = spec$labs$subtitle, size = bs,
            fill = th$text, anchor = "start", layer = "anno"))
  }
  if (!is.null(spec$labs$x)) {
    add(.mk("text", x = (px0 + px1) / 2,
            y = height - 12 - (if (has_cap) bs * 1.6 else 0),
            text = spec$labs$x, size = bs, fill = th$text, anchor = "middle",
            layer = "anno"))
  }
  if (!is.null(spec$labs$y)) {
    add(.mk("text", x = 14, y = (py0 + py1) / 2, text = spec$labs$y,
            size = bs, fill = th$text, anchor = "middle", rotate = -90,
            layer = "anno"))
  }
  if (has_cap) {
    add(.mk("text", x = width - 12, y = height - 10, text = spec$labs$caption,
            size = bs * 0.8, fill = th$axis, anchor = "end", layer = "anno"))
  }

  ## ---- legend ------------------------------------------------------------
  if (show_legend) {
    lx <- px1 + 20
    ly <- py0 + 6
    if (!is.null(legend_title) && nzchar(legend_title)) {
      add(.mk("text", x = lx, y = ly, text = legend_title, size = bs * 0.9,
              fill = th$title, anchor = "start", weight = "600",
              layer = "legend"))
      ly <- ly + bs * 1.5
    }
    if (legend$type == "discrete") {
      for (j in seq_along(legend$levels)) {
        add(.mk("rect", x = lx, y = ly - bs * 0.62, w = bs * 0.85,
                h = bs * 0.85, fill = legend$colours[j], stroke = NA, r = 2,
                layer = "legend", key = legend$levels[j]))
        add(.mk("text", x = lx + bs * 1.25, y = ly, text = legend$levels[j],
                size = bs * 0.85, fill = th$text, anchor = "start",
                layer = "legend", key = legend$levels[j]))
        ly <- ly + bs * 1.5
      }
    } else if (legend$type == "continuous") {
      hgt <- min(160, py1 - ly - 10)
      nstep <- 40
      at <- seq(1, 0, length.out = nstep)
      if (isTRUE(legend$reverse)) at <- rev(at)
      cols <- .ramp(legend$palette, at = at)
      for (j in seq_len(nstep)) {
        add(.mk("rect", x = lx, y = ly + (j - 1) * hgt / nstep,
                w = bs * 1.1, h = hgt / nstep + 0.6, fill = cols[j],
                stroke = NA, layer = "legend"))
      }
      lab <- .fmt_num(legend$limits)
      add(.mk("text", x = lx + bs * 1.5, y = ly + bs * 0.3, text = lab[2],
              size = bs * 0.8, fill = th$text, anchor = "start", layer = "legend"))
      add(.mk("text", x = lx + bs * 1.5, y = ly + hgt, text = lab[1],
              size = bs * 0.8, fill = th$text, anchor = "start", layer = "legend"))
    } else if (legend$type == "size") {
      rr <- legend$range
      lab <- .fmt_num(legend$limits)
      for (j in 1:2) {
        add(.mk("circle", x = lx + rr[2], y = ly + rr[2] + (j - 1) * (rr[2] * 2 + 8),
                r = rr[j], fill = th$accent, stroke = th$panel, sw = 0.8,
                alpha = 0.85, layer = "legend"))
        add(.mk("text", x = lx + rr[2] * 2 + 8,
                y = ly + rr[2] + (j - 1) * (rr[2] * 2 + 8) + bs * 0.32,
                text = lab[j], size = bs * 0.8, fill = th$text,
                anchor = "start", layer = "legend"))
      }
    }
  }

  list(width = width, height = height, marks = marks, theme = th,
       panel = c(px0, py0, px1, py1),
       interactive = !identical(opts$interactive, FALSE))
}
