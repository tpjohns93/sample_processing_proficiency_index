---
title: "sample_processing_proficiency_index.md"
author: "Taylor Johnson"
date: "2026-23-2"
output: github_document
---
# Sample Processing Proficiency Index
   
## Background/Overview
-------------------------------
This repository provides a reproducible workflow for monitoring sample processing quality and consistency when paired replicate samples are processed 
in parallel, and data in the form of (i) count and (ii) ratio derived from count (dependent ratio) are recorded. The core output is the Sample Processing Proficiency Index (SPPI), a composite measure that combines both:

1. sample quality, through within-replicate viability
2. sample consistency, through agreement between replicate tubes or wells

SPPI is useful because sample processing is a major source of technical variation in downstream experiments. Even when the biology is unchanged, differences 
in collection, handling, isolation, and counting can alter viability, recovery, and total yield. Monitoring SPPI helps identify when processing performance 
is strong, drifting, or inconsistent over time, across technicians, protocols, or other comparison groups.

Given:
(i)	The innate variabilities of each research participant
(ii)	The sensitivity of research technologies deployed to assess this variation (single cell RNA seq, timsTOF MS-GC, etc.)
(iii)	The unknown magnitude of effect within each unique cohort to be determined
(iv)	The exploratory nature of foundational studies leading to hypothesis-driven experiment designs

The importance of quality and consistency in sample processing cannot be overstated. 

## Project Aims
The purpose of this repository is to:

(i) Establish baseline biorepository metrics 
(ii) Provide reference statistics to guague all future-processing events by

This importantly informs the average quality of the total biorepository storage currently on hand, and creates a tool for managing quality of all future samples to be banked, promoting a more consistent sample pool amassed over time (through decades and technicians).

Aim 1: Generate reference statistics: Assess between current processing technicians using reference_pbmc_score.Rmd

Aim 2: Generate new-user metrics: Assess single data-point values versus reference statistics using new_user_pbmc_score.Rmd

## Minimum requirements to use SPPI
-------------------------------
This repository is intentionally structured so it can be adapted to a broad range of sample types and methods. SPPI can be calculated as long as the dataset 
includes both of the following:

1. Both proportion and count metrics
2. Replicate samples processed in parallel

At minimum, each paired event should have count-based readouts (ex. total, live, and dead cells) to calculate a dependent proportion (ex. viability), plus a replicate 
identifier so the two measurements can be matched (ex. for a single paired isolation event: consistent date, parent group, technician, isolation event, cell type, tube type, and protocol).


## Repository structure
-------------------------------
The repository is organized around a small set of reusable R files and one main Shiny-driven analysis document.

Core files:
- launch.R: A simplified script for launching the SPPI Shiny app
- config.R: Central configuration file for packages, file paths, labels, thresholds, plotting settings, and the active comparison group.
- check.R: Validation and normalization helpers. This file checks the input structure, enforces replicate pairing rules, confirms count 
           consistency, and calculates blood volume from tube volume minus additive volume.
- plot_helpers.R: Shared plotting functions used across the dashboard.
- sample_processing_proficiency_index.Rmd: Main analysis workflow and Shiny app. This is where validation, calculation, summary statistics, and visual output come together.

Expected input data:
- data/example_reference_dataset.csv
- data/USER_DEFINED_FILE.csv

Main outputs:
- output/reference_index_data.rds: Paired-event dataset used for downstream analysis.
- output/reference_statistics.rds: Repository-level summary statistics for SPPI and its component metrics.
- output/comparison_group_summary.rds: Summary table by the active comparison group.
- output/Index_data.rds: Saved paired-event dataset used during the workflow.

Statistics derived from simple raw cell counts per processing technitian (live, dead, total) are compared between phlepotomy tube replicates per isolation event to create a `SPPI` aggregate which is then used to compare isolation quality and consistency between processing technitians. SPPI is composed of two major metric averages: 

(i) Total cell viability of tube replicates
(ii) Viability and total cell counts *between* tube replicates.

These two values capture both quality and consistency of isolations and are averaged with equal weight to obtain a final composite metric for statistical comparison.


