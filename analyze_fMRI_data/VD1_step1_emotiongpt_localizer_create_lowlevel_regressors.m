%% EmotionGPT, localizer: Calculate low-level features and create low level regressors
%
% Procedure
%           1.  Auditory features are calculated in 40ms time-windows (video frame rate is 25/s => 40ms) and
%               visual features for each frame or each consecutive frame pairs. 
%
%           2.  Low-level features from film clips are catenated for each
%               subject separately and adjusted for the clip duration based on Presentation log files
%
%           3.  Features are correlated and we take PCA. Based on covariance between features and components
%               we choose 8 principal components (explain ~93 % of
%               variance and have a clear interpretation)
%
%           4.  PCs are convolved with canonical HRF and interpolated to
%               fMRI timings to build regressors for modelling
%
% Severi Santavirta 1.2.2026

%% 1. Estimate low-level features
p_clips = 'path/videos/video_clips_presentation_order';
f = dir(p_clips);

data_clip = cell(size(f,1)-2,7);
for I = 3:size(f,1)
    
    v = sprintf('%s/%s',p_clips,f(I).name);
    vidIn = VideoReader(v);
    
    data_visual = zeros(vidIn.NumFrames,6);
    cats_visual = {'luminance','luminance_d','opticflow','spatialenergy_1','spatialenergy_10','differentialenergy'};
    
    % Luminance
    fprintf('Clip: %i/%i, Estimating luminance\n',I-2,size(f,1)-2);
    data_visual(:,1) = video_luminance(v);
    data_visual(2:end,2) = diff(data_visual(:,1));
    
    % Optic flow
    fprintf('Clip: %i/%i, Estimating optic flow\n',I-2,size(f,1)-2);
    data_visual(:,3) = video_opticFlow(v);
    
    % Spatial energy
    fprintf('Clip: %i/%i, Estimating spatial energy\n',I-2,size(f,1)-2);
    data_visual(:,4) = video_spatialEnergy(v,0,1); % Mask radius 1 % of frame height (check how the filtered images look within the function with commented plotting lines)
    data_visual(:,5) = video_spatialEnergy(v,0,10); % Mask radius 10 % of frame height (check how the filtered images look within the function with commented plotting lines)
    
    % Differential energy
    fprintf('Clip: %i/%i, Estimating differential energy\n',I-2,size(f,1)-2);
    data_visual(:,6) = video_differentialEnergy(v);
    
    % Auditory features
    fprintf('Clip: %i/%i, Estimating auditory features\n',I-2,size(f,1)-2);
    [data_auditory,cats_auditory,audio_dur] = video_lowlevelAudio(v,0.04,0.040); % Calculate auditory features in 40ms windows and the next windows start at the point where the previous ends.
    
    data_clip{I-2,1} = f(I).name;
    data_clip{I-2,2} = data_visual;
    data_clip{I-2,3} = cats_visual;
    data_clip{I-2,4} = vidIn.NumFrames/vidIn.FrameRate;
    data_clip{I-2,5} = data_auditory;
    data_clip{I-2,6} = cats_auditory;
    data_clip{I-2,7} = audio_dur;
    
end

save('path/lowlevel_features/data_clip.mat','data_clip');

%% 2. Catenate clip data for each subject

% The actual frame rate of the presented clips vary between subject so we
% need to correct the timings based on Presentation log files for each
% subject separately

load('path/lowlevel_features/data_clip.mat');
subjects = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'018';'019';'020';'021';'022';'023';'024';'025';'026';'027';'028';'029';'030';'031';'032';'033';'034';'035';'036';'037';'038';'039';'040';'041';'042';'043';'044';'045';'046';'047';'048';'049';'050';'051';'052';'053';'054';'055';'056';'057';'058';'059';'060';'061';'062';'063';'064';'065';'066';'067';'068';'069';'070';'071';'072';'073';'074';'075';'076';'077';'078';'079';'080';'081';'082';'083';'084';'085';'086';'087';'088';'089';'090';'091';'092';'093';'094';'095';'096';'097';'098';'099';'100';'101';'102';'103';'104'};
logfiles = strcat('path/presentation_log_files/megafMRI_',subjects,'-megalocalizer.log');

y_sub = []; % Collect features for mean features calculations 
x_sub = [];

