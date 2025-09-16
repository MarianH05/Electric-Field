function simulateMotion(fig)
% SIMULATEMOTION - simulate a particle moving in the existing electric field
% using RK4 integration. Clears previous particle/trajectory if present.
%
% fig - handle to the main figure of your GUI
%
% Author: Hariton Marian

handles = guidata(fig);
ax = handles.ax;
charges = handles.charges;

if isempty(charges.x)
    msgbox('Add charges first!', 'Error','error');
    return;
end

% --- Remove previous particle/trajectory if they exist ---
if isfield(handles, 'particleHandle') && isvalid(handles.particleHandle)
    delete(handles.particleHandle);
end
if isfield(handles, 'trajHandle') && isvalid(handles.trajHandle)
    delete(handles.trajHandle);
end

% Particle properties
pos = [0, 0];          % start at origin
vel = [0, 0];          % initial velocity
dt = 0.05;             % time step
mass = 1e-3;           % kg
q_particle = 1e-6;     % C

% Plot particle initially (white point)
particleHandle = plot(ax, pos(1), pos(2), 'wo', 'MarkerFaceColor','w', 'MarkerSize',8);

trajX = pos(1); trajY = pos(2);
trajHandle = plot(ax, trajX, trajY, 'w--', 'LineWidth', 1); % initialize trajectory line

% Store handles for future removal
handles.particleHandle = particleHandle;
handles.trajHandle = trajHandle;
guidata(fig, handles);

% Disable UI interactions while simulating
set(fig, 'Pointer', 'watch');
drawnow;

max_steps = 1000;
for step = 1:max_steps
    if ~isvalid(fig)
        break;
    end

    % --- RK4 integration ---
    f = @(state) dynamics(state, charges, q_particle, mass);
    state = [pos, vel]; % [x, y, vx, vy]

    k1 = f(state);
    k2 = f(state + dt/2 * k1);
    k3 = f(state + dt/2 * k2);
    k4 = f(state + dt   * k3);

    state = state + dt/6 * (k1 + 2*k2 + 2*k3 + k4);

    % Unpack new state
    pos = state(1:2);
    vel = state(3:4);

    % Update particle position
    set(particleHandle, 'XData', pos(1), 'YData', pos(2));

    % Update trajectory
    trajX(end+1) = pos(1);
    trajY(end+1) = pos(2);
    set(trajHandle, 'XData', trajX, 'YData', trajY);

    drawnow;

    % Stop if particle goes out of bounds
    xlim_ = get(ax,'XLim'); ylim_ = get(ax,'YLim');
    if pos(1)<xlim_(1) || pos(1)>xlim_(2) || pos(2)<ylim_(1) || pos(2)>ylim_(2)
        break;
    end

    pause(0.05); % slow down simulation
end

set(fig, 'Pointer', 'arrow');
end

% ------------------------------------------------------
function dstate = dynamics(state, charges, q_particle, mass)
% DYNAMICS - derivative of state for RK4
% state = [x, y, vx, vy]

pos = state(1:2);
vel = state(3:4);

% Electric field at current position
[Ex, Ey] = calculateElectricField(pos(1), pos(2), charges);
acc = q_particle * [Ex, Ey] / mass;

% dx/dt = vx, dy/dt = vy, dv/dt = acc
dstate = [vel, acc];
end
