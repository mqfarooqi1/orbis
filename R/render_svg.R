## Render a scene to a standalone SVG string, optionally with embedded
## JavaScript providing tooltips, hover highlighting, zoom, pan and legend
## toggling. No external JavaScript library is used.

#' @keywords internal
#' @noRd
.attr_alpha <- function(a) if (is.null(a) || is.na(a) || a >= 1) "" else
  paste0(" opacity=\"", .r2(a), "\"")

#' @keywords internal
#' @noRd
.path_d <- function(xs, ys, closed, smooth = FALSE) {
  n <- length(xs)
  if (n < 2) return("")
  if (!smooth || n < 3) {
    d <- paste0("M", .r2(xs[1]), " ", .r2(ys[1]), " L",
                paste(.r2(xs[-1]), .r2(ys[-1]), sep = " ", collapse = " L"))
  } else {
    # Catmull-Rom converted to cubic Bezier
    seg <- character(n - 1)
    for (i in seq_len(n - 1)) {
      p0x <- xs[max(i - 1, 1)]; p0y <- ys[max(i - 1, 1)]
      p1x <- xs[i];             p1y <- ys[i]
      p2x <- xs[i + 1];         p2y <- ys[i + 1]
      p3x <- xs[min(i + 2, n)]; p3y <- ys[min(i + 2, n)]
      c1x <- p1x + (p2x - p0x) / 6; c1y <- p1y + (p2y - p0y) / 6
      c2x <- p2x - (p3x - p1x) / 6; c2y <- p2y - (p3y - p1y) / 6
      seg[i] <- paste0("C", .r2(c1x), " ", .r2(c1y), " ", .r2(c2x), " ",
                       .r2(c2y), " ", .r2(p2x), " ", .r2(p2y))
    }
    d <- paste0("M", .r2(xs[1]), " ", .r2(ys[1]), " ", paste(seg, collapse = " "))
  }
  if (closed) d <- paste0(d, " Z")
  d
}

#' @keywords internal
#' @noRd
.svg_mark <- function(m) {
  cls <- paste0(" class=\"o-", m$layer %||% "data", "\"")
  ser <- if (!is.null(m$series) && !is.na(m$series))
    paste0(" data-series=\"", .xml_escape(m$series), "\"") else ""
  key <- if (!is.null(m$key)) paste0(" data-key=\"", .xml_escape(m$key), "\"") else ""
  tip <- if (!is.null(m$tooltip) && !is.na(m$tooltip))
    paste0(" data-tip=\"", .xml_escape(m$tooltip), "\"") else ""
  al <- .attr_alpha(m$alpha)

  if (m$type == "rect") {
    st <- if (is.null(m$stroke) || is.na(m$stroke)) "" else
      paste0(" stroke=\"", m$stroke, "\" stroke-width=\"", .r2(m$sw %||% 1), "\"")
    rx <- if (!is.null(m$r)) paste0(" rx=\"", .r2(m$r), "\"") else ""
    paste0("<rect x=\"", .r2(m$x), "\" y=\"", .r2(m$y), "\" width=\"",
           .r2(max(m$w, 0)), "\" height=\"", .r2(max(m$h, 0)), "\" fill=\"",
           m$fill %||% "none", "\"", rx, st, al, cls, ser, key, tip, "/>")
  } else if (m$type == "circle") {
    st <- if (is.null(m$stroke) || is.na(m$stroke)) "" else
      paste0(" stroke=\"", m$stroke, "\" stroke-width=\"", .r2(m$sw %||% 1), "\"")
    paste0("<circle cx=\"", .r2(m$x), "\" cy=\"", .r2(m$y), "\" r=\"",
           .r2(m$r), "\" fill=\"", m$fill %||% "none", "\"", st, al, cls,
           ser, key, tip, "/>")
  } else if (m$type == "line") {
    paste0("<line x1=\"", .r2(m$x1), "\" y1=\"", .r2(m$y1), "\" x2=\"",
           .r2(m$x2), "\" y2=\"", .r2(m$y2), "\" stroke=\"", m$stroke,
           "\" stroke-width=\"", .r2(m$sw %||% 1), "\"", al, cls, "/>")
  } else if (m$type == "path") {
    d <- .path_d(m$xs, m$ys, isTRUE(m$closed), isTRUE(m$smooth))
    if (!nzchar(d)) return("")
    st <- if (is.null(m$stroke) || is.na(m$stroke)) " stroke=\"none\"" else
      paste0(" stroke=\"", m$stroke, "\" stroke-width=\"", .r2(m$sw %||% 1),
             "\" stroke-linejoin=\"round\" stroke-linecap=\"round\"")
    paste0("<path d=\"", d, "\" fill=\"",
           if (is.null(m$fill) || is.na(m$fill)) "none" else m$fill, "\"",
           st, al, cls, ser, key, tip, "/>")
  } else if (m$type == "text") {
    tr <- if (!is.null(m$rotate))
      paste0(" transform=\"rotate(", m$rotate, " ", .r2(m$x), " ", .r2(m$y), ")\"")
      else ""
    wt <- if (!is.null(m$weight)) paste0(" font-weight=\"", m$weight, "\"") else ""
    paste0("<text x=\"", .r2(m$x), "\" y=\"", .r2(m$y), "\" font-size=\"",
           .r2(m$size), "\" fill=\"", m$fill, "\" text-anchor=\"",
           m$anchor %||% "start", "\"", wt, tr, al, cls, key,
           ">", .xml_escape(m$text), "</text>")
  } else ""
}

