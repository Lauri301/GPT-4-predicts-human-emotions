%% EmotionGPT: Calculate low-level features and create low level regressors for image experiment
%
% Procedure
%           1.  Average visual features are calculated for each static image.
%
%           2.  Features are correlated and we take PCA. We select all 4
%               PCs for analysis as they all explain unique variance.
%
%           3.  PCs are convolved with canonical HRF and interpolated to
%               fMRI timings to build regressors for modelling
%
% Severi Santavirta 1.2.2026

%% 1. Estimate low-level features
p_imgs = 'path/naps/PIC_naps_megafmri';
f = dir(p_imgs);
f = f(~ismember({f.name}, {'.', '..'}));
pics = {f.name}';

data_img = zeros(size(pics,1),4);
for I = 1:size(pics,1)
    fprintf('%d/%d\n',(I),(size(pics,1)))
    p = sprintf('%s/%s',p_imgs,pics{I});
    pic = imread(p);

    [data_visual,cats_visual] = image_filter_avg(pic);
    data_img(I,:) = data_visual;
end

data_img = array2table(data_img);
data_img.Properties.VariableNames = cats_visual;
data_img.names = pics;
writetable(data_img,'path/naps/lowlevel/lowlevel_data.csv');

%% 2. PCA of low level features

data = table2array(data_img(:,1:4));

y_std = zscore(data); % Features are in very different scales, we need to standardize them first.
[coeff,score,latent,tsquared,explained,mu] = pca(y_std);

cats_lowlevel = {'pca1','pca2','pca3','pca4'};
data_pca = array2table(score);
data_pca.Properties.VariableNames = cats_lowlevel;
data_pca.names = pics;
writetable(data_pca,'path/naps/lowlevel/lowlevel_data_pca.csv');

%% 3. Build the regressors

datapath_lowlevel = 'path/naps/lowlevel/lowlevel_data_pca.csv';
datapath_log = 'path/presentation_log_files';
output = 'path/naps/lowlevel/pca_regressors';
tr = 2.6; % time of repetition (the length of one volume in seconds)
num_vols = 511;

tbl = readtable(datapath_lowlevel);
data = table2array(tbl(:,1:4));
pics = tbl.names;
pics = erase(pics, ".jpg");
features = tbl.Properties.VariableNames(1:4);
features = [features,'Image_off'];

% Build individual regressors for each subject based on their log files
logs = find_files(datapath_log,'*-AffectiveImages_Scenario.log');
logs = logs(2:end);

subjects = {'sub-001';'sub-002';'sub-003';'sub-004';'sub-005';'sub-006';'sub-007';'sub-008';'sub-009';'sub-010';'sub-011';'sub-012';'sub-013';'sub-014';'sub-015';'sub-016';'sub-017';'sub-018';'sub-019';'sub-020';'sub-021';'sub-022';'sub-023';'sub-024';'sub-025';'sub-026';'sub-027';'sub-028';'sub-029';'sub-030';'sub-031';'sub-032';'sub-033';'sub-034';'sub-035';'sub-036';'sub-037';'sub-038';'sub-039';'sub-040';'sub-041';'sub-042';'sub-043';'sub-044';'sub-045';'sub-046';'sub-047';'sub-048';'sub-049';'sub-050';'sub-051';'sub-052';'sub-053';'sub-054';'sub-055';'sub-056';'sub-057';'sub-058';'sub-059';'sub-060';'sub-061';'sub-062';'sub-063';'sub-064';'sub-065';'sub-066';'sub-067';'sub-068';'sub-069';'sub-070';'sub-071';'sub-072';'sub-073';'sub-074';'sub-075';'sub-076';'sub-077';'sub-078';'sub-079';'sub-080';'sub-081';'sub-082';'sub-083';'sub-084';'sub-085';'sub-086';'sub-087';'sub-088';'sub-089';'sub-090';'sub-091';'sub-092';'sub-093';'sub-094';'sub-095';'sub-096';'sub-097';'sub-098';'sub-099';'sub-100';'sub-101';'sub-102';'sub-103';'sub-104'};

for sub = 1:size(subjects,1)

    % Read the log file
    [presented_pic_order,presented_pic_onsets,presented_pic_durs] = pictures_read_log(logs{sub});
    
    % Build regressors
    [R,TS,tR,tTS] = pictures_create_gpt_regressors(data,pics,presented_pic_order,presented_pic_onsets,presented_pic_durs,num_vols,tr);

    % Save the data
    save(sprintf('%s/pictures_%s_lowlevel_regressors.mat',output,subjects{sub}),'R','TS','tR','tTS','features');
