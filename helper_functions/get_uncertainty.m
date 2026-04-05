function [varx, vary, varz, varvx, varvy, varvz] = get_uncertainty(nac_p, nac_v)
% get_uncertainty  Convert ADS-B NACp and NACv codes to metric uncertainty values.
%
%   Returns position and velocity measurement uncertainty (standard deviations)
%   derived from the ADS-B Navigation Accuracy Category codes. These values
%   are used to build the Kalman filter measurement noise matrix R.
%
%   Reference: The 1090 MHz Riddle, Junzi Sun, p.88
%              https://mode-s.org/decode/book-the_1090mhz_riddle-junzi_sun.pdf
%
%   Inputs:
%     nac_p  - NACp integer code (0-11): position accuracy category
%     nac_v  - NACv integer code (0-4):  velocity accuracy category
%
%   Outputs:
%     varx   - horizontal position uncertainty in X (metres)
%     vary   - horizontal position uncertainty in Y (metres)
%     varz   - vertical position uncertainty in Z (metres)
%     varvx  - velocity uncertainty in X (m/s)
%     varvy  - velocity uncertainty in Y (m/s)
%     varvz  - vertical velocity uncertainty (m/s)

% Position uncertainty from NACp
switch nac_p
    case 11
        varx = 3;    vary = 3;     varz = 4;
    case 10
        varx = 10;   vary = 10;    varz = 15;
    case 9
        varx = 30;   vary = 30;    varz = 45;
    case 8
        varx = 93;   vary = 93;    varz = 45;
    case 7
        varx = 185;  vary = 185;   varz = 45;
    case 6
        varx = 556;  vary = 556;   varz = 45;
    case 5
        varx = 926;  vary = 926;   varz = 45;
    case 4
        varx = 1852; vary = 1852;  varz = 45;
    case 3
        varx = 3704; vary = 3704;  varz = 45;
    case 2
        varx = 7408; vary = 7408;  varz = 45;
    case 1
        varx = 18520; vary = 18520; varz = 45;
    otherwise
        % NACp = 0: unknown or >10 NM accuracy — use maximum uncertainty
        warning('get_uncertainty: NACp value %d unrecognised. Using maximum uncertainty.', nac_p);
        varx = 18520; vary = 18520; varz = 45;
end

% Velocity uncertainty from NACv
switch nac_v
    case 4
        varvx = 0.3;  varvy = 0.3;  varvz = 0.46;
    case 3
        varvx = 1;    varvy = 1;    varvz = 1.5;
    case 2
        varvx = 3;    varvy = 3;    varvz = 4.5;
    case 1
        varvx = 10;   varvy = 10;   varvz = 15.2;
    otherwise
        % NACv = 0: unknown accuracy — use maximum uncertainty
        warning('get_uncertainty: NACv value %d unrecognised. Using maximum uncertainty.', nac_v);
        varvx = 10;   varvy = 10;   varvz = 15.2;
end

end
