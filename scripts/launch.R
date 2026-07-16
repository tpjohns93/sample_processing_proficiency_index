# ==============================================================================
# launch.R
#
# Launch the Sample Processing Proficiency Index Shiny application.
# ==============================================================================

sppi_file <- "sample_processing_proficiency_index.Rmd"

# Extract all R code chunks from the Rmd into a temporary .R file.
sppi_r <- tempfile(fileext = ".R")
knitr::purl(sppi_file, output = sppi_r, quiet = TRUE)

# Run the extracted code. This defines ui and server.
source(sppi_r, local = globalenv())

# Launch the app.
shiny::shinyApp(ui = ui, server = server)