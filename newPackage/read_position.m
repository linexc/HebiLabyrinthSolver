% from camera snapshot read the position of ball

function [ball_x, ball_y] = read_position(cameraParams)
    cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');

    % Capture one frame to get ball position.
    videoFrame = snapshot(cam);
    line_frame = undistortImage(videoFrame,cameraParams);
     videoFrame = imcrop(line_frame, [55 65 480 370]);
    [ball_pos, ball_rad] = find_ball(videoFrame);
    ball_x = ball_pos(1,1);
    ball_y = ball_pos(1,2);
end