end

%% Functions

function [avgFiltered,filters] = image_filter_avg(img)
% Function filters the input frame in multiple ways and only calculates the
% average over the whole image.
%
% Filters:
%       1. Luminance
%       2. Entropy
%       3. Spatial energy high frequency (Fourier transform -> low-pass filter -> 1% cut-off from the highest frequencies)
%       4. Spatial energy low frequency (Fourier transform -> low-pass filter -> 10% cut-off from the highest frequencies)
%
% Severi Santavirta 23.11.2023
filters = {'Luminance','Entropy','SpatialEnergyHF','SpatialEnergyLF'};

% Filter image
avgFiltered = zeros(1,4);
[avgFiltered(1),avgFiltered(2)] = filter_avg_luminance_entropy(img);
avgFiltered(3) = filter_avg_spatialEnergy(img,1);
avgFiltered(4) = filter_avg_spatialEnergy(img,10);

end
function [luminance,visualEntropy] = filter_avg_luminance_entropy(img)

    % Get value from HSV for luminance estimation
    hsv_img = rgb2hsv(img);
    v = squeeze(hsv_img(:,:,3));
    v = v(:);
    luminance = mean(v);
    
    % Greyscale for entropy estimation
    imgGrey = rgb2gray(img);
    visualEntropy = entropy(imgGrey);
    
end
function spatialEnergy = filter_avg_spatialEnergy(img,fourierRadius)


    % Fourier filter
    % Define Low-pass filter
    siz = size(img);
    [Y,X]=ndgrid(1:siz(1),1:siz(2));
    rad = fourierRadius/100*siz(1);
    tmp = max((Y.^2+X.^2<rad^2),max((flipud(Y).^2+X.^2<rad^2),max((Y.^2+fliplr(X).^2<rad^2),(flipud(Y).^2+fliplr(X).^2<rad^2))));
    fourierMask = ones(siz(1),siz(2));
    fourierMask(tmp) = 0;
    
    % Calculate snrg
    F = fft2(mean(img,3,'omitnan')); % Fourier transform
    spatialEnergy = abs(ifft2(fourierMask.*F)); % Filtered image
    spatialEnergy = mean(spatialEnergy(:));
end
function [picture_presentation_order,picture_onsets,picture_durs] = pictures_read_log(logfile)
% Read the timing information of the presented picture from
% presentation log files in a localizer design

fid = fopen(logfile,'r');

c = 1;
while(c)
    l = fgetl(fid);
    h = strsplit(l,'\t');
    if(strcmp(h{1},'Subject'))
        c = 0;
        header = h;
    else
        c = 1;
    end
end

t_idx = find(strcmp(header,'Time'));
et_idx = find(strcmp(header,'Event Type'));
c_idx = find(strcmp(header,'trialNumber(num)'));

t = zeros(10000,1);
events = cell(10000,1);
codes = events;

l = fgetl(fid);
i = 0;
while(isempty(l) || length(l) > 1 || l~=-1)
    if(~isempty(l))
        h = strsplit(l,'\t','CollapseDelimiters',false);
        if(strcmp(h{1},'Event Type'))
            break;
        end
        i = i + 1;
        events{i} = h{et_idx};
        codes{i} = h{c_idx};
        t(i) = str2double(h{t_idx});
    end
    l = fgetl(fid);
end

fclose(fid);

t = t(1:i);
codes = codes(1:i);
events = events(1:i);

t = (t - t(1))/10000;

picture_idx = strcmp(events,'Picture');

picture_presentation_order = codes(picture_idx);
picture_onsets = t(picture_idx);

fix_idx = ~strcmp(picture_presentation_order, 'fix');
picture_presentation_order = picture_presentation_order(fix_idx);
picture_onsets = picture_onsets(fix_idx);

picture_durs = diff(picture_onsets);
picture_durs = [picture_durs;mean(picture_durs)]; 

