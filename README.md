Reproducing Results of Gerard and Stephens (2017)
================

Introduction
============

This repository contains code to reproduce the empirical evaluations of Gerard and Stephens (2017). The new methods can be found in the [vicar](https://github.com/dcgerard/vicar) package.

If you are having trouble reproducing these results, it might be that you need to update some of your R packages. These are the versions that I used:

``` r
sessionInfo()
```

    ## R version 3.4.4 (2018-03-15)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 16.04.4 LTS
    ## 
    ## Matrix products: default
    ## BLAS: /usr/lib/atlas-base/atlas/libblas.so.3.0
    ## LAPACK: /usr/lib/atlas-base/atlas/liblapack.so.3.0
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
    ##  [1] R.utils_2.6.0     R.oo_1.21.0       R.methodsS3_1.7.1
    ##  [4] assertthat_0.2.0  seqgendiff_0.1.0  vicar_0.1-9      
    ##  [7] limma_3.26.9      sva_3.18.0        genefilter_1.52.1
    ## [10] mgcv_1.8-23       nlme_3.1-137      devtools_1.13.5  
    ## [13] snow_0.4-2        gridExtra_2.3     cate_1.0.4       
    ## [16] ruv_0.9.7         pROC_1.11.0       forcats_0.3.0    
    ## [19] stringr_1.3.0     dplyr_0.7.4       purrr_0.2.4      
    ## [22] readr_1.1.1       tidyr_0.8.0       tibble_1.4.2     
    ## [25] ggplot2_2.2.1     tidyverse_1.2.1  
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] Biobase_2.30.0       svd_0.4              httr_1.3.1          
    ##  [4] jsonlite_1.5         splines_3.4.4        modelr_0.1.1        
    ##  [7] stats4_3.4.4         cellranger_1.1.0     yaml_2.1.14         
    ## [10] pillar_1.2.1         RSQLite_1.1-2        backports_1.0.5     
    ## [13] lattice_0.20-34      glue_1.2.0           digest_0.6.12       
    ## [16] rvest_0.3.2          colorspace_1.3-2     htmltools_0.3.5     
    ## [19] Matrix_1.2-14        plyr_1.8.4           psych_1.6.12        
    ## [22] XML_3.98-1.10        pkgconfig_2.0.1      esaBcv_1.2.1        
    ## [25] broom_0.4.3          haven_1.1.1          xtable_1.8-2        
    ## [28] corpcor_1.6.8        scales_0.5.0         annotate_1.48.0     
    ## [31] IRanges_2.4.8        withr_1.0.2          BiocGenerics_0.16.1 
    ## [34] lazyeval_0.2.0       cli_1.0.0            mnormt_1.5-5        
    ## [37] survival_2.41-3      magrittr_1.5         crayon_1.3.4        
    ## [40] readxl_1.0.0         memoise_1.0.0        evaluate_0.10       
    ## [43] MASS_7.3-45          xml2_1.2.0           foreign_0.8-69      
    ## [46] tools_3.4.4          hms_0.4.2            S4Vectors_0.8.11    
    ## [49] munsell_0.4.3        AnnotationDbi_1.32.3 bindrcpp_0.2        
    ## [52] compiler_3.4.4       rlang_0.2.0          grid_3.4.4          
    ## [55] leapp_1.2            rstudioapi_0.7       rmarkdown_1.9       
    ## [58] gtable_0.2.0         DBI_0.8              reshape2_1.4.3      
    ## [61] R6_2.2.2             lubridate_1.7.3      knitr_1.20          
    ## [64] bindr_0.1            rprojroot_1.3-2      stringi_1.1.7       
    ## [67] parallel_3.4.4       Rcpp_0.12.16

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
                   "cate", "gridExtra", "snow", "devtools", 
                   "assertthat", "R.utils"))
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
