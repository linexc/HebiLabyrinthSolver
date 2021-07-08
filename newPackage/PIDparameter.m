%% PID parameters
Kp1 = 1; % P element of Hebi1 
Ki1 = 1; % I element of Hebi1 
Kd1 = 0.001; % D element of Hebi1 

Kp2 = 1; % P element of Hebi2
Ki2 = 1; % I element of Hebi2
Kd2 = 0.001; % D element of Hebi2

%% Declare error variables
esum_x = 0;
esum_y =0; % starting value for cumulative error
e_x = 0;
e_y = 0;% current error
eold_x = 0;
eold_y = 0;% previous error

t0 = group.getNextFeedback.time; % module time at start
told = t0;