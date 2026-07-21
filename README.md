---
title: "sample_processing_proficiency_index.md"
author: "Taylor Johnson"
date: "2026-21-7"
output: github_document
---
# Sample Processing Proficiency Index
   
## Background
-------------------------------
This repository provides a reproducible workflow for monitoring sample processing quality and consistency when paired replicate samples are processed in parallel. The primary output is a Sample Processing Proficiency Index (SPPI), a composite measure that combines both:

1. Sample quality: captured by within-replicate sample viability
2. Sample consistency: captured by between-replicate agreement of both viability and cell count 

Sample processing provides a potential major source of technical, masquerading as biological, variation. Even when the biology is unchanged, differences experienced throughout the sample processing workflow in terms of logistics, methodology, and inclusion of personal touch during processing, can alter sample quality and consistency, affecting generated data and downstream interpretations. Provided replicate samples and processed in parallel, this variability can be identified and aggregated into single metric, SPPI, which integrates broad quality and consistency metrics with equal weight.

Given:
1. The innate biological variation inherant to human research participant
2. The sensitivity of research technologies deployed to assess this variation (single cell RNA seq, timsTOF MS-GC, etc.)
3. The unknown magnitude of effect within each unique cohort to be determined
4. The exploratory nature of foundational studies leading to hypothesis-driven experiment designs
5. The biorepository as a valuable capital asset

The importance of monitoring and maintaining sample processing quality and consistency cannot be overstated. 

## Project Aims
-------------------------------
The purpose of this repository is to:

1. Establish baseline biorepository metrics
2. Provide reference statistics to guague all future-processing events by

Monitoring via SPPI supports biorepository management across scales – from single-protocol laboratories to enterprise-wide operations. By establishing benchmark reference statistics, SPPI provides context for the quality of current biorepository holdings while enabling continuous monitoring of future processing events, promoting a more consistent and reliable sample repository over time. Additionally, SPPI may also be leveraged to optimize processing pipelines ahead of committting to and scaling a workflow. Within the associated SPPI dashboard application, comparison group options generate single-parameter statistics assessed in a repository-wide manner by either: (i) lab groups, (ii) processing technicians, (iii) collection methods, (iv) protocols, and (v) cell types, from a single user-defined .csv upload to help identify when processing performance is strong, drifting, or inconsistent over time across technicians, protocols, or other comparison groups. Examples of user-defined source reference dataset .csv builds include: 

- Technician: Compare SPPI between technicians to evaluate processing proficiency, training outcomes, and long-term consistency.
- Parent Group: Compare SPPI across laboratories, institutions, or study sites to benchmark processing quality.
- Cell Type: Compare SPPI between isolated cell populations (e.g., PBMCs, neutrophils) to evaluate workflow performance.
- Tube Type: Compare SPPI across blood collection tube types or anticoagulants to identify optimal collection systems.
- Protocol: Compare SPPI across isolation protocols to optimize workflows and quantify the impact of protocol modifications.

SPPI prioritizes interpretability over complexity, enabling rapid identification of meaningful differences in sample processing performance. The strength of the SPPI Dashboard lies in thoughtfully tailoring the user-defined reference dataset to provide the appropriate context for each comparison, allowing the same analytical framework to address a wide range of workflow optimization questions.

## Minimum requirements to use SPPI
-------------------------------
This repository is strategically build so it may be adapted to a support a broader range of sample types and workflows, and serve as a foundational add-on component to a larger variety of exhisting, custom and complete workflows. Requirements for SPPI calculation:

1. **Count data** (ex. total, live, and dead cells) and **associated proportion metrics** (ex. viability)
2. **Replicate samples processed in parallel** (i.e. consistent ID, date, parent group, technician, isolation event, cell type, tube type, and protocol)

Please see **How to adapt this repository** below for more information.

## Repository structure
-------------------------------
The repository is organized around a small set of customizable R files and one main Shiny-driven dashboard application for analysis, requiring only the running of launch.R from a local machine.

Core files:
- `launch.R`: A simplified script for launching the SPPI Shiny dashboard App.
- `sample_processing_proficiency_index.Rmd`: Main analysis workflow and Shiny dashboard app generation. This script includes dataset validation, calculation, summary statistics, and visual output.
- `config.R`: Central configuration file for defining the active comparison groups, packages, file paths, labels, thresholds, and plotting settings.
- `check.R`: Validation and normalization helpers. This file checks the input structure, enforces replicate pairing rules, confirms count consistency and metric normalization.
- `plot_helpers.R`: Shared plotting functions used across the dashboard.

Expected input data:
- data/example_reference_dataset.csv 
- data/USER_DEFINED_FILE.csv

Main outputs:
- output/reference_index_data.rds: Paired-event dataset used for downstream analysis.
- output/reference_statistics.rds: Repository-level summary statistics for SPPI and its component metrics.
- output/comparison_group_summary.rds: Summary table by **active comparison group**.
- output/Index_data.rds: Saved paired-event dataset used during the workflow.

## Data Structure
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

