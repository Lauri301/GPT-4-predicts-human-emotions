# Collecting multiple independent evaluations for same stimuli increases the accuracy of GPT-4 ratings (video dataset 2)
#
# Lauri Suominen 21.8.2025

library(tidyverse)
library(ggplot2)
library(dplyr)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load human rating data

# Load combined average human ratings for all videos
human_data <- read.csv('path/data/VD2/ratings/data/human_data/average_ratings/combined_averages_gpt-4-1.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Clean up column names for consistency

# Rename columns to match GPT column formatting
colnames(human_data)[colnames(human_data) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(human_data)[colnames(human_data) == "Empathic_pain"] <- "Empathic pain"
colnames(human_data)[colnames(human_data) == "Not_fair"] <- "Not fair"
colnames(human_data)[colnames(human_data) == "Sexual_desire"] <- "Sexual desire"
colnames(human_data)[colnames(human_data) == "Row"] <- "videoNames"

# Convert human ratings to long format
human_data_long <- human_data %>%
  pivot_longer(cols = -videoNames, names_to = "emotion", values_to = "mean_human_rating")

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load and analyze multiple GPT rating files

# Read all gpt csv files
gpt_files <- list.files('path/data/VD2/ratings/data/gpt_4-1_data/average/all_averages', pattern = "output_average_\\d+_files.*\\.csv", full.names = TRUE)

# Initialize a table to store average correlations for each comparison
average_correlations <- data.frame(Comparison = integer(0), AverageCorrelation = numeric(0))

# Counter for tracking comparison ID
comparison_count <- 1

# Loop through each GPT file
for (file in gpt_files) {
  # Load current GPT file
  gpt_data <- read.csv(file, check.names = FALSE)

  # Rename GPT columns for consistency
  colnames(gpt_data)[colnames(gpt_data) == "A sense of safety"] <- "Safety"
  colnames(gpt_data)[colnames(gpt_data) == "Like things are not fair"] <- "Not fair"
  colnames(gpt_data)[colnames(gpt_data) == "Like things are under control"] <- "Control"
  colnames(gpt_data)[colnames(gpt_data) == "Like this is something you would want to approach"] <- "Approach"
  colnames(gpt_data)[colnames(gpt_data) == "Like this went better than it first seemed it would"] <- "Upswing"
  colnames(gpt_data)[colnames(gpt_data) == "Like you identify with a group of people"] <- "Identity"
  colnames(gpt_data)[colnames(gpt_data) == "Like viewing this demands effort"] <- "Effort"
  colnames(gpt_data)[colnames(gpt_data) == "Like you are obstructed by something"] <- "Obstruction"
  
  # Match GPT video rows to human data by videoNames
  gpt_data <- gpt_data[match(human_data$videoNames, gpt_data$videoNames), ]
  row.names(gpt_data) <- 1:nrow(gpt_data)

  # Sort columns alphabetically, keeping videoNames as the first column
  gpt_data <- gpt_data[, c(1, order(names(gpt_data)[-1]) + 1)]
  human_data <- human_data[, c(1, order(names(human_data)[-1]) + 1)]

  # Select only numeric columns for correlation
  gpt_data_numeric <- gpt_data %>% select(where(is.numeric))
  human_data_numeric <- human_data %>% select(where(is.numeric))

  # Ensure the column names match
  if (!all(names(gpt_data_numeric) == names(human_data_numeric))) {
    stop("Column names do not match!")
  }
  
  # Convert GPT data to long format
  gpt_data_long <- gpt_data %>%
    pivot_longer(cols = -videoNames, names_to = "emotion", values_to = "mean_gpt_rating")
  
  # Merge GPT and human long-form data by video and emotion
  combined_long <- left_join(human_data_long, gpt_data_long, by = c('videoNames', 'emotion'))
  
  # Calculate Pearson correlation between human and GPT ratings
  correlations <- cor(combined_long$mean_human_rating, combined_long$mean_gpt_rating, method = 'pearson')

  average_correlation <- correlations
  
  # Store the correlation in the result table
  average_correlations <- rbind(average_correlations, data.frame(Comparison = comparison_count, AverageCorrelation = average_correlation))

  # Increment the comparison index
  comparison_count <- comparison_count + 1
}

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Add class labels based on number of GPT files used in each average

class <- c(rep(1, choose(10,1)), # Single file average
           rep(2, choose(10,2)), # 2-file averages
           rep(3, choose(10,3)), # ...
           rep(4, choose(10,4)), 
           rep(5, choose(10,5)),
           rep(6, choose(10,6)), 
           rep(7, choose(10,7)),
           rep(8, choose(10,8)), 
           rep(9, choose(10,9)),
           rep(10, choose(10,10)) # 10-file average
          )

# Ensure class length matches number of comparisons
if (length(class) != nrow(average_correlations)) {
  stop("Mismatch between class values and number of rows!")
}

# Assign class info to the results
average_correlations$Class <- class

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Prepare data for plotting

# Store original comparison order
original_order <- average_correlations$Comparison

# Sort data by average correlation for better plotting
average_correlations <- average_correlations %>%
  arrange(AverageCorrelation)

# Restore the original order for the 'Comparison' column
average_correlations$Comparison <- original_order

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot the results

# Save figure showing how GPT-human correlation improves with more GPT samples
pdf('path/VD2_GPT-4_raiting_correlation_with_humans.pdf', width = 10, height = 10)
ggplot(average_correlations, aes(x = Comparison, y = AverageCorrelation, color = Class)) +
  geom_point(size = 3) +
  scale_color_gradientn(colors = c("#2166AC", "#00BA38", "yellow", "#B2182B")) +
  labs(
    x = 'Dataset',
    y = 'GPT-4 rating correlation with humans',
  ) + 
  theme_minimal() +
  theme(
    plot.background = element_rect(fill = 'white', color = NA),
    panel.background = element_rect(fill = 'white', color = NA),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    axis.text.x = element_text(size = 14),
    axis.text.y = element_text(size = 14)
  )
dev.off()
