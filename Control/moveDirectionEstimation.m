%This scrpit can estimate the position on the plane, while the marble moving along the
% line

% current position read from the camera
p_measure = [x_measure, y_measure];

%% state estimate with Kalman filter for single track
% % for each track, the motion is considered as constant velocity.
% dt = 0.01;
% alpha1 = 0; % the spin rad for Hebi1
% alpha2 = 0; % the spin rad for Hebi2
% v_x = 9.81 * sin(alpha1); % "constant speed" for inclined direction
% v_y = 9.81 * sin(alpha2); 
% x=[0;0;v_x;v_y];
% A = [1 0 dt 0;
%     0 1 0 dt;
%     0 0 1 0;
%     0 0 0 1];
% H = [1 0 0 0;
%     0 1 0 0]; % Measurement matrix
% P = 1000; % State variance
% Q = 0.1; % model error
% R =0.1; % measure noise
% z = p_measure';  % measured value  
% 
% while distance >0.1 % if the current location is closed to the current target 
%    
%    K = P * H'*(H* P*H' + R)^-1;
%    x = x + K*(z - H* x);
%    P = (eye(4)-K*H)*P;
%    
%    x = A * x;
%    P= A*P*A' +Q;
%    
% end
% x_correct= x(1);
% y_correct = x(2);

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

%while 1 % this should run until the marble reaches the final target
   
K = P * H'*(H*P*H' + V*R*V')^-1;
x = x + K *(z - sqrt(x(1)^2+x(2)^2) );
P = (eye(2)-K*H)*P;

x = A * x;
P= A*P*A' +W*Q*W';
   
%end
x_correct= x(1);
y_correct =x(2);

%% state estimate with PID
%todo if need
%% 
% corrected value of current position
p_correct = [x_correct, y_correct];

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






