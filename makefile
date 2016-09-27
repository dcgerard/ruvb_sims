## The data output from gtex_extract_tissues_v6p.R
tissue_dat = ./Output/gtex_tissue_gene_reads_v6p/adiposetissue.csv \
	     ./Output/gtex_tissue_gene_reads_v6p/bladder.csv \
             ./Output/gtex_tissue_gene_reads_v6p/bloodvessel.csv \
             ./Output/gtex_tissue_gene_reads_v6p/breast.csv \
             ./Output/gtex_tissue_gene_reads_v6p/colon.csv \
             ./Output/gtex_tissue_gene_reads_v6p/fallopiantube.csv \
             ./Output/gtex_tissue_gene_reads_v6p/kidney.csv \
             ./Output/gtex_tissue_gene_reads_v6p/lung.csv \
             ./Output/gtex_tissue_gene_reads_v6p/nerve.csv \
             ./Output/gtex_tissue_gene_reads_v6p/pancreas.csv \
             ./Output/gtex_tissue_gene_reads_v6p/prostate.csv \
             ./Output/gtex_tissue_gene_reads_v6p/skin.csv \
             ./Output/gtex_tissue_gene_reads_v6p/spleen.csv \
             ./Output/gtex_tissue_gene_reads_v6p/testis.csv \
             ./Output/gtex_tissue_gene_reads_v6p/uterus.csv \
             ./Output/gtex_tissue_gene_reads_v6p/adrenalgland.csv \
             ./Output/gtex_tissue_gene_reads_v6p/blood.csv \
             ./Output/gtex_tissue_gene_reads_v6p/brain.csv \
             ./Output/gtex_tissue_gene_reads_v6p/cervixuteri.csv \
             ./Output/gtex_tissue_gene_reads_v6p/esophagus.csv \
             ./Output/gtex_tissue_gene_reads_v6p/heart.csv \
             ./Output/gtex_tissue_gene_reads_v6p/liver.csv \
             ./Output/gtex_tissue_gene_reads_v6p/muscle.csv \
             ./Output/gtex_tissue_gene_reads_v6p/ovary.csv \
             ./Output/gtex_tissue_gene_reads_v6p/pituitary.csv \
             ./Output/gtex_tissue_gene_reads_v6p/salivarygland.csv \
             ./Output/gtex_tissue_gene_reads_v6p/smallintestine.csv \
             ./Output/gtex_tissue_gene_reads_v6p/stomach.csv \
             ./Output/gtex_tissue_gene_reads_v6p/thyroid.csv \
             ./Output/gtex_tissue_gene_reads_v6p/vagina.csv

cleaned_dat = ./Output/cleaned_gtex_data/adiposetissue.Rds \
	      ./Output/cleaned_gtex_data/bladder.Rds \
	      ./Output/cleaned_gtex_data/bloodvessel.Rds \
	      ./Output/cleaned_gtex_data/breast.Rds \
	      ./Output/cleaned_gtex_data/esophagus.Rds \
	      ./Output/cleaned_gtex_data/kidney.Rds \
	      ./Output/cleaned_gtex_data/lung.Rds \
	      ./Output/cleaned_gtex_data/nerve.Rds \
	      ./Output/cleaned_gtex_data/pituitary.Rds \
	      ./Output/cleaned_gtex_data/skin.Rds \
	      ./Output/cleaned_gtex_data/spleen.Rds \
	      ./Output/cleaned_gtex_data/thyroid.Rds \
	      ./Output/cleaned_gtex_data/adrenalgland.Rds \
	      ./Output/cleaned_gtex_data/blood.Rds \
	      ./Output/cleaned_gtex_data/brain.Rds \
	      ./Output/cleaned_gtex_data/colon.Rds \
	      ./Output/cleaned_gtex_data/heart.Rds \
	      ./Output/cleaned_gtex_data/liver.Rds \
	      ./Output/cleaned_gtex_data/muscle.Rds \
	      ./Output/cleaned_gtex_data/pancreas.Rds \
	      ./Output/cleaned_gtex_data/salivarygland.Rds \
	      ./Output/cleaned_gtex_data/smallintestine.Rds \
	      ./Output/cleaned_gtex_data/stomach.Rds

