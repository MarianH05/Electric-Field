function plotFieldLines(ax, charges, density)
    if isempty(charges.x), return; end

    lines_per_charge = density;

    for i = 1:length(charges.x)
        n_lines = round(abs(charges.q(i)) * lines_per_charge);
        theta = linspace(0, 2*pi, n_lines + 1); theta(end) = [];

        r_start = 0.3;
        x_start = charges.x(i) + r_start * cos(theta);
        y_start = charges.y(i) + r_start * sin(theta);

        for j = 1:length(x_start)
            if charges.q(i) > 0
                [x_line, y_line] = traceFieldLine(x_start(j), y_start(j), charges, 1);
            else
                [x_line, y_line] = traceFieldLine(x_start(j), y_start(j), charges, -1);
            end

            if length(x_line) > 1
                plot(ax, x_line, y_line, 'b-', 'LineWidth', 1.5);

                if length(x_line) > 10
                    mid_idx = round(length(x_line)/2);
                    dx = x_line(mid_idx+1) - x_line(mid_idx);
                    dy = y_line(mid_idx+1) - y_line(mid_idx);
                    norm_val = sqrt(dx^2 + dy^2);
                    if norm_val > 0
                        dx = dx / norm_val * 0.3;
                        dy = dy / norm_val * 0.3;
                        quiver(ax, x_line(mid_idx), y_line(mid_idx), dx, dy, 0, 'b', 'LineWidth', 1.5, 'MaxHeadSize', 0.5);
                    end
                end
            end
        end
    end
end
