% this script is used for HebiController, the rotation direction from script
% moveDirectionEstimation. 

group = HebiLookup.newGroupFromNames('Team',{'Hebi1','Hebi2'});
cmd = CommandStruct();
fbk =group.getNextFeedback; 

%point array of the route
route= []; % n*2 
len= length(route);
interval = 10; %every 10 points will be considered
%target position of this Labyrinth
x_target = route(len,1);
y_target = route(len,2);
p_target = [x_target,y_target];
% minimal distance for spining the Hebi
threshold= 0.1;
%move_hebi1
movingDirection =[move_hebi1,move_hebi2];
move_hebi1=0;  move_hebi2=0;
right=1; left =-1;

% the target of current segment
k_next= 1+interval;
k_old = 1;

% update the Hebi rotation angle
while (k_next<len+1)
    
    moveDirectionEstimation;
    angle_1 = move_hebi1 * alpha1;
    angle_2 = move_hebi2 * alpha2;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % after 1 sec, the Hebi should spin to make the plate horizontal, in order
    % to make sure the marble with a low speed while closing to the target
    pause(1);
    angle_1 = 0;
    angle_2 = 0;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    MarbleCorrection;
    angle_1 = move_hebi1 * alpha1;
    angle_2 = move_hebi2 * alpha2;
    cmd.position = [angle_1,angle_2];
    group.send(cmd);
    
    % update target
    if (norm(p-p_next)<threshold)
        k_old= k_next;
        k_next=k_next+interval;
    end
end




