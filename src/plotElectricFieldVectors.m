function plotElectricFieldVectors(ax, charges)
    if isempty(charges.x), return; end

    [X, Y] = meshgrid(-10:1.5:10, -10:1.5:10);
    [Ex, Ey] = calculateElectricField(X, Y, charges);

    E_mag = sqrt(Ex.^2 + Ey.^2);
    E_mag(E_mag < 1e-6) = 1e-6;

    scale = log10(E_mag + 1);
    Ex_norm = Ex ./ E_mag .* scale;
    Ey_norm = Ey ./ E_mag .* scale;

    for i = 1:length(charges.x)
        dist = sqrt((X - charges.x(i)).^2 + (Y - charges.y(i)).^2);
        mask = dist < 0.8;
        Ex_norm(mask) = 0;
        Ey_norm(mask) = 0;
    end

    q = quiver(ax, X, Y, Ex_norm, Ey_norm, 0.5, 'Color', [0.95 0.8 0.1], 'LineWidth', 1);
    q.MaxHeadSize = 0.8;
end
