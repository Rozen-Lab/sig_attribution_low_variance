library(mSigTools)
rm(list = ls())
olddir = "../new_attr_code"
rest = "analysis/raw_output/SBS/deconstruct/syn/inferred_exposures.csv"
new = mSigTools::read_exposure(file.path(".", rest))
old = mSigTools::read_exposure(file.path(olddir, rest))

syndata.rest = "/synthetic_data/SBS/ground.truth.syn.catalog.csv"
newin = ICAMS::ReadCatalog(file.path(".", syndata.rest))
oldin = ICAMS::ReadCatalog(file.path(olddir, syndata.rest))

sigs = ICAMS::ReadCatalog("synthetic_data/SBS/ground.truth.sigs.csv")

source("analysis/code/deconstruct_analysis.R")

testin = spectra = cbind(oldin[ ,1],newin[ , 1])
colnames(testin) = c("old", "new")
exp = call_deconstruct(testin, 
                 signatures = sigs,
                 more_args = list(signature.cutoff = 0.06))