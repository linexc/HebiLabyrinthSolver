
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this part will receive the photo from camera and process it

function [erode]=image_process(img, cameraParams)
% calibrate the photo
img = undistortImage(img,cameraParams); %if you want to test with your photo, annotate this row
%image process,turn the rgb image to binary image
bw = imbinarize(img,0.3);
% erode = bw;
% erode and dilate the binary image to reduce the noise
se1 = strel('square', 3);
dilate = imdilate(bw, se1);
se2 = strel('square', 3);
erode = imerode(dilate, se2);

end



