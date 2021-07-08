% 1. initialize camera and create video player
% 2. from camera snapshot get the line position array
% 3. get the position of ball in real time
group = HebiLookup.newGroupFromNames('Team',{'Hebi1','Hebi2'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 
load('camera_parameters.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% camera initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pause 3 seconds and then get a snapshot of camera
% pause (3);
line_frame = snapshot(cam);

% through snapshot to get line position array
[line_frame] = image_process(line_frame, cameraParams);
line_frame = imcrop(line_frame, [55 65 480 370]);
[sorted_pos] = extract_pos(line_frame);
route= sorted_pos; 

len= length(route);
interval = 10; %every 10 points will be considered
%target position of this Labyrinth
x_target = route(len,1);
y_target = route(len,2);
p_target = [x_target,y_target];
% minimal distance for spining the Hebi
threshold= 0.1;
%move_hebi1
movingDirection =[move_hebi1,move_hebi2];
move_hebi1=0;  move_hebi2=0;
% rotation direction 
right=1; left =-1;
up = 1; down = -1;
% rotation angle
alpha1 = 2; %kurz
alpha2= 2; % lang

% the target of current segment
k_next= 1+interval;
k_old = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runLoop = true;
frameCount = 2;
while runLoop && frameCount < 100000
    % Get the next frame.
    videoFrame = snapshot(cam);
    frameCount = frameCount + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    line_frame = undistortImage(videoFrame,cameraParams);
     videoFrame = imcrop(line_frame, [55 65 480 370]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % repair the distorted videoframe and get the ball position
%     videoFrame = undistortImage(videoFrame,cameraParams);
    [ball_pos, ball_rad] = find_ball(videoFrame);
    ctr = ball_pos;
    rad = ball_rad;
        if size(ctr,1)==1
        
        % Display circle being tracked. display a circle at the tracked
        % position, x=ctr(1,1), y=ctr(1,2), radius=rad
        videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
            'LineWidth', 2);
        
        % Display tracked points. at the centriod of circle display a cross
        % with color white. return the frame(videoFrame) with mark.
        videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
        end
    
    x_old = route(k_old,1);
    y_old = route(k_old,2);
    % middle point of the segment 
    x_middle = (x_old + x_next)/2;
    y_m1ddle = (y_old + y_next)/2;
    p_middle = [x_middle, y_middle];
    
    moveDirectionEstimation;
    angle_1 = move_hebi1 * alpha1;
    angle_2 = move_hebi2 * alpha2;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % after 1 sec, the Hebi should spin to make the plate horizontal, in order
    % to make sure the marble with a low speed while closing to the target
    pause(0.1);
    angle_1 = 0;
    angle_2 = 0;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    MarbleCorrection;
    angle_1 = move_hebi1 * alpha1;
    angle_2 = move_hebi2 * alpha2;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % after 1 sec, the Hebi should spin to make the plate horizontal, in order
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
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
    
    % wait for 0.01s
    pause(0.01);
end
