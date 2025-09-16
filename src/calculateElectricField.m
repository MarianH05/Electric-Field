function [Ex, Ey] = calculateElectricField(X, Y, charges)
    k = 8.99e9; % Coulomb's constant
    Ex = zeros(size(X));
    Ey = zeros(size(Y));

    for i = 1:length(charges.x)
        dx = X - charges.x(i);
        dy = Y - charges.y(i);
        r = sqrt(dx.^2 + dy.^2);
        r(r < 0.1) = 0.1;

        E_mag = k * abs(charges.q(i)) * 1e-6 ./ r.^2;
        Ex = Ex + sign(charges.q(i)) * E_mag .* dx ./ r;
        Ey = Ey + sign(charges.q(i)) * E_mag .* dy ./ r;
    end
end