#' @keywords internal
#' @noRd
.svg_js <- function(id) {
  sprintf('
(function(){
  var root=document.getElementById("%s"); if(!root) return;
  var svg=root.querySelector("svg"), tip=root.querySelector(".o-tip");
  var g=svg.querySelector(".o-zoom"), st={k:1,x:0,y:0}, drag=null;
  function apply(){ g.setAttribute("transform","translate("+st.x+","+st.y+") scale("+st.k+")"); }
  svg.addEventListener("mousemove",function(e){
    var t=e.target, d=t.getAttribute&&t.getAttribute("data-tip");
    if(d){ var r=root.getBoundingClientRect();
      tip.style.display="block";
      tip.style.left=(e.clientX-r.left+14)+"px";
      tip.style.top=(e.clientY-r.top+12)+"px";
      tip.textContent=d; t.style.filter="brightness(1.15)";
    } else { tip.style.display="none"; }
    if(drag){ st.x=e.clientX-drag.x; st.y=e.clientY-drag.y; apply(); }
  });
  svg.addEventListener("mouseout",function(e){
    if(e.target.style) e.target.style.filter="";
    tip.style.display="none";
  });
  svg.addEventListener("mousedown",function(e){ drag={x:e.clientX-st.x,y:e.clientY-st.y}; svg.style.cursor="grabbing"; });
  window.addEventListener("mouseup",function(){ drag=null; svg.style.cursor="grab"; });
  svg.addEventListener("wheel",function(e){
    e.preventDefault();
    var r=svg.getBoundingClientRect(), mx=e.clientX-r.left, my=e.clientY-r.top;
    var f=e.deltaY<0?1.12:1/1.12, k2=Math.min(24,Math.max(1,st.k*f));
    st.x=mx-(mx-st.x)*(k2/st.k); st.y=my-(my-st.y)*(k2/st.k); st.k=k2;
    if(st.k===1){ st.x=0; st.y=0; }
    apply();
  },{passive:false});
  svg.addEventListener("dblclick",function(){ st={k:1,x:0,y:0}; apply(); });
  root.querySelectorAll("[data-key]").forEach(function(el){
    el.style.cursor="pointer";
    el.addEventListener("click",function(){
      var k=el.getAttribute("data-key"), off=el.getAttribute("data-off")==="1";
      root.querySelectorAll(\'[data-key="\'+k+\'"]\').forEach(function(e2){
        e2.setAttribute("data-off", off?"0":"1");
        e2.style.opacity = off?"":"0.25";
      });
      root.querySelectorAll(\'[data-series="\'+k+\'"]\').forEach(function(e2){
        e2.style.display = off?"":"none";
      });
    });
  });
})();', id)
}

#' Render a plot as SVG
#'
#' Produces a standalone SVG image of a plot. SVG is a vector format, so the
#' result is resolution independent: it stays sharp at any size or zoom level,
#' which is what makes it suitable both for the web and for print.
#'
#' @param plot An `orb_spec` object.
#' @param width,height Size in pixels.
#' @param interactive Embed JavaScript for tooltips, hover highlighting, zoom,
#'   pan and legend toggling. Set `FALSE` for a static image, for example when
#'   embedding in a document that forbids scripts.
#' @param id Element id used by the embedded script; generated if `NULL`.
#' @return A character string containing SVG (and, if requested, a wrapping
#'   `div` with the script).
#' @seealso [orb_save()], [orb_interactive()]
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg) + orb_points()
#' s <- orb_svg(p, interactive = FALSE)
#' substr(s, 1, 40)
#' @export
orb_svg <- function(plot, width = 820, height = 520, interactive = TRUE,
                    id = NULL) {
  if (!inherits(plot, "orb_spec")) .stop("`plot` must be an orb_spec object.")
  sc <- .build(plot, width, height)
  interactive <- interactive && sc$interactive
  th <- sc$theme
  body <- vapply(sc$marks, .svg_mark, character(1))
  is_data <- vapply(sc$marks, function(m)
    identical(m$layer, "data") || identical(m$layer, "grid"), logical(1))

  pan <- sc$panel
  clip <- paste0("<clipPath id=\"", id %||% "orbclip",
                 "-c\"><rect x=\"", .r2(pan[1]), "\" y=\"", .r2(pan[2]),
                 "\" width=\"", .r2(pan[3] - pan[1]), "\" height=\"",
                 .r2(pan[4] - pan[2]), "\"/></clipPath>")

  svg <- paste0(
    "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ", width, " ",
    height, "\" width=\"100%\" style=\"max-width:", width,
    "px;height:auto;font-family:", th$font, ";cursor:grab;\">",
    "<defs>", clip, "</defs>",
    paste(body[!is_data], collapse = ""),
    "<g class=\"o-zoom\" clip-path=\"url(#", id %||% "orbclip", "-c)\">",
    paste(body[is_data], collapse = ""),
    "</g></svg>")

  if (!interactive) return(svg)
  wid <- id %||% paste0("orbis-", paste(sample(c(letters, 0:9), 8, TRUE),
                                        collapse = ""))
  paste0(
    "<div id=\"", wid, "\" style=\"position:relative;display:inline-block;",
    "max-width:100%;\">", svg,
    "<div class=\"o-tip\" style=\"position:absolute;display:none;",
    "pointer-events:none;background:", th$title, ";color:", th$bg,
    ";padding:4px 8px;border-radius:4px;font:12px ", th$font,
    ";white-space:nowrap;z-index:9;box-shadow:0 2px 8px rgba(0,0,0,.25)\">",
    "</div><script>", .svg_js(wid), "</script></div>")
}
