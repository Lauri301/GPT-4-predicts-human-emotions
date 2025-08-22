# Boxplot of emotion-specific distances between human and GPT-4 ratings for image dataset
#
# Lauri Suominen 21.8.2025

library(dplyr)
library(readr)
library(ggplot2)
library(stats)
library(tidyr)
library(tidyverse)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load GPT and human CSV files

gpt <- read.csv('path/data/ID/ratings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
human <- read.csv('path/data/ID/ratings/data/human_data/NAPS_human_average_ratings_gpt-4-1.csv)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Prepare and align data

# Sort rows by imageNames to ensure alignment between human and GPT tables
gpt <- gpt %>% arrange(imageNames)
human <- human %>% arrange(imageNames)

# Remove non-numeric columns (only keep emotion ratings)
dimensio_human <- human %>% select(-imageNames)
dimensio_gpt <- gpt %>% select(-imageNames)

# Ensure all values are numeric
dimensio_human <- as.data.frame(lapply(dimensio_human, as.numeric))
dimensio_gpt <- as.data.frame(lapply(dimensio_gpt, as.numeric))

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Separate emotion categories

# Extract basic emotions and arousal/valence from both GPT and human datasets
gpt_basic_emotions <- dimensio_gpt[, c('Anger', 'Disgust', 'Fear', 'Happiness', 'Sadness', 'Surprise')]
gpt_aro_val <- dimensio_gpt[, c('Arousal', 'Valence')]

human_basic_emotions <- dimensio_human[, c('Anger', 'Disgust', 'Fear', 'Happiness', 'Sadness', 'Surprise')]
human_aro_val <- dimensio_human[, c('Arousal', 'Valence')]

# Initialize normalized versions for both GPT and human datasets
norm_gpt_basic_emotions <- gpt_basic_emotions
norm_gpt_aro_val <- gpt_aro_val

norm_human_basic_emotions <- human_basic_emotions
norm_human_aro_val <- human_aro_val

# Normalize emotion values to a 0–10 scale:
# Basic emotions were originally rated from 1–7, arousal/valence from 1–9
norm_gpt_basic_emotions <- ((norm_gpt_basic_emotions-1)/(7-1))*10
norm_gpt_aro_val <- ((norm_gpt_aro_val-1)/(9-1))*10

norm_human_basic_emotions <- ((norm_human_basic_emotions-1)/(7-1))*10
norm_human_aro_val <- ((norm_human_aro_val-1)/(9-1))*10

# Combine normalized values into single dataframes
norm_gpt <- cbind(norm_gpt_basic_emotions, norm_gpt_aro_val)
norm_human <- cbind(norm_human_basic_emotions, norm_human_aro_val)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Calculate distances between human and GPT ratings

# Compute absolute difference per emotion and image
distance_matrix <- norm_gpt - norm_human

# Create dataframe to hold image names and distances
dist <- data.frame(imageNames = gpt$imageNames)
dist <- cbind(dist, distance_matrix)

# Save column names for later use
emotion_names <- names(distance_matrix)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Calculate statistical summaries for each emotion

# Calculating Average, Median, 95% Confidence Interval and 90% Quantile Range
summary_stats <- data.frame(
  emotions = emotion_names,
  # Average
  mean = sapply(emotion_names, function(e) mean(distance_matrix[[e]], na.rm = TRUE)),
  # Median
  median = sapply(emotion_names, function(e) median(distance_matrix[[e]], na.rm = TRUE)),
  # 95 % Confidence Interval
  CI_lower = sapply(emotion_names, function(e) {
    t_test <- t.test(distance_matrix[[e]], conf.level = 0.95)
    t_test$conf.int[1]
  }),
  CI_upper = sapply(emotion_names, function(e) {
    t_test <- t.test(distance_matrix[[e]], conf.level = 0.95)
    t_test$conf.int[2]
  }),
  # 90 % Quantile Range
  Q90_lower = sapply(emotion_names, function(e) quantile(distance_matrix[[e]], 0.05, na.rm = TRUE)),
  Q90_upper = sapply(emotion_names, function(e) quantile(distance_matrix[[e]], 0.95, na.rm = TRUE))
)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot boxplots of emotion-wise distance distributions

# Convert wide-format distance matrix to long-format for ggplot
dist_long <- dist %>%
  pivot_longer(cols = -imageNames, names_to = 'emotions', values_to = 'distance')

# Merge with summary statistics based on emotion names
dist_summary <- left_join(dist_long, summary_stats, by = 'emotions')

# Sort emotions by median distance for clearer visual comparison
dist_summary$emotions <- factor(dist_summary$emotions, levels = summary_stats$emotions[order(summary_stats$median)])

# Save boxplot as PDF
pdf('path/ID_boxplot_confidence_interval_and_median.pdf', width = 4, height = 6)
ggplot(dist_summary, aes(x = emotions, y = distance, fill = emotions)) +
  # Jitter points
  geom_jitter(aes(color = emotions), width = 0.2, size = 2, alpha = 0.3, show.legend = FALSE) +
  # Boxplot
  geom_boxplot(alpha = 0.6, outlier.shape = NA) +
  # Y-axis label
  labs(y = 'Distance') +
  # Use minimal theme for clean visuals
  theme_minimal() +
  # Customize font sizes
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 14),
    axis.text.y = element_text(size = 13),
    axis.title.y = element_text(size = 13),
    legend.position = 'none',
    plot.background = element_rect(fill = 'white', color = NA),
    plot.margin = margin(20, 20, 20, 20)
  ) +
  # Replace dots with spaces in x-axis labels
  scale_x_discrete(labels = function(x) gsub("\\.", " ", x))
dev.off()
