group = HebiLookup.newGroupFromNames('Team1',{'lang','kurz'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 
load('camera_parameters.mat');

% Angle of both Hebi when plate horizontal 
null_pos1 = fbk.position(1);
null_pos2 = fbk.position(2);

% camera initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');