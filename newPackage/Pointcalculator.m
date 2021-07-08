% coordinate for actual position
    x_old = route(k_old,1);
    y_old = route(k_old,2);
    p_old = [x_old, y_old];
    
    % coordinate for next position
    x_next = route(k_next,1);
    y_next = route(k_next,2);
    p_next = [x_next, y_next];

    % middle point of the segment 
    x_middle = (x_old + x_next)/2;
    y_middle = (y_old + y_next)/2;
    p_middle = [x_middle, y_middle];