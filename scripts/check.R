# ==============================================================================
# check.R — Input validation helpers for paired replicate index workflows
# ==============================================================================
# Source this after config.R so DEFAULT_COMPARISON_GROUP, COUNT_TOLERANCE,
# REQUIRED_COLUMNS, NUMERIC_COLUMNS, and ALLOWED_REPLICATES are available.
# ======================================================================

# --- Helper: stable row labels for clearer validation messages -----------------
fmt_rows <- function(x) {
  paste(sort(unique(x)), collapse = ", ")
}

# --- Helper: parse dates consistently -----------------------------------------
parse_reference_date <- function(x) {
  as.Date(x, tryFormats = c("%Y-%m-%d", "%m/%d/%y", "%m/%d/%Y"))
}

# --- Core validation function --------------------------------------------------
# Returns a validated data frame with:
#   - .row_id added temporarily for error reporting
#   - Replicate standardized to uppercase/trimmed text
#   - Blood_Volume added
validate_data <- function(reference_data) {
  if (!exists("DEFAULT_COMPARISON_GROUP", inherits = TRUE)) {
    stop("DEFAULT_COMPARISON_GROUP is not defined. Source config.R before check.R.")
  }
  
  if (!exists("REQUIRED_COLUMNS", inherits = TRUE)) {
    stop("REQUIRED_COLUMNS is not defined. Source config.R before check.R.")
  }
  
  if (!exists("NUMERIC_COLUMNS", inherits = TRUE)) {
    stop("NUMERIC_COLUMNS is not defined. Source config.R before check.R.")
  }
  
  if (!exists("COUNT_TOLERANCE", inherits = TRUE)) {
    COUNT_TOLERANCE <- 0
  }
  
  if (!exists("ALLOWED_REPLICATES", inherits = TRUE)) {
    ALLOWED_REPLICATES <- c("A", "B")
  }
  
  if (!DEFAULT_COMPARISON_GROUP %in% REQUIRED_COLUMNS) {
    stop(
      paste0(
        "DEFAULT_COMPARISON_GROUP ('", DEFAULT_COMPARISON_GROUP,
        "') must match one of the required input columns."
      )
    )
  }
  
  # Add a stable row id for clearer error messages
  reference_data$.row_id <- seq_len(nrow(reference_data))
  
  # Confirm all required columns are present
  missing_cols <- setdiff(REQUIRED_COLUMNS, names(reference_data))
  if (length(missing_cols) > 0) {
    stop(
      paste0(
        "Missing required columns: ",
        paste(missing_cols, collapse = ", ")
      )
    )
  }
  
  # Standardize replicate labels early
  reference_data$Replicate <- toupper(trimws(as.character(reference_data$Replicate)))
  reference_data$Sample_ID <- as.character(trimws(reference_data$Sample_ID))
  
  # Confirm required columns do not contain missing values
  na_rows <- lapply(REQUIRED_COLUMNS, function(col) {
    reference_data$.row_id[is.na(reference_data[[col]])]
  })
  names(na_rows) <- REQUIRED_COLUMNS
  na_rows <- na_rows[lengths(na_rows) > 0]
  
  if (length(na_rows) > 0) {
    msg <- paste(
      names(na_rows),
      "(rows:",
      vapply(na_rows, fmt_rows, character(1)),
      ")",
      collapse = "; "
    )
    stop(paste("Missing values detected in required columns:", msg))
  }
  
  # Confirm required numeric columns are numeric
  non_numeric_cols <- NUMERIC_COLUMNS[
    !vapply(reference_data[NUMERIC_COLUMNS], is.numeric, logical(1))
  ]
  
  if (length(non_numeric_cols) > 0) {
    bad_rows <- lapply(non_numeric_cols, function(col) {
      reference_data$.row_id[
        !is.na(reference_data[[col]]) &
          is.na(suppressWarnings(as.numeric(as.character(reference_data[[col]]))))
      ]
    })
    names(bad_rows) <- non_numeric_cols
    bad_rows <- bad_rows[lengths(bad_rows) > 0]
    
    msg <- paste(
      names(bad_rows),
      "(rows:",
      vapply(bad_rows, fmt_rows, character(1)),
      ")",
      collapse = "; "
    )
    stop(paste("Non-numeric values detected in required numeric columns:", msg))
  }
  
  # Confirm key numeric values are > 0
  positive_cols <- c("Isolation_event", "Total", "Tube_volume")
  non_positive_rows <- lapply(positive_cols, function(col) {
    reference_data$.row_id[!is.na(reference_data[[col]]) & reference_data[[col]] <= 0]
  })
  names(non_positive_rows) <- positive_cols
  non_positive_rows <- non_positive_rows[lengths(non_positive_rows) > 0]
  
  if (length(non_positive_rows) > 0) {
    msg <- paste(
      names(non_positive_rows),
      "(rows:",
      vapply(non_positive_rows, fmt_rows, character(1)),
      ")",
      collapse = "; "
    )
    stop(paste("Non-positive values (<= 0) detected in columns:", msg))
  }
  
  # Confirm additive volume is non-negative (0 is allowed)
  additive_negative_rows <- reference_data$.row_id[
    !is.na(reference_data$Additive_vol) & reference_data$Additive_vol < 0
  ]
  if (length(additive_negative_rows) > 0) {
    stop(
      paste0(
        "Negative values detected in Additive_vol at row(s): ",
        fmt_rows(additive_negative_rows),
        ". Additive_vol must be >= 0."
      )
    )
  }
  
  # Confirm Live and Dead counts are not negative
  count_cols <- c("Live", "Dead")
  negative_rows <- lapply(count_cols, function(col) {
    reference_data$.row_id[!is.na(reference_data[[col]]) & reference_data[[col]] < 0]
  })
  names(negative_rows) <- count_cols
  negative_rows <- negative_rows[lengths(negative_rows) > 0]
  
  if (length(negative_rows) > 0) {
    msg <- paste(
      names(negative_rows),
      "(rows:",
      vapply(negative_rows, fmt_rows, character(1)),
      ")",
      collapse = "; "
    )
    stop(paste("Negative values detected in columns:", msg))
  }
  
  # Confirm Live and Dead do not exceed Total
  if (any(reference_data$Live > reference_data$Total, na.rm = TRUE)) {
    bad_rows <- reference_data$.row_id[reference_data$Live > reference_data$Total]
    stop(
      paste0(
        "Invalid data: Live count cannot exceed Total count. Row(s): ",
        fmt_rows(bad_rows)
      )
    )
  }
  
  if (any(reference_data$Dead > reference_data$Total, na.rm = TRUE)) {
    bad_rows <- reference_data$.row_id[reference_data$Dead > reference_data$Total]
    stop(
      paste0(
        "Invalid data: Dead count cannot exceed Total count. Row(s): ",
        fmt_rows(bad_rows)
      )
    )
  }
  
  # Sanity check with COUNT_TOLERANCE for rounding/counting differences
  count_diff <- abs(reference_data$Total - (reference_data$Live + reference_data$Dead))
  percent_diff <- count_diff / reference_data$Total
  
  if (any(percent_diff > COUNT_TOLERANCE, na.rm = TRUE)) {
    bad_rows <- reference_data$.row_id[percent_diff > COUNT_TOLERANCE]
    stop(
      paste0(
        "Invalid data: Total differs from Live + Dead by more than ",
        COUNT_TOLERANCE * 100,
        "% in row(s): ",
        fmt_rows(bad_rows)
      )
    )
  }
  
  # Check for duplicate Date / Parent_group / active comparison group / Isolation_event / Replicate rows
  duplicate_group_cols <- c(
    "Date",
    "Parent_group",
    DEFAULT_COMPARISON_GROUP,
    "Isolation_event",
    "Replicate"
  )
  
  dup_keys <- reference_data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(duplicate_group_cols))) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::ungroup()
  
  if (nrow(dup_keys) > 0) {
    stop(
      paste0(
        "Duplicate rows detected for Date/Parent_group/",
        DEFAULT_COMPARISON_GROUP,
        "/Isolation_event/Replicate at row(s): ",
        fmt_rows(dup_keys$.row_id)
      )
    )
  }
  
  # Validate replicate structure:
  # each isolation event must contain exactly one A and one B replicate
  replicate_check <- reference_data |>
    dplyr::group_by(
      dplyr::across(
        dplyr::all_of(c(
          "Date",
          "Parent_group",
          DEFAULT_COMPARISON_GROUP,
          "Isolation_event"
        ))
      )
    ) |>
    dplyr::summarise(
      rows = paste(.row_id, collapse = ", "),
      reps = paste(sort(unique(Replicate)), collapse = ","),
      n_rows = dplyr::n(),
      n_unique_reps = dplyr::n_distinct(Replicate),
      .groups = "drop"
    )
  
  allowed_rep_string <- paste(ALLOWED_REPLICATES, collapse = ",")
  
  bad_replicates <- replicate_check |>
    dplyr::filter(
      n_rows != length(ALLOWED_REPLICATES) |
        n_unique_reps != length(ALLOWED_REPLICATES) |
        reps != allowed_rep_string
    )
  
  if (nrow(bad_replicates) > 0) {
    stop(
      paste0(
        "Invalid replicate structure found in row(s): ",
        paste(bad_replicates$rows, collapse = "; "),
        ". Each Date/Parent_group/",
        DEFAULT_COMPARISON_GROUP,
        "/Isolation_event group must contain exactly one A and one B replicate."
      )
    )
  }
  
  # Validate Cell_type consistency within each paired event
  event_cell_type_check <- reference_data |>
    dplyr::group_by(
      dplyr::across(
        dplyr::all_of(c(
          "Date",
          "Parent_group",
          DEFAULT_COMPARISON_GROUP,
          "Isolation_event"
        ))
      )
    ) |>
    dplyr::summarise(
      rows = paste(.row_id, collapse = ", "),
      n_cell_types = dplyr::n_distinct(Cell_type),
      .groups = "drop"
    )
  
  bad_cell_type <- event_cell_type_check |>
    dplyr::filter(n_cell_types != 1)
  
  if (nrow(bad_cell_type) > 0) {
    stop(
      paste0(
        "Inconsistent Cell_type values found in row(s): ",
        paste(bad_cell_type$rows, collapse = "; "),
        ". Each Date/Parent_group/",
        DEFAULT_COMPARISON_GROUP,
        "/Isolation_event group must have exactly one Cell_type."
      )
    )
  }
  
  # Validate Tube_type and Additive_vol consistency within each paired event
  event_additive_check <- reference_data |>
    dplyr::group_by(
      dplyr::across(
        dplyr::all_of(c(
          "Date",
          "Parent_group",
          DEFAULT_COMPARISON_GROUP,
          "Isolation_event"
        ))
      )
    ) |>
    dplyr::summarise(
      rows = paste(.row_id, collapse = ", "),
      n_tube_types = dplyr::n_distinct(Tube_type),
      n_additive_vols = dplyr::n_distinct(Additive_vol),
      .groups = "drop"
    )
  
  bad_additive <- event_additive_check |>
    dplyr::filter(n_tube_types != 1 | n_additive_vols != 1)
  
  if (nrow(bad_additive) > 0) {
    stop(
      paste0(
        "Inconsistent Tube_type or Additive_vol values found in row(s): ",
        paste(bad_additive$rows, collapse = "; "),
        ". Each Date/Parent_group/",
        DEFAULT_COMPARISON_GROUP,
        "/Isolation_event group must have exactly one Tube_type and one Additive_vol."
      )
    )
  }
  
  # Check volume feasibility
  bad_volume_rows <- reference_data$.row_id[
    reference_data$Tube_volume <= reference_data$Additive_vol
  ]
  
  if (length(bad_volume_rows) > 0) {
    stop(
      paste0(
        "Invalid tube volume detected at row(s): ",
        fmt_rows(bad_volume_rows),
        ". Tube_volume must be greater than Additive_vol."
      )
    )
  }
  
  # Validate Sample_ID consistency within each paired event
  # Validate Sample_ID consistency within each paired event
  event_sample_id_check <- reference_data |>
    dplyr::group_by(
      dplyr::across(
        dplyr::all_of(c(
          "Date",
          "Parent_group",
          DEFAULT_COMPARISON_GROUP,
          "Isolation_event"
        ))
      )
    ) |>
    dplyr::summarise(
      rows = paste(.row_id, collapse = ", "),
      Sample_ID = dplyr::first(Sample_ID),
      n_sample_ids = dplyr::n_distinct(Sample_ID),
      .groups = "drop"
    )
  
  bad_sample_id <- event_sample_id_check |>
    dplyr::filter(n_sample_ids != 1)
  
  if (nrow(bad_sample_id) > 0) {
    stop(
      paste0(
        "Inconsistent Sample_ID values found in row(s): ",
        paste(bad_sample_id$rows, collapse = "; "),
        ". Each Date/Parent_group/",
        DEFAULT_COMPARISON_GROUP,
        "/Isolation_event group must have exactly one Sample_ID."
      )
    )
  }
  
  duplicate_sample_ids <- event_sample_id_check |>
    dplyr::count(Sample_ID, name = "n_events") |>
    dplyr::filter(n_events > 1)
  
  if (nrow(duplicate_sample_ids) > 0) {
    stop(
      paste0(
        "Sample_ID must be unique to one paired event. Duplicate Sample_ID(s): ",
        paste(duplicate_sample_ids$Sample_ID, collapse = ", ")
      )
    )
  }
  
  # Compute blood volume
  reference_data$Blood_Volume <- reference_data$Tube_volume - reference_data$Additive_vol
  
  if (any(reference_data$Blood_Volume <= 0, na.rm = TRUE)) {
    bad_rows <- reference_data$.row_id[reference_data$Blood_Volume <= 0]
    stop(
      paste0(
        "Invalid blood volume after correction at row(s): ",
        fmt_rows(bad_rows)
      )
    )
  }
  
  # Drop helper column before returning
  reference_data$.row_id <- NULL
  reference_data
}