## The workflow described
----------------------
1. Load the reference dataset: either (i) example_refernce_dataset.csv or (ii) USER_DEFINED_FILE.csv.
2. Validate the input using check.R
3. Format the dataset
4. Calculate viability and normalized counts.
5. Pair the two replicates within each isolation event.
6. Calculate inter-replicate agreement metrics.
7. Combine quality and consistency into the final SPPI.
8. Summarize results by the selected comparison group.
9. Display the results in the Shiny dashboard application and save reference outputs to the output folder.

## Statistical assessment
----------------------
Comparisons between processing technicians are performed using a combination of parametric and non-parametric methods, depending on metric type (cell count, proportion). 
SPPI, viability, and inter-tube variability are tested using two-sided Wilcoxon rank-sum (Mann–Whitney U) or Kruskal-Wallis tests (depending on the number of relationships to be tested) to account for non-normality. Raw cell count metrics (total, live, and dead cell counts) are evaluated using parametric t-test or One-way ANOVA (depending on the number of relationships to be tested).

## How to use the repository
-------------------------
1. Make sure your input data follows the required column structure.
2. Open and run launch.R.
3. Upload the user-defined reference dataset .csv via the Shiny dashboard application
5. Select comparison groups and assess SPPI cross sectionally and longitudinally, or by component metrics
6. Run the workflow via launch.R to generate the SPPI outputs and reference statistics.
7. Use the Shiny dashboard to review plots, summaries, and comparisons.

For new datasets, the app lets you:
- upload a CSV
- choose the comparison group
- generate reference statistics
- inspect SPPI, viability, inter-replicate agreement, and longitudinal trends

## How to adapt this repository
-------------------------------------------
The strength of this repository lies in its adaptability. Beyond the five comparison groups described above, SPPI can be repurposed for virtually any sample processing workflow that incorporates (i) a normalization metric, (ii) complementary count metrics satisfying `Total = A + B`, (iii) an associated proportion metric (`A / Total`), and (iv) technical replicates processed in parallel. Repository customization is primarily achieved through `config.R`, allowing users to redefine comparison groups and adapt workflow-specific metrics. Examples include:

| Workflow                                       | **Analyte**                  | Normalization metric                       | Count variables (`Total = Live + Dead`)           | Ratio                          | **SPPI assessment**                                                        |
| ---------------------------------------------- | ---------------------------- | ------------------------------------------ | ------------------------------------------------- | ------------------------------ | -------------------------------------------------------------------------- |
| **Cell or nuclei isolation**                   | Cells or nuclei              | Blood volume, tissue weight, or cell input | Total cells/nuclei = Intact (or viable) + Damaged | Intact / Total                 | Isolation quality and reproducibility                                      |
| **NGS read alignment**                         | DNA or RNA sequencing reads  | Input DNA/RNA mass                         | Total reads = Mapped + Unmapped                   | Mapped / Total reads           | Alignment efficiency and workflow reproducibility                          |
| **NGS fragment size selection**                | DNA or RNA fragments         | Input DNA/RNA mass                         | Total fragments = In-range + Out-of-range         | In-range / Total fragments     | Fragmentation profile, size-selection performance, and cleanup consistency |
| **Cryopreservation & thaw recovery**           | Cells                        | Cells frozen                               | Total recovered cells = Viable + Non-viable       | Viable / Total recovered cells | Cryopreservation performance and recovery consistency                      |
| **Assay optimization / protocol development**  | Any measurable sample output | Starting sample or reaction input          | Total outputs = Passing + Failing                 | Passing / Total outputs        | Process optimization, protocol benchmarking, and workflow reproducibility  |
| **Manufacturing / production quality control** | Products or components       | Batch size or starting material            | Total products = Passing + Failing                | Passing / Total products       | Batch quality and process consistency                                      |

## Notes
------------
- Keep the reference dataset in a consistent format so validation and pairing work correctly.
- If you change the active comparison group, make sure that field exists in the input data and is suitable for grouping paired events.
- This repository is designed to be reusable, but the input data still needs to satisfy the paired-replicate structure for SPPI to be meaningful.

Important validation rules: The workflow expects paired replicate data with a consistent structure. The current validation checks that:
- All required columns are present
- Required fields are not missing (no missing values)
- Numeric fields contain numeric data
- Count values are not negative
- Live and Dead do not exceed Total, and equate to be within a modifiable tolerance threshold to account for any rounding
- Each paired event contains exactly one A replicate and one B replicate.
- Replicate rows are consistent with date and comparison groups.
- Cell_type, Tube_type, and Additive_vol is consistent within each paired event
- Tube_volume is greater than Additive_vol
- Total, Dead, Live is unique per individually processed sample

## Responsibilities and Acknowledgements
This repository was conceived, developed, and validated by Taylor Johnson. Please reach out to Taylor Johnson (taylor.johnson@ucsf.edu)for all questions and inquiries regarding this GitHub repository.

OpenAI's ChatGPT was used as an AI-assisted development tool to support code refinement, documentation, repository organization, troubleshooting, and software design. All scientific methodology, implementation decisions, statistical approaches, and repository content were reviewed and approved by the author.
