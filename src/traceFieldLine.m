function [x_line, y_line] = traceFieldLine(x0, y0, charges, direction)
    dt = 0.05;       % step size (arc-length parameter)
    max_steps = 500;
    min_dist = 0.2;
    max_dist = 15;

    x_line = x0;
    y_line = y0;

    for step = 1:max_steps
        x = x_line(end);
        y = y_line(end);

        % Stop if too far away
        if abs(x) > max_dist || abs(y) > max_dist
            break;
        end

        % Stop if too close to a charge
        for i = 1:length(charges.x)
            dist = sqrt((x - charges.x(i))^2 + (y - charges.y(i))^2);
            if dist < min_dist
                return;
            end
        end

        % --- RK4 integration ---
        f = @(pos) fieldDir(pos(1), pos(2), charges, direction);

        pos = [x, y];
        k1 = f(pos);
        k2 = f(pos + dt/2 * k1);
        k3 = f(pos + dt/2 * k2);
        k4 = f(pos + dt   * k3);

        pos_next = pos + dt/6 * (k1 + 2*k2 + 2*k3 + k4);

        x_line(end+1) = pos_next(1);
        y_line(end+1) = pos_next(2);
    end
end

% Helper: returns normalized E direction vector
function dpos = fieldDir(x, y, charges, direction)
    [Ex, Ey] = calculateElectricField(x, y, charges);
    E_mag = sqrt(Ex^2 + Ey^2);
    if E_mag < 1e-12
        dpos = [0, 0];
    else
        dpos = direction * [Ex, Ey] / E_mag;
    end
end
