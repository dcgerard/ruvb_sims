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

## Output from sims_ruv3paper_sims.R
sims_out = ./Output/sims_out/auc_mat2.csv \
	   ./Output/sims_out/cov_mat2.csv \
	   ./Output/sims_out/general_sims2.Rd \
	   ./Output/sims_out/mse_mat2.csv

## Output of sim_plots_revamped_cleaned.R
sim_plots = ./Output/figures/auc_boxplots.pdf \
	    ./Output/figures/auc_means.pdf \
	    ./Output/figures/ruvb_auc_means.pdf \
	    ./Output/figures/loss_plots.pdf \
	    ./Output/figures/coverage_best_boxplots.pdf \
	    ./Output/figures/coverage_medians.pdf \
	    ./Output/figures/combo_cov.pdf

## Output from correlation_sims.R
cor_sims_out = ./Output/cor_sims_out/cor_sims.RDS

## Plots of the results of cor_sims
cor_plots = ./Output/figures/cor_sims_auc.pdf \
            ./Output/figures/cov_box.pdf

## Output from misspecification sims
mis_sims_out = ./Output/mis_sims_out/mis_sims.RDS

## Plots of the reusults of mis_sims
mis_plots = ./Output/figures/mis_sims_auc.pdf \
	    ./Output/figures/mis_box.pdf

all: one_data sims corr miss

## extract tissue data
$(tissue_dat) : ./R/gtex_extract_tissues_v6p.R
	mkdir -p Output/gtex_tissue_gene_reads_v6p
	Rscript ./R/gtex_extract_tissues_v6p.R

## example of unobserved confounding
./Output/figures/all_null.pdf : $(tissue_dat) ./R/one_dataset_run.R
	 mkdir -p Output/figures
	 Rscript ./R/one_dataset_run.R

.PHONY : one_data
one_data : ./Output/figures/all_null.pdf

## run simulations
$(sims_out) : $(tissue_dat) ./R/sims_ruv3paper_sims.R
	mkdir -p Output/sims_out
	Rscript ./R/sims_ruv3paper_sims.R

## plot simulations
$(sim_plots) : $(sims_out) ./R/sim_plots_revamped_cleaned.R
	mkdir -p Output/figures
	Rscript ./R/sim_plots_revamped_cleaned.R

.PHONY : sims
sims : $(sim_plots)

## run correlation simulations
$(cor_sims_out) : $(tissue_dat) ./R/correlation_sims.R
	mkdir -p Output/cor_sims_out
	Rscript ./R/correlation_sims.R

$(cor_plots) : $(cor_sims_out) ./R/plot_correlation_sims.R
	mkdir -p Output/figures
	Rscript ./R/plot_correlation_sims.R

.PHONY : corr
corr : $(cor_plots)

## Run simulations where we misspecify the negative controls
$(mis_sims_out) : $(tissue_dat) ./R/misspecified_sims.R
	mkdir -p Output/mis_sims_out
	Rscript ./R/misspecified_sims.R

$(mis_plots) : $(mis_sims_out) ./R/plot_misspecified_sims.R
	mkdir -p Output/figures
	Rscript ./R/plot_misspecified_sims.R

.PHONY : miss
miss: $(mis_plots)
