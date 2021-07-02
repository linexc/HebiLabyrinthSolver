
% %Camear Init
% cam = ipcam('http://192.168.0.8/mjpg/video.mjpg','admin','1234');
% 
% % Capture one frame to get its size.
% videoFrame = snapshot(cam);
% frameSize = size(videoFrame);
% 
% % Create the video player object.
% videoPlayer = vision.VideoPlayer('Position', [100 100 [frameSize(2), frameSize(1)]+30]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this part will receive the photo from camera and process it

function [erode]=image_process(img, cameraParams)
% calibrate the photo
img = undistortImage(img,cameraParams); %if you want to test with your photo, annotate this row
%image process,turn the rgb image to binary image
bw = im2bw(img,0.35);

% erode and dilate the binary image to reduce the noise
se1 = strel('square', 3);
dilate = imdilate(bw, se1);
se2 = strel('square', 3);
erode = imerode(dilate, se2);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this part try to extract the black point from operated image, and because
% of the width of line in the image, there exists more than one points
% which have the same x value but different y values, although the
% differents of y value between points are small, so try to compute the
% mean y value of those points.

function [pos] = extract_pos(erode)
%extract the coordinate of line
pos = [];       % position of points on the line, unsorted
count = 0;      % count how much y position were summed
y_pos_sum = 0;  % the total y position with the same x coordinate
extend_pixel_flag = false;  % a flag to determin if there still exists points far away from the current point,
                            % false == not, 
[x,y] = size(erode);                            
% double 'for' loop to check every point.
for i=1:x
    for j = 1:y
        % if the current position is not on the line, skip
        % on the line: 0 (black)// not on the line: 1 (white)
        if erode(i,j) == 1
            continue;
        end
        % start to count how much point with the same x coordinate on
        % the line. and start to sum the y value in order to get the mean y
        % in the end. set the flag to false assum there not exists points
        % far away from current point
        count = count +1;
        y_pos_sum = y_pos_sum + j;
        extend_pixel_flag = false;
        
        % if there exist at least one black point in next 50 pixels in y
        % dirction set the flag to true, prevent the 'y_pos_sum' and 'count' reset
        for extend_pixel = 1:50
            if j + extend_pixel > y           % prevent out of index 
                break;
            end
            if erode(i,j + extend_pixel) == 0 % exists black point
                extend_pixel_flag = true;
                break;
            end
        end
        % if there is no more black point in next 50 points, compute the
        % mean y value to get a central point.
        if extend_pixel_flag == false
            pos = [pos; [i, y_pos_sum/count]];
            y_pos_sum =0;
            count = 0;
        end
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this part will sort the points in 'pos' array.
% because the array from last part is not sorted, that means matlab always
% extract the point from one side to other side, if the line reach two
% points separately with the same x value but different y value, matlab
% will just put them together. this part will find the sequence of each
% point in the line

% backup of the 'pos' array
pos_copy = pos;

% start point, will through camera determine
% for the picture test3 as well as test3-min,test3-min2
 current_pos = [50, 165];
% for test4
% current_pos = [840,30];

sorted_pos = [];      % the array after sort
current_row = 1;      
start_flag = false;   
smallest_distance = inf;  


for count = 1:length(pos_copy)
    
    % for the first time run the function
    if start_flag == false       
        % try to find the nearest point on the line from start point
        for k = 1:length(pos_copy)  
            %calculate the distance betwenn two points in euclidean
            %distance
            distance = pdist([current_pos;pos_copy(k,:)],'euclidean');
            %save the smallst distance and nearest point
            if distance < smallest_distance
                smallest_distance = distance;
                recorded_pos = pos_copy(k,:);
                recorded_row = k;
            end
        end
        % save the start point and nearest point in a new array 
        sorted_pos = [sorted_pos; current_pos];
        current_pos = recorded_pos;
        current_row = recorded_row;
        start_flag = true;
        sorted_pos = [sorted_pos; current_pos];
        continue;
    end
    % reset the ssmallest_distance and try to sort the line
    smallest_distance = inf;
    smallest_index = 1;
    biggest_index = length(pos_copy);
    % try to find  the next nearest point from current point.
    % e.g. the current point is [50,50] this loop will try to find the
    % nearest point between [50,30] and [50,70] and the nearest point muss
    % be the point next current point, but because of the large numbers of
    % point and the curve line, there will exist some points with the same
    % x coordinate but different y coordinate.
    for i = -20:20
        %prevent the index beyond boundary
        if current_row + i < smallest_index
            j = smallest_index - current_row;
        elseif current_row + i > biggest_index
            j = biggest_index - current_row;
        else
            j = i;
        end
        % find the nearest point and save
        distance = pdist([current_pos;pos_copy(current_row + j,:)],'euclidean');
        if distance < smallest_distance
            smallest_distance = distance;
            recorded_pos = pos_copy(current_row + j,:);
            recorded_row = current_row + j;
        end
    end
    % reset the sorted point to prevent repeatedly read
    pos_copy(recorded_row,:) = [0,0];
    current_pos = recorded_pos;
    current_row = recorded_row;
    % save the points in array and prevent [0,0] points
    if current_pos ~= [0,0]
        sorted_pos = [sorted_pos; current_pos];
    end
end
end

