# The overall similarity of the emotion ratings between GPT-4 and humans for video dataset 2
#
# Lauri Suominen 21.8.2025

library(dplyr)
library(tidyr)
library(ggplot2)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load GPT and human CSV files

gpt_file <- read.csv('path/data/VD2/ratings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
human_file <- read.csv('path/data/VD2/ratings/data/human_data/average_ratings/combined_averages_gpt-4-1.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Rename columns and reshape data to long format

# Rename columns
colnames(gpt_file)[colnames(gpt_file) == "Unnamed..0"] <- "videoNames"
colnames(human_file)[colnames(human_file) == "Row"] <- 'videoNames'

# Convert gpt data to long format
gpt_long <- gpt_file %>%
  pivot_longer(cols = -videoNames, names_to = "variable", values_to = "gpt_value")

# Convert human data to long format
human_long <- human_file %>%
  pivot_longer(cols = -videoNames, names_to = "variable", values_to = "human_value")

# Merge the two long-format datasets by video name and emotion variable
combined_data <- merge(gpt_long, human_long)

# Make a copy of the merged data for normalization
norm_emotions <- combined_data

# Normalize GPT and human values from original scale (1–9) to 0–10 scale
norm_emotions$gpt_value <- ((norm_emotions$gpt_value-1)/(9 - 1))*10
norm_emotions$human_value <- ((norm_emotions$human_value-1)/(9-1))*10

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot normalized scatterplot and save as PDF

# Scatterplot on all emotions
pdf('path/VD2_human_vs_gpt_norm_scatterplot.pdf', width = 10, height = 9)
ggplot(norm_emotions, aes(x = human_value, y = gpt_value)) +
  # Use hex bins to show density of overlapping points
  geom_hex(bins = 25, aes(fill = ..count../sum(..count..), alpha = ..count..)) + 
  # Define gradient color for density
  scale_fill_gradientn(colors = c('blue', 'red')) +
  # Define transparency scale
  scale_alpha_continuous(range = c(0.1,30)) + 
  # Use minimal theme for clean visuals
  theme_minimal() + 
  # Fix axis limits
  coord_cartesian(xlim = c(0,10), ylim = c(0,10)) + 
  # Axis labels
  labs(x = 'Human average', y = 'GPT-4') + 
  # Customize font sizes
  theme(axis.title = element_text(size = 28),
        plot.title = element_text(hjust = 0.5, size = 32),
        axis.text.x = element_text(size = 24),
        axis.text.y = element_text(size = 24)) +
  # Add y = x reference line for comparison
  geom_abline(slope = 1, intercept = 0, color = 'black', linewidth = 3)
dev.off()

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Calculate and print Pearson correlation coefficient between GPT and human ratings

correlation <- cor(combined_data$gpt_value, combined_data$human_value, method = 'pearson')
print(correlation)
