data/raw/gusto.rda : code/GetGustoData.sh
	$<

figures/deviate_linear_08.png : code/PlotDeviations.R\
	code/helpers/PlotGammas.R\
	data/processed/analysisIds.csv\
	data/processed/analysisIdsInteractions.csv
	$<


figures/rmse_moderate_base.png : code/PlotRmse.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	code/helpers/Absolute.R\
	data/processed/rmse.csv\
	data/processed/analysisIds.csv
	$< moderate 4250 0.75 base

figures/rmse_moderate_sample_size.png : code/PlotRmse.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	code/helpers/Absolute.R\
	data/processed/rmse.csv\
	data/processed/analysisIds.csv
	$< moderate 17000 0.75 sample_size

figures/rmse_moderate_auc.png : code/PlotRmse.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	code/helpers/Absolute.R\
	data/processed/rmse.csv\
	data/processed/analysisIds.csv
	$< moderate 4250 0.85 auc

figures/discrimination_moderate_base.png : code/DiscriminationBase.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	data/processed/discrimination.csv\
	data/processed/analysisIds.csv
	$< moderate 4250 0.75 base

figures/discrimination_moderate_sample_size.png : code/DiscriminationBase.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	data/processed/discrimination.csv\
	data/processed/analysisIds.csv
	$< moderate 17000 0.75 sample_size

figures/discrimination_moderate_auc.png : code/DiscriminationBase.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	data/processed/discrimination.csv\
	data/processed/analysisIds.csv
	$< moderate 4250 0.85 auc

figures/calibration_moderate_base.png : code/CalibrationBase.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	data/processed/calibration.csv
	$< moderate 4250 0.75 base

figures/calibration_moderate_sample_size.png : code/CalibrationBase.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	data/processed/calibration.csv
	$< moderate 17000 0.75 sample_size

figures/calibration_moderate_auc.png : code/CalibrationBase.R\
	code/helpers/CreateManuscriptPlots.R\
	code/helpers/PlotResult.R\
	data/processed/calibration.csv
	$< moderate 4250 0.85 auc

figures/gusto.png : code/GustoPlot.R\
	data/raw/gusto.rda
	$<

index.html : index.Rmd\
  figures/gusto.png\
  figures/rmse_moderate_base.png\
  figures/deviate_linear_08.png\
  figures/rmse_moderate_sample_size.png\
  figures/rmse_moderate_auc.png\
  figures/discrimination_moderate_base.png\
  figures/discrimination_moderate_auc.png\
  figures/discrimination_moderate_sample_size.png\
  figures/calibration_moderate_base.png\
  figures/calibration_moderate_auc.png\
  figures/calibration_moderate_sample_size.png
	R -e 'rmarkdown::render("index.Rmd", output_format = "all")'
