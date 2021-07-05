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

%% state estimate with Kalman filter for single track
% for each track, the motion is considered as constant velocity.
dt = 0.01;
alpha1 = 0; % the spin rad for Hebi1
alpha2 = 0; % the spin rad for Hebi2
v_x = 9.81 * sin(alpha1); % "constant speed" for inclined direction
v_y = 9.81 * sin(alpha2); 
x=[0;0;v_x;v_y];
A = [1 0 dt 0;
    0 1 0 dt;
    0 0 1 0;
    0 0 0 1];
H = [1 0 0 0;
    0 1 0 0]; % Measurement matrix
P = 1000; % State variance
Q = 0.1; % model error
R =0.1; % measure noise
z = p_measure';  % measured value  

while distance >0.1 % if the current location is closed to the current target 
   
   K = P * H'*(H* P*H' + R)^-1;
   x = x + K*(z - H* x);
   P = (eye(4)-K*H)*P;
   
   x = A * x;
   P= A*P*A' +Q;
   
end
x_correct= x(1);
y_correct = x(2);

%% state estimate with EKF for the entire track
dt= 0.1;
x = [0; 0]; 
A = [1 0; 0 1];
W = [dt ; dt]; 
z = sqrt(p_measure(1)^2+p_measure(2)^2);
H = [p_measure(1)/z p_measure(2)/z];
V =1 ;
P = 1000; % State variance
Q = 0.1; % model error
R =0.1; % measure noise

while 1 % this should run until the marble reaches the final target
   
   K = P * H'*(H*P*H' + V*R*V')^-1;
   x = x + K *(z - sqrt(x(1)^2+x(2)^2) );
   P = (eye(2)-K*H)*P;
   
   x = A * x;
   P= A*P*A' +W*Q*W';
   
end
x_correct= x(1);
y_correct = x(2);


%% state estimate with PID
%% 
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

