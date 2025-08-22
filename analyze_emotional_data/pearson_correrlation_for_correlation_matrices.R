# Correlation combinations values to Figure 6
#
# Lauri Suominen 21.8.2025

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load data

# Load averaged GPT-4.1 and human rating data for video dataset 1
VD1_gpt_file <- read.csv('path/data/VD1/ratings/data/gpt-4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
VD1_human_file <- read.csv('path/data/VD1/ratings/data/human_data/average_ratings/combined_averages.csv')

# Load averaged GPT-4.1 and human rating data for video dataset 2
VD2_gpt_file <- read.csv('path/data/VD2/ratings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
VD2_human_file <- read.csv('path/data/VD2/ratings/data/human_data/average_ratings/combined_averages_gpt-4-1.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 1: GPT correlation matrix

# Compute correlation matrix for video dataset 1 GPT ratings
VD1_gpt = cor(VD1_gpt_file[,2:ncol(VD1_gpt_file)])

# Rename variables for readability in row names
rownames(VD1_gpt)[rownames(VD1_gpt) == "A.sense.of.safety"] <- "Safety"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.things.are.under.control"] <- "Control"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Like.things.are.not.fair"] <- "Not fair"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Sexual.desire"] <- "Sexual desire"
rownames(VD1_gpt)[rownames(VD1_gpt) == "Empathic.pain"] <- "Empathic pain"

# Rename variables in column names to match row names
colnames(VD1_gpt)[colnames(VD1_gpt) == "A.sense.of.safety"] <- "Safety"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.things.are.under.control"] <- "Control"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Like.things.are.not.fair"] <- "Not fair"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Sexual.desire"] <- "Sexual desire"
colnames(VD1_gpt)[colnames(VD1_gpt) == "Empathic.pain"] <- "Empathic pain"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 1: human correlation matrix

# Compute correlation matrix for video dataset 1 human ratings
VD1_human = cor(VD1_human_file[,2:ncol(VD1_human_file)])

# Rename variables for readability in row names
rownames(VD1_human)[rownames(VD1_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
rownames(VD1_human)[rownames(VD1_human) == "Sexual_desire"] <- "Sexual desire"
rownames(VD1_human)[rownames(VD1_human) == "Empathic_pain"] <- "Empathic pain"
rownames(VD1_human)[rownames(VD1_human) == "Not_fair"] <- "Not fair"

# Rename variables in column names to match row names
colnames(VD1_human)[colnames(VD1_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(VD1_human)[colnames(VD1_human) == "Sexual_desire"] <- "Sexual desire"
colnames(VD1_human)[colnames(VD1_human) == "Empathic_pain"] <- "Empathic pain"
colnames(VD1_human)[colnames(VD1_human) == "Not_fair"] <- "Not fair"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 2: GPT correlation matrix

# Compute correlation matrix for video dataset 2 GPT ratings
VD2_gpt = cor(VD2_gpt_file[,2:ncol(VD2_gpt_file)])

# Rename variables for readability in row names
rownames(VD2_gpt)[rownames(VD2_gpt) == "A.sense.of.safety"] <- "Safety"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.things.are.under.control"] <- "Control"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Like.things.are.not.fair"] <- "Not fair"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Sexual.desire"] <- "Sexual desire"
rownames(VD2_gpt)[rownames(VD2_gpt) == "Empathic.pain"] <- "Empathic pain"

# Rename variables in column names to match row names
colnames(VD2_gpt)[colnames(VD2_gpt) == "A.sense.of.safety"] <- "Safety"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.things.are.under.control"] <- "Control"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Like.things.are.not.fair"] <- "Not fair"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Sexual.desire"] <- "Sexual desire"
colnames(VD2_gpt)[colnames(VD2_gpt) == "Empathic.pain"] <- "Empathic pain"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 2: human correlation matrix

# Compute correlation matrix for video dataset 2 human ratings
VD2_human = cor(VD2_human_file[,2:ncol(VD2_human_file)])

# Rename variables for readability in row names
rownames(VD2_human)[rownames(VD2_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
rownames(VD2_human)[rownames(VD2_human) == "Sexual_desire"] <- "Sexual desire"
rownames(VD2_human)[rownames(VD2_human) == "Empathic_pain"] <- "Empathic pain"
rownames(VD2_human)[rownames(VD2_human) == "Not_fair"] <- "Not fair"

# Rename variables in column names to match row names
colnames(VD2_human)[colnames(VD2_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(VD2_human)[colnames(VD2_human) == "Sexual_desire"] <- "Sexual desire"
colnames(VD2_human)[colnames(VD2_human) == "Empathic_pain"] <- "Empathic pain"
colnames(VD2_human)[colnames(VD2_human) == "Not_fair"] <- "Not fair"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reordering correlation matrices

# Reorder video dataset 2 human matrix using hierarchical clustering
VD2_human_ordered <- corReorder(VD2_human, order = c('hclust'), hclust_type = c('average'))

# Reorder video dataset 2 GPT matrix to match the human order
VD2_gpt_ordered <- VD2_gpt[colnames(VD2_human_ordered), colnames(VD2_human_ordered)]

# Reorder video dataset 1 matrices to match video dataset 2 human order
VD1_human_ordered <- VD1_human[colnames(VD2_human_ordered), colnames(VD2_human_ordered)] # Use Tettamanti order
VD1_gpt_ordered <- VD1_gpt[colnames(VD1_human_ordered), colnames(VD1_human_ordered)]

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compute lower triangle correlation vectors

# Extract lower triangle of correlation matrices as vectors
VD2_gpt_vector <- as.vector(VD2_gpt_ordered[lower.tri(VD2_gpt_ordered)])
VD2_human_vector <- as.vector(VD2_human_ordered[lower.tri(VD2_human_ordered)])
VD1_gpt_vector <- as.vector(VD1_gpt_ordered[lower.tri(VD1_gpt_ordered)])
VD1_human_vector <- as.vector(VD1_human_ordered[lower.tri(VD1_human_ordered)])

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compute inter-matrix correlations

# Pearson correlation between different model/human/matrix combinations
VD2_gpt_and_VD2_human <- cor(VD2_gpt_vector,VD2_human_vector,method = 'pearson')
VD1_gpt_and_VD1_human <- cor(VD1_gpt_vector,VD1_human_vector,method = 'pearson')
VD2_gpt_and_VD1_gpt <- cor(VD2_gpt_vector,VD1_gpt_vector,method = 'pearson')
VD1_human_and_VD2_human <- cor(VD1_human_vector,VD2_human_vector,method = 'pearson')
VD1_gpt_and_VD2_human <- cor(VD1_gpt_vector,VD2_human_vector,method = 'pearson')
VD1_human_and_VD2_gpt <- cor(VD1_human_vector,VD2_gpt_vector,method = 'pearson')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Print results

print(paste('Video dataset 2 GPT and Human correlation:', VD2_gpt_and_VD2_human))
print(paste('Video dataset 1 GPT and Human correlation:', VD1_gpt_and_VD1_human))
print(paste('Video dataset 2 GPT and Video dataset 1 GPT correlation:', VD2_gpt_and_VD1_gpt))
print(paste('Video dataset 1 Human and Video dataset 2 Human correlation:', VD1_human_and_VD2_human))
print(paste('Video dataset 1 GPT and Video dataset 2 Human correlation:', VD1_gpt_and_VD2_human))
print(paste('Video dataset 1 Human and Video dataset 2 GPT correlation:', VD1_human_and_VD2_gpt))
