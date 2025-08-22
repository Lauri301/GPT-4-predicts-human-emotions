# GPT social perception: Plot the brain result similarities for each feature as a bar plot (GPT4.1 data)
# (video dataset 1)
#
# Yuhang Wu & Severi Santavirta 8.8.2024, Lauri Suominen 21.8.2025

library(readr)
library(ggplot2)
library(reshape2)
library(dplyr)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load data

# Read the correlation and thresholding results from CSV file
cor_and_threshold_results <- read.csv("path/VD1/fmri_analysis/VD1_gpt-4-1_similarity_table.csv")

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Preprocess data

# Convert underscores to spaces
cor_and_threshold_results$Emotion <- gsub('_', ' ', cor_and_threshold_results$Emotion)

# Select and sort data by correlation values (descending order)
sorted_data <- cor_and_threshold_results %>%
  select(Emotion, Correlation) %>%
  arrange(desc(Correlation))

# Convert emotion labels to a factor to preserve the sorted order in plots
sorted_data$Emotion<- factor(sorted_data$Emotion, levels = sorted_data$Emotion)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot raw correlations between predicted and observed brain responses

# Save the plot to a PDF file
pdf("path/VD1_raw_beta_correlation.pdf",height = 6,width = 20)

# Create bar plot for raw correlations
ggplot(sorted_data, aes(x = Emotion, y = Correlation)) +
  # Blue bars with black borders
  geom_bar(stat = "identity",fill = "#0072B2", color = "black") +
  # Remove axis labels
  labs(x = NULL, y = NULL) +
  # Use minimal theme
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 270, hjust = 0, vjust = 0.5, size = 18),
        axis.text.y = element_text(size = 14))
dev.off()

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot thresholded predictive values

# Select relevant columns for PPV values
selected_data <- cor_and_threshold_results %>%
  select(Emotion, PPV_unc0001, PPV_FWE005)

# Reshape data from wide to long format for plotting with ggplot
cor_and_threshold_long <- melt(selected_data, id.vars = "Emotion", 
                               variable.name = "Type", value.name = "Value")

# Ensure emotion order is preserved (same as in raw correlation plot)
cor_and_threshold_long$Emotion <- factor(cor_and_threshold_long$Emotion, levels = sorted_data$Emotion)

# Define custom colors for the two PPV types
custom_colors <- c("PPV_unc0001" = "#e31a1c", "PPV_FWE005" = "white")

# Save the PPV plot to a PDF file
pdf("path/VD1_thresholded_ppv.pdf",height = 6,width = 20)

# Create grouped bar plot for PPV values (two conditions per emotion)
ggplot(cor_and_threshold_long, aes(x = Emotion, y = Value, fill = Type)) +
  geom_bar(stat = "identity",color = "black",position = position_dodge()) +
  labs(x = NULL, y = NULL) +
  theme_minimal() +
  scale_fill_manual(values = custom_colors) +
  theme(axis.text.x = element_text(angle = 270, hjust = 0,vjust = 0.5,size = 18),
        axis.text.y = element_text(size = 14))
dev.off()
