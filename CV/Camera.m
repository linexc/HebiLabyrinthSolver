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
pause (3);
line_frame = snapshot(cam);

% through snapshot to get line position array
[line_frame] = image_process(line_frame, cameraParams);
[sorted_pos] = extract_pos(line_frame);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runLoop = true;
frameCount = 2;
while runLoop && frameCount < 100000
    % Get the next frame.
    videoFrame = snapshot(cam);
    frameCount = frameCount + 1;
    
    % repair the distorted videoframe and get the ball position
    videoFrame = undistortImage(videoFrame,cameraParams);
    [ball_pos, ball_rad] = find_ball(videoFrame);
    
    % Display the annotated video frame using the video player object.
    step(videoPlayer, videoFrame);
    
    % Check whether the video player window has been closed.
    runLoop = isOpen(videoPlayer);
    
    % wait for 0.01s
    pause(0.01);
end
