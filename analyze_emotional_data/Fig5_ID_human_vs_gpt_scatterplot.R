# The overall similarity of the emotion ratings between GPT-4 and humans for image dataset
#
# Lauri Suominen 21.8.2025

library(dplyr)
library(tidyr)
library(ggplot2)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load GPT and human CSV files

gpt_file <- read.csv('path/NAPS_project/raitings/data/gpt_4-1_data/average/all_averages_without_sex_pic/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
human_file <- read.csv('path/NAPS_project/raitings/data/human_data/NAPS_human_average_ratings_gpt-4-1_without_sex_pic.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Separate emotion ratings into two categories: basic emotions and arousal/valence

# Extract basic emotions and arousal/valence from both GPT and human datasets
gpt_basic_emotions <- gpt_file[, c('imageNames', 'Happiness', 'Sadness', 'Fear', 'Surprise', 'Anger', 'Disgust')]
gpt_aro_val <- gpt_file[, c('imageNames', 'Arousal', 'Valence')]

human_basic_emotions <- human_file[, c('imageNames', 'Happiness', 'Sadness', 'Fear', 'Surprise', 'Anger', 'Disgust')]
human_aro_val <- human_file[, c('imageNames', 'Arousal', 'Valence')]

# Convert GPT basic emotions to long format
gpt_long_basic_emotions <- gpt_basic_emotions %>%
  pivot_longer(cols = -imageNames, names_to = "emotions", values_to = "gpt_values") %>%
  mutate(type = 'Basic Emotion')

# Convert GPT arousal/valence to long format
gpt_long_aro_val <- gpt_aro_val %>%
  pivot_longer(cols = -imageNames, names_to = "emotions", values_to = "gpt_values") %>%
  mutate(type = 'Arousal/Valence')

# Convert human basic emotions to long format
human_long_basic_emotions <- human_basic_emotions %>%
  pivot_longer(cols = -imageNames, names_to = "emotions", values_to = "human_values") %>%
  mutate(type = 'Basic Emotion')

# Convert human arousal/valence to long format
human_long_aro_val <- human_aro_val %>%
  pivot_longer(cols = -imageNames, names_to = "emotions", values_to = "human_values") %>%
  mutate(type = 'Arousal/Valence')

# Merge GPT and human basic emotion ratings by image and emotion
combined_basic_emotions <- merge(gpt_long_basic_emotions, human_long_basic_emotions)

# Merge GPT and human arousal/valence ratings
combined_aro_val <- merge(gpt_long_aro_val, human_long_aro_val)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Normalize values and prepare data for scatterplot

# Create copies for normalization
norm_basic_emotions = combined_basic_emotions
norm_aro_val = combined_aro_val

# Normalize ratings to 0–10 scale:
# Basic emotions: originally from 1–7
norm_basic_emotions$gpt_values <- ((norm_basic_emotions$gpt_values-1)/(7-1))*10
norm_basic_emotions$human_values <- ((norm_basic_emotions$human_values-1)/(7-1))*10

# Arousal and Valence: originally from 1–9
norm_aro_val$gpt_values <- ((norm_aro_val$gpt_values-1)/(9-1))*10
norm_aro_val$human_values <- ((norm_aro_val$human_values-1)/(9-1))*10

# Combine both normalized datasets into one
combined <- rbind(norm_basic_emotions, norm_aro_val)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Create scatterplot comparing normalized GPT and human ratings

# Save plot to PDF
pdf("path/gpt-4-1/NAPS_human_vs_gpt_norm_scatterplot.pdf", width = 9, height = 9)
ggplot(combined, aes(x = human_values, y = gpt_values)) +
  # Use hex bins to show density of overlapping points
  geom_hex(bins = 25, aes(fill = after_stat(density), alpha = after_stat(density)), show.legend = FALSE) +
  # Define gradient color for density
  scale_fill_gradientn(colors = c("blue","red")) +
  # Define transparency scale
  scale_alpha_continuous(range = c(0.1,30)) +
  # Use minimal theme for clean visuals
  theme_minimal() +
  # Fix axis limits
  coord_cartesian(xlim = c(0,10), ylim = c(0,10)) +
  # Axis labels
  labs(x = "Human average", y = "GPT-4") +
  # Customize font sizes
  theme(axis.title = element_text(size = 28),
        plot.title = element_text(hjust = 0.5, size = 32),
        axis.text.x = element_text(size = 24),
        axis.text.y = element_text(size = 24),
        legend.position = "none") +
  # Add y = x reference line for comparison
  geom_abline(slope = 1, intercept = 0, color = "black", linewidth = 3)
dev.off()

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Calculate and print Pearson correlation coefficient between GPT and human ratings

correlation <- cor(combined$gpt_values, combined$human_values, method = 'pearson')
print(correlation)
