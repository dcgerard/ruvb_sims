Reproducing Results of Gerard and Stephens (2017)
================

Introduction
============

This repository contains code to reproduce the empirical evaluations of Gerard and Stephens (2017). The new methods can be found in the [vicar](https://github.com/dcgerard/vicar) package.

If you are having trouble reproducing these results, it might be that you need to update some of your R packages. These are the versions that I used:

``` r
sessionInfo()
```

    ## R version 3.3.2 (2016-10-31)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 16.04.2 LTS
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] assertthat_0.2.0  seqgendiff_0.1.0  vicar_0.1.6      
    ##  [4] limma_3.26.9      sva_3.18.0        genefilter_1.52.1
    ##  [7] mgcv_1.8-17       nlme_3.1-131      devtools_1.12.0  
    ## [10] snow_0.4-2        gridExtra_2.2.1   cate_1.0.4       
    ## [13] ruv_0.9.6         pROC_1.9.1        stringr_1.2.0    
    ## [16] dplyr_0.5.0       purrr_0.2.2       readr_1.0.0      
    ## [19] tidyr_0.6.1       tibble_1.2        ggplot2_2.2.1    
    ## [22] tidyverse_1.1.1  
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Biobase_2.30.0       svd_0.4              httr_1.2.1          
    ##  [4] jsonlite_1.3         splines_3.3.2        modelr_0.1.0        
    ##  [7] stats4_3.3.2         yaml_2.1.14          RSQLite_1.1-2       
    ## [10] backports_1.0.5      lattice_0.20-34      digest_0.6.12       
    ## [13] rvest_0.3.2          colorspace_1.3-2     htmltools_0.3.5     
    ## [16] Matrix_1.2-8         plyr_1.8.4           psych_1.6.12        
    ## [19] XML_3.98-1.5         esaBcv_1.2.1         broom_0.4.2         
    ## [22] haven_1.0.0          xtable_1.8-2         corpcor_1.6.8       
    ## [25] scales_0.4.1         annotate_1.48.0      IRanges_2.4.8       
    ## [28] withr_1.0.2          BiocGenerics_0.16.1  lazyeval_0.2.0      
    ## [31] mnormt_1.5-5         survival_2.41-2      magrittr_1.5        
    ## [34] readxl_0.1.1         memoise_1.0.0        evaluate_0.10       
    ## [37] MASS_7.3-45          forcats_0.2.0        xml2_1.1.1          
    ## [40] foreign_0.8-67       tools_3.3.2          hms_0.3             
    ## [43] S4Vectors_0.8.11     munsell_0.4.3        AnnotationDbi_1.32.3
    ## [46] grid_3.3.2           leapp_1.2            rmarkdown_1.3       
    ## [49] gtable_0.2.0         DBI_0.6              reshape2_1.4.2      
    ## [52] R6_2.2.0             lubridate_1.6.0      knitr_1.15.1        
    ## [55] rprojroot_1.2        stringi_1.1.2        parallel_3.3.2      
    ## [58] Rcpp_0.12.11

As you can see above, I've also only tried this out on Ubuntu.

If you find a bug, please create an [issue](https://github.com/dcgerard/ruvb_sims/issues).

Instructions
============

To reproduce the results of Gerard and Stephens (2017), you need to (1) install the appropriate R packages, (2) obtain the appropriate data, (3) run `make` and (4) get some coffee while you wait.

Install R Packages
------------------

To install the needed R packages, run the following in R

``` r
install.packages(c("tidyverse", "stringr", "pROC", "ruv",
                   "cate", "gridExtra", "snow", "devtools", "assertthat"))
source("https://bioconductor.org/biocLite.R")
biocLite(c("sva", "limma"))
devtools::install_github("dcgerard/vicar")
devtools::install_github("dcgerard/seqgendiff")
```

Get Data
--------

Place the following files in the Data folder:

1.  [GTEx\_Data\_V6\_Annotations\_SampleAttributesDS.txt](http://www.gtexportal.org/home/datasets#filesetFilesDiv21)
2.  [GTEx\_Analysis\_v6p\_RNA-seq\_RNA-SeQCv1.1.8\_gene\_reads.gct.gz](http://www.gtexportal.org/home/datasets#filesetFilesDiv11)

These files are only available if you are a registered user of the GTEx Portal. I don't think I'm allowed to release these data.

Run Make
--------

To reproduce all of the results in Gerard and Stephens (2017), simply run `make` from the terminal.

If you want to reproduce just the simulation results, run

``` bash
make sims
```

If you want to reproduce the figure in the introduction, run

``` bash
make one_data
```

Get Coffee
----------

These runs should take a very long time (a day to a couple of days). You should get some coffee. Here is a list of some of my favorite places:

-   Chicago
    -   [Sawada Coffee](https://www.yelp.com/biz/sawada-coffee-chicago)
    -   [Plein Air Cafe](https://www.yelp.com/biz/plein-air-cafe-and-eatery-chicago-2)
-   Seattle
    -   [Bauhaus Ballard](https://www.yelp.com/biz/bauhaus-ballard-seattle)
    -   [Cafe Solstice](https://www.yelp.com/biz/cafe-solstice-seattle)
-   Columbus
    -   [Yeah, Me Too](https://www.yelp.com/biz/yeah-me-too-columbus)
    -   [Stauf's Coffee Roasters](https://www.yelp.com/biz/staufs-coffee-roasters-columbus-2)
    -   [Caffe Apropos](https://www.yelp.com/biz/caff%C3%A9-apropos-columbus-2)

References
==========

Gerard, David, and Matthew Stephens. 2017. “Unifying and Generalizing Methods for Removing Unwanted Variation Based on Negative Controls.” *Github Preprint*.
