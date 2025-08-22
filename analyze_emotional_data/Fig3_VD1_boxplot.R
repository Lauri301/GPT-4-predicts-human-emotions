# Boxplot of emotion-specific distances between human and GPT-4 ratings for video dataset 1
#
# Lauri Suominen 21.8.2025

library(dplyr)
library(readr)
library(ggplot2)
library(stats)
library(tidyr)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load GPT and human CSV files

human <- read_csv('path/data/VD1/ratings/data/human_data/average_ratings/combined_averages.csv')
gpt <- read_csv('path/data/VD1/ratings/data/gpt-4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Rename and match column names

# Rename columns for human data
names(human)[names(human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
names(human)[names(human) == "Empathic_pain"] <- "Empathic pain"
names(human)[names(human) == "Not_fair"] <- "Not fair"
names(human)[names(human) == "Sexual_desire"] <- "Sexual desire"
names(human)[names(human) == "Row"] <- "VideoName"

# Rename columns for GPT data
names(gpt)[names(gpt) == "A sense of safety"] <- "Safety"
names(gpt)[names(gpt) == "Like things are not fair"] <- "Not fair"
names(gpt)[names(gpt) == "Like things are under control"] <- "Control"
names(gpt)[names(gpt) == "Like this is something you would want to approach"] <- "Approach"
names(gpt)[names(gpt) == "Like this went better than it first seemed it would"] <- "Upswing"
names(gpt)[names(gpt) == "Like you identify with a group of people"] <- "Identity"
names(gpt)[names(gpt) == "Like viewing this demands effort"] <- "Effort"
names(gpt)[names(gpt) == "Like you are obstructed by something"] <- "Obstruction"
names(gpt)[names(gpt) == "videoNames"] <- "VideoName"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reorder columns and prepare numerical data

# Sort emotion columns alphabetically (excluding first column = VideoName)
gpt <- gpt[, c(1, order(names(gpt)[-1]) + 1)]
human <- human[, c(1, order(names(human)[-1]) + 1)]

# Sort rows by VideoName to ensure alignment between human and GPT tables
gpt <- gpt %>% arrange(VideoName)
human <- human %>% arrange(VideoName)

# Remove non-numeric columns (VideoName) for numeric operations
dimensio_human <- human %>% select(-VideoName)
dimensio_gpt <- gpt %>% select(-VideoName)

# Convert all columns to numeric 
dimensio_human <- as.data.frame(lapply(dimensio_human, as.numeric))
dimensio_gpt <- as.data.frame(lapply(dimensio_gpt, as.numeric))

# Normalize scatterplot on all emotions
norm_human <- dimensio_human
norm_gpt <- dimensio_gpt

# Normalize values to 0–10 scale (original scale assumed to be 1–9)
norm_human <- ((norm_human-1)/(9 - 1))*10
norm_gpt <- ((norm_gpt-1)/(9-1))*10

# Calculate absolute distances for each emotion and video
distances_matrix <- norm_gpt - norm_human

# Create a new dataframe with VideoName and distance values
dist <- data.frame(VideoName = human$VideoName)

# Adding distances and feelings as columns
dist <- cbind(dist, distances_matrix)

# Store the emotion names (column names of distance matrix)
emotion_names <- names(distances_matrix)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Calculate statistics per emotion

# Calculating Average, Median, 95% Confidence Interval and 90% Quantile Range
summary_stats <- data.frame(
  emotion = emotion_names,
  # Average
  mean = sapply(emotion_names, function(e) mean(distances_matrix[[e]], na.rm = TRUE)),
  # Median
  median = sapply(emotion_names, function(e) median(distances_matrix[[e]], na.rm = TRUE)),
  # 95 % Confidence Interval
  CI_lower = sapply(emotion_names, function(e) {
    t_test <- t.test(distances_matrix[[e]], conf.level = 0.95)
    t_test$conf.int[1]
  }),
  CI_upper = sapply(emotion_names, function(e) {
    t_test <- t.test(distances_matrix[[e]], conf.level = 0.95)
    t_test$conf.int[2]
  }),
  # 90 % Quantile Range
  Q90_lower = sapply(emotion_names, function(e) quantile(distances_matrix[[e]], 0.05, na.rm = TRUE)),
  Q90_upper = sapply(emotion_names, function(e) quantile(distances_matrix[[e]], 0.95, na.rm = TRUE))
)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot and save boxplots

# Forming a table in long format
dist_long <- dist %>%
  pivot_longer(cols = -VideoName, names_to = "emotion", values_to = "distance")

# Combining dist_long and summary_stats by the column named emotion
dist_summary <- left_join(dist_long, summary_stats, by = "emotion")

# Sorting emotions by median
dist_summary$emotion <- factor(dist_summary$emotion, levels = summary_stats$emotion[order(summary_stats$median)])

# Drawing boxplot
pdf('path/MEG_boxplot_confidence_interval_and_median.pdf', width = 15, height = 6)
ggplot(dist_summary, aes(x = emotion, y = distance, fill = emotion)) +
  # Jitter points
  geom_jitter(aes(color = emotion), width = 0.2, size = 2, alpha = 0.3, show.legend = FALSE) + 
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
  # Editing the x-axis names
  scale_x_discrete(labels = function(x) gsub("\\.", " ", x))
dev.off()
