# The similarity of the emotion rating structures for video dataset 2
#
# Lauri Suominen 9.9.2025

library(corrplot)
library(lessR)
library(ape)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load emotion rating data

# Load GPT-4 rating data
gpt_data <- read.csv('path/data/VD2/ratings/data/gpt-4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
# Load human average ratings
human_data <- read.csv('path/data/VD2/ratings/data/human_data/average_ratings/combined_averages.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compute correlation matrices for each dataset

# Rename long column names to shorter, more readable labels for plotting (GPT matrix)
colnames(gpt_data)[colnames(gpt_data) == "A.sense.of.safety"] <- "Safety"
colnames(gpt_data)[colnames(gpt_data) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
colnames(gpt_data)[colnames(gpt_data) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
colnames(gpt_data)[colnames(gpt_data) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
colnames(gpt_data)[colnames(gpt_data) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
colnames(gpt_data)[colnames(gpt_data) == "Like.viewing.this.demands.effort"] <- "Effort"
colnames(gpt_data)[colnames(gpt_data) == "Like.things.are.under.control"] <- "Control"
colnames(gpt_data)[colnames(gpt_data) == "Like.things.are.not.fair"] <- "Not fair"
colnames(gpt_data)[colnames(gpt_data) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
colnames(gpt_data)[colnames(gpt_data) == "Sexual.desire"] <- "Sexual desire"
colnames(gpt_data)[colnames(gpt_data) == "Empathic.pain"] <- "Empathic pain"

# Rename column names for human matrix to match the GPT format
colnames(human_data)[colnames(human_data) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(human_data)[colnames(human_data) == "Sexual_desire"] <- "Sexual desire"
colnames(human_data)[colnames(human_data) == "Empathic_pain"] <- "Empathic pain"
colnames(human_data)[colnames(human_data) == "Not_fair"] <- "Not fair"

# Separate ratings to emotions and dimensions in both gpt and human evaluations
gpt_emotions <- gpt_data[, c('Admiration', 'Adoration', 'Aesthetic appreciation', 'Amusement', 'Anger',
                             'Anxiety', 'Awe', 'Awkwardness','Boredom','Calmness',
                             'Confusion','Contempt','Craving','Disappointment','Disgust',
                             'Empathic pain','Entrancement','Envy','Excitement','Fear',
                             'Guilt','Horror','Interest','Joy','Nostalgia',
                             'Pride','Relief','Romance','Sadness','Satisfaction',
                             'Sexual desire','Surprise','Sympathy','Triumph')]
gpt_dimensions <- gpt_data[, c('Approach','Stimulated','Focused','Certain','Commitment',
                               'Control','Dominant','Effort','Not fair','Identity',
                               'Obstruction','Safety','Upswing','Pleasant')]

human_emotions <- human_data[, c('Admiration', 'Adoration', 'Aesthetic appreciation', 'Amusement', 'Anger',
                                 'Anxiety', 'Awe', 'Awkwardness','Boredom','Calmness',
                                 'Confusion','Contempt','Craving','Disappointment','Disgust',
                                 'Empathic pain','Entrancement','Envy','Excitement','Fear',
                                 'Guilt','Horror','Interest','Joy','Nostalgia',
                                 'Pride','Relief','Romance','Sadness','Satisfaction',
                                 'Sexual desire','Surprise','Sympathy','Triumph')]
human_dimensions <- human_data[, c('Approach','Stimulated','Focused','Certain','Commitment',
                                   'Control','Dominant','Effort','Not fair','Identity',
                                   'Obstruction','Safety','Upswing','Pleasant')]

# Compute correlation matrix from GPT data
gpt_emotions_cor <- cor(gpt_emotions)
gpt_dimensions_cor <- cor(gpt_dimensions)

# Compute correlation matrix from human ratings
human_emotions_cor <- cor(human_emotions)
human_dimensions_cor <- cor(human_dimensions)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reorder correlation matrices based on column order from H_ordered

# Reorder emotions correlation matrix
human_emotions_cor_ordered <- corReorder(human_emotions_cor, order = c('hclust'), hclust_type = c('average'))
gpt_emotions_cor_ordered <- gpt_emotions_cor[colnames(human_emotions_cor_ordered), colnames(human_emotions_cor_ordered)]

# Reorder dimensions correlation matrix
human_dimensions_cor_ordered <- corReorder(human_dimensions_cor, order = c('hclust'), hclust_type = c('average'))
gpt_dimensions_cor_ordered <- gpt_dimensions_cor[colnames(human_dimensions_cor_ordered), colnames(human_dimensions_cor_ordered)]

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot correlation matrices

#### GPT ####

# Save GPT emotions correlation matrix as PDF
pdf("path/VD2_gpt_emotions_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot GPT emotions matrix (lower triangle only)
corrplot(gpt_emotions_cor_ordered, method = 'color', tl.col = 'black', type = 'lower', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

# Save GPT dimensions correlation matrix as PDF
pdf("path/VD2_gpt_dimensions_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot GPT dimensions matrix (lower triangle only)
corrplot(gpt_dimensions_cor_ordered, method = 'color', tl.col = 'black', type = 'lower', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

#### HUMAN ####

# Save human emotions correlation matrix as PDF
pdf("path/VD2_human_emotions_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot human emotions matrix (upper triangle only)
corrplot(human_emotions_cor_ordered, method = 'color', tl.col = 'black', type = 'upper', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

# Save human dimensions correlation matrix as PDF
pdf("path/VD2_human_dimensions_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot human dimensions matrix (upper triangle only)
corrplot(human_dimensions_cor_ordered, method = 'color', tl.col = 'black', type = 'upper', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compare structural similarity between matrices

# Extract lower triangle values (excluding diagonals) into vectors for comparison
gpt_emotions_vector <- as.vector(gpt_emotions_cor_ordered[lower.tri(gpt_emotions_cor_ordered)])
gpt_dimensions_vector <- as.vector(gpt_dimensions_cor_ordered[lower.tri(gpt_dimensions_cor_ordered)])

human_emotions_vector <- as.vector(human_emotions_cor_ordered[lower.tri(human_emotions_cor_ordered)])
human_dimensions_vector <- as.vector(human_dimensions_cor_ordered[lower.tri(human_dimensions_cor_ordered)])

# Compute Pearson correlation between the lower triangle vectors
correlation_emotions <- cor(gpt_emotions_vector, human_emotions_vector, method = 'pearson')
correlation_dimensions <- cor(gpt_dimensions_vector, human_dimensions_vector, method = 'pearson')

# Perform Mantel test to assess the significance of the matrix correlation
p_value_emotions <- mantel.test(gpt_emotions_cor_ordered, human_emotions_cor_ordered, nperm = 1000000, graph = T, alternative = "greater")
p_value_dimensions <- mantel.test(gpt_dimensions_cor_ordered, human_dimensions_cor_ordered, nperm = 1000000, graph = T, alternative = "greater")

# Output the correlation coefficient and Mantel test result
print(paste0('Correlation of emotions: ', correlation_emotions))
print(p_value_emotions)
print(paste0('Correlation of dimensions: ', correlation_dimensions))
print(p_value_dimensions)
