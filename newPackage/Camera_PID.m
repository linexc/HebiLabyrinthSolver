clear
% 1. initialize camera and create video player
% 2. from camera snapshot get the line position array
% 3. get the position of ball in real time

Hebiparameter; 

% Capture one frame to get its size.
videoFrame = snapshot(cam);
frameSize = size(videoFrame);

% Create the video player object.
% videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

%%
line = snapshot(cam);
% through snapshot to get line position array
line = image_process(line,cameraParams);
line = imcrop(line, [40 65 480 370]);

pause(5); %% move the ball at the start point
% the line_frame2 with ball
line_frame_m = snapshot(cam);
line_frame2 = undistortImage(line_frame_m,cameraParams);
line_frame2 = imcrop(line_frame2, [40 65 480 370]);

% find the initial position of marble
start_position = read_start_position(line_frame2);
[sorted_pos,pos] = extract_pos(line, start_position);
%% 
Motionparameter;

runLoop = true;
frameCount = 2;

PIDparameter; 

while runLoop && frameCount < 100000

    % Get the next frame.
    videoFrame = snapshot(cam);
    frameCount = frameCount + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    line_frame = undistortImage(videoFrame,cameraParams);
     videoFrame = imcrop(line_frame, [55 65 480 370]);
     
     % repair the distorted videoframe and get the ball position
%     videoFrame = undistortImage(videoFrame,cameraParams);
    [ball_pos, ball_rad] = find_ball(videoFrame);
    ctr = ball_pos;
    rad = ball_rad;
%         if size(ctr,1)==1
%         
%         % Display circle being tracked. display a circle at the tracked
%         % position, x=ctr(1,1), y=ctr(1,2), radius=rad
%         videoFrame = insertShape(videoFrame, 'Circle', [ctr(1,1),ctr(1,2),rad], ...
%             'LineWidth', 2);
%         
%         % Display tracked points. at the centriod of circle display a cross
%         % with color white. return the frame(videoFrame) with mark.
%         videoFrame = insertMarker(videoFrame, ctr, '+', 'Color', 'white');
%         end
    
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
%     pause(0.1);
%     angle_1 = 0;
%     angle_2 = 0;
%     cmd.position = [angle_1,angle_2];
%     group.send(cmd);
    
    % update target
    if (norm(remainDistance)<threshold)
        k_old= k_next;
        k_next=k_next+interval;
    end
    
    % Display the annotated video frame using the video player object.
%     step(videoPlayer, videoFrame);
    
    % Check whether the video player window has been closed.
    %runLoop = isOpen(videoPlayer);
    
    % wait for 0.01s
    pause(0.01);
end
