function [ctr,rad] = find_circular_object(frm)
% Finds circular objects in frame

% Subtract red channel from image
diff_im = imsubtract(frm(:,:,1), rgb2gray(frm));
% Use a median filter to filter out noise
diff_im = medfilt2(diff_im, [3 3]);
% Convert the resulting grayscale image into a binary image.
bw = imbinarize(diff_im,0.26); % This boundary value differs depending on environment
% Select only areas bigger than 2000 pxs
bw = bwareaopen(bw,20);
bw = imfill(bw,'holes');
%imshow(bw);
% Find areas
st = regionprops('table',bw, 'Area', 'Centroid','MajorAxisLength','MinorAxisLength');
diameters = mean([st.MajorAxisLength st.MinorAxisLength],2);
rad = diameters/2;
% Ensure that selected area is a circular object
sel = ([st.Area] > 0.9*(pi*rad.^2)) & ([st.Area] < 1.3*(pi*rad.^2));
st = st(sel,:);
rad = rad(sel);
ctr = st.Centroid;

end