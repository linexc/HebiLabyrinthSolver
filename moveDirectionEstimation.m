% estimate the position on the plane, while the marble moving along the
% line

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

% current position read from the camera
p_measure = [x_measure, y_measure];

% state estimate with Kalman filter

%state estimate with PID

% corrected value of current position
p_correct = [x_correct, y_correct];

% the target of current segment
k_next= 1+interval;
k_old = 1;

while (k_next<len+1)
    % from current point to next position
    x_next = route(k_next,1);
    y_next = route(k_next,2);
    p_next =[x_next,y_next];
    if(x_next< x_correct)
            move_hebi1= left;
        elseif (x_next> x_correct)
            move_hebi1= right;
        else 
            move_hebi1=0;
    end
    if(y_next< y_correct)
            move_hebi2= down;
        elseif (y_next> y_correct)
            move_hebi2= up;
        else
            move_hebi2=0;
    end
    
    %update current position
    x = x_measure;
    y = y_measure;
    
    % if the marble devates from current segment, the Hebi should spin in
    % oder to make sure the marble can roll back to the line.
    
    % middle point of the segment 
    x_old = route(k_old,1);
    y_old = route(k_old,2);
    x_middle = (x_old + x_next)/2;
    y_m1ddle = (y_old + y_next)/2;
    p_middle = [x_middle, y_middle];
    if (norm(p-p_middle)>threshold)
       if(x_middle< x_correct)
            move_hebi1= left;
        elseif (x_middle> x_correct)
            move_hebi1= right;
        else 
            move_hebi1=0;
        end
        if(y_m1ddle< y_correct)
                move_hebi2= down;
            elseif (y_m1ddle> y_correct)
                move_hebi2= up;
            else
                move_hebi2=0;
        end
    end
    
    % update target
    if (norm(p-p_next)<threshold)
        k_old= k_next;
        k_next=k_next+interval;
    end
end