for I = 1:size(logfiles,1) % subjects
    
    x_visual = [];
    y_visual = [];
    x_auditory = [];
    y_auditory = [];
    
    [video_presentation_order,video_onsets,video_durs] = megafmri_localizer_read_log_final(logfiles{I});
    
    tw_audit = zeros(size(data_clip,1),1);
    for J = 1:size(data_clip,1) % clips
        
        data_visual = data_clip{J,2};
        data_auditory = data_clip{J,5};
        
        t0 = video_onsets(J); % clip start time
        t1 = t0+video_durs(J); % clip end time
        
        tw_visual = video_durs(J)/size(data_visual,1); % True time-window for visual features
        tw_auditory = video_durs(J)/size(data_auditory,1); % True time-window for auditory features
        tw_audit(J) = tw_auditory;
        
        x_v = (t0+tw_visual:tw_visual:t1)'; % True time-points for visual features
        x_a = (t0+tw_auditory:tw_auditory:t1)'; % True time-points for auditory features
        
        x_visual = vertcat(x_visual,x_v);
        x_auditory = vertcat(x_auditory,x_a);
        y_visual = vertcat(y_visual,data_visual);
        y_auditory = vertcat(y_auditory,data_auditory);
        
        
    end
    
    % Visual features have a couple of more data points, we interpolate it to the same timepoints with the auditory signal 
    y_visual = interp1(x_visual,y_visual,x_auditory,'nearest');
    
    y = horzcat(y_visual,y_auditory);
    x = x_auditory;
    tw = mean(tw_audit);
    cats = horzcat(data_clip{1,3},data_clip{1,6});
    fname = strcat('path/lowlevel_features/subjects/lowlevel_',subjects{I},'.mat');
    save(fname,'y','x','cats','tw');
    
    y_sub(:,:,I) = y;
    x_sub(:,I) = x;
    
end

y_mu = mean(y_sub,3); % Average feature time-series
x_mu = mean(x_sub,2);
save('path/lowlevel_features/lowlevel_features.mat','y_mu','x_mu','cats');
y_mu = array2table(y_mu);
y_mu.Properties.VariableNames = cats;
writetable(y_mu,'path/lowlevel_features/lowlevel_features.csv');


%% 3. PCA of low level features

load('path/lowlevel_features/lowlevel_features.mat');

y_std = zscore(y_mu); % Features are in very different scales, we need to standardize them first.
[coeff,score,latent,tsquared,explained,mu] = pca(y_std);

cats_lowlevel = horzcat(cats,'pca1','pca2','pca3','pca4','pca5','pca6','pca7','pca8','pca9','pca10','pca11','pca12','pca13','pca14');
y_lowlevel = horzcat(y_std,score);
save('path/lowlevel_features/pca_lowlevel_features.mat','x_mu','y_lowlevel','cats_lowlevel');
y_lowlevel = array2table(y_lowlevel);
y_lowlevel.Properties.VariableNames = cats_lowlevel;
writetable(y_lowlevel,'path/lowlevel_features/pca_lowlevel_features.csv'); % For correlation analysis in R


%% 4. Create low level regressors

load('path/lowlevel_features/pca_lowlevel_features.mat');
out = 'path/lowlevel_features/pca_regressors';

subjects = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'018';'019';'020';'021';'022';'023';'024';'025';'026';'027';'028';'029';'030';'031';'032';'033';'034';'035';'036';'037';'038';'039';'040';'041';'042';'043';'044';'045';'046';'047';'048';'049';'050';'051';'052';'053';'054';'055';'056';'057';'058';'059';'060';'061';'062';'063';'064';'065';'066';'067';'068';'069';'070';'071';'072';'073';'074';'075';'076';'077';'078';'079';'080';'081';'082';'083';'084';'085';'086';'087';'088';'089';'090';'091';'092';'093';'094';'095';'096';'097';'098';'099';'100';'101';'102';'103';'104'};
files = strcat('path/lowlevel_features/subjects/lowlevel_',subjects,'.mat');

for I = 1:size(files)
    load(files{I});
    x_start = (tw:tw:x(1))'; % timepoints before stimulus starts
    x_end = (x(end)+tw:tw:467*2.6)'; % timepoints after stimulus
    y_start = zeros(size(x_start,1),28);
    y_end = zeros(size(x_end,1),28);
    
    x = vertcat(x_start,x,x_end);
    y = vertcat(y_start,y_lowlevel,y_end);
    
    tw2 = (2.6*467)/size(x,1);
    
    % Convolve with canonical hrf
    r = zeros(size(y));
    for J = 1:size(y,2)
       c = conv(y(:,J),bramila_hrf(tw2,1,6,16));
       r(:,J) = c(1:length(x));
    end
    
    % Interpolate linearly to fMRI timepoints
    x_fmri = (1.3:2.6:467*2.6)';
    r = interp1(x,r,x_fmri,'linear');
    
    save(sprintf('%s/megafmri-localizer-sub-%s_lowlevel_regressors.mat',out,subjects{I}),'r','cats_lowlevel');
