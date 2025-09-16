function V = calculatePotential(X, Y, charges)
    k = 8.99e9; % Coulomb's constant
    V = zeros(size(X));

    for i = 1:length(charges.x)
        dx = X - charges.x(i);
        dy = Y - charges.y(i);
        r = sqrt(dx.^2 + dy.^2);
        r(r < 0.1) = 0.1;

        V = V + k * charges.q(i) * 1e-6 ./ r;
    end
end
