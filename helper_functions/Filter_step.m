function [State_update, Covar_update] = Filter_step(time_step, measurement, uncert, projected_state, projected_cov)
% Filter_step  Kalman filter measurement update (correction) step.
%
%   Applies the Kalman gain to correct the predicted state using the actual
%   ADS-B measurement observation. Uses the Joseph-form covariance update
%   for numerical stability.
%
%   Inputs:
%     time_step       - prediction timestep in seconds (Ts) — reserved for future use
%     measurement     - (6x1) observed state vector [x; y; z; Vx; Vy; Vz]
%     uncert          - struct with fields varx, vary, varz, varvx, varvy, varvz
%                       (from get_uncertainty.m, index 1 used for constant R)
%     projected_state - (9x1) predicted state from Predict_step
%     projected_cov   - (9x9) predicted covariance from Predict_step
%
%   Outputs:
%     State_update    - (9x1) corrected state estimate
%     Covar_update    - (9x9) updated covariance matrix (Joseph form)

% Observation matrix: maps 9-element CA state to 6 observable values
% (position x,y,z and velocity Vx,Vy,Vz — acceleration not directly observed)
H = [1 0 0  0 0 0  0 0 0;
     0 0 0  1 0 0  0 0 0;
     0 0 0  0 0 0  1 0 0;
     0 1 0  0 0 0  0 0 0;
     0 0 0  0 1 0  0 0 0;
     0 0 0  0 0 0  0 1 0];

% Measurement noise matrix from ADS-B NACp/NACv accuracy codes
R = [uncert(1).varx^2   0                   0                  0                   0                   0;
     0                  uncert(1).vary^2     0                  0                   0                   0;
     0                  0                   uncert(1).varz^2   0                   0                   0;
     0                  0                   0                  uncert(1).varvx^2   0                   0;
     0                  0                   0                  0                   uncert(1).varvy^2   0;
     0                  0                   0                  0                   0                   uncert(1).varvz^2];

P = projected_cov;
X = projected_state;

% Kalman gain
K = (P * H') / (H * P * H' + R);

% State update
measure_diff = measurement - H * X;
State_update = X + K * measure_diff;

% Covariance update (Joseph stabilised form)
LinDiff      = eye(9) - K * H;
Covar_update = LinDiff * P * LinDiff' + K * R * K';

end
