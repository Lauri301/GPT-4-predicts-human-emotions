# The similarity of the emotion rating structures for image dataset
#
# Lauri Suominen 21.8.2025

library(corrplot)
library(lessR)
library(ape)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load emotion rating data

# Load GPT-4 rating data
gpt_file <- read.csv('path/data/ID/ratings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
# Load human average ratings
human_file <- read.csv('path/data/ID/ratings/data/human_data/NAPS_human_average_ratings_gpt-4-1.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Prepare and align data

# Sort rows by imageNames to ensure alignment between human and GPT tables
gpt_file <- gpt_file %>% arrange(imageNames)
human_file <- human_file %>% arrange(imageNames)

# Remove non-numeric columns (only keep emotion ratings)
dimensio_gpt <- gpt_file %>% select(-imageNames)
dimensio_human <- human_file %>% select(-imageNames)

# Ensure all values are numeric
dimensio_gpt <- as.data.frame(lapply(dimensio_gpt, as.numeric))
dimensio_human <- as.data.frame(lapply(dimensio_human, as.numeric))

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
# Compute correlation matrices for each dataset

# Compute correlation matrix from GPT data
GPT = cor(norm_gpt)

# Compute correlation matrix from human ratings
H = cor(norm_human)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reorder correlation matrices based on column order from H_ordered

# Match GPT and human correlation matrices to the same variable order
H_ordered <- corReorder(H, order = c('hclust'), hclust_type = c('average'))
GPT_ordered = GPT[colnames(H_ordered), colnames(H_ordered)]

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot correlation matrices

# Save GPT correlation matrix as PDF
pdf("path/ID_gpt_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot GPT matrix (lower triangle only)
corrplot(GPT_ordered, method = 'color', tl.col = 'black', type = 'lower', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

# Save human correlation matrix as PDF
pdf("path/ID_human_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot human matrix (upper triangle only)
corrplot(H_ordered, method = 'color', tl.col = 'black', type = 'upper', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compare structural similarity between matrices

# Extract lower triangle values (excluding diagonals) into vectors for comparison
GPT_vector <- as.vector(GPT_ordered[lower.tri(GPT_ordered)])
H_vector <- as.vector(H_ordered[lower.tri(H_ordered)])

# Compute Pearson correlation between the lower triangle vectors
correlation <- cor(GPT_vector, H_vector, method = 'pearson')

# Perform Mantel test to assess the significance of the matrix correlation
p_value <- mantel.test(GPT_ordered,H_ordered,nperm = 1000000, graph = T,alternative = "greater")

# Output the correlation coefficient and Mantel test result
print(correlation)
print(p_value)
