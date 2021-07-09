% 1. initialize camera and create video player
% 2. from camera snapshot get the line position array
% 3. get the position of ball in real time

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
find_ball_max_lang = 480;
find_ball_min_lang = 45;
find_ball_max_kurz = 370;
find_ball_min_kurz = 65;
% through snapshot to get line position array
[line_frame] = image_process(line_frame, cameraParams);
line_frame = imcrop(line_frame, [find_ball_min_lang, find_ball_min_kurz, find_ball_max_lang, find_ball_max_kurz]);% 50, 65, 480, 370
[sorted_pos,pos] = extract_pos(line_frame);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runLoop = true;
frameCount = 2;
frame_max_lang = 560;
frame_min_lang = 0;
frame_max_kurz = 460;
frame_min_kurz = 0;
while runLoop && frameCount < 100000
    % Get the next frame.
    videoFrame = snapshot(cam);
    frameCount = frameCount + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    videoFrame = undistortImage(videoFrame,cameraParams);
    videoFrame = imcrop(videoFrame, [frame_min_lang frame_min_kurz frame_max_lang frame_max_kurz]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
    
    % wait for 0.01s
    pause(0.01);
end
