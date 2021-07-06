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