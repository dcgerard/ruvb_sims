sims_out = ./Output/sims_out/auc_mat2.csv \
	./Output/sims_out/cov_mat2.csv \
	./Output/sims_out/general_sims2.Rd \
	./Output/sims_out/mse_mat2.csv

all: one_data sims

## example of unobserved confounding
.PHONY : one_data
one_data : $(tissue_dat) ./R/one_dataset_run.R
	 mkdir -p Output/figures
	 Rscript ./R/one_dataset_run.R

## run simulations
$(sims_out) : $(tissue_dat) ./R/sims_ruv3paper_sims.R
	mkdir -p Output/sims_out
	Rscript ./R/sims_ruv3paper_sims.R

## plot simulations
.PHONY : sims
sims : $(sims_out) ./R/sim_plots_revamped_cleaned.R
	mkdir -p Output/figures
	Rscript ./R/sim_plots_revamped_cleaned.R
