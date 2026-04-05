function [State_pred, Covar_pred] = Predict_step(time_step, t, prev_state, prev_cov, noise)
% Predict_step  Kalman filter prediction step for the CA motion model.
%
%   Computes the predicted state vector and covariance matrix for time step k+1
%   based on the Constant Acceleration (CA) transition model.
%
%   Inputs:
%     time_step  - prediction lookahead in seconds (Ts)
%     t          - current timestep index (use t=1 to initialise)
%     prev_state - (9x1) state vector from previous step [x;xdot;xddot; y;ydot;yddot; z;zdot;zddot]
%     prev_cov   - (9x9) covariance matrix from previous step
%     noise      - process noise acceleration constant (sigma_a squared)
%
%   Outputs:
%     State_pred - (9x1) predicted state vector at k+1
%     Covar_pred - (9x9) predicted covariance matrix at k+1

Ts = time_step;

% CA state transition matrix (3D: x, y, z axes)
F = [1 Ts 0.5*Ts^2  0  0       0        0  0       0;
     0  1  Ts        0  0       0        0  0       0;
     0  0  1         0  0       0        0  0       0;
     0  0  0         1  Ts  0.5*Ts^2    0  0       0;
     0  0  0         0   1  Ts           0  0       0;
     0  0  0         0   0   1           0  0       0;
     0  0  0         0   0   0           1  Ts  0.5*Ts^2;
     0  0  0         0   0   0           0   1  Ts;
     0  0  0         0   0   0           0   0   1];

% Wiener-process acceleration noise matrix
Q = [0.25*Ts^4  0.5*Ts^3  0.5*Ts^2   0          0          0          0          0          0;
     0.5*Ts^3   Ts^2      Ts         0          0          0          0          0          0;
     0.5*Ts^2   Ts        1          0          0          0          0          0          0;
     0          0         0          0.25*Ts^4  0.5*Ts^3   0.5*Ts^2   0          0          0;
     0          0         0          0.5*Ts^3   Ts^2       Ts         0          0          0;
     0          0         0          0.5*Ts^2   Ts         1          0          0          0;
     0          0         0          0          0          0          0.25*Ts^4  0.5*Ts^3   0.5*Ts^2;
     0          0         0          0          0          0          0.5*Ts^3   Ts^2       Ts;
     0          0         0          0          0          0          0.5*Ts^2   Ts         1] .* noise^2;

if t == 1
    % Initialise at first timestep with zero state and high uncertainty
    Xi    = zeros(9, 1);
    Pint  = 200 * eye(9);
else
    % Use previous state and covariance
    Xi   = prev_state;
    Pint = prev_cov;
end

% Prediction equations
State_pred = F * Xi;
Covar_pred = F * Pint * F' + Q;

end
