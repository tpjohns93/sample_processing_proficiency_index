# scripts/plot_helpers.R
# Shared plotting helpers for index figures.

y_expansion <- list(
  ggplot2::scale_y_continuous(
    expand = ggplot2::expansion(mult = c(0.05, 0.35))
  )
)

format_p_label <- function(
    p_value,
    test_name = "Mann-Whitney",
    digits = P_VALUE_DIGITS
) {
  paste0(
    "P ",
    test_name,
    " = ",
    formatC(p_value, format = "f", digits = digits)
  )
}

betweenstats <- function(
    data,
    x,
    y,
    type = c("nonparametric", "parametric"),
    results.subtitle = FALSE,
    display.stats = FALSE,
    y_label = NULL
) {
  
  type <- match.arg(type)
  
  if (!is.character(x) || length(x) != 1) {
    stop("x must be a single column name string.")
  }
  
  if (!is.character(y) || length(y) != 1) {
    stop("y must be a single column name string.")
  }
  
  plot_data <- data |>
    dplyr::rename(
      .x = dplyr::all_of(x),
      .y = dplyr::all_of(y)
    ) |>
    dplyr::mutate(
      .x = factor(
        .x,
        levels = sort(unique(as.character(.x)))
      )
    )
  
  group_levels <- levels(plot_data$.x)
  
  if (length(group_levels) < 2) {
    stop("x must contain at least two groups for comparison.")
  }
  
  group_palette <- stats::setNames(
    rep(COMPARISON_COLORS, length.out = length(group_levels)),
    group_levels
  )
  
  p <- ggstatsplot::ggbetweenstats(
    data = plot_data,
    x = .x,
    y = .y,
    type = type,
    messages = FALSE,
    results.subtitle = results.subtitle,
    display.stats = display.stats,
    violin.args = list(
      width = 0.8,
      alpha = 0.2,
      color = "#FFFFFF"
    ),
    boxplot.args = list(
      width = 0.1,
      alpha = 0.5,
      color = "white"
    ),
    centrality.type = "label",
    centrality.label.args = list(
      size = 7,
      nudge_x = 0.35,
      fill = "white",
      fontface = "bold"
    ),
    point.args = list(
      alpha = 0.8,
      size = 5,
      position = ggplot2::position_jitter(
        width = 0.2,
        seed = 123
      )
    ),
    ggsignif.args = list(
      textsize = 6,
      color = COLORS$primary,
      vjust = -0.5
    ),
    ggplot.component = y_expansion
  )
  
  p <- p +
    ggplot2::scale_color_manual(
      values = COMPARISON_COLORS
    )
  
  if (!is.null(y_label)) {
    p <- p + ggplot2::labs(
      x = x,
      y = y_label
    )
  } else {
    p <- p + ggplot2::labs(
      x = x,
      y = y
    )
  }
  
  p + custom_theme
}

adaptive_date_scale <- function(dates) {
  dates <- as.Date(dates)
  dates <- dates[!is.na(dates)]
  
  if (length(dates) < 2) {
    return(
      ggplot2::scale_x_date(
        date_breaks = "1 month",
        date_labels = "%b\n%Y"
      )
    )
  }
  
  span_days <- as.numeric(
    difftime(max(dates), min(dates), units = "days")
  )
  
  if (span_days <= 60) {
    ggplot2::scale_x_date(
      date_breaks = "1 week",
      date_labels = "%b %d"
    )
  } else if (span_days <= 365) {
    ggplot2::scale_x_date(
      date_breaks = "1 month",
      date_labels = "%b\n%Y"
    )
  } else if (span_days <= 3 * 365) {
    ggplot2::scale_x_date(
      date_breaks = "3 months",
      date_labels = "%b\n%Y"
    )
  } else if (span_days <= 10 * 365) {
    ggplot2::scale_x_date(
      date_breaks = "1 year",
      date_labels = "%Y"
    )
  } else {
    ggplot2::scale_x_date(
      date_breaks = "2 years",
      date_labels = "%Y"
    )
  }
}