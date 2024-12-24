rm(list = ls())

source("synthetic_data/data_gen_code/data_gen_utils.R")

library(dplyr)
library(ggpubr)
library(gridExtra)
library(SynSigGen) # remotes::install_github(repo = "steverozen/SynSigGen",ref = "1.2.2-branch")
library(ICAMS) # remotes::install_github("steverozen/ICAMS", ref = "v3.0.8-branch")
library(mSigAct) # remotes::install_github(repo = "steverozen/mSigAct", ref = "v3.0.1-branch")
library(PCAWG7) # remotes::install_github(repo = "steverozen/PCAWG7", ref = "v0.1.3-branch")
library(cosmicsig) # remotes::install_github(repo = "Rozen-Lab/cosmicsig", ref = "v1.2.0-branch")

# Add noise to noiseless synthetic data with different negative-binomial size
# parameter
dir_noiseless_sbs <-
  "synthetic_data/SBS/intermed_results/SBS96.syn.exposures.no.noise/"
noiseless_data_sbs <- get_syn_data_info(dir = dir_noiseless_sbs)
seed <- 658220

nb_sizes_sbs <- 1:100

total_cores <- parallel::detectCores()
cores_to_use <- round(total_cores / 2)

sbs40 <-
  cosmicsig::COSMIC_v3.3$signature$GRCh37$SBS96[, "SBS40", drop = FALSE]
sigs_sbs <-
  cbind(cosmicsig::COSMIC_v3.4$signature$GRCh37$SBS96, sbs40)

noise_data_sbs <- generate_noisy_data(
  seed = seed,
  exposure = noiseless_data_sbs$exposure,
  sigs = sigs_sbs,
  nb_sizes = nb_sizes_sbs,
  mc_cores = cores_to_use
)
syn_distance_sbs <-
  get_multiple_syn_distances(
    list_of_syn_data = noise_data_sbs,
    mc_cores = cores_to_use
  )

median_cosines <- list()

for (group in names(syn_distance_sbs)) {
  syn_distances <- syn_distance_sbs[[group]][["cosine"]]
  median_cosines[[group]] <- median(syn_distances)
}


df <- data.frame(median_cosine = unlist(median_cosines))
df2 <-
  dplyr::tibble(
    size = rownames(df),
    median_cosine = df$median_cosine,
    abs_median_cosine_minus_0.985 = abs(df$median_cosine - 0.985)
  )

output_home <- "synthetic_data/noise_selection/output"

if (!dir.exists(output_home)) {
  dir.create(output_home, recursive = TRUE)
}
write.csv(df2,
  file = file.path(
    output_home,
    "SBS_syn_data_median_cosine.csv"
  ),
  row.names = FALSE
)

df3 <- df2[which.min(df2$abs_median_cosine_minus_0.985), ]
df3$size #"size_18"
