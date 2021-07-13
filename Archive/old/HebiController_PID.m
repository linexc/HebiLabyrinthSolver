% this script is used for HebiController, the rotation direction from script
% moveDirectionEstimation. 
Hebiparameter;

line_frame = snapshot(cam);
% through snapshot to get line position array
[line_frame] = image_process(line_frame, cameraParams);
[sorted_pos] = extract_pos(line_frame);

Motionparameter; 

PIDparameter; 

%% update the Hebi rotation angle
while (k_next<len+1)

    Pointcalculator; 
    
    moveDirectionEstimation;
    cmd.position = [y1,y2];
    group.send(cmd);
    
%     MarbleCorrection;
%     angle_1 = move_hebi1 * alpha1;
%     angle_2 = move_hebi2 * alpha2;
%     cmd.position = [angle_1,angle_2];
%     group.send(cmd);
%     
%     % after 0.1 sec, the Hebi should spin to make the plate horizontal, in order
%     % to make sure the marble with a low speed while closing to the target
%     pause(0.1);
%     angle_1 = 0;
%     angle_2 = 0;
%     cmd.position = [angle_1,angle_2];
%     group.send(cmd);
    
    % update target
    if (norm(p_correct-p_next)<threshold)
        k_old= k_next;
        k_next=k_next+interval;
    end
end




