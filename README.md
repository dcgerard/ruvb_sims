# Reproducing Results of Gerard and Stephens (2016)
David Gerard  

# Instructions

To reproduce the results of @gerard2016unifying, you need to (1) install the appropriate R packages, (2) obtain the appropriate data, (3) run `make` and (4) get some coffee while you wait.

## Install R Packages

To install the needed R packages, run the following in R

``` r
install.packages(c("dplyr", "stringr", "ggplot2", "reshape2", "pROC",
                   "ruv", "cate", "gridExtra", "snow", "devtools"))
source("https://bioconductor.org/biocLite.R")
biocLite(c("sva", "limma"))
devtools::install_github("dcgerard/vicar")
```


## Get Data

Place the following files in the Data folder:

1. [GTEx_Data_V6_Annotations_SampleAttributesDS.txt](http://www.gtexportal.org/home/datasets#filesetFilesDiv21)
2. [GTEx_Analysis_v6p_RNA-seq_RNA-SeQCv1.1.8_gene_reads.gct.gz](http://www.gtexportal.org/home/datasets#filesetFilesDiv11)
3. [gencode.v19.genes.V6p_model.patched_contigs.gtf](http://www.gtexportal.org/home/datasets#filesetFilesDiv14)
4. [GTEx_Data_V6_Annotations_SubjectPhenotypesDS.txt](http://www.gtexportal.org/home/datasets#datasetDiv2)
5. [HK_genes.txt](http://www.tau.ac.il/~elieis/HKG/HK_genes.txt)
6. [gene2ensembl.gz](ftp://ftp.ncbi.nih.gov/gene/DATA/)

## Run Make

Then simply run `make` from the terminal.

If you want to reproduce just the results from Section 6.1, run
``` bash
make sims
```

If you want to reproduce just the results from Section 6.2, run
``` bash
make gtex_analysis
```

If you want to reproduce the figure in the introduction, run
``` bash
make one_data
```

## Get Coffee

All of these runs (except the last one) should take a very long time
(a day to a couple of days). You should get some coffee. If you're in
the Chicago area, I would recommend
[Plein Air Cafe](http://www.pleinaircafe.co/).

# References
