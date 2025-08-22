# Correlation combinations values to Figure 6
#
# Lauri Suominen 21.8.2025

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load data

# Load averaged GPT-4.1 and human rating data for video dataset 1
MEG_gpt_file <- read.csv('path/megaperception_project/raitings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
MEG_human_file <- read.csv('path/megaperception_project/raitings/data/human_data/average_ratings/combined_averages_without_sex.csv')

# Load averaged GPT-4.1 and human rating data for video dataset 2
TET_gpt_file <- read.csv('path/tettamanti_project/raitings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv')
TET_human_file <- read.csv('path/tettamanti_project/raitings/data/human_data/average_ratings/combined_averages_without_t4.csv')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 1: GPT correlation matrix

# Compute correlation matrix for video dataset 1 GPT ratings
MEG_gpt = cor(MEG_gpt_file[,2:ncol(MEG_gpt_file)])

# Rename variables for readability in row names
rownames(MEG_gpt)[rownames(MEG_gpt) == "A.sense.of.safety"] <- "Safety"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.things.are.under.control"] <- "Control"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Like.things.are.not.fair"] <- "Not fair"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Sexual.desire"] <- "Sexual desire"
rownames(MEG_gpt)[rownames(MEG_gpt) == "Empathic.pain"] <- "Empathic pain"

# Rename variables in column names to match row names
colnames(MEG_gpt)[colnames(MEG_gpt) == "A.sense.of.safety"] <- "Safety"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.things.are.under.control"] <- "Control"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Like.things.are.not.fair"] <- "Not fair"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Sexual.desire"] <- "Sexual desire"
colnames(MEG_gpt)[colnames(MEG_gpt) == "Empathic.pain"] <- "Empathic pain"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 1: human correlation matrix

# Compute correlation matrix for video dataset 1 human ratings
MEG_human = cor(MEG_human_file[,2:ncol(MEG_human_file)])

