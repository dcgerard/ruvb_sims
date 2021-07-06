Reproducing Results of Gerard and Stephens (2021)
================

# Introduction

This repository contains code to reproduce the empirical evaluations of
Gerard and Stephens (2021). The new methods can be found in the
[vicar](https://github.com/dcgerard/vicar) package.

If you are having trouble reproducing these results, it might be that
you need to update some of your R packages. These are the versions that
I used:

``` r
sessionInfo()
```

    ## R version 4.1.0 (2021-05-18)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 20.04.2 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/liblapack.so.3
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
    ##  [1] broom_0.7.8         R.utils_2.10.1      R.oo_1.24.0        
    ##  [4] R.methodsS3_1.8.1   assertthat_0.2.1    seqgendiff_1.2.2   
    ##  [7] vicar_0.1-11        limma_3.48.1        sva_3.40.0         
    ## [10] BiocParallel_1.26.1 genefilter_1.74.0   mgcv_1.8-36        
    ## [13] nlme_3.1-152        devtools_2.4.2      usethis_2.0.1      
    ## [16] snow_0.4-3          gridExtra_2.3       cate_1.1.1         
    ## [19] ruv_0.9.7.1         pROC_1.17.0.1       forcats_0.5.1      
    ## [22] stringr_1.4.0       dplyr_1.0.7         purrr_0.3.4        
    ## [25] readr_1.4.0         tidyr_1.1.3         tibble_3.1.2       
    ## [28] ggplot2_3.3.5       tidyverse_1.3.1    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] colorspace_2.0-2       ellipsis_0.3.2         rprojroot_2.0.2       
    ##  [4] corpcor_1.6.9          XVector_0.32.0         fs_1.5.0              
    ##  [7] rstudioapi_0.13        remotes_2.4.0          leapp_1.2             
    ## [10] bit64_4.0.5            AnnotationDbi_1.54.1   fansi_0.5.0           
    ## [13] lubridate_1.7.10       xml2_1.3.2             splines_4.1.0         
    ## [16] cachem_1.0.5           knitr_1.33             pkgload_1.2.1         
    ## [19] jsonlite_1.7.2         annotate_1.70.0        dbplyr_2.1.1          
    ## [22] png_0.1-7              compiler_4.1.0         httr_1.4.2            
    ## [25] backports_1.2.1        Matrix_1.3-4           fastmap_1.1.0         
    ## [28] cli_3.0.0              htmltools_0.5.1.1      prettyunits_1.1.1     
    ## [31] tools_4.1.0            gtable_0.3.0           glue_1.4.2            
    ## [34] GenomeInfoDbData_1.2.6 Rcpp_1.0.6             Biobase_2.52.0        
    ## [37] cellranger_1.1.0       vctrs_0.3.8            Biostrings_2.60.1     
    ## [40] xfun_0.24              ps_1.6.0               testthat_3.0.4        
    ## [43] rvest_1.0.0            lifecycle_1.0.0        XML_3.99-0.6          
    ## [46] edgeR_3.34.0           MASS_7.3-54            zlibbioc_1.38.0       
    ## [49] scales_1.1.1           hms_1.1.0              parallel_4.1.0        
    ## [52] yaml_2.2.1             memoise_2.0.0          stringi_1.6.2         
    ## [55] RSQLite_2.2.7          desc_1.3.0             S4Vectors_0.30.0      
    ## [58] BiocGenerics_0.38.0    pkgbuild_1.2.0         GenomeInfoDb_1.28.1   
    ## [61] rlang_0.4.11           pkgconfig_2.0.3        bitops_1.0-7          
    ## [64] matrixStats_0.59.0     evaluate_0.14          lattice_0.20-44       
    ## [67] esaBcv_1.2.1           bit_4.0.4              tidyselect_1.1.1      
    ## [70] processx_3.5.2         plyr_1.8.6             magrittr_2.0.1        
    ## [73] R6_2.5.0               IRanges_2.26.0         generics_0.1.0        
    ## [76] DBI_1.1.1              pillar_1.6.1           haven_2.4.1           
    ## [79] withr_2.4.2            survival_3.2-11        KEGGREST_1.32.0       
    ## [82] RCurl_1.98-1.3         modelr_0.1.8           crayon_1.4.1          
    ## [85] utf8_1.2.1             rmarkdown_2.9          locfit_1.5-9.4        
    ## [88] grid_4.1.0             readxl_1.3.1           blob_1.2.1            
    ## [91] callr_3.7.0            reprex_2.0.0           digest_0.6.27         
    ## [94] svd_0.5                xtable_1.8-4           stats4_4.1.0          
    ## [97] munsell_0.5.0          sessioninfo_1.1.1

I’ve also only tried this out on Ubuntu.

If you find a bug, please create an
[issue](https://github.com/dcgerard/ruvb_sims/issues).

# Instructions

To reproduce the results of Gerard and Stephens (2021), you need to (1)
install the appropriate R packages, (2) obtain the appropriate data, (3)
run `make` and (4) get some coffee while you wait.

## Install R Packages

To install the needed R packages, run the following in R

``` r
devtools::install_version("ruv", 
                          version = "0.9.6", 
                          repos = "http://cran.us.r-project.org")
install.packages(c("tidyverse", "pROC", "cate", "gridExtra", "broom",
                   "snow", "devtools", "assertthat", "R.utils",
                   "BiocManager"))
BiocManager::install(c("sva", "limma"), update = FALSE)
devtools::install_github("dcgerard/vicar",
                         ref = "e7caad35b403d83546680a89f5af2b3b4ed5fe6a")
devtools::install_github("dcgerard/seqgendiff",
                         ref = "a2fe006e8012cbfe5295e6212938e9fb865be63b")
```

-   `ruv` was updated and now the equivalencies between the `vicar`
    method and the `ruv` method are not *exactly* the same. This is why
    we install version 0.9.6 of `ruv`.

-   Newer versions of `seqgendiff` should not work as the `poisthin()`
    function has been replaced by `select_counts()` and `thin_2group()`.

## Get Data

Place the following files in the Data folder:

1.  [GTEx\_Data\_V6\_Annotations\_SampleAttributesDS.txt](http://www.gtexportal.org/home/datasets#filesetFilesDiv21)
2.  [GTEx\_Analysis\_v6p\_RNA-seq\_RNA-SeQCv1.1.8\_gene\_reads.gct.gz](http://www.gtexportal.org/home/datasets#filesetFilesDiv11)

These files are only available if you are a registered user of the GTEx
Portal. You can create a free account at <https://gtexportal.org/>

## Run Make

To reproduce all of the results in Gerard and Stephens (2021), simply
run `make` from the terminal.

If you want to reproduce just the simulation results in the main text,
run

``` bash
make sims
```

If you want to reproduce the supplementary simulations with correlated
confounders, run

``` bash
make corr
```

If you want to reproduce the supplementary simulations with misspecified
negative controls, run

``` bash
make miss
```

If you want to reproduce the figure in the introduction, run

``` bash
make one_data
```

## Get Coffee

These runs should take a very long time (a day to a couple of days). You
should get some coffee. Here is a list of some of my favorite places:

-   Washington, DC
    -   [Colony Club](https://www.yelp.com/biz/colony-club-washington)
    -   [Grace Street
        Coffee](https://www.yelp.com/biz/grace-street-coffee-georgetown)
-   Chicago
    -   [Sawada Coffee](https://www.yelp.com/biz/sawada-coffee-chicago)
    -   [Plein Air
        Cafe](https://www.yelp.com/biz/plein-air-cafe-and-eatery-chicago-2)
-   Seattle
    -   [Bauhaus
        Ballard](https://www.yelp.com/biz/bauhaus-ballard-seattle)
    -   [Cafe Solstice](https://www.yelp.com/biz/cafe-solstice-seattle)
-   Columbus
    -   [Yeah, Me Too](https://www.yelp.com/biz/yeah-me-too-columbus)
    -   [Stauf’s Coffee
        Roasters](https://www.yelp.com/biz/staufs-coffee-roasters-columbus-2)

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-gerard2021unifying" class="csl-entry">

Gerard, David, and Matthew Stephens. 2021. “Unifying and Generalizing
Methods for Removing Unwanted Variation Based on Negative Controls.”
*Statistica Sinica* 31 (3): 1145–66.
<https://doi.org/10.5705/ss.202018.0345>.

</div>

</div>
