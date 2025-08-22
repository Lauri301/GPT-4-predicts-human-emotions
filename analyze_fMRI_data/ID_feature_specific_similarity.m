%% MegaGPT: Compare the emotion specific fMRI results for emotional evaluation between GPT-4 and humans
% The following metrics for evaluating the reliability of GPT-4 derived brain response patterns are calculated
% correlation = Correlation between the unthresholded second level beta maps
% tp_norm = How many true positives out of all positive voxels (positive predictive value, PPV)
% fp_norm = How many false positives out of all positive voxels (false discovery rate, FDR)
% tn_norm = How many true negatives out of all negative voxels (negative predictive value, NPV)
% fn_norm = How many false negatives out of negative voxels (false omission rate, FOV)

% Severi Santavirta & Yuhang Wu, 8.8.2024, Lauri Suominen 21.8.2025

clear; clc;

%% INPUT

% Directories
basedir = 'path/fmri_analysis/NAPS_fmri_gpt-4-1'; % CHANGE
brainmask = 'path/fmri_analysis/megafmri_localizer_gm_mask.nii';

human_dir = fullfile(basedir, '/second_level_human');
gpt_dir = fullfile(basedir, '/second_level_gpt');

%% SCRIPT

% List all subfolders in human_dir folder
dir_info = dir(human_dir);

% Filter out '.' and '..'
dir_info_idx = ~ismember({dir_info.name}, {'.', '..'});

% Look for the names of emotions in the subfolder names
emotions = {dir_info(dir_info_idx).name};
n_emotions = length(emotions);

% Specify the filename to be compared
target_file = 'beta_0001.nii';

% Read brainmask
brainmask_V = spm_vol(brainmask);
brainmask_data = spm_read_vols(brainmask_V);
brainmask_data = logical(brainmask_data(:));

% Defining tables
emotion_names = cell(n_emotions,1);  % Names of emotions
correlations = zeros(n_emotions,1);  % Pearson correlations
PPV_matrix_unc0001 = zeros(n_emotions,1);    % PPV-values to unc0001
NPV_matrix_unc0001 = zeros(n_emotions,1);    % NPV-values to unc0001
PPV_matrix_FWE005 = zeros(n_emotions,1);    % PPV-values to FWE005
NPV_matrix_FWE005 = zeros(n_emotions,1);    % NPV-values to FWE005

