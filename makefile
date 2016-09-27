all: sims gtex_analysis one_data

extract:
	R CMD BATCH ./R/gtex_extract_tissues_v6p.R

clean: extract
	R CMD BATCH ./R/gtex_clean.R

gtex_analysis: clean
	R CMD BATCH ./R/gtex_topk_analysis.R
	R CMD BATCH ./R/gtex_raster_plot.R
	R CMD BATCH ./R/gtex_most_sig_qq.R

sims: extract
	R CMD BATCH ./R/sims_ruv3paper_sims.R
	R CMD BATCH ./R/sims_paper_plots.R
	R CMD BATCH ./R/sims_paper_plots_line.R

one_data: extract
	R CMD BATCH ./R/one_dataset_run.R
