group = HebiLookup.newGroupFromNames('Team1',{'lang','kurz'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 
load('camera_parameters.mat');
%% safety parameters
safetyParams = group.getSafetyParams();
safetyParams.positionLimitStrategy = [3 3]; % damped spring
safetyParams.positionMinLimit = [-1.4 -1.7];
safetyParams.positionMaxLimit = [1.4 1.7];
group.send('SafetyParams', safetyParams);

% Angle of both Hebi when plate horizontal 
null_pos1 = fbk.position(1);
null_pos2 = fbk.position(2);

% camera initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');