% Loop for all emotions
for i = 1:n_emotions
    emotion = emotions{i};

    unc0001 = sprintf('spmT_0001_unc0001_pos_%s.nii', emotion);
    FWE005 = sprintf('spmT_0001_FWE005_pos_%s.nii', emotion);

    % Save the emotion name
    emotion_names{i} = emotion;
    
    % Paths to files
    human_file_beta = fullfile(human_dir, emotion, target_file);
    gpt_file_beta   = fullfile(gpt_dir, emotion, target_file);
    
    % Check that both files exist
    if exist(human_file_beta, 'file') && exist(gpt_file_beta, 'file')
        
        % Read NIFTI files
        human_beta_V = spm_vol(human_file_beta);
        human_beta_data = spm_read_vols(human_beta_V);
        human_beta_data = human_beta_data(:);

        gpt_beta_V = spm_vol(gpt_file_beta);
        gpt_beta_data = spm_read_vols(gpt_beta_V);
        gpt_beta_data = gpt_beta_data(:);

        % Remove NaN values with brainmask
        human_beta_data = human_beta_data(brainmask_data);
        gpt_beta_data = gpt_beta_data(brainmask_data);

        % Remove the remaining NaN values
        H_nan_idx = ~isnan(human_beta_data);
        human_beta_data = human_beta_data(H_nan_idx);

        GPT_nan_idx = ~isnan(gpt_beta_data);
        gpt_beta_data = gpt_beta_data(GPT_nan_idx);

        % Calculate Pearson’s correlation
        [r,p] = corr(human_beta_data,gpt_beta_data,'Type','Pearson');

        % Add correlation value to table
        correlations(i) = r;
    end

    % Paths to files
    human_file_unc0001 = fullfile(human_dir, emotion, unc0001);
    gpt_file_unc0001   = fullfile(gpt_dir, emotion, unc0001);

    % Check that both files exist
    if exist(human_file_unc0001, 'file') && exist(gpt_file_unc0001, 'file')

        % Read NIFTI files
        human_unc0001_V = spm_vol(human_file_unc0001);
        human_unc0001_data = spm_read_vols(human_unc0001_V);
        human_unc0001_data = human_unc0001_data(:);

        gpt_unc0001_V = spm_vol(gpt_file_unc0001);
        gpt_unc0001_data = spm_read_vols(gpt_unc0001_V);
        gpt_unc0001_data = gpt_unc0001_data(:);

        % Remove NaN values with brainmask
        human_unc0001_data = human_unc0001_data(brainmask_data);
        gpt_unc0001_data = gpt_unc0001_data(brainmask_data);
    
        % Calculate TP, FP, TN and FN
        TP_unc0001 = sum(human_unc0001_data > 0 & gpt_unc0001_data > 0);
        FP_unc0001 = sum(isnan(human_unc0001_data) & gpt_unc0001_data > 0);
        TN_unc0001 = sum(isnan(human_unc0001_data) & isnan(gpt_unc0001_data));
        FN_unc0001 = sum(human_unc0001_data > 0 & isnan(gpt_unc0001_data));
    
        % Calculate PPV and NPV
        PPV_unc0001 = TP_unc0001 / (TP_unc0001 + FP_unc0001);
        NPV_unc0001 = TN_unc0001 / (TN_unc0001 + FN_unc0001);
    
        % Save PPV and NPV values
        PPV_matrix_unc0001(i) = PPV_unc0001;
        NPV_matrix_unc0001(i) = NPV_unc0001;
    end

    % Paths to files
    human_file_FWE005 = fullfile(human_dir, emotion, FWE005);
    gpt_file_FWE005   = fullfile(gpt_dir, emotion, FWE005);

    % Check that both files exist
    if exist(human_file_FWE005, 'file') && exist(gpt_file_FWE005, 'file')

        % Read NIFTI files
        human_FWE005_V = spm_vol(human_file_FWE005);
        human_FWE005_data = spm_read_vols(human_FWE005_V);
        human_FWE005_data = human_FWE005_data(:);

        gpt_FWE005_V = spm_vol(gpt_file_FWE005);
        gpt_FWE005_data = spm_read_vols(gpt_FWE005_V);
        gpt_FWE005_data = gpt_FWE005_data(:);

        % Remove NaN values with brainmask
        human_FWE005_data = human_FWE005_data(brainmask_data);
        gpt_FWE005_data = gpt_FWE005_data(brainmask_data);
    
        % Calculate TP, FP, TN and FN
        TP_FWE005 = sum(human_FWE005_data > 0 & gpt_FWE005_data > 0);
        FP_FWE005 = sum(isnan(human_FWE005_data) & gpt_FWE005_data > 0);
        TN_FWE005 = sum(isnan(human_FWE005_data) & isnan(gpt_FWE005_data));
        FN_FWE005 = sum(human_FWE005_data > 0 & isnan(gpt_FWE005_data));
    
        % Calculate PPV and NPV
        PPV_FWE005 = TP_FWE005 / (TP_FWE005 + FP_FWE005);
        NPV_FWE005 = TN_FWE005 / (TN_FWE005 + FN_FWE005);
    
        % Save PPV and NPV values
        PPV_matrix_FWE005(i) = PPV_FWE005;
        NPV_matrix_FWE005(i) = NPV_FWE005;
    end
end

% Combine all matrices into one table
similarity_table = table(emotion_names, correlations, PPV_matrix_unc0001, NPV_matrix_unc0001, PPV_matrix_FWE005, NPV_matrix_FWE005, ...
    'VariableNames', {'Emotion', 'Correlation', 'PPV_unc0001', 'NPV_unc0001', 'PPV_FWE005', 'NPV_FWE005'});

filename = 'NAPS_gpt-4-turbo_similarity_table.csv';
writetable(similarity_table, fullfile(basedir, filename));
