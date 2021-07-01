% this is used for HebiController, the rotation direction from script
% moveDirectionEstimation. 

group = HebiLookup.newGroupFromNames('Team',{'Hebi1','Hebi2'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 
% rotation angle of Hebi is 10rad
angle = 10;
angle_1 = move_hebi1 * 10;
angle_2 = move_hebi2 * 10;
cmd.position = [angle_1,angle_2];
group.send(cmd);

% after 1 sec, the Hebi should spin to make the plate horizontal, in order
% to make sure the marble with a low speed while closing to the target
pause(1);
angle_1 = 0;
angle_2 = 0;
cmd.position = [angle_1,angle_2];
group.send(cmd);