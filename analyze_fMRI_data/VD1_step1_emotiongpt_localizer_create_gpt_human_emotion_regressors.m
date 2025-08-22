%% Emotion GPT: Build GPT and human regressors for the megafmri data

% Severi Santavirta 5.3.2025, Lauri Suominen 21.8.2025

clear; clc;

%% INPUT

vids_path = 'path/fmri_analysis/localizer/video_clips_presentation_order';
datapath_gpt = 'path/fmri_analysis/VD1_fmri_gpt_4-1/materials/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv';
datapath_human = 'path/fmri_analysis/VD1_fmri_gpt_4-1/materials/combined_averages.csv';
datapath_log = 'path/presentation_log_files';
output = 'path/fmri_analysis/VD1_fmri_4-1/regressors';
volumes_path = 'path/fmri_analysis/localizer/megafmri-localizer-num_dyns.mat';
tr = 2.6; % time of repetition (the length of one volume in seconds)

%% Process the GPT ratings into suitable format

% Read the presented clips
clips = find_files(vids_path,'*.mp4');
[~,clips,~] = fileparts(clips);
clips = unique(clips);

% Get the video names in the presentations order
vidnames = cellfun(@(x) x(5:end), clips, 'UniformOutput', false);

% Read the rating data
ratings_gpt = readtable(datapath_gpt);
ratings_human = readtable(datapath_human);

% Sort therows into same alphabetical order
ratings_gpt = sortrows(ratings_gpt);
ratings_human = sortrows(ratings_human);

% Give row names and remove the video name columns
ratings_gpt.Properties.RowNames = ratings_gpt.videoNames;
ratings_gpt.videoNames = [];
ratings_human.Properties.RowNames = ratings_human.Row;
ratings_human.Row = [];

% Match emotion naming with humans
cols = ratings_gpt.Properties.VariableNames;
cols{strcmp(cols, 'ASenseOfSafety')} = 'Safety';
cols{strcmp(cols, 'LikeThisWentBetterThanItFirstSeemedItWould')} = 'Upswing';
cols{strcmp(cols, 'LikeYouIdentifyWithAGroupOfPeople')} = 'Identity';
cols{strcmp(cols, 'LikeThisIsSomethingYouWouldWantToApproach')} = 'Approach';
cols{strcmp(cols, 'LikeYouAreObstructedBySomething')} = 'Obstruction';
cols{strcmp(cols, 'LikeViewingThisDemandsEffort')} = 'Effort';
cols{strcmp(cols, 'LikeThingsAreUnderControl')} = 'Control';
cols{strcmp(cols, 'LikeThingsAreNotFair')} = 'Not_fair';
cols{strcmp(cols, 'AestheticAppreciation')} = 'Aesthetic_appreciation';
cols{strcmp(cols, 'SexualDesire')} = 'Sexual_desire';
cols{strcmp(cols, 'EmpathicPain')} = 'Empathic_pain';
ratings_gpt.Properties.VariableNames = cols;

% Sort columns into same alphabetical order
[~, idx] = sort(ratings_gpt.Properties.VariableNames);
ratings_gpt = ratings_gpt(:,idx);
[~, idx] = sort(ratings_human.Properties.VariableNames);
ratings_human = ratings_human(:,idx);

% Get the row indices of the videos in the ratings data (indices are the same for human and gpt)
[~, indices] = ismember(vidnames, ratings_gpt.Properties.RowNames);

% Megaperception dataset did not contain all videos shown in fMRI (9 out of 96 presented videos are not available)
indices(indices==0) = [];

% Select only these rows
feature_ratings_gpt = table2array(ratings_gpt(indices,:));
feature_ratings_human= table2array(ratings_human(indices,:));
feature_clips = ratings_gpt.Properties.RowNames(indices);
feature_clips = cellfun(@(x) ['v', x], feature_clips, 'UniformOutput', false);
features = ratings_gpt.Properties.VariableNames;

