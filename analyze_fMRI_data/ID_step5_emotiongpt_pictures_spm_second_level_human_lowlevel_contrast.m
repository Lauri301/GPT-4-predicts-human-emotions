%% EmotionGPT: Contrast the human based results with the low-level results
% For both statistical thresholds only those voxels are considered to be related to emotion prosessing 
% where the the association is stronger than for any lowlevel features

% Severi Santavirta 17.1.2026

%% SCRIPT

lowlevel_output = 'path/naps/fmri_analysis/second_level/lowlevel_confounds';
feature_output = 'path/naps/fmri_analysis/second_level/human';

feature_dirs = dir(feature_output);
feature_dirs = feature_dirs([feature_dirs.isdir]); % Keep only directories
feature_dirs = feature_dirs(~ismember({feature_dirs.name}, {'.', '..'}));

lowlevel_dirs = dir(lowlevel_output);
lowlevel_dirs = lowlevel_dirs([lowlevel_dirs.isdir]); % Keep only directories
lowlevel_dirs = lowlevel_dirs(~ismember({lowlevel_dirs.name}, {'.', '..'}));

for i = 1:length(feature_dirs)
    % Load emotion results
    V = spm_vol(sprintf('%s/%s/spmT_0001_unc0001_pos_%s.nii',feature_output,feature_dirs(i).name,feature_dirs(i).name));
    img_feature_unc = spm_read_vols(V);
    V = spm_vol(sprintf('%s/%s/spmT_0001_FWE005_pos_%s.nii',feature_output,feature_dirs(i).name,feature_dirs(i).name));
    img_feature_fdr = spm_read_vols(V);
    img_contrast_unc = zeros(size(img_feature_unc));
    img_contrast_fdr = zeros(size(img_feature_unc));
    for j = 1:length(lowlevel_dirs)
        % Load lowlevel results
        V = spm_vol(sprintf('%s/%s/spmT_0001_unc0001_pos_%s.nii',lowlevel_output,lowlevel_dirs(j).name,lowlevel_dirs(j).name));
        img_lowlevel_unc = spm_read_vols(V);
        V = spm_vol(sprintf('%s/%s/spmT_0001_FWE005_pos_%s.nii',lowlevel_output,lowlevel_dirs(j).name,lowlevel_dirs(j).name));
        img_lowlevel_fdr = spm_read_vols(V);

        % Perform voxel-wise comparison between feature and low-level results
        img_contrast_unc = img_contrast_unc + ((img_feature_unc > img_lowlevel_unc) | (isnan(img_lowlevel_unc) & ~isnan(img_feature_unc)));
        img_contrast_fdr = img_contrast_fdr + ((img_feature_fdr > img_lowlevel_fdr) | (isnan(img_lowlevel_fdr) & ~isnan(img_feature_fdr)));

    end

    % From the original T map select only those voxels where T-value was
    % higher than any of the low level contrast T values
    img_final_unc = img_feature_unc;
    img_final_unc(img_contrast_unc < length(lowlevel_dirs)) = nan;
    img_final_fdr = img_feature_fdr;
    img_final_fdr(img_contrast_fdr < length(lowlevel_dirs)) = nan;

    % Save the contrast results
    V.fname = sprintf('%s/%s/spmT_0001_unc0001_pos_%s_lowlevel_contrasted.nii', feature_output, feature_dirs(i).name, feature_dirs(i).name);
    spm_write_vol(V, img_final_unc);
    V.fname = sprintf('%s/%s/spmT_0001_FWE005_pos_%s_lowlevel_contrasted.nii', feature_output, feature_dirs(i).name, feature_dirs(i).name);
    spm_write_vol(V, img_final_fdr);
end