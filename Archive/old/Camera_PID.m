%clear
% 1. initialize camera and create video player
% 2. from camera snapshot get the line position array
% 3. get the position of ball in real time
Hebiparameter; 
% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);
% Create the video player object.
videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

%%
line = snapshot(cam);
find_ball_max_lang = 480;
find_ball_min_lang = 45;
find_ball_max_kurz = 370;
find_ball_min_kurz = 65;
frame_max_lang = 560;
frame_min_lang = 0;
frame_max_kurz = 460;
frame_min_kurz = 0;
% through snapshot to get line position array
line = image_process(line,cameraParams);
line = imcrop(line, [find_ball_min_lang, find_ball_min_kurz, find_ball_max_lang, find_ball_max_kurz]);
start_position =  [50,65];
[sorted_pos,pos] = extract_pos(line, start_position);

% pause(5); %% move the ball at the start point
% the line_frame2 with ball
% find the initial position of marble
% start_position = read_start_position(line_frame2);

%% 
Motionparameter;

runLoop = true;
frameCount = 2;

PIDparameter; 

ball_pos_record = [];
target_pos_record= [];

while runLoop && frameCount < 100000

       hold on;
       
    % Get the next frame.
    videoFrame = snapshot(cam);
    frameCount = frameCount + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    videoFrame = undistortImage(videoFrame,cameraParams);
     videoFrame = imcrop(videoFrame, [frame_min_lang frame_min_kurz frame_max_lang frame_max_kurz]);
     % repair the distorted videoframe and get the ball position
%     videoFrame = undistortImage(videoFrame,cameraParams);
    [ball_pos, ball_rad] = find_ball(videoFrame);
    ctr = ball_pos;
    rad = ball_rad;
    ball_x = ball_pos(1,1) * (find_ball_max_lang - find_ball_min_lang) / (frame_max_lang - frame_min_lang);
    ball_y = ball_pos(1,2) * (find_ball_max_kurz - find_ball_min_kurz) / (frame_max_kurz - frame_min_kurz);
    ball_pos = [ball_x, ball_y];
    
        if size(ctr,1)==1
        
        % Display circle being tracked. display a circle at the tracked
        % position, x=ctr(1,1), y=ctr(1,2), radius=rad
        videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
            'LineWidth', 2);
        
        % Display tracked points. at the centriod of circle display a cross
        % with color white. return the frame(videoFrame) with mark.
        videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
        end
    
    Pointcalculator; 
    
    moveDirectionEstimation_PID;
    angle1 = y1 * alpha1 + null_pos1;
    angle2 = y2 * alpha2 + null_pos2;
    cmd.position = [angle1,angle2];
    group.send(cmd);
    
    % after 1 sec, the Hebi should spin to make the plate horizontal, in order
%     % to make sure the marble with a low speed while closing to the target
%      pause(1);
%      angle_1 =null_pos1;
%      angle_2 =null_pos2;
%      cmd.position = [angle_1,angle_2];
%     group.send(cmd);
    
%     MarbleCorrection;
%     angle_1 = move_hebi1 * alpha1;
%     angle_2 = move_hebi2 * alpha2;
%     cmd.position = [angle_1,angle_2];
%     group.send(cmd);
%     
%     % after 1 sec, the Hebi should spin to make the plate horizontal, in order
%     % to make sure the marble with a low speed while closing to the target
    pause(2);
    angle_1 = 0;
    angle_2 = 0;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % update target
    if (norm(remainDistance)<threshold)
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
