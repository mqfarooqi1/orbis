## Submission

This is a new submission: orbis 0.1.0.

orbis is a layered grammar of graphics that compiles a plot to a
resolution-independent scene description and renders it through two back-ends:
a self-contained SVG writer with embedded JavaScript for interactive figures,
and R's own graphics devices for output at any resolution. Geographic layers
and a simplified world polygon dataset ship with the package, with six map
projections.

The package imports only base R packages (grDevices, grid, stats, utils) plus
htmltools, and contains no compiled code.

## R CMD check results

Local `R CMD check --as-cran` (Windows 11, R 4.5.2):
0 errors | 0 warnings | 1 note.

* The note is the standard "New submission".
* The only WARNING seen locally is `'qpdf' is needed for checks on size
  reduction of PDFs`, which is an artefact of qpdf not being installed on the
  local machine; it does not occur on systems that have qpdf.

GitHub Actions `R-CMD-check` passes on all five configurations: Ubuntu
(release, devel and oldrel-1), Windows (release) and macOS (release).

## Notes for the reviewer

* Single quotes in the Description are used only for software names
  ('JavaScript'); file formats such as SVG are not quoted.
* All method references in the Description are given in the
  `authors (year) <doi:...>` form with no space after `doi:`.
* Any words flagged as possibly misspelled are surnames from those references
  (Wickham, Savric, Patterson, Jenny, Crameri, Shephard, Heron, Snyder,
  Douglas, Peucker) or cartographic terms (equirectangular, equalearth,
  Mollweide, Robinson, choropleth); these are listed in `inst/WORDLIST`.
* Examples and tests write only to `tempdir()`, and nothing modifies the global
  environment or the user's file space.
* The bundled `world_map` dataset derives from the world database of the maps
  package, whose boundaries come from Natural Earth and are in the public
  domain. The provenance is documented in `?world_map`.

## Test environments

* Local: Windows 11, R 4.5.2
* GitHub Actions: Ubuntu (release, devel, oldrel-1), Windows (release),
  macOS (release)
