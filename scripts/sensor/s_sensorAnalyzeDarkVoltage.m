%% s_sensorAnalyzeDarkVoltage
%
%    Script illustrating an experimental approach to measuring the sensor
%    dark voltage.
%
% To measure the dark voltage, take a picture of a zero intensity scene
% (cap on) at different exposure durations.  The average dark voltage
% (mv/sec), is derived from the slope (pooling all the pixels) of the
% voltage vs. time curve.
%
% In addition to the dark voltage estimate (V/s), we calculate the mean
% voltage at each exposure duration.
%
% The curve plot(expTimes,meanVolts) shows the measured data. 
%   
% Copyright ImagEval Consultants, LLC, 2005.

%% Create a sensor
sensor = sensorCreate;

% Set a range of exposure times
expTimes = logspace(0,1.5,10); 
% For this case, we have a little glitch at the shortest exposure (1 sec),
% which has a significant component of noise from other sources.  The other
% terms, however, are dominated by the dark voltage.

% How many color filters?
nFilters = sensorGet(sensor,'nfilters');

%% Make a black scene 
scene = sceneCreate('uniformee');
darkScene = sceneAdjustLuminance(scene,1e-8);
darkScene = sceneSet(darkScene,'fov',sensorGet(sensor,'fov')*1.5);

%% Compute the optical image
oi = vcGetObject('opticalimage');
if isempty(oi), oi = oiCreate('default',[],[],0); end
darkOI = oiCompute(darkScene,oi);

% For dark voltage, we use long exposure times.  This gives the voltage
% time  to  become significantly larger than the other types of noise. 
% In this simulation case, we read the voltages at the sensor.  In many
% practical cases, however, you do not have access to the raw camera
% voltages.  Typically, you might have access only to the digital values.
% If that is all you have, it will be necessary to find ways to estimate
% the volts from the digital values.
clear volts
nRepeats = length(expTimes);
wBar = waitbar(0,'Acquiring images');

nSamp = prod(sensorGet(sensor,'size'))/2;
volts = zeros(nSamp,nRepeats);
for ii=1:nRepeats
    waitbar(ii/nRepeats,wBar);
    sensor = sensorSet(sensor,'exposureTime',expTimes(ii));
    sensor = sensorCompute(sensor,darkOI,0);
    if nFilters == 3
        volts(:,ii) = sensorGet(sensor,'volts',2);
    elseif nFilters == 1
        tmp = sensorGet(sensor,'volts');
        volts(:,ii) = tmp(:);
    end
end
close(wBar);

%% Compute the mean voltage across all the pixels at each exposure duration.
% You can select the shortest exposure duration used in the fitting by
% adjusting the parameter shortestTime. Hint: Try using 4.
shortestTime = 1; list = shortestTime:length(expTimes);
meanVolts = mean(volts,1);
[darkVoltageEstimate,o] = ieFitLine(expTimes(list),meanVolts(list));

%% Plot the data and analyze the values.
vcNewGraphWin;
title('Measured voltages')
plot(expTimes(list),meanVolts(list));
xlabel('Exposure time (s)'); ylabel('Voltage (v)'); 
grid on

pixel = sensorGet(sensor,'pixel');
trueDV = pixelGet(pixel,'darkvoltage');
fprintf('---------------------------\n')
fprintf('True dark voltage: %.5f\n',trueDV);
fprintf('Estimated:  %.5f\n',darkVoltageEstimate);
fprintf('Percent error: %.2f\n', 100*(trueDV- darkVoltageEstimate )/trueDV )
fprintf('---------------------------\n')

%% End
