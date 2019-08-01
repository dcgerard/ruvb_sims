Reproducing Results of Gerard and Stephens (2017)
================

# Introduction

This repository contains code to reproduce the empirical evaluations of
Gerard and Stephens (2017). The new methods can be found in the
[vicar](https://github.com/dcgerard/vicar) package.

If you are having trouble reproducing these results, it might be that
you need to update some of your R packages. These are the versions that
I used:

``` r
sessionInfo()
```

    ## R version 3.6.1 (2019-07-05)
    ## Platform: x86_64-w64-mingw32/x64 (64-bit)
    ## Running under: Windows 10 x64 (build 17134)
    ## 
    ## Matrix products: default
    ## 
    ## locale:
    ## [1] LC_COLLATE=English_United States.1252 
    ## [2] LC_CTYPE=English_United States.1252   
    ## [3] LC_MONETARY=English_United States.1252
    ## [4] LC_NUMERIC=C                          
    ## [5] LC_TIME=English_United States.1252    
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] broom_0.5.2         R.utils_2.9.0       R.oo_1.22.0        
    ##  [4] R.methodsS3_1.7.1   assertthat_0.2.1    seqgendiff_1.0.0   
    ##  [7] vicar_0.1-9         limma_3.40.6        sva_3.32.1         
    ## [10] BiocParallel_1.18.0 genefilter_1.66.0   mgcv_1.8-28        
    ## [13] nlme_3.1-141        devtools_2.1.0      usethis_1.5.1      
    ## [16] snow_0.4-3          gridExtra_2.3       cate_1.0.4         
    ## [19] ruv_0.9.6           pROC_1.15.3         forcats_0.4.0      
    ## [22] stringr_1.4.0       dplyr_0.8.3         purrr_0.3.2        
    ## [25] readr_1.3.1         tidyr_0.8.3         tibble_2.1.3       
    ## [28] ggplot2_3.2.0       tidyverse_1.2.1    
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] svd_0.4.3            bitops_1.0-6         matrixStats_0.54.0  
    ##  [4] fs_1.3.1             lubridate_1.7.4      bit64_0.9-7         
    ##  [7] httr_1.4.0           rprojroot_1.3-2      tools_3.6.1         
    ## [10] backports_1.1.4      R6_2.4.0             DBI_1.0.0           
    ## [13] lazyeval_0.2.2       BiocGenerics_0.30.0  colorspace_1.4-1    
    ## [16] withr_2.1.2          prettyunits_1.0.2    processx_3.4.1      
    ## [19] tidyselect_0.2.5     bit_1.1-14           compiler_3.6.1      
    ## [22] cli_1.1.0            rvest_0.3.4          Biobase_2.44.0      
    ## [25] xml2_1.2.1           desc_1.2.0           scales_1.0.0        
    ## [28] callr_3.3.1          esaBcv_1.2.1         digest_0.6.20       
    ## [31] rmarkdown_1.14       pkgconfig_2.0.2      htmltools_0.3.6     
    ## [34] sessioninfo_1.1.1    rlang_0.4.0          readxl_1.3.1        
    ## [37] rstudioapi_0.10      RSQLite_2.1.2        generics_0.0.2      
    ## [40] jsonlite_1.6         leapp_1.2            RCurl_1.95-4.12     
    ## [43] magrittr_1.5         Matrix_1.2-17        Rcpp_1.0.2          
    ## [46] munsell_0.5.0        S4Vectors_0.22.0     stringi_1.4.3       
    ## [49] yaml_2.2.0           MASS_7.3-51.4        pkgbuild_1.0.3      
    ## [52] plyr_1.8.4           grid_3.6.1           blob_1.2.0          
    ## [55] parallel_3.6.1       crayon_1.3.4         lattice_0.20-38     
    ## [58] haven_2.1.1          splines_3.6.1        annotate_1.62.0     
    ## [61] hms_0.5.0            ps_1.3.0             zeallot_0.1.0       
    ## [64] knitr_1.23           pillar_1.4.2         corpcor_1.6.9       
    ## [67] pkgload_1.0.2        stats4_3.6.1         XML_3.98-1.20       
    ## [70] glue_1.3.1           evaluate_0.14        remotes_2.1.0       
    ## [73] modelr_0.1.4         vctrs_0.2.0          testthat_2.2.1      
    ## [76] cellranger_1.1.0     gtable_0.3.0         xfun_0.8            
    ## [79] xtable_1.8-4         survival_2.44-1.1    AnnotationDbi_1.46.0
    ## [82] memoise_1.1.0        IRanges_2.18.1

I’ve also only tried this out on Ubuntu.

If you find a bug, please create an
[issue](https://github.com/dcgerard/ruvb_sims/issues).

# Instructions

To reproduce the results of Gerard and Stephens (2017), you need to (1)
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

  - `ruv` was updated and now the equivalencies between the `vicar`
    method and the `ruv` method are not *exactly* the same. This is why
    we install version 0.9.6 of `ruv`.

## Get Data

Place the following files in the Data
    folder:

1.  [GTEx\_Data\_V6\_Annotations\_SampleAttributesDS.txt](http://www.gtexportal.org/home/datasets#filesetFilesDiv21)
2.  [GTEx\_Analysis\_v6p\_RNA-seq\_RNA-SeQCv1.1.8\_gene\_reads.gct.gz](http://www.gtexportal.org/home/datasets#filesetFilesDiv11)

These files are only available if you are a registered user of the GTEx
Portal. You can create a free account at <https://gtexportal.org/>

## Run Make

To reproduce all of the results in Gerard and Stephens (2017), simply
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

  - Washington, DC
      - [Colony Club](https://www.yelp.com/biz/colony-club-washington)
      - [Grace Street
        Coffee](https://www.yelp.com/biz/grace-street-coffee-georgetown)
      - [Shop Made in
        DC](https://www.yelp.com/biz/shop-made-in-dc-washington)
  - Chicago
      - [Sawada Coffee](https://www.yelp.com/biz/sawada-coffee-chicago)
      - [Plein Air
        Cafe](https://www.yelp.com/biz/plein-air-cafe-and-eatery-chicago-2)
  - Seattle
      - [Bauhaus
        Ballard](https://www.yelp.com/biz/bauhaus-ballard-seattle)
      - [Cafe Solstice](https://www.yelp.com/biz/cafe-solstice-seattle)
  - Columbus
      - [Yeah, Me Too](https://www.yelp.com/biz/yeah-me-too-columbus)
      - [Stauf’s Coffee
        Roasters](https://www.yelp.com/biz/staufs-coffee-roasters-columbus-2)

# References

<div id="refs" class="references">

<div id="ref-gerard2017unifying">

Gerard, David, and Matthew Stephens. 2017. “Unifying and Generalizing
Methods for Removing Unwanted Variation Based on Negative Controls.”
*arXiv Preprint arXiv:1705.08393*. <https://arxiv.org/abs/1705.08393>.

</div>

</div>
