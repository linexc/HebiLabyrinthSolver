clear; close all;

% Hebi Initialization
group = HebiLookup.newGroupFromNames('Team1',{'lang','kurz'}); % lang is for x axle, kurz for y
cmd = CommandStruct();
fbk =group.getNextFeedback; 

%% safety parameters
safetyParams = group.getSafetyParams();
safetyParams.positionLimitStrategy = [3 3]; % damped spring
safetyParams.positionMinLimit = [-1.4 -1.7];
safetyParams.positionMaxLimit = [1.4 1.7];
group.send('SafetyParams', safetyParams);

%% set board horizontal
cmd.position = [0,0];
group.send(cmd);
pause(3);

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
% videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);


% Desired ball position
board_center_pos = [250 290];

% preallocation
frameCount = 0;
error_x = 0.0;
error_old_x = 0.0;
error_sum_x = 0.0;
theta_kurz = 0.0;

error_y = 0.0;
error_old_y = 0.0;
error_sum_y = 0.0;
theta_lang = 0.0;

% execute loop at fixed frequency
freq = 100; %Hz
r = rateControl(freq);    % 10 Hz
dt = 1/freq;    
% t is the couter for loop
t =0;
ctr_old =0;

% record the x and y measurement
x_measure=[];
y_measure= [];
while true 
    %% get ball position from camera
    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrame = undistortImage(videoFrame,cameraParams);
    videoFrame = videoFrame(1:460,10:550,1:3);
    frameCount = frameCount + 1;
    % Search for circles in current frame
    [ctr,rad] = find_circular_object(videoFrame);
    % if t = 0, the loop excutes at the first time. if no ball is found,
    % the default location is assigned at the ball. The default position
    % can be modified by user. 
    % if t>0, the loop excutes already several times. the previous location
    % of ball is kept in crt_old, if no ball is found, the ctr will be
    % assigned as the previous frame. 
    if t<= 0
        if isempty(ctr) == 1
            ctr = [100,100];
        end
    else
        if isempty(ctr) == 1
            ctr = ctr_old;
        end
    end
    
    ctr_old = ctr;
    
    x_measure = [x_measure, ctr(1)];
    y_measure= [y_measure, ctr(2)];
    
    hold on
    subplot(2,1,1)
    scatter(t,ctr(1),'red'); % plot x in each frame.
    hold on
    subplot(2,1,2)
    scatter(t,ctr(2),'green');% plot y in each frame. 
    
%     if size(ctr,1)==1
%         % Display circle being tracked.
%         videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
%             'LineWidth', 2);
%         % Display tracked points.
%         videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
%     end
%    % Display the annotated video frame using the video player object.
%    step(videoPlayer, videoFrame);
%   %  Check whether the video player window has been closed.
%    runLoop = isOpen(videoPlayer);
    
    
    %% compute error
    K_p_x =0.110 ; % 0.13
    K_i_x = 0; %0.4
    K_d_x = 0.000
    error_old_x = error_x;

    if (size(ctr,1) ~= 0)
        error_x =  board_center_pos(1)-ctr(1) ;
    end
    error_sum_x = error_sum_x + K_i_x*dt*error_x;
    theta_lang = K_p_x*error_x + error_sum_x + K_d_x*( error_x - error_old_x )/dt;
    
%     if (error_x < 1e-3)
%         error_sum_x = 0.0;
%     end
         
    K_p_y = 0.06; % 0.11
    K_i_y =0; %.2
    K_d_y = 0.000;
    
    error_old_y = error_y;
    if (size(ctr,1) ~= 0)
        error_y =  board_center_pos(2)-ctr(2)   ;
    end
    error_sum_y = error_sum_y + K_i_y*dt*error_y;
    theta_kurz = K_p_y*error_y + error_sum_y + K_d_y*(error_y -error_old_y)/dt;
%     if (error_y < 1e-3)
%         error_sum_y = 0.0;
%     end
    
    %% map errors to thetas
    
%     theta_kurz_send = 0.2;
    theta_lang_send = map_error_x(theta_lang);
    theta_kurz_send = map_error_y(theta_kurz);
    
    [theta_lang_send theta_kurz_send]

%     %% debug
%     error = [error_x, error_y]
%     theta = [theta_lang, theta_kurz];
%     theta_send = [theta_lang_send, theta_kurz_send]
%     K_d = [K_d_x*(error_old_x - error_x)/dt K_d_y*(error_old_y - error_y)/dt]

    
    %% set actuators
    cmd.position = [theta_lang_send, theta_kurz_send];
    group.send(cmd);
    t = t+dt;
    waitfor(r);
    
end

hold off

function theta_l = map_error_x(e_x)
    theta_l =4/520*e_x;
end


function theta_k = map_error_y(e_y)
    theta_k = -3/450*e_y;
end