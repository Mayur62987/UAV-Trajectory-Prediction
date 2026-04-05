function [ x_pro, P ] = Model_mix( u, x1, x2, x3, x4, P1, P2, P3, P4)
% Model_mix  Combine state estimates and covariances for the 4-mode IMM.
%
%   Inputs:
%     u       - (4x1) current mode probability vector [mu1; mu2; mu3; mu4]
%     x1..x4  - (6x1) state vectors for CV, CA(trunc), CT1(trunc), CT2(trunc)
%     P1..P4  - (6x6) covariance matrices for each mode
%
%   Outputs:
%     x_pro   - (6x1) probability-weighted fused state estimate
%     P       - (6x6) probability-weighted fused covariance

x_pro = x1*u(1) + x2*u(2) + x3*u(3) + x4*u(4);

P = u(1)*(P1 + (x1 - x_pro)*((x1 - x_pro)')) + ...
    u(2)*(P2 + (x2 - x_pro)*((x2 - x_pro)')) + ...
    u(3)*(P3 + (x3 - x_pro)*((x3 - x_pro)')) + ...
    u(4)*(P4 + (x4 - x_pro)*((x4 - x_pro)'));

end
