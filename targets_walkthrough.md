Introduction to the targets package in R
================

<script src="targets_walkthrough_files/libs/htmlwidgets-1.5.4/htmlwidgets.js"></script>
<link href="targets_walkthrough_files/libs/vis-9.1.0/vis-network.min.css" rel="stylesheet" />
<script src="targets_walkthrough_files/libs/vis-9.1.0/vis-network.min.js"></script>
<script src="targets_walkthrough_files/libs/visNetwork-binding-2.1.2/visNetwork.js"></script>


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

    ✖ Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

    ℹ File "_targets.R" already exists. Stash and retry for a fresh copy.

    ℹ File "run.R" already exists. Stash and retry for a fresh copy.

    ℹ File "run.sh" already exists. Stash and retry for a fresh copy.

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
viewed [here]() in their original script and can also be seen in the
code chunk below.

We can use read_csv and read_rds to read in the files so we don’t need
to define new functions here.

Now we edit the [\_targets.R]() file directly which you can see
[here]().

## Inspect the pipeline

`tar_manifest` gives a handy table detailing the pipeline

``` r
tar_manifest()
```

    # A tibble: 9 × 2
      name          command                                   
      <chr>         <chr>                                     
    1 file_b        "file.path(here(), \"dataset_b.rds\")"    
    2 file_a        "file.path(here(), \"dataset_a.csv\")"    
    3 b_raw         "read_rds(file_b)"                        
    4 a_raw         "read_csv(file_a, show_col_types = FALSE)"
    5 b_clean       "clean_b(b_raw)"                          
    6 a_clean       "clean_a(a_raw)"                          
    7 ab            "join_ab(a_clean, b_clean)"               
    8 qa_message    "quality_checks(ab)"                      
    9 summary_stats "summarise_ab(ab)"                        

`tar_visnetwork` gives you a plot of the pipeline. You will need to
install `visNetwork` but a prompt comes up so I’ve omitted.

``` r
tar_visnetwork()
```

<div id="htmlwidget-5e57afc30b615204731f" style="width:672px;height:480px;" class="visNetwork html-widget"></div>
<script type="application/json" data-for="htmlwidget-5e57afc30b615204731f">{"x":{"nodes":{"name":["a_clean","a_raw","ab","b_clean","b_raw","file_a","file_b","qa_message","summary_stats","quality_checks","join_ab","summarise_ab","clean_a","clean_b"],"type":["stem","stem","stem","stem","stem","stem","stem","stem","stem","function","function","function","function","function"],"status":["outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","outdated","uptodate","uptodate","uptodate","uptodate","uptodate"],"seconds":[0.007,0.059,0.005,0.006,0,0,0.001,0.001,0.005,null,null,null,null,null],"bytes":[234,388,301,256,262,152,468,301,203,null,null,null,null,null],"branches":[null,null,null,null,null,null,null,null,null,null,null,null,null,null],"label":["a_clean","a_raw","ab","b_clean","b_raw","file_a","file_b","qa_message","summary_stats","quality_checks","join_ab","summarise_ab","clean_a","clean_b"],"color":["#78B7C5","#78B7C5","#78B7C5","#78B7C5","#78B7C5","#78B7C5","#78B7C5","#78B7C5","#78B7C5","#354823","#354823","#354823","#354823","#354823"],"id":["a_clean","a_raw","ab","b_clean","b_raw","file_a","file_b","qa_message","summary_stats","quality_checks","join_ab","summarise_ab","clean_a","clean_b"],"level":[3,2,4,3,2,1,1,5,5,1,1,1,1,1],"shape":["dot","dot","dot","dot","dot","dot","dot","dot","dot","triangle","triangle","triangle","triangle","triangle"]},"edges":{"from":["a_raw","clean_a","file_b","ab","quality_checks","ab","summarise_ab","file_a","b_raw","clean_b","a_clean","b_clean","join_ab"],"to":["a_clean","a_clean","b_raw","qa_message","qa_message","summary_stats","summary_stats","a_raw","b_clean","b_clean","ab","ab","ab"],"arrows":["to","to","to","to","to","to","to","to","to","to","to","to","to"]},"nodesToDataframe":true,"edgesToDataframe":true,"options":{"width":"100%","height":"100%","nodes":{"shape":"dot","physics":false},"manipulation":{"enabled":false},"edges":{"smooth":{"type":"cubicBezier","forceDirection":"horizontal"}},"physics":{"stabilization":false},"interaction":{"zoomSpeed":1},"layout":{"hierarchical":{"enabled":true,"direction":"LR"}}},"groups":null,"width":null,"height":null,"idselection":{"enabled":false,"style":"width: 150px; height: 26px","useLabels":true,"main":"Select by id"},"byselection":{"enabled":false,"style":"width: 150px; height: 26px","multiple":false,"hideColor":"rgba(200,200,200,0.5)","highlight":false},"main":{"text":"","style":"font-family:Georgia, Times New Roman, Times, serif;font-weight:bold;font-size:20px;text-align:center;"},"submain":null,"footer":null,"background":"rgba(0, 0, 0, 0)","highlight":{"enabled":true,"hoverNearest":false,"degree":{"from":1,"to":1},"algorithm":"hierarchical","hideColor":"rgba(200,200,200,0.5)","labelOnly":true},"collapse":{"enabled":true,"fit":false,"resetHighlight":true,"clusterOptions":null,"keepCoord":true,"labelSuffix":"(cluster)"},"legend":{"width":0.2,"useGroups":false,"position":"right","ncol":1,"stepX":100,"stepY":100,"zoom":true,"nodes":{"label":["Outdated","Up to date","Stem","Function"],"color":["#78B7C5","#354823","#899DA4","#899DA4"],"shape":["dot","dot","dot","triangle"]},"nodesToDataframe":true},"tooltipStay":300,"tooltipStyle":"position: fixed;visibility:hidden;padding: 5px;white-space: nowrap;font-family: verdana;font-size:14px;font-color:#000000;background-color: #f5f4ed;-moz-border-radius: 3px;-webkit-border-radius: 3px;border-radius: 3px;border: 1px solid #808074;box-shadow: 3px 3px 10px rgba(0, 0, 0, 0.2);"},"evals":[],"jsHooks":[]}</script>

## Run the pipeline

If running for the first time then the whole pipeline will be ran.

``` r
tar_make()
```

    • start target file_b
    • built target file_b [0.001 seconds]
    • start target file_a
    • built target file_a [0.001 seconds]
    • start target b_raw
    • built target b_raw [0 seconds]
    • start target a_raw
    • built target a_raw [0.059 seconds]
    • start target b_clean
    • built target b_clean [0.005 seconds]
    • start target a_clean
    • built target a_clean [0.002 seconds]
    • start target ab
    • built target ab [0.005 seconds]
    • start target qa_message
    QA Check: Sales ok
    • built target qa_message [0.001 seconds]
    • start target summary_stats
    • built target summary_stats [0.005 seconds]
    • end pipeline [0.182 seconds]

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
    • built target file_a [0 seconds]
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