%% Build the regressors

% Load the volumes of each subjects' fmri
load(volumes_path);

% Build individual regressors for each subject based on their log files
logs = find_files(datapath_log,'*megalocalizer.log');
logs = logs(2:end);

for sub = 1:size(subjects,1)

    % Read the log file
    [presented_video_order,presented_video_onsets,presented_video_durs] = localizer_read_log(logs{sub});
    
    % Build regressors
    [Rgpt,TSgpt,tRgpt,tTSgpt] = localizer_create_gpt_regressors(feature_ratings_gpt,feature_clips,presented_video_order,presented_video_onsets,presented_video_durs,num_dyns(sub),tr);
    [Rhuman,TShuman,tRhuman,tTShuman] = localizer_create_gpt_regressors(feature_ratings_human,feature_clips,presented_video_order,presented_video_onsets,presented_video_durs,num_dyns(sub),tr);

    % Save the data
    save(sprintf('%s/gpt_reg/localizer_sub-%s_gpt_regressors.mat',output,subjects{sub}),'Rgpt','TSgpt','tRgpt','tTSgpt','features');
    save(sprintf('%s/human_reg/localizer_sub-%s_human_regressors.mat',output,subjects{sub}),'Rhuman','TShuman','tRhuman','tTShuman','features');

end

function [video_presentation_order,video_onsets,video_durs] = localizer_read_log(logfile)
% Read the timing information of the presented video clips from
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
c_idx = find(strcmp(header,'Code'));

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
        if(strcmp(events{i},'Video'))
            t(i) = str2double(h{t_idx+4});
        end
        k = 0;
        while(isnan(t(i)))
            k = k + 1;
            t(i) = str2double(h{t_idx+k});
        end
    end
    l = fgetl(fid);
end

fclose(fid);

t = t(1:i);
codes = codes(1:i);
events = events(1:i);

t = (t - t(1))/10000;

video_idx = strcmp(events,'Video');
fix1_idx = strcmp(codes,'fix1');

video_presentation_order = codes(video_idx);
video_onsets = t(video_idx);
last_dur = t(fix1_idx) - video_onsets(end);
video_durs = [diff(video_onsets);last_dur];

end
function [R,TS,tR,tTS] = localizer_create_gpt_regressors(feature_ratings,feature_clips,presented_video_order,presented_video_onsets,presented_video_durs,num_vols,tr)
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
    video_ratings_presentation{i,3} = presented_video_durs(i);
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
nt = sum(cellfun(@length,video_ratings_presentation(:,3)));
t_vid = zeros(nt,1);
nf = size(video_ratings_presentation{1,2},2);
Y = zeros(nt,nf);
for i = 1:n_clips
    x = video_ratings_presentation(i,:);
    nvx = size(x{2},1);
    first_zero_idx = find(t_vid == 0, 1, 'first');
    t_vid(first_zero_idx:(first_zero_idx+nvx-1)) = x{3};
    Y(first_zero_idx:(first_zero_idx+nvx-1),:) = x{2};
end

% Upsample rating time series to 100ms scale
t_vid = cumsum(t_vid);
tTS = 0.1:0.1:t_vid(end);
TS = zeros(length(tTS),nf);
for i = 1:nt
    if(i == 1)
        st = 0.1;
    else
        st = t_vid(i-1);
    end
    et = t_vid(i);
    v_idx = tTS >= st & tTS < et;
    for j = 1:nf
        TS(v_idx,j) = Y(i,j);
    end
end

% Convolve the upsampled rating time series with canonical HRF
Z_hrf = zeros(size(TS));
for i = 1:nf
    Z_hrf(:,i) = hrf_convolve_regressor(TS(:,i),0.1,1,6,16);
end

% Interpolate to fMRI time points
tTS = tTS + presented_video_onsets(1); % Correct timings for the onset of the fMRI scan
R = zeros(num_vols,nf);
for i = 1:nf
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
