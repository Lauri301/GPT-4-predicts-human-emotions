# The similarity of the emotion rating structures for video dataset 2
#
# Lauri Suominen 21.8.2025

library(corrplot)
library(lessR)
library(ape)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load emotion rating data

# Load GPT-4 rating data
output_average_10 <- read.csv('path/tettamanti_project/raitings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
# Load human average ratings
combined_averages <- read.csv('path/tettamanti_project/raitings/data/human_data/average_ratings/combined_averages_without_t4.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compute correlation matrices for each dataset

# Compute correlation matrix from GPT data (excluding video names)
GPT = cor(output_average_10[,2:ncol(output_average_10)])

# Rename long column/row names to shorter, more readable labels for plotting (GPT matrix)
rownames(GPT)[rownames(GPT) == "A.sense.of.safety"] <- "Safety"
rownames(GPT)[rownames(GPT) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
rownames(GPT)[rownames(GPT) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
rownames(GPT)[rownames(GPT) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
rownames(GPT)[rownames(GPT) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
rownames(GPT)[rownames(GPT) == "Like.viewing.this.demands.effort"] <- "Effort"
rownames(GPT)[rownames(GPT) == "Like.things.are.under.control"] <- "Control"
rownames(GPT)[rownames(GPT) == "Like.things.are.not.fair"] <- "Not fair"
rownames(GPT)[rownames(GPT) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
rownames(GPT)[rownames(GPT) == "Sexual.desire"] <- "Sexual desire"
rownames(GPT)[rownames(GPT) == "Empathic.pain"] <- "Empathic pain"

# Apply the same renaming to column names (GPT)
colnames(GPT)[colnames(GPT) == "A.sense.of.safety"] <- "Safety"
colnames(GPT)[colnames(GPT) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
colnames(GPT)[colnames(GPT) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
colnames(GPT)[colnames(GPT) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
colnames(GPT)[colnames(GPT) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
colnames(GPT)[colnames(GPT) == "Like.viewing.this.demands.effort"] <- "Effort"
colnames(GPT)[colnames(GPT) == "Like.things.are.under.control"] <- "Control"
colnames(GPT)[colnames(GPT) == "Like.things.are.not.fair"] <- "Not fair"
colnames(GPT)[colnames(GPT) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
colnames(GPT)[colnames(GPT) == "Sexual.desire"] <- "Sexual desire"
colnames(GPT)[colnames(GPT) == "Empathic.pain"] <- "Empathic pain"

# Compute correlation matrix from human ratings (excluding video names)
H = cor(combined_averages[,2:ncol(combined_averages)])

# Rename column and row names for human matrix to match the GPT format
rownames(H)[rownames(H) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
rownames(H)[rownames(H) == "Sexual_desire"] <- "Sexual desire"
rownames(H)[rownames(H) == "Empathic_pain"] <- "Empathic pain"
rownames(H)[rownames(H) == "Not_fair"] <- "Not fair"

colnames(H)[colnames(H) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(H)[colnames(H) == "Sexual_desire"] <- "Sexual desire"
colnames(H)[colnames(H) == "Empathic_pain"] <- "Empathic pain"
colnames(H)[colnames(H) == "Not_fair"] <- "Not fair"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reorder correlation matrices based on column order from H_ordered

# Match GPT and human correlation matrices to the same variable order
H_ordered <- corReorder(H, order = c('hclust'), hclust_type = c('average'))
GPT_ordered = GPT[colnames(H_ordered), colnames(H_ordered)]

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Plot correlation matrices

# Save GPT correlation matrix as PDF
pdf("path/TET_gpt_structural_correlation_matrix.pdf", width = 15, height = 15)

# Plot GPT matrix (lower triangle only)
corrplot(GPT_ordered, method = 'color', tl.col = 'black', type = 'lower', col = colorRampPalette(c("#2166AC", "#4393C3", "#92C5DE", "#D1E5F0", "#FDDBC7", "#F4A582", "#D6604D", "#B2182B"))(20))
dev.off()

# Save human correlation matrix as PDF
pdf("path/TET_human_structural_correlation_matrix.pdf", width = 15, height = 15)

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
p_value <- mantel.test(GPT_ordered_1,H_ordered_1,nperm = 1000000, graph = T,alternative = "greater")

# Output the correlation coefficient and Mantel test result
print(correlation)
