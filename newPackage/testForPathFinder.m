% test for path finder 
line = imread('image.jpg');
%grabit(line)

bw = imbinarize(line,0.3);
% erode = bw;
% erode and dilate the binary image to reduce the noise
se1 = strel('square', 3);
dilate = imdilate(bw, se1);
se2 = strel('square', 3);
line = imerode(dilate, se2);

start_position = [0,1600];

[x,y,~] = size(line);  

dark_point = [];
for i=1:x
    for j = 1:y
        if erode(i,j) == 1
            continue;
        end
        dark_point = [dark_point; line(x,y)];
    end
end

% from the start point, find the closest point to it.
% find the index of startpoint
k = 1;
sorted= start_position;
line(1,:)= [inf,inf];

t = start_position; 
count = 0;
while (count<len(line(:,1)))
    dist = line -t; 
    norm_distance = sqrt(dist(:,1).^2+ dist(:,2).^2); 
    [~,I] = min(norm_distance);
    sorted = [sorted; line(I)];
    t = line(I);
    line(I)= [inf,inf];
    count = count+1;
end

