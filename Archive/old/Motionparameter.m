% find route array
route= sorted_pos; 
len= length(route);
interval = 20; %every 20 points will be considered
%target position of this Labyrinth
x_target = route(len,1);
y_target = route(len,2);
p_target = [x_target,y_target];
% minimal distance for spining the Hebi
threshold= 0.5;
%move_hebi1
move_hebi1=0;  move_hebi2=0;
movingDirection =[move_hebi1,move_hebi2];
% rotation direction 
right=1; left =-1;
up = 1; down = -1;
% rotation angle
alpha1 = 0.4; %lang/ Hebi1
alpha2= 0.4; %kurz / Hebi2
% the target of current segment
k_next= 1+interval;
k_old = 1;