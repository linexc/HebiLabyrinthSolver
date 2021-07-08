%clear; close all;

% Hebi Initialization
group = HebiLookup.newGroupFromNames('Team1',{'kurz','lang'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 

%% set board horizontal
offset = [3.47, 3.85];
cmd.position = [offset(1), offset(2)];
group.send(cmd);
pause(3);

% Camera Initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');
% Capture one frame to get its size.
videoFrame = snapshot(cam);
% videoFrame = videoFrame(80:400,107:532,1:3);
frameSize = size(videoFrame);
% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);


% Desired ball position
board_center_pos = [299.6 250.7];

% preallocation
frameCount = 0;
error_x = 0.0;
error_old_x = 0.0;
error_sum_x = 0.0;
theta_1 = 0.0;
error_y = 0.0;
error_old_y = 0.0;
error_sum_y = 0.0;
theta_2 = 0.0;

% execute loop at fixed frequency
freq = 100; %Hz
r = rateControl(freq);    % 10 Hz
dt = 1/freq;    
while true 
    %% get ball position from camera
    % Get the next frame.
    videoFrame = snapshot(cam);
%     videoFrame = videoFrame(80:400,107:532);
    frameCount = frameCount + 1;
    % Search for circles in current frame
    [ctr,rad] = get_ball_position(videoFrame);
    if size(ctr,1)==1
        % Display circle being tracked.
        videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
            'LineWidth', 2);
        % Display tracked points.
        videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
    end
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
    
    
    %% compute error
    K_p_x = 1/100;
    K_i_x = 0;
    K_d_x = 0;
    error_old_x = error_x;
    error_x = board_center_pos(1) - ctr(1);
    error_sum_x = error_sum_x + K_i_x*dt*error_x;
    theta_1 = K_p_x*error_x + error_sum_x + K_d_x*(error_old_x - error_x)/dt
    
    K_p_y = 1/1000;
    K_i_y = 0;
    K_d_y = 0;
    error_old_y = error_y;
    error_y = -(board_center_pos(2) - ctr(2));
    error_sum_y = error_sum_y + K_i_y*dt*error_y;
    theta_2 = K_p_y*error_y + error_sum_y + K_d_y*(error_old_y - error_y)/dt
    
    %% compute offset for servos
    theta_1 = theta_1 + offset(1);
    theta_2 = theta_2 + offset(2);
            
    %% set actuators
    cmd.position = [theta_1, theta_2];
    group.send(cmd);
    
    waitfor(r);
end
    
