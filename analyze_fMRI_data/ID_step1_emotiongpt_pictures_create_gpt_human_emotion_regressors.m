%% Emotion GPT: Build GPT and human regressors for the megafmri data

% Severi Santavirta 5.3.2025, Lauri Suominen 21.8.2025

%% INPUT

datapath_gpt = 'path/fmri_analysis/ID_fmri_gpt-4-1/materials/output_average_10_files_1_2_3_4_5_6_7_8_9_10.csv';
datapath_human = 'path/fmri_analysis/ID_fmri_gpt-4-1/materials/human_average_ratings_gpt-4-1.csv';
datapath_log = 'path/presentation_log_files';
output = 'path/fmri_analysis/ID_fmri_gpt-4-1/regressors';
tr = 2.6; % time of repetition (the length of one volume in seconds)
num_vols = 511;


%% Process the GPT ratings into suitable format

% Read the rating data
ratings_gpt = readtable(datapath_gpt);
ratings_gpt.imageNames = erase(ratings_gpt.imageNames, '.jpg');
ratings_human = readtable(datapath_human);

% Search videos and ratings from human data using gpt retings
[~, gpt_pics_idx] = ismember(ratings_human.imageNames, ratings_gpt.imageNames);
ratings_human = ratings_human(gpt_pics_idx,:);

% Sort therows into same alphabetical order
ratings_gpt = sortrows(ratings_gpt);
ratings_human = sortrows(ratings_human);

% Give row names and remove the video name columns
ratings_gpt.Properties.RowNames = ratings_gpt.imageNames;
ratings_gpt.imageNames = [];
ratings_human.Properties.RowNames = ratings_human.imageNames;
ratings_human.imageNames = [];

% Sort columns into same alphabetical order
[~, idx] = sort(ratings_gpt.Properties.VariableNames);
ratings_gpt = ratings_gpt(:,idx);
[~, idx] = sort(ratings_human.Properties.VariableNames);
ratings_human = ratings_human(:,idx);

% Select only these rows
feature_ratings_gpt = table2array(ratings_gpt);
feature_ratings_human= table2array(ratings_human);
feature_clips = ratings_gpt.Properties.RowNames;
features_gpt = ratings_gpt.Properties.VariableNames;
features_human = ratings_human.Properties.VariableNames;

%% Build the regressors

% Build individual regressors for each subject based on their log files
logs = find_files(datapath_log,'*-AffectiveImages_Scenario.log');
logs = logs(2:end);

subjects = {'sub-001';'sub-002';'sub-003';'sub-004';'sub-005';'sub-006';'sub-007';'sub-008';'sub-009';'sub-010';'sub-011';'sub-012';'sub-013';'sub-014';'sub-015';'sub-016';'sub-017';'sub-018';'sub-019';'sub-020';'sub-021';'sub-022';'sub-023';'sub-024';'sub-025';'sub-026';'sub-027';'sub-028';'sub-029';'sub-030';'sub-031';'sub-032';'sub-033';'sub-034';'sub-035';'sub-036';'sub-037';'sub-038';'sub-039';'sub-040';'sub-041';'sub-042';'sub-043';'sub-044';'sub-045';'sub-046';'sub-047';'sub-048';'sub-049';'sub-050';'sub-051';'sub-052';'sub-053';'sub-054';'sub-055';'sub-056';'sub-057';'sub-058';'sub-059';'sub-060';'sub-061';'sub-062';'sub-063';'sub-064';'sub-065';'sub-066';'sub-067';'sub-068';'sub-069';'sub-070';'sub-071';'sub-072';'sub-073';'sub-074';'sub-075';'sub-076';'sub-077';'sub-078';'sub-079';'sub-080';'sub-081';'sub-082';'sub-083';'sub-084';'sub-085';'sub-086';'sub-087';'sub-088';'sub-089';'sub-090';'sub-091';'sub-092';'sub-093';'sub-094';'sub-095';'sub-096';'sub-097';'sub-098';'sub-099';'sub-100';'sub-101';'sub-102';'sub-103';'sub-104'};

features_gpt{:,size(features_gpt,2) + 1} = 'Image_off';
features_human{:,size(features_human,2) + 1} = 'Image_off';

for sub = 1:size(subjects,1)

    % Read the log file
    [presented_video_order,presented_video_onsets,presented_video_durs] = pictures_read_log(logs{sub});
    
    % Build regressors
    [Rgpt,TSgpt,tRgpt,tTSgpt] = localizer_create_gpt_regressors(feature_ratings_gpt,feature_clips,presented_video_order,presented_video_onsets,presented_video_durs,num_vols,tr);
    [Rhuman,TShuman,tRhuman,tTShuman] = localizer_create_gpt_regressors(feature_ratings_human,feature_clips,presented_video_order,presented_video_onsets,presented_video_durs,num_vols,tr);

    % Save the data
    save(sprintf('%s/gpt_reg/localizer_%s_gpt_regressors.mat',output,subjects{sub}),'Rgpt','TSgpt','tRgpt','tTSgpt','features_gpt');
    save(sprintf('%s/human_reg/localizer_%s_human_regressors.mat',output,subjects{sub}),'Rhuman','TShuman','tRhuman','tTShuman','features_human');

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
