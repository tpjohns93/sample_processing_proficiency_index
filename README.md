---
title: "sample_processing_proficiency_index.md"
author: "Taylor Johnson"
date: "2026-23-2"
output: github_document
---
# Sample Processing Proficiency Index
   
## Background
-------------------------------
This repository provides a reproducible workflow for monitoring sample processing quality and consistency when paired replicate samples are processed in parallel. The primary output of this repository is the Sample Processing Proficiency Index (SPPI), a composite measure that combines both:

1. Sample quality: captured by within-replicate sample viability
2. Sample consistency: captured by between-replicate agreement of both viability and cell count 

Sample processing provides a potential major source of technical variation affecting output of downstream experimentation. Even when the biology is unchanged, differences experienced through changes in logistics, methodology, and personal touch can alter quality and consistency of processing, affecting data generated and interpretation of outcome. Given replicate samples processed in parallel, this variability can be identified and aggregated into single metric, SPPI, which integrates broad quality and consistency metrics with equal weight.

Given:
1. The innate variabilities of each research participant
2. The sensitivity of research technologies deployed to assess this variation (single cell RNA seq, timsTOF MS-GC, etc.)
3. The unknown magnitude of effect within each unique cohort to be determined
4. The exploratory nature of foundational studies leading to hypothesis-driven experiment designs

The importance of sample processing quality and consistency cannot be overstated. 

## Project Aims
The purpose of this repository is to:

(i) Establish baseline biorepository metrics 
(ii) Provide reference statistics to guague all future-processing events by

Monitoring via SPPI supports biorepository management across scales – from single-protocol laboratories to enterprise-wide operations. By establishing benchmark reference statistics, SPPI provides context for the quality of current biorepository holdings while enabling continuous monitoring of future processing events, promoting a more consistent and reliable sample repository over time. Additionally, SPPI may also be leveraged to optimize processing pipelines ahead of committting to any workflow. 

Comparison group options generate single-parameter statistics assessed in a repository-wide manner by either: (i) lab group(s), (ii) processing technician(s), (iii) collection method(s), (iv) protocol(s), and (v) cell type(s). Thus, SPPI and the associated Dashboard Application helps identify when processing performance is strong, drifting, or inconsistent over time, across technicians, protocols, or other comparison groups. Examples include: 

- Technician: Compare SPPI between technicians to evaluate processing proficiency, training outcomes, and long-term consistency.
- Parent Group: Compare SPPI across laboratories, institutions, or study sites to benchmark processing quality.
- Cell Type: Compare SPPI between isolated cell populations (e.g., PBMCs, neutrophils) to evaluate workflow performance.
- Tube Type: Compare SPPI across blood collection tube types or anticoagulants to identify optimal collection systems.
- Protocol: Compare SPPI across isolation protocols to optimize workflows and quantify the impact of protocol modifications.

SPPI prioritizes interpretability over complexity, enabling rapid identification of meaningful differences in sample processing performance. The strength of the SPPI Dashboard lies in thoughtfully tailoring the user-defined reference dataset to provide the appropriate context for each comparison, allowing the same analytical framework to address a wide range of quality assurance and process optimization questions.

## Minimum requirements to use SPPI
-------------------------------
This repository is strategically structured so it may be adapted to a support a broader range of sample types and methods, and serve as a foundational add-on component of a larger variety of exhisting, custom complete workflows. SPPI may be calculated as long as the dataset 
includes both of the following:

1. Count data (ex. total, live, and dead cells) and associated proportion metrics (ex. viability)
2. Replicate samples processed in parallel (i.e. consistent ID, date, parent group, technician, isolation event, cell type, tube type, and protocol).

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
- count or quality metrics for each replicate
- a consistent way to identify each paired event

To adapt the repo, update the input data and, if needed, change the active comparison group in config.R. The existing code is already organized so that a single comparison field can drive the grouping, summaries, and plots.

Typical ways to repurpose the workflow include:
- changing the cell type being analyzed
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
Please reach out to Taylor Johnson (taylor.johnson@ucsf.edu) for all questions and inquiries regarding this GitHub repository.