## How the workflow works
----------------------
1. Load the reference dataset.
2. Validate the input using check.R.
3. Standardize replicate labels and parse dates.
4. Calculate viability and normalized counts.
5. Pair the two replicates within each isolation event.
6. Calculate inter-replicate agreement metrics.
7. Combine quality and consistency into the final SPPI.
8. Summarize results by the selected comparison group.
9. Display the results in the Shiny dashboard and save reference outputs to the output folder.

## Statistical assessment
----------------------
Comparisons between processing technicians are performed using a combination of parametric and non-parametric methods, depending on metric type (cell count, proportion). 
SPPI, viability, proportion, and inter-tube variability are tested using two-sided Wilcoxon rank-sum (Mann–Whitney U) or Kruskal-Wallis tests (depending on the number of relationships to be tested) to account for non-normality. Raw cell count metrics (total, live, and dead cell counts) are evaluated using parametric t-test or One-way ANOVA (depending on the number of relationships to be tested).


## Important validation rules
--------------------------
The workflow expects paired replicate data with a consistent structure. The current validation checks that:

- all required columns are present
- required fields are not missing
- numeric fields are numeric
- count values are not negative
- Live and Dead do not exceed Total
- Total is consistent with Live + Dead within the configured tolerance
- each paired event contains exactly one A replicate and one B replicate
- replicate rows are unique within Date, Parent_group, comparison group, Isolation_event, and Replicate
- Cell_type is consistent within each paired event
- Tube_type and Additive_vol are consistent within each paired event
- Tube_volume is greater than Additive_vol
- Blood_Volume remains positive after correction

By default, the repo uses Technician as the active comparison group, but that setting can be changed in config.R.

## How to use the repository
-------------------------
1. Place your reference CSV in the data folder, or upload it through the Shiny app.
2. Open and run the main Rmd file in RStudio.
3. Confirm that config.R, check.R, and plot_helpers.R are sourced at the top of the document.
4. Make sure your input data follows the required column structure.
5. Run the reference workflow via launch.R to generate the SPPI outputs and reference statistics.
6. Use the Shiny dashboard to review plots, summaries, and comparisons.

For new datasets, the app lets you:
- upload a CSV
- choose the comparison group
- generate reference statistics
- inspect SPPI, viability, inter-replicate agreement, and longitudinal trends

## How to adapt this repo to another cell type
-------------------------------------------
This repository can be reused for another cell type or sample type as long as the new workflow still has the bare minimum needed for SPPI:

- paired replicates
- count and count-dependent ratio metrics for each replicate
- a consistent way to identify each paired event

To adapt the repo, update the input data and, if needed, change the active comparison group in config.R. The existing code is already organized so that a single comparison field can drive the grouping, summaries, and plots.

Typical ways to repurpose the workflow include:
- changing the cell type being analyzed
- changing the tube volume to tissue mass or other relevant relative reference for normalizing count data
- changing the tube format or well-based format
- using a different processing role or grouping variable
- benchmarking a different laboratory workflow while keeping the same paired-replicate design

As long as the paired measurements have quality and quantity readouts, the SPPI framework can be reused as a general processing-quality monitor.

## Project output and interpretation
---------------------------------
The dashboard is designed to show both the overall score and the component values that contribute to it. In general:

- higher viability is better
- higher replicate agreement is better
- higher SPPI is better

The repository also produces summary statistics that can be used to benchmark new users, new runs, or new batches against the reference dataset.

## Data Structure
-------------------------

project_directory
```bash
├──  data
    └── example_reference_dataset.csv
├──  output
├──  README.txt
├──  scripts 
    └── config.R
    └── check.R
    └── plot_helpers.R
    └── sample_processing_proficiency_index.Rmd
```

## Notes
-----
- Keep the reference dataset in a consistent format so validation and pairing work correctly.
- If you change the active comparison group, make sure that field exists in the input data and is suitable for grouping paired events.
- The repo is designed to be reusable, but the input data still needs to satisfy the paired-replicate structure for SPPI to be meaningful.


## Responsibilities and Acknowledgements
Please reach out to Taylor Johnson (tpjohns93@gmail.com) for all questions and inquiries regarding this GitHub repository.
