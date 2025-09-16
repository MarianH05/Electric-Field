function plotEquipotentialLines(ax, charges)
    if isempty(charges.x), return; end

    [X, Y] = meshgrid(linspace(-10, 10, 120), linspace(-10, 10, 120));
    V = calculatePotential(X, Y, charges);

    V_max = prctile(abs(V(:)), 98);
    V(V >  V_max) =  V_max;
    V(V < -V_max) = -V_max;

    n_levels = 20;
    levels = linspace(min(V(:)), max(V(:)), n_levels);

    [~, h] = contour(ax, X, Y, V, levels, 'LineColor', [1 0 0], 'LineStyle', '-', 'LineWidth', 0.8);

    if min(V(:)) < 0 && max(V(:)) > 0
        hold(ax,'on');
        contour(ax, X, Y, V, [0 0], 'c', 'LineWidth', 1.4);
    end

    clabel([], h, 'FontSize', 7, 'Color', [0.7 0.1 0.1]);
end
