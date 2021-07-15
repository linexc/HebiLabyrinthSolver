% this script is used for HebiController, the rotation direction from script
clear; close all;
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

%% camera initialization
cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');
line_frame = snapshot(cam);
load('camera_parameters.mat');

%% through snapshot to get line position array
line = snapshot(cam);
% lengths for cropping the photo for extracting the trajectory
find_ball_max_lang = 480;
find_ball_min_lang = 45;
find_ball_max_kurz = 370;
find_ball_min_kurz = 65;
line = image_process(line,cameraParams);
line = imcrop(line, [find_ball_min_lang, find_ball_min_kurz, find_ball_max_lang, find_ball_max_kurz]);
% the start position is fixed
start_position =  [228,87];
% sorted_pos is desired position array
[sorted_pos,pos] = extract_pos(line, start_position);
% after 7 sec, place the ball on the plate
pause(7)

%% lengths for cropping the video for reading the ball's position, used in the loop
frame_max_lang = 560;
frame_min_lang = 0;
frame_max_kurz = 460;
frame_min_kurz = 0;

%% point array of the route
route= sorted_pos; 
len= length(route);
interval = 5; %every 5 points will be considered

%% points distance tolerance
threshold= 0.5;
%% the index of current segment
% index for actuall segment
k_next = len-interval;

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

%% execute loop at fixed frequency
freq = 1000; %Hz
r = rateControl(freq);    % 10 Hz
dt = 1/freq;    
% t is the couter for loop
t =0;
%% record the x and y measurement
x_measure=[];
y_measure= [];
ctr_old =0;% for saving coordinate of previous point
%% update the Hebi rotation angle
while (k_next<1)
    
    % actuell target for current segment
    target = route(k_next,:);
  
    %% get ball position from camera
    % Get the next frame.
    videoFrame = snapshot(cam);
    videoFrame = undistortImage(videoFrame,cameraParams);
    videoFrame = videoFrame(1:460,10:550,1:3);
    frameCount = frameCount + 1;
    % Search for circles in current frame and assign ball's coordinate in
    % ctr
    [ctr,~] = find_circular_object(videoFrame);
    
    % update target
    if (norm(ctr-target)<threshold)
        k_old= k_next;
        k_next=k_next-interval;
    end
    
     if t<= 0
        if isempty(ctr) == 1
            ctr = [228,87];
        end
    else
        if isempty(ctr) == 1
            ctr = ctr_old;
            ctr(1) = ctr(1) * 435 / 560;
            ctr(2) = ctr(2) * 305/460;
        end
     end
          
    ctr_old = ctr;
    x_measure = [x_measure, ctr(1)];
    y_measure= [y_measure, ctr(2)];
    
    hold on
    subplot(2,1,1)
    scatter(t,ctr(1),'red'); % plot ball's coodinate along x axis
    hold on
    subplot(2,1,2)
    scatter(t,ctr(2),'green');% plot ball's coordinate along y axis
%     if size(ctr,1)==1
%         % Display circle being tracked.
%         videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
%             'LineWidth', 2);
%         % Display tracked points.
%         videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
%     end
    
    % Display the annotated video frame using the video player object.
    %step(videoPlayer, videoFrame);
    %% compute error
    % lange Seite regler for x axis 
    K_p_x = 0.2;
    K_i_x = 0.8;
    K_d_x = 0.002;
    if (size(ctr,1) ~= 0)
        error_x = target(1) - ctr(1);
    end
    error_sum_x = error_sum_x + error_x;
    theta_lang = K_p_x*error_x + K_i_x*dt*error_sum_x + K_d_x*(error_x - error_old_x)/dt ; 
    error_old_x = error_x;
    
    % kurze Seite regler for y axis
    K_p_y = 0.2;
    K_i_y = 0.9;
    K_d_y = 0.0009;
    if (size(ctr,2) ~= 0)
        error_y = target(2) - ctr(2);
    end
    error_sum_y = error_sum_y + error_y;
    theta_kurz = K_p_y*error_y + K_i_y*dt*error_sum_y + K_d_y*(error_y - error_old_y)/dt ;
    error_old_y = error_y;
        
    %% map errors to thetas
    theta_lang_send = map_error_x(theta_lang);
    theta_kurz_send = map_error_y(theta_kurz);
    
    [theta_lang_send theta_kurz_send]

    %% set actuators
    cmd.position = [theta_kurz_send, theta_lang_send];
    group.send(cmd);
    t = t+1; % after each loop, the counter increase 1
    waitfor(r); % ratecontroll

end

function theta_l = map_error_x(e_x)
    theta_l = 1.7/230*e_x;
end

function theta_k = map_error_y(e_y)
    theta_k = -1.4/175*e_y;
end


