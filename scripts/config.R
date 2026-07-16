# ==============================================================================
# config.R — Centralized project configuration
# Purpose: Single entry point for package management, file paths, constants,
#          labels, thresholds, and shared plot/UI settings used across the project.
# ==============================================================================

# --- Project Root -------------------------------------------------------------
here::i_am("scripts/config.R")

# --- Package Management --------------------------------------------------------
if (!requireNamespace("cli", quietly = TRUE)) install.packages("cli")
library(cli)

cran_packages <- c(
  "here", "shiny", "ggplot2", "bslib", "ggpubr",
  "ggstatsplot", "qgraph", "tidyr", "dplyr", "rlang"
)

missing_cran_packages <- setdiff(cran_packages, rownames(installed.packages()))

if (length(missing_cran_packages) > 0) {
  cli_alert_info("Installing {length(missing_cran_packages)} CRAN packages...")
  install.packages(missing_cran_packages, quiet = TRUE)
}

for (pkg in cran_packages) {
  suppressPackageStartupMessages(
    library(pkg, character.only = TRUE)
  )
}

# --- File Paths ---------------------------------------------------------------
DATA_DIR   <- here("data")
OUTPUT_DIR <- here("output")
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

# --- Data Contract ------------------------------------------------------------
REQUIRED_COLUMNS <- c(
  "Date",
  "Parent_group",
  "Technician",
  "Replicate",
  "Isolation_event",
  "Cell_type",
  "Tube_type",
  "Additive_vol",
  "Protocol",
  "Total",
  "Dead",
  "Live",
  "Tube_volume"
)

NUMERIC_COLUMNS <- c(
  "Isolation_event",
  "Additive_vol",
  "Total",
  "Dead",
  "Live",
  "Tube_volume"
)

ID_COLUMNS <- c(
  "Date",
  "Parent_group",
  "Technician",
  "Isolation_event",
  "Replicate"
)

ALLOWED_REPLICATES <- c("A", "B")

COUNT_TOLERANCE <- 0.02

# --- Display Labels -----------------------------------------------------------
DEFAULT_COMPARISON_GROUP <- "Technician"

PARENT_GROUP_LABEL <- "Parent group"
CELL_TYPE_LABEL <- "Cell type"
TUBE_TYPE_LABEL <- "Tube type"
SPECIMEN_ADDITIVE_LABEL <- "Specimen additive"
ADDITIVE_VOL_LABEL <- "Additive volume"
TUBE_VOLUME_LABEL <- "Tube volume"


# --- Plot/Reporting Precision -------------------------------------------------
P_VALUE_DIGITS <- 3

# --- Thresholds ---------------------------------------------------------------
INDEX_THRESHOLDS <- c(
  excellent = 0.97,
  good = 0.90,
  acceptable = 0.85
)

VIABILITY_THRESHOLDS <- c(
  excellent = 0.98,
  good = 0.95
)

# --- Color Palette ------------------------------------------------------------
COLORS <- list(
  primary    = "#00bc8c",
  bg_dark    = "#222222",
  bg_darker  = "#1a1a1a",
  bg_panel   = "#444444",
  grid       = "#666666",
  grid_dark  = "#333333",
  text       = "white",
  accent_red = "red"
)

COMPARISON_COLORS <- c(
  "#00A9FF",
  "#F8766D",
  "#00BFC4",
  "#7CAE00",
  "#C77CFF",
  "#FF61CC",
  "#00BA38",
  "#619CFF",
  "#F564E3",
  "#B79F00"
)

# Temporary alias so older code does not break while you finish renaming.
TECHNICIAN_COLORS <- COMPARISON_COLORS

# --- Shared ggplot2 Theme -----------------------------------------------------
custom_theme <- theme(
  panel.background = element_rect(fill = COLORS$bg_dark, color = NA),
  plot.background = element_rect(fill = COLORS$bg_panel, color = NA),
  panel.grid.major = element_line(color = COLORS$grid),
  panel.grid.minor = element_blank(),
  text = element_text(size = 18, color = COLORS$text, face = "bold"),
  axis.title = element_text(size = 18, face = "bold"),
  axis.text = element_text(size = 16, color = COLORS$primary, face = "bold"),
  plot.title = element_text(size = 22, face = "bold", color = COLORS$text),
  plot.subtitle = element_text(size = 14, color = COLORS$text, face = "bold"),
  legend.background = element_blank(),
  plot.margin = margin(t = 30, r = 10, b = 10, l = 10)
)

# --- Render Background --------------------------------------------------------
RENDER_BG <- COLORS$bg_dark

# --- bs_theme for Shiny UI ----------------------------------------------------
app_theme <- bs_theme(
  version = 5,
  bootswatch = "darkly",
  primary = COLORS$primary
)

cli_alert_success("config.R loaded - project root: {here()}")