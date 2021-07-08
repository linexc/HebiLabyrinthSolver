
% this script is used for HebiController, the rotation direction from script
% moveDirectionEstimation. 

group = HebiLookup.newGroupFromNames('Team1',{'lang','kurz'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 
load('camera_parameters.mat');

% camera initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');
line_frame = snapshot(cam);
% through snapshot to get line position array
[line_frame] = image_process(line_frame, cameraParams);
[sorted_pos] = extract_pos(line_frame);
%point array of the route
route= sorted_pos; 
len= length(route);
interval = 10; %every 10 points will be considered
%target position of this Labyrinth
x_target = route(len,1);
y_target = route(len,2);
p_target = [x_target,y_target];
% minimal distance for spining the Hebi
threshold= 0.5;
%move_hebi1 direction
move_hebi1=0;  move_hebi2=0;
movingDirection =[move_hebi1,move_hebi2];

% rotation direction 
right=1; left =-1;
up = 1; down = -1;
% rotation angle
alpha1 = 2; %2 rad
alpha2= 2;

% the target of current segment
k_next= 1+interval;
k_old = 1;

% update the Hebi rotation angle
while (k_next<len+1)
    
    x_old = route(k_old,1);
    y_old = route(k_old,2);
    x_next = route(k_next,1);
    y_next = route(k_next,2);
    % middle point of the segment 
    x_middle = (x_old + x_next)/2;
    y_middle = (y_old + y_next)/2;
    p_middle = [x_middle, y_middle];
    
    moveDirectionEstimation;
    angle_1 = move_hebi1 * alpha1;
    angle_2 = move_hebi2 * alpha2;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % after 0.1 sec, the Hebi should spin to make the plate horizontal, in order
    % to make sure the marble with a low speed while closing to the target
    pause(0.1);
    angle_1 = 0;
    angle_2 = 0;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
%     MarbleCorrection;
    angle_1 = move_hebi1 * alpha1;
    angle_2 = move_hebi2 * alpha2;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % after 0.1 sec, the Hebi should spin to make the plate horizontal, in order
    % to make sure the marble with a low speed while closing to the target
    pause(0.1);
    angle_1 = 0;
    angle_2 = 0;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % update target
    if (norm(p_correct-p_next)<threshold)
        k_old= k_next;
        k_next=k_next+interval;
    end
end




