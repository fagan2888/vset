% Create six channel sensor for some test analyses.
%
% This is a fabricated sensor.
%

wave = 400:1:700;

% Read cmy and then rgb data examples
cymFile = fullfile(isetRootPath,'data','sensor','cym');
[cmyData,cmyFilterNames] = ieReadColorFilter(wave,cymFile);

rgbFile = fullfile(isetRootPath,'data','sensor','rgb');
[rgbData,rgbFilterNames] = ieReadColorFilter(wave,rgbFile);

% Merge the data sets
data = [rgbData, 0.35*cmyData];
filterNames = cellMerge(rgbFilterNames,cmyFilterNames);

% Fastest way to save the color filter is to dummy up a sensor, add the
% filters and filternames, and have ieSaveColorFilter pull everything out
% for us.
sensor = sensorCreate;
sensor = sensorSet(sensor,'wave',wave);
sensor = sensorSet(sensor,'colorfilters',data);
sensor = sensorSet(sensor,'filterNames',filterNames);
fName = fullfile(isetRootPath,'data','sensor','colorfilters','sixChannel.mat');
ieSaveColorFilter(sensor,fName);