sims_out = ./Output/sims_out/auc_mat2.csv \
	./Output/sims_out/cov_mat2.csv \
	./Output/sims_out/general_sims2.Rd \
	./Output/sims_out/mse_mat2.csv

ruvb_out = ./Output/ruvbout/ruvbout_adiposetissue.Rds \
	   ./Output/ruvbout/ruvbout_blood.Rds \
	   ./Output/ruvbout/ruvbout_breast.Rds \
	   ./Output/ruvbout/ruvbout_heart.Rds \
	   ./Output/ruvbout/ruvbout_lung.Rds \
	   ./Output/ruvbout/ruvbout_pancreas.Rds \
	   ./Output/ruvbout/ruvbout_skin.Rds \
	   ./Output/ruvbout/ruvbout_stomach.Rds \
	   ./Output/ruvbout/ruvbout_adrenalgland.Rds \
	   ./Output/ruvbout/ruvbout_bloodvessel.Rds \
	   ./Output/ruvbout/ruvbout_colon.Rds \
	   ./Output/ruvbout/ruvbout_kidney.Rds \
	   ./Output/ruvbout/ruvbout_muscle.Rds \
	   ./Output/ruvbout/ruvbout_pituitary.Rds \
	   ./Output/ruvbout/ruvbout_smallintestine.Rds \
	   ./Output/ruvbout/ruvbout_thyroid.Rds \
	   ./Output/ruvbout/ruvbout_bladder.Rds \
	   ./Output/ruvbout/ruvbout_brain.Rds \
	   ./Output/ruvbout/ruvbout_esophagus.Rds \
	   ./Output/ruvbout/ruvbout_liver.Rds \
	   ./Output/ruvbout/ruvbout_nerve.Rds \
	   ./Output/ruvbout/ruvbout_salivarygland.Rds \
	   ./Output/ruvbout/ruvbout_spleen.Rds



all: one_data gtex_analysis sims

## extract tissue data
$(tissue_dat) : ./R/gtex_extract_tissues_v6p.R
	mkdir -p Output/gtex_tissue_gene_reads_v6p
	Rscript ./R/gtex_extract_tissues_v6p.R

## clean tissue data for gtex analysis
$(cleaned_dat) : ./R/gtex_clean.R $(tissue_dat)
	mkdir -p Output/cleaned_gtex_data
	Rscript ./R/gtex_clean.R

## example of unobserved confounding
.PHONY : one_data
one_data : $(tissue_dat) ./R/one_dataset_run.R
	 mkdir -p Output/figures
	 Rscript ./R/one_dataset_run.R

## run gtex analysis
$(ruvb_out) : $(cleaned_dat) ./R/gtex_topk_analysis.R
	mkdir -p Output/ruvbout
	Rscript ./R/gtex_topk_analysis.R

## plot gtex_analysis
.PHONY : gtex_analysis
gtex_analysis : $(ruvb_out) ./R/gtex_raster_plot.R ./R/gtex_most_sig_qq.R
	mkdir -p Output/figures
	Rscript ./R/gtex_raster_plot.R
	Rscript ./R/gtex_most_sig_qq.R

## run simulations
$(sims_out) : $(tissue_dat) ./R/sims_ruv3paper_sims.R
	mkdir -p Output/sims_out
	Rscript ./R/sims_ruv3paper_sims.R

## plot simulations
.PHONY : sims
sims : $(sims_out) ./R/sims_paper_plots.R ./R/sims_paper_plots_line.R
	mkdir -p Output/figures
	Rscript ./R/sims_paper_plots.R
	Rscript ./R/sims_paper_plots_line.R
