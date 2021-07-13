clear
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

start_position = [1671,61];

[x,y,~] = size(line);  

dark_point = [];
for i=1:100:x
    for j = 1:100:y
        if line(i,j) == 1
            continue;
        end
        dark_point = [dark_point; [i,j]];
    end
end

% from the start point, find the closest point to it.
sorted= start_position;
dark_point(1,:)= [inf,inf];

t = start_position; 
count = 0;
while (count<length(dark_point(:,1)))
    dist = dark_point -t; 
    norm_distance = sqrt(dist(:,1).^2+ dist(:,2).^2); 
    [~,I] = min(norm_distance);
    sorted = [sorted; dark_point(I,:)];
    t = dark_point(I,:);
    dark_point(I,:)= [inf,inf];
    count = count+1;
end

