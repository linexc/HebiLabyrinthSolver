clear; close all;


% Hebi Initialization
group = HebiLookup.newGroupFromNames('Team1',{'kurz','lang'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 

%% safety parameters
safetyParams = group.getSafetyParams();
safetyParams.positionLimitStrategy = [3 3]; % damped spring
safetyParams.positionMinLimit = [-1.4 -1.7];
safetyParams.positionMaxLimit = [1.4 1.7];
group.send('SafetyParams', safetyParams);

%% set board horizontal
cmd.position = [0, 0];
group.send(cmd);
pause(1);

% Camera Initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');
% Capture one frame to get its size.
videoFrame = snapshot(cam);
% undistor image
load('camera_parameters.mat')
videoFrame = undistortImage(videoFrame,cameraParams);
videoFrame = videoFrame(1:460,10:550,1:3);
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
theta_kurz = 0.0;
error_old_y = 0.0;
error_y = 0.0;
error_sum_y = 0.0;
theta_lang = 0.0;
record= [];

% execute loop at fixed frequency
freq = 1000; %Hz
r = rateControl(freq);    % 10 Hz
dt = 1/freq;    
while true 
    %% get ball position from camera
    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrame = undistortImage(videoFrame,cameraParams);
    videoFrame = videoFrame(1:460,10:550,1:3);
    frameCount = frameCount + 1;
    % Search for circles in current frame
    [ctr,rad] = get_ball_position(videoFrame);
    record = [record; ctr];
    if size(ctr,1)==1
        % Display circle being tracked.
        videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
            'LineWidth', 2);
        % Display tracked points.
        videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
    end
    hold on
    plot(record(:,1),record(:,2))
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
    
    
    %% compute error
    %% lange Seite regler
    K_p_x = 0.2;%.17;
    K_i_x = 0.8;
    K_d_x = 0.002;
    
    size(ctr);
    if (size(ctr,1) ~= 0)
        error_x = board_center_pos(1) - ctr(1);
    end

    error_sum_x = error_sum_x + error_x;
    theta_lang = K_p_x*error_x + K_i_x*dt*error_sum_x + K_d_x*(error_x - error_old_x)/dt
    error_old_x = error_x;
    
    %% kurze Seite regler
    K_p_y = 0.2;%.17;
    K_i_y = 0.9;
    K_d_y = 0.0009;
    
    size(ctr);
    if (size(ctr,1) ~= 0)
        error_y = board_center_pos(2) - ctr(2);
    end

    error_sum_y = error_sum_y + error_y;
    theta_kurz = K_p_y*error_y + K_i_y*dt*error_sum_y + K_d_y*(error_y - error_old_y)/dt
    error_old_y = error_y;
        
    %% map errors to thetas
    theta_kurz_send = map_error_y(theta_kurz);
    theta_lang_send = map_error_x(theta_lang);
    
    
    %% debug
    error = [error_x, error_y];
    theta = [theta_lang, theta_kurz];
    theta_send = [theta_lang_send, theta_kurz_send];

    
    %% set actuators
    cmd.position = [theta_kurz_send, theta_lang_send];
    group.send(cmd);
    
    waitfor(r); % ratecontroll

    
end
function theta_l = map_error_x(e_x)
%     theta_l = 1.7/220*e_x;
    theta_l = 1.7/230*e_x;
end

function theta_k = map_error_y(e_y)
    theta_k = -1.4/175*e_y;
% theta_k = -1.4/180*e_y;
end