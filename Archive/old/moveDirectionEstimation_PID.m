%This scrpit can estimate the position on the plane, while the marble moving along the line

% current position read from the camera
p_measure = ball_pos;
x_measure = p_measure(1);
y_measure = p_measure(2);

ball_pos_record = [ball_pos_record; p_measure];
subplot(2,1,1);
plot(ball_pos_record(:,1),ball_pos_record(:,2));
%% Regulation with PID
%t = fbk.time;
%dt = t- told;
dt= 0.01;
%told= t;

e_x = x_measure- x_next;
e_y = y_measure- y_next;
esum_x = esum_x + e_x*dt;
esum_y = esum_y + e_y*dt;

ouputP1 = Kp1 * e_x; 
ouputP2 = Kp2 * e_y; 
ouputI1 = Ki1* esum_x;
ouputI2 = Ki2* esum_y;
ouputD1 = Kd1*(e_x-eold_x)/dt;
ouputD2 = Kd2*(e_y-eold_y)/dt;

y1 = ouputP1 + ouputI1 + ouputD1 +null_pos1;
disp(y1)

y2 = ouputP2 + ouputI2 + ouputD2+ null_pos2;
disp(y2)

if e_x > eold_x
    y1 = y1 /200;
end

if e_y > eold_y
    
end

y1 = y1 /200;

y2 = y2/200;

% distance from current position to the target
remainDistance = [y1, y2];

eold_x = e_x;
eold_y = e_y;