end

function hrfOut = bramila_hrf(par1,par2,par3,par4)
%Produces a canonical two Gamma hemodynamic response function (HRF)
%
%Takes four parameters:
%par1 time step length in seconds
%par2 weight for the second Gamma (e.g. 0 for just one gamma funtion)
%par3 shape parameter for first Gamma probability density function (pdf)
%par4 shape parameter for second Gamma pdf
%
%defaults:
%par1 = 2
%par2 = 1
%par3 = 6
%par4 = 16
%
%The scale parameter for both Gamma pdfs is 1/par3
%length of the output HRF is 30 seconds

if nargin<1 || isempty(par1)
    par1=2;
end;
if nargin<2 || isempty(par2)
    par2=1;
end;
if nargin<3 || isempty(par3)
    par3=6;
end;
if nargin<4 || isempty(par4)
    par4=16;
end;


timepoints=0:par1:30-par1;

hrfOut=gampdf(timepoints,par3,1)-par2*gampdf(timepoints,par4,1)/par3;

end
function [video_presentation_order,video_onsets,video_durs] = megafmri_localizer_read_log_final(logfile)

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
function L = video_luminance(videofile)
% Function calculates luminance of a video input.
% Luminance (L) is returned for every video frame.  Fr is the video frame
% rate
%
% "Luminance" is approximated as rgb2hsv transformation where
% Luminance ~ V = max{R,G,B}
%
% Severi Santavirta

%% Video

try
    obj = VideoReader(videofile);
catch ME
    error('Problems with reading the file %s.',videofile);
end

Fr = obj.FrameRate;
num_frames = ceil(obj.Duration*Fr);
L = nan(num_frames,1);

i = 0;
while(hasFrame(obj))
    i = i + 1;
    frame = readFrame(obj);
    hsv_frame = rgb2hsv(frame);
    v = squeeze(hsv_frame(:,:,3));
    L(i) = mean(v(:));
end

L(isnan(L)) = [];
end
function opticFlow = video_opticFlow(videofile)
% Estimate optic flow based on LK algorithm and basic options. Optic flow is a single
% measure of absolute movement between adjacent frames.
%
% Severi Santavirta

% Methods
o = opticalFlowLK;

vidIn = VideoReader(videofile);

opticFlow = zeros(vidIn.NumFrames,1);

t = 0;

% Plot for checks
%h = figure;
%movegui(h);
%hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
%hPlot = axes(hViewPanel);

while hasFrame(vidIn)
    t=t+1;
    flow = estimateFlow(o,im2gray(readFrame(vidIn))); % Function calculates optic flow by comparing current frame to the previous (previous frame is assumed black for the first frame)
    opticFlow(t,1) = sum(sqrt(flow.Vx.^2 + flow.Vy.^2),'all'); % Sum of all detected movement 

    %imshow(vidIn.readFrame)
    %hold on
    %plot(flow,'DecimationFactor',[5 5],'ScaleFactor',60,'Parent',hPlot);
    %hold off 
    
    %pause(0.1)
end
end
function nrg = video_spatialEnergy(videofile,lowpass,radius)
% Function calculated the Fourier transform for each frame of the video. A
% mask is used to filter unwanted frequecie Spatial energy is then calculated as the mean of the
% Fourier filtered images.
%
% INPUT
%           videofile           = myFile.mp4
%           lowpass             = 1 (filter out high frequencies), 0 (filter out low frequencies)
%           radius              = radius of the circular frequency mask as
%                                 percentage of the image height (radius/100*image.Height is the radius of the mask)
%
% OUTPUT
%           nrg                 = spatial energy
%
% Severi Santavirta & Juha Lahnakoski, 27th of May, 2022


v = VideoReader(videofile);
[Y,X]=ndgrid(1:v.Height,1:v.Width);

rad = radius/100*v.Height;
if(lowpass)
    % High-pass filter (used as low-pass filter)
    fftmask=max((Y.^2+X.^2<rad^2),max((flipud(Y).^2+X.^2<rad^2),max((Y.^2+fliplr(X).^2<rad^2),(flipud(Y).^2+fliplr(X).^2<rad^2))));
else
    % Low-pass filter
    tmp = max((Y.^2+X.^2<rad^2),max((flipud(Y).^2+X.^2<rad^2),max((Y.^2+fliplr(X).^2<rad^2),(flipud(Y).^2+fliplr(X).^2<rad^2))));
    fftmask = ones(v.Height,v.Width);
    fftmask(tmp) = 0;
end

nrg = zeros(v.NumFrames,1); % Spatial energy
%images = zeros(v.Height,v.Width,3,v.NumFrames); % Save original images as double (uint8(images(:,:,:,fr)) for plotting);
%transform = zeros(v.Height,v.Width,v.NumFrames); % Save Fourier transforms
%masked_transform = zeros(v.Height,v.Width,v.NumFrames); % Masked fourier transform
%filtered = zeros(v.Height,v.Width,v.NumFrames); % Save Fourier filtered images
fr=0;
while hasFrame(v)
    fr=fr+1;
    %images(:,:,:,fr) = v.readFrame;
    F = fft2(nanmean(v.readFrame,3)); % Fourier transform
    
    filtered = abs(ifft2(fftmask.*F)); % Filtered image 
    nrg(fr) = nanmean(nanmean(filtered)); % Spatial energy
    
    %F = fftshift(F); % Center FFT
    %F = abs(F); % Get the magnitude
    %F = log(F+1); % Use log, for perceptual scaling, and +1 since log(0) is undefined
    %transform(:,:,fr) = mat2gray(F); % Use mat2gray to scale the image between 0 and 1
    %masked_transform(:,:,fr) = fftmask.*F;
    
    %subplot(1,3,1);
    %imagesc(uint8(images(:,:,:,fr)));
    %title('Image');
    %subplot(1,3,2);
    %imagesc(uint8(filtered(:,:,fr)));
    %title('Filtered');
    %subplot(1,3,3);
    %imagesc(masked_transform(:,:,fr));
    %title('Masked Fourier transform');

end

end
function dnrg = video_differentialEnergy(videofile)
% Function calculates the difference between voxels between adjacent frames
% Estimate of "movement/change" of image
%
% Severi Santavirta & Juha Lahnakoski

vidIn = VideoReader(videofile);

dnrg = zeros(vidIn.NumFrames,1);
imLast = zeros(vidIn.Height,vidIn.Width,3);
t=0;
while hasFrame(vidIn)
    t=t+1;
    im = double(vidIn.readFrame);
    dnrg(t)=sqrt(nanmean((im(:)-imLast(:)).^2));
    imLast = im;
end

end
function [data,cats,dur_tw] = video_lowlevelAudio(videofile,time_window,hop)
% This function utilizes MIRtoolbox to extract some predefined low-level
% features mainly important for fMRI/eye-tracking analysis
% INPUT
%       videofile   = myVideo.mp4
%       time_window = temporal length of each time window (in seconds)
%       hop         = how far from the start of previous time-window to start the next
%                     time-window (in seconds). If you like to have
%                     interleaved time-windows then hop < time_window
% OUTPUT
%       data        = extracted auditory features
%       cats        = column names in data matrix
%       dur_tw      = Duration of the audio stream
%
% Severi Santavirta, last modified 27th May 2022


audioIn = mirframe(videofile,time_window,'s',hop,'s'); % Calculate everything in time-windows, windows are not interleaved
n_tw = size(mirgetdata(audioIn),2);
dur_tw = n_tw*time_window;


cats = {'rms','zerocrossing','centroid','spread','entropy','rollof85','roughness'};
data = zeros(n_tw,7);

data(:,1) = mirgetdata(mirrms(audioIn)); % rms: RMS / "intensity"

data(:,2) = mirgetdata(mirzerocross(audioIn)); % Zero crossing: Zero crossings of the audio wawe / "noisiness"

mu = mirgetdata(mircentroid(audioIn)); % Centroid: Mean of the frequency spectrum / "average frequency"  
mu(isnan(mu)) = nanmean(mu); % if silence, has NaN value, substitute with the average frequency over the whole video
data(:,3) = mu;  

sd = mirgetdata(mirspread(audioIn)); % Spread: SD of the frequency spectrum / "spread of frequencies"
sd(isnan(sd)) = nanmean(sd); % if silence, has NaN value, substitute with the average value in the sequence;
data(:,4) = sd;  

ent = mirgetdata(mirentropy(audioIn)); % Entropy of the frequency spectrum / "dominant peaks (low entropy) vs. heterogenous spectra (high entropy)"
ent(isnan(ent)) = nanmean(ent); % if silence, has NaN value, substitute with the average value in the sequence;
data(:,5) = ent;  

high_nrg = mirgetdata(mirrolloff(audioIn)); % Rolloff: "85% of energy is under this frequency"
high_nrg(isnan(high_nrg)) = nanmean(high_nrg); % if silence, has NaN value, substitute with the average value in the sequence;
data(:,6) = high_nrg;  

data(:,7) = mirgetdata(mirroughness(audioIn)); % Roughness: Sensory dissonance / "Roughness of the sound"

end