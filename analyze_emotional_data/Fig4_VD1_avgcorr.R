# GPT social perception: Calculate how similarly GPT4.1 evaluated megaperception clip experiment data compared to real human participants
# (video dataset 1)
#
# Process:
#       1. We have approximately 10 human raters select all possible combinations of K raters, K = {1,2,3,4,5}
#       2. Calculate the average correlation between the left_out_group and other humans
#       3. Calculate the average between GPT ratings and human average  (calculated over all raters)
#       4. Store results separately for each K for later comparison.

# Severi Santavirta 27.5.2025, Lauri Suominen 21.8.2025

library(psych)
library(gtools)
library(ggplot2)
library(ggrepel)
require(lattice)

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Define all paths

gpt_data_all_average_path <- 'path/megaperception_project/raitings/data/gpt_4-1_data/average/all_averages/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv'
human_data_batches_path <- 'path/megaperception_project/raitings/data/human_data/data_csv'
average_corr_table_save_path <- 'path/megaperception_project/raitings/data/human_data/average_corr_tables'
scatterplot_avgcorr_save_path <- 'path/megaperception_project/raitings/analysis_gpt_4-1'

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Load preprocessed GPT data

# Load the GPT matrix
data_gpt = read.csv(gpt_data_all_average_path, check.names = FALSE)

# Edit data_gpt matrix
rownames(data_gpt) <- data_gpt$videoNames
data_gpt$videoNames <- NULL

colnames(data_gpt)[colnames(data_gpt) == 'Like things are under control'] <- 'Control'
colnames(data_gpt)[colnames(data_gpt) == 'Like viewing this demands effort'] <- 'Effort'
colnames(data_gpt)[colnames(data_gpt) == 'Like things are not fair'] <- 'Not fair'
colnames(data_gpt)[colnames(data_gpt) == 'Like you are obstructed by something'] <- 'Obstruction'
colnames(data_gpt)[colnames(data_gpt) == 'Like this went better than it first seemed it would'] <- 'Upswing'
colnames(data_gpt)[colnames(data_gpt) == 'Like you identify with a group of people'] <- 'Identity'
colnames(data_gpt)[colnames(data_gpt) == 'A sense of safety'] <- 'Safety'
colnames(data_gpt)[colnames(data_gpt) == 'Like this is something you would want to approach'] <- 'Approach'

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Calculate correlations between GPT and human average as well as correlations between human raters separately for each videoset (6 set) and feature (136 features)

# How many stimulus sets
n_sets = 4

# How many human to left out
khuman = c(1,2,3,4,5)

