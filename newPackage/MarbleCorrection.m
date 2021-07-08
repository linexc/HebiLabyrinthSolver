% if the marble devates from current segment, the Hebi should spin in
% oder to make sure the marble can roll back to the line.

if (norm(p_correct-p_middle)>threshold)
   if(x_middle< x_correct)
        move_hebi1= left;
    elseif (x_middle> x_correct)
        move_hebi1= right;
    else 
        move_hebi1=0;
    end
    if(y_m1ddle< y_correct)
            move_hebi2= up;
        elseif (y_m1ddle> y_correct)
            move_hebi2= down;
        else
            move_hebi2=0;
    end
end