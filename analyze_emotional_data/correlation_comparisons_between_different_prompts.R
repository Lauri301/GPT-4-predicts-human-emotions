# Correlations for each emotion in the image dataset across different prompts
#
# Lauri Suominen 3.3.2026

library(dplyr)
library(tidyr)
library(ggplot2)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Define file paths and save path
gpt_original_prompt_file <- read.csv('path/data/ID/ratings/data/gpt-4-1/original_prompt/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
gpt_prompt2_file <- read.csv('path/data/ID/ratings/data/gpt-4-1/alternative_prompt_1/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
gpt_prompt3_file <- read.csv('path/data/ID/ratings/data/gpt-4-1/alternative_prompt_2/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
csv_save_path <- 'path/analysis'

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SCRIPT

# Initializing the results table 'results'
results <- data.frame(
  emotion = colnames(gpt_original_prompt_file[2:ncol(gpt_original_prompt_file)]),
  correlation_between_OP_and_AP1 = numeric(ncol(gpt_original_prompt_file)-1),
  correlation_between_OP_and_AP2 = numeric(ncol(gpt_original_prompt_file)-1),
  correlation_between_AP1_and_AP2 = numeric(ncol(gpt_original_prompt_file)-1)
)

# Loop all columns, calculate correlations between different prompts and save the results in the table 'results'
for (i in 2:ncol(gpt_original_prompt_file)) {
  results$correlation_between_OP_and_AP1[i-1] <- cor(gpt_original_prompt_file[,i],gpt_prompt2_file[,i],method = 'pearson')
  results$correlation_between_OP_and_AP2[i-1] <- cor(gpt_original_prompt_file[,i],gpt_prompt3_file[,i],method = 'pearson')
  results$correlation_between_AP1_and_AP2[i-1] <- cor(gpt_prompt2_file[,i],gpt_prompt3_file[,i],method = 'pearson')
}

# Save csv-file
write.csv(results, file.path(csv_save_path, 'ID_correlations_between_different_prompts.csv'), row.names = FALSE)