# Rename variables for readability in row names
rownames(MEG_human)[rownames(MEG_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
rownames(MEG_human)[rownames(MEG_human) == "Sexual_desire"] <- "Sexual desire"
rownames(MEG_human)[rownames(MEG_human) == "Empathic_pain"] <- "Empathic pain"
rownames(MEG_human)[rownames(MEG_human) == "Not_fair"] <- "Not fair"

# Rename variables in column names to match row names
colnames(MEG_human)[colnames(MEG_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(MEG_human)[colnames(MEG_human) == "Sexual_desire"] <- "Sexual desire"
colnames(MEG_human)[colnames(MEG_human) == "Empathic_pain"] <- "Empathic pain"
colnames(MEG_human)[colnames(MEG_human) == "Not_fair"] <- "Not fair"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 2: GPT correlation matrix

# Compute correlation matrix for video dataset 2 GPT ratings
TET_gpt = cor(TET_gpt_file[,2:ncol(TET_gpt_file)])

# Rename variables for readability in row names
rownames(TET_gpt)[rownames(TET_gpt) == "A.sense.of.safety"] <- "Safety"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.things.are.under.control"] <- "Control"
rownames(TET_gpt)[rownames(TET_gpt) == "Like.things.are.not.fair"] <- "Not fair"
rownames(TET_gpt)[rownames(TET_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
rownames(TET_gpt)[rownames(TET_gpt) == "Sexual.desire"] <- "Sexual desire"
rownames(TET_gpt)[rownames(TET_gpt) == "Empathic.pain"] <- "Empathic pain"

# Rename variables in column names to match row names
colnames(TET_gpt)[colnames(TET_gpt) == "A.sense.of.safety"] <- "Safety"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.this.went.better.than.it.first.seemed.it.would"] <- "Upswing"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.you.identify.with.a.group.of.people"] <- "Identity"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.this.is.something.you.would.want.to.approach"] <- "Approach"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.you.are.obstructed.by.something"] <- "Obstruction"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.viewing.this.demands.effort"] <- "Effort"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.things.are.under.control"] <- "Control"
colnames(TET_gpt)[colnames(TET_gpt) == "Like.things.are.not.fair"] <- "Not fair"
colnames(TET_gpt)[colnames(TET_gpt) == "Aesthetic.appreciation"] <- "Aesthetic appreciation"
colnames(TET_gpt)[colnames(TET_gpt) == "Sexual.desire"] <- "Sexual desire"
colnames(TET_gpt)[colnames(TET_gpt) == "Empathic.pain"] <- "Empathic pain"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Video dataset 2: human correlation matrix

# Compute correlation matrix for video dataset 2 human ratings
TET_human = cor(TET_human_file[,2:ncol(TET_human_file)])

# Rename variables for readability in row names
rownames(TET_human)[rownames(TET_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
rownames(TET_human)[rownames(TET_human) == "Sexual_desire"] <- "Sexual desire"
rownames(TET_human)[rownames(TET_human) == "Empathic_pain"] <- "Empathic pain"
rownames(TET_human)[rownames(TET_human) == "Not_fair"] <- "Not fair"

# Rename variables in column names to match row names
colnames(TET_human)[colnames(TET_human) == "Aesthetic_appreciation"] <- "Aesthetic appreciation"
colnames(TET_human)[colnames(TET_human) == "Sexual_desire"] <- "Sexual desire"
colnames(TET_human)[colnames(TET_human) == "Empathic_pain"] <- "Empathic pain"
colnames(TET_human)[colnames(TET_human) == "Not_fair"] <- "Not fair"

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Reordering correlation matrices

# Reorder video dataset 2 human matrix using hierarchical clustering
TET_human_ordered <- corReorder(TET_human, order = c('hclust'), hclust_type = c('average'))

# Reorder video dataset 2 GPT matrix to match the human order
TET_gpt_ordered <- TET_gpt[colnames(TET_human_ordered), colnames(TET_human_ordered)]

# Reorder video dataset 1 matrices to match video dataset 2 human order
MEG_human_ordered <- MEG_human[colnames(TET_human_ordered), colnames(TET_human_ordered)] # Use Tettamanti order
MEG_gpt_ordered <- MEG_gpt[colnames(MEG_human_ordered), colnames(MEG_human_ordered)]

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compute lower triangle correlation vectors

# Extract lower triangle of correlation matrices as vectors
TET_gpt_vector <- as.vector(TET_gpt_ordered[lower.tri(TET_gpt_ordered)])
TET_human_vector <- as.vector(TET_human_ordered[lower.tri(TET_human_ordered)])
MEG_gpt_vector <- as.vector(MEG_gpt_ordered[lower.tri(MEG_gpt_ordered)])
MEG_human_vector <- as.vector(MEG_human_ordered[lower.tri(MEG_human_ordered)])

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Compute inter-matrix correlations

# Pearson correlation between different model/human/matrix combinations
TET_gpt_and_TET_human <- cor(TET_gpt_vector,TET_human_vector,method = 'pearson')
MEG_gpt_and_MEG_human <- cor(MEG_gpt_vector,MEG_human_vector,method = 'pearson')
TET_gpt_and_MEG_gpt <- cor(TET_gpt_vector,MEG_gpt_vector,method = 'pearson')
MEG_human_and_TET_human <- cor(MEG_human_vector,TET_human_vector,method = 'pearson')
MEG_gpt_and_TET_human <- cor(MEG_gpt_vector,TET_human_vector,method = 'pearson')
MEG_human_and_TET_gpt <- cor(MEG_human_vector,TET_gpt_vector,method = 'pearson')

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Print results

print(paste('Tettamanti GPT and Human correlation:', TET_gpt_and_TET_human))
print(paste('Megaperception GPT and Human correlation:', MEG_gpt_and_MEG_human))
print(paste('Tettamanti GPT and Megaperception GPT correlation:', TET_gpt_and_MEG_gpt))
print(paste('Megaperception Human and Tettamanti Human correlation:', MEG_human_and_TET_human))
print(paste('Megaperception GPT and Tettamanti Human correlation:', MEG_gpt_and_TET_human))
print(paste('Megaperception Human and Tettamanti GPT correlation:', MEG_human_and_TET_gpt))
