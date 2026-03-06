%% EmotionGPT: Calculate cumulative maps for emotions in pictures dataset based on GPT and human based fMRI results

% Severi Santavirta, Lauri Suominen 1.2.2026

%% SCRIPT

% Calculate the cumulative maps from p < 0.001, uncorrected results
basedir = 'path/naps/fmri_analysis/second_level';

feature_dirs = dir(sprintf('%s/gpt',basedir));
feature_dirs = feature_dirs([feature_dirs.isdir]); % Keep only directories
feature_dirs = feature_dirs(~ismember({feature_dirs.name}, {'.', '..'}));

for i = 1:length(feature_dirs)
    fprintf('%d\n',i);
    feature = feature_dirs(i).name;

    % Read data
    human = spm_read_vols(spm_vol(sprintf('%s/human/%s/spmT_0001_unc0001_pos_%s_lowlevel_contrasted.nii',basedir,feature,feature)));
    gpt = spm_read_vols(spm_vol(sprintf('%s/gpt/%s/spmT_0001_unc0001_pos_%s_lowlevel_contrasted.nii',basedir,feature,feature)));

    % Binarize
    gpt(~isnan(gpt)) = 1;
    gpt(isnan(gpt)) = 0;
    human(~isnan(human)) = 1;
    human(isnan(human)) = 0;

    if(i == 1)
        gpt_cum = gpt;
        human_cum = human;
    else
        gpt_cum = gpt_cum + gpt;
        human_cum = human_cum + human;
    end
end

% Calculate a difference map
cum_diff = human_cum - gpt_cum;

% Save the maps
V = spm_vol(sprintf('%s/human/%s/spmT_0001_unc0001_pos_%s_lowlevel_contrasted.nii',basedir,feature,feature)); % Copy header
V.fname = sprintf('%s/cumulative_gpt.nii',basedir);
%spm_write_vol(V,gpt_cum);
V.fname = sprintf('%s/cumulative_human.nii',basedir);
%spm_write_vol(V,human_cum);
V.fname = sprintf('%s/cumulative_difference.nii',basedir);
%spm_write_vol(V,cum_diff);

% Calcalate the correlation between the cumulative maps.
img_gpt = spm_read_vols(spm_vol(sprintf('%s/cumulative_gpt.nii',basedir)));
img_human = spm_read_vols(spm_vol(sprintf('%s/cumulative_human.nii',basedir)));
img_gpt = img_gpt(:);
img_human = img_human(:);

% Select only in-brain voxels
mask = spm_read_vols(spm_vol('path/megafmri_localizer_gm_mask_3mm.nii'));
mask = logical(mask(:));
img_gpt = img_gpt(mask);
img_human = img_human(mask);
r = corr(img_gpt,img_human);