features <- colnames(data_gpt)
features <- gsub(" ","_",features)
for(ki in khuman){
  print(paste("Calculating correlations, k = ",ki,sep = ""))
  
  # Initialize result matrices
  avgcorr_human_set <- matrix(0,ncol = n_sets,nrow = length(features))
  avgcorr_gpt_set <- matrix(0,ncol = n_sets,nrow = length(features))
  avgcorr_gpt_set_pval <- matrix(0,ncol = n_sets,nrow = length(features))
  
  for(set in seq(from=1,to=n_sets)){
    # Calculate the pairwise correlations and average correlations for this video set
    for(feat in seq(from=1,to=ncol(data_gpt))){
      
      # Load human data
      data_human <- read.csv(paste(human_data_batches_path, '/',features[feat],"_",set,".csv",sep=""))
      rownames(data_human) <- data_human$Row
      data_human$Row <- NULL
      
      # Check include videos and take all values of that
      include_vid <- intersect(rownames(data_human),rownames(data_gpt))
      data_human_set <- data_human[include_vid,]
      
      # Reorder data_gpt to same order than data_human_set
      data_gpt_set <- data_gpt[rownames(data_human_set),]
      
      # Calculate the correlation between GPT and human average and check the p-value as well 
      cortest <- cor.test(data_gpt_set[,feat],rowMeans(data_human_set),method = "pearson",alternative = "greater",na.rm=T)
      avgcorr_gpt_set[feat,set] <- cortest$estimate
      avgcorr_gpt_set_pval[feat,set] <- cortest$p.value
      
      # Select the K left of human raters
      raters <- seq(from=1,by=1,to=ncol(data_human_set))
      k <- combn(raters,ki)
      
      # Correlations between individual raters compared to the average of others humans (GPT ratings are not included in the average calculations)
      avgcorr_human_feat <- c() 
      for(left_group in seq(from=1,by=1,to=ncol(k))){
        
        # Mean of the left out raters
        if(ki>1){
          mu_left <- rowMeans(data_human_set[,k[,left_group]],na.rm=T)
        }else{
          mu_left <- as.matrix(data_human_set[k[,left_group]])
        }
        
        # Mean of the other raters
        mu_others <- rowMeans(data_human_set[,setdiff(raters,k[,left_group])],na.rm=T)
        
        # Calculate the correlation between the two groups
        cortest_human <- cor.test(mu_left,mu_others,method = "pearson",na.rm=T)
        avgcorr_human_feat[left_group] <- cortest_human$estimate
        
      }
      
      # Store the the mean value over all possible combinations of groups (take Fischer transformation before calculating the mean)
      avgcorr_human_set[feat,set] <- tanh(mean(atanh(avgcorr_human_feat),na.rm = T))
    }
  }
  
  ##----------------------------------------------------------------------------------------------------------------------------------------------------------------
  # Save results
  
  # Take the average per videosets (take Fischer transformation before calculating the mean)
  avgcorr_gpt_mean <- tanh(rowMeans(atanh(avgcorr_gpt_set),na.rm = T))
  avgcorr_human_mean <- tanh(rowMeans(atanh(avgcorr_human_set),na.rm = T))
  
  # Calculate the aggregate p-value for each feature (https://www.nature.com/articles/s41598-021-8646y5-, Fischer's method)
  pvalues <- c()
  for(feat in seq(from=1,by=1,to=length(features))){
    pvals <- avgcorr_gpt_set_pval[feat,]
    pvals <- pvals[!is.na(pvals)]
    stat <- -2*sum(log(pvals))
    pvalues[feat] <- pchisq(stat, df = 2 * length(pvals), lower.tail = FALSE)
  }
  
  # Make data frames
  avgcorr <- as.data.frame(avgcorr_gpt_mean)
  rownames(avgcorr) <- features
  colnames(avgcorr) <- "gpt"
  
  # Human data is the same for each dataset, no need to save all
  avgcorr$human <- avgcorr_human_mean
  
  # Add the p-values
  avgcorr$gpt_pvalues <- pvalues
  
  # Save
  write.csv(avgcorr,paste(average_corr_table_save_path,'/avgcorr_table_',ki,'.csv',sep=""),row.names = T)
}

##-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Scatterplot the feature specific correlations against the correlations between humans. Plot seprately for each k (k: Number of humans to be left out from the calculation)

avgcor_gpt_better <- matrix(NA,nrow = ki,ncol = 4)
for(kj in khuman){
  
  avg_data <- read.csv(paste(average_corr_table_save_path, '/avgcorr_table_',kj,'.csv',sep=""))
  avg_data$X <- gsub("_", " ",avg_data$X) 
  
  # Scatterplot
  p <- ggplot(avg_data, aes(x=human, y=gpt,label = X)) + 
    geom_point(size=2) +
    geom_text_repel(box.padding = 0.3, max.overlaps = Inf,size = 6,segment.size = 0.1) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +  # Add y = x line
    ylab("Agreement of GPT-4V") +
    xlab("Intersubject consistency") +
    scale_x_continuous(limits = c(0,1)) +
    scale_y_continuous(limits = c(0,1)) +
    theme_minimal() +
    theme(axis.title = element_text(size=24),
          axis.text = element_text(size=20))
  
  pdf(paste(scatterplot_avgcorr_save_path,'/scatterplot_avgcorr_',kj,'.pdf',sep=""),width = 20,height = 6)
  print(p)
  dev.off()
  
  # For how many features the GPT exceeds individual humans ratings?
  avgcor_gpt_better[kj,1] <- sum(avg_data$gpt > avg_data$human) # Raw
  avgcor_gpt_better[kj,2] <- sum(avg_data$gpt > avg_data$human)/nrow(avg_data) # Percentage
  avgcor_gpt_better[kj,3] <- mean(avg_data$gpt) # Mean cor GPT
  avgcor_gpt_better[kj,4] <- mean(avg_data$human) # Mean cor human
}

avgcor_gpt_better <- as.data.frame(avgcor_gpt_better)
colnames(avgcor_gpt_better) <- c("gpt_better","gpt_better_perc","gpt_avgcor","human_avgcor")
