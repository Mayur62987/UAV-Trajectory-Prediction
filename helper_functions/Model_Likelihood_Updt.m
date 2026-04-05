function [ u ] = Model_Likelihood_Updt( r1, r2, r3, r4, S1, S2, S3, S4, c_i )
% Model_Likelihood_Updt  Update mode probabilities for the 4-mode IMM.
%
%   Computes the Gaussian likelihood for each of the 4 filter modes and
%   returns a normalised updated probability vector.
%
%   Inputs:
%     r1..r4  - innovation vectors for each filter: Z - H*X_pred
%     S1..S4  - innovation covariance matrices:     H*P*H' + R
%     c_i     - current mode probability vector (4x1)
%
%   Output:
%     u       - updated and normalised mode probability vector (4x1)

% Compute Gaussian likelihood for each mode
if det(2*pi*S1) > 0
    Lfun1 = (1/(sqrt(det(2*pi*S1)))) * exp(-0.5 * (r1' * (S1^-1) * r1));
else
    Lfun1 = 0;
end

if det(2*pi*S2) > 0
    Lfun2 = (1/(sqrt(det(2*pi*S2)))) * exp(-0.5 * (r2' * (S2^-1) * r2));
else
    Lfun2 = 0;
end

if det(2*pi*S3) > 0
    Lfun3 = (1/(sqrt(det(2*pi*S3)))) * exp(-0.5 * (r3' * (S3^-1) * r3));
else
    Lfun3 = 0;
end

if det(2*pi*S4) > 0
    Lfun4 = (1/(sqrt(det(2*pi*S4)))) * exp(-0.5 * (r4' * (S4^-1) * r4));
else
    Lfun4 = 0;
end

% Handle edge cases to prevent division by zero
if Lfun1 == 0 && Lfun2 == 0 && Lfun3 == 0 && Lfun4 == 0
    % All likelihoods zero: assign equal weights
    Lfun1 = 0.1;
    Lfun2 = 0.1;
    Lfun3 = 0.1;
    Lfun4 = 0.1;
end

if Lfun1 > 0 && Lfun2 == 0 && Lfun3 == 0 && Lfun4 == 0
    Lfun1 = 1; Lfun2 = 0; Lfun3 = 0; Lfun4 = 0;
end

if Lfun1 == 0 && Lfun2 > 0 && Lfun3 == 0 && Lfun4 == 0
    Lfun1 = 0; Lfun2 = 1; Lfun3 = 0; Lfun4 = 0;
end

if Lfun1 == 0 && Lfun2 == 0 && Lfun3 > 0 && Lfun4 == 0
    Lfun1 = 0; Lfun2 = 0; Lfun3 = 1; Lfun4 = 0;
end

if Lfun1 == 0 && Lfun2 == 0 && Lfun3 == 0 && Lfun4 > 0
    Lfun1 = 0; Lfun2 = 0; Lfun3 = 0; Lfun4 = 1;
end

% Normalise likelihoods
sumVal = Lfun1 + Lfun2 + Lfun3 + Lfun4;
Lfun1 = Lfun1 / sumVal;
Lfun2 = Lfun2 / sumVal;
Lfun3 = Lfun3 / sumVal;
Lfun4 = Lfun4 / sumVal;

% Compute updated mode probabilities
c = [Lfun1, Lfun2, Lfun3, Lfun4] * c_i;
u = (1/c) .* [Lfun1, Lfun2, Lfun3, Lfun4]' .* c_i;

end
