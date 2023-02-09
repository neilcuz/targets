Introduction to the targets package in R
================

This notebook contains the code underpinning the *Targets* Twitter
thread.

- Check out the Shoogle blog for more R and data science content
  [Shoogle Blog](https://www.shoogle.co/blog)

- Follow me on Twitter for threads on data and coding @neilgcurrie
  [twitter.com/neilgcurrie](www.twitter.com/neilgcurrie)

You can find code and links to all my threads
[here](https://github.com/neilcuz/threads).

## Setup the targets package

First we need to install and load the targets package.

``` r
if (!require(targets)) install.packages("targets")

library(targets)
```

Now we need to initialise the \_targets.R file. This controls the
pipeline. Luckily we can do it with a one-liner.

``` r
use_targets()
```

## An example pipeline

Load libraries required for inside the pipeline

``` r
library(tidyverse)
library(here)
```

Generate some fake data for the pipeline. `a` we will save as a CSV file
and `b` as an rds file.

``` r
# Create dataset A

stores <- c("glasgow", "oslo", "philadelphia", "montreal", "osaka", "seoul")

file_a <- file.path(here(), "dataset_a.csv")

stores |> 
  tibble(store = _,
         sales = c(runif(5, 50000, 100000), NA_real_)) |> 
  write_csv(file_a)
  
# Create dataset B

file_b <- file.path(here(), "dataset_b.rds")

tibble(region = rep(c("EUROPE", "NORTH AMERICA", "ASIA"), each = 2),
       store = str_to_sentence(stores),
       years_open = round(runif(6, 1, 15))) |> 
  write_rds(file_b)
```

We create some functions and save them in `functions.R`. These can
viewed [here](https://github.com/neilcuz/targets/blob/main/functions.R)
in their original script and can also be seen in the code chunk below.

``` r
clean_a <- function (a_raw) {
  
  a_raw |> 
    filter(!is.na(sales)) |> 
    mutate(store = str_to_sentence(store))
  
}

clean_b <- function (b_raw) {
  
  b_raw |> 
    mutate(region = str_to_sentence(region))
  
}

join_ab <- function (a_clean, b_clean) {
  
  left_join(a_clean, b_clean, by = "store") |> 
    select(region, store, sales, years_open)
  
}

quality_checks <- function (ab) {
  
  min_sales <- ab |> 
    pull(sales) |> 
    min()
  
  if (min_sales < 0) {
    
    message ("QA CHECK: Error in sales")
    
  }
  
  message ("QA Check: Sales ok")
  
  return (ab)
  
}

summarise_ab <- function (ab) {
  
  ab |> 
    group_by(region) |> 
    summarise(mean_sales = mean(sales)) |> 
    arrange(mean_sales)
  
}
```

We can use read_csv and read_rds to read in the files so we don’t need
to define new functions here.

Now we edit the \_targets.R file directly which you can see
[here](https://github.com/neilcuz/targets/blob/main/_targets.R). The
code in this file is also in the chunk below.

``` r
# Load packages required to define the pipeline:

library(targets) # Crucial to any pipeline
suppressMessages(library(tidyverse) )
suppressMessages(library(here))

source(file.path(here(), "functions.R")) # Load functions

# Set target options:

tar_option_set(packages = c("tidyverse", "here"))

list(
  tar_target(file_a, 
             file.path(here(), "dataset_a.csv"),
             format = "file"),
  
  tar_target(file_b, 
             file.path(here(), "dataset_b.rds"),
             format = "file"),  
  
  tar_target(a_raw, read_csv(file_a, show_col_types = FALSE)),
  
  tar_target(b_raw, read_rds(file_b)),
  
  tar_target(a_clean, clean_a(a_raw)),
  
  tar_target(b_clean, clean_b(b_raw)),
  
  tar_target(ab, join_ab(a_clean, b_clean)),
  
  tar_target(qa_message, quality_checks(ab)),
  
  tar_target(summary_stats, summarise_ab(ab))
  
)
```

## Inspect the pipeline

`tar_manifest` gives a handy table detailing the pipeline

``` r
tar_manifest()
```

`tar_visnetwork` gives you a plot of the pipeline. You will need to
install `visNetwork` but a prompt comes up so I’ve omitted. I’ve omitted
the plot for GitHub because rendering was a little complicated.

``` r
tar_visnetwork()
```

## Run the pipeline

If running for the first time then the whole pipeline will be ran.

``` r
tar_make()
```

    • start target file_b
    • built target file_b [0 seconds]
    • start target file_a
    • built target file_a [0 seconds]
    • start target b_raw
    • built target b_raw [0 seconds]
    • start target a_raw
    • built target a_raw [0.059 seconds]
    • start target b_clean
    • built target b_clean [0.006 seconds]
    • start target a_clean
    • built target a_clean [0.003 seconds]
    • start target ab
    • built target ab [0.006 seconds]
    • start target qa_message
    QA Check: Sales ok
    • built target qa_message [0.001 seconds]
    • start target summary_stats
    • built target summary_stats [0.005 seconds]
    • end pipeline [0.184 seconds]

What happens though when we update dataset `a` only.

``` r
stores |> 
  tibble(store = _,
         sales = c(runif(5, 50000, 100000), NA_real_)) |> 
  write_csv(file_a)
```

Re-run the pipeline. Notice that reading in and cleaning file b have
both been skipped because there were no changes. If a run takes a while
that could be a good time saving.

``` r
tar_make()
```

    ✔ skip target file_b
    • start target file_a
    • built target file_a [0.001 seconds]
    ✔ skip target b_raw
    • start target a_raw
    • built target a_raw [0.06 seconds]
    ✔ skip target b_clean
    • start target a_clean
    • built target a_clean [0.007 seconds]
    • start target ab
    • built target ab [0.005 seconds]
    • start target qa_message
    QA Check: Sales ok
    • built target qa_message [0.001 seconds]
    • start target summary_stats
    • built target summary_stats [0.005 seconds]
    • end pipeline [0.178 seconds]