end
function [R,TS,tR,tTS] = pictures_create_gpt_regressors(feature_ratings,feature_clips,presented_video_order,presented_video_onsets,presented_video_durs,num_vols,tr)
% This function creates convolved regressors for features in localizer design where short video clips are presented during an fmri scan by matching
% behavioural data with the timings read from the presentation log files
%
% INPUT
%       feature_rating              = N x M matrix of behavioural rating data, N = number of time points, M = number of features
%       feature_clips               = N x 1 vector of video clip information of the time points
%       presented_video_order       = K x 1 vector, clip names in presentation order (from localizer_read_log function)
%       presented_video_onsets      = K x 1 vector, clip onsets in presentation order (from localizer_read_log function)
%       presented_video_durs        = K x 1 vector, clip duration in presentation order (from localizer_read_log function)
%       num_vols                    = value, number of volumes in fMRI scan
%       tr                          = value, time of repetition in seconds
%
% OUTPUT
%       R                           = num_vols x M matrix, Convolved regressors for behavioural rating data
%       TS                          = L x M marix, Upsampled (100ms) rating time series of behavioural data in fMRI order and timings
%       tR                          = num_vols x 1 vector, Regressor timings
%       tTS                         = L x 1 vector, upsampled data timings
% @ Severi Santavirta 15.05.2023

% Scan times
scan_dur = num_vols*tr;
h = tr/2;
tR = h:tr:scan_dur;

n_clips = size(presented_video_order,1);
video_ratings_presentation = cell(n_clips,4);

% Loop over all the presented video clips
n_missing = 0;
for i = 1:n_clips
    v = presented_video_order{i};
    idx = find(strcmp(feature_clips,v));
    video_ratings_presentation{i,1} = v;
    video_ratings_presentation{i,3} = presented_video_onsets(i);
    video_ratings_presentation{i,4} = presented_video_durs(i);
    if(any(idx))
        video_ratings_presentation{i,2} = feature_ratings(idx,:);
    else % We have no ratings for this clip. Use zero values here.
        video_ratings_presentation{i,2} = zeros(1,size(feature_ratings,2));
        n_missing = n_missing+1;
    end
end

%% Create the regressors

% Create the rating time series in fMRI order
t_start = cell2mat(video_ratings_presentation(:,3));
t_end = t_start + 1.4;

% Make time index
t_start_idx = round(t_start*10);
t_end_idx = round(t_end*10);

% Initialize variables
nf = size(video_ratings_presentation{1,2},2);
tTS = 0.1:0.1:(tr*num_vols);
TS = zeros(size(tTS,2), nf);
offTS = zeros(length(tTS),1);
tR = 1.3:2.6:(tr*num_vols);

% Loop for filling the Y matrix
for n = 1:n_clips
    TS(t_start_idx(n):t_end_idx(n),:) = repmat(video_ratings_presentation{n,2},t_end_idx(n) - t_start_idx(n) + 1,1);
    if(n<n_clips)
        offTS(t_end_idx(n)+1:t_start_idx(n+1) - 1, 1) = 1;
    else
        % Fill in the sections before and after the stimulus
        offTS(t_end_idx(n)+1:end,1) = 1;
        offTS(1:t_start_idx(1)-1,1) = 1;
    end
end

TS(:,size(TS,2) + 1) = offTS;

% Convolve the upsampled rating time series with canonical HRF
Z_hrf = zeros(size(TS));
for i = 1:nf+1
    Z_hrf(:,i) = hrf_convolve_regressor(TS(:,i),0.1,1,6,16);
end

% Interpolate to fMRI time points
R = zeros(num_vols,nf+1);
for i = 1:nf+1
    R(:,i) = interp1(tTS,Z_hrf(:,i),tR,'linear',0);
end

tTS = tTS'; tR = tR';
end
function files = find_files(directory,filter)

if(nargin < 2)
    msg = sprintf('You need to specify two input arguments: First, the directory under which you want to perform the search, and second the filter.\n\nFor example: files = find_files(''/scratch/shared/toolbox/spm12'',''*.m'')');
    error(msg);
end

files = get_filenames(directory,filter);
if(~isempty(files))
    dirs = zeros(length(files),1);
    for f = 1:length(files)
        dirs(f) = isdir(files{f});
    end
    dir_idx = find(dirs);
    files(dir_idx) = [];
end

d = dir(directory);
isub = [d(:).isdir]; %# returns logical vector
all_subfolders = {d(isub).name}';
all_subfolders(ismember(all_subfolders,{'.','..'})) = [];

all_subfolders = strcat(directory,'/',all_subfolders);

for i = 1:length(all_subfolders)
    a = find_files(all_subfolders{i},filter);
    if(~isempty(a))
        files = [files;a];
    end
end

end