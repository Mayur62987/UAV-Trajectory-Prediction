function[State_pred,Covar_pred] = Predict_step(time_step,t,prev_state,prev_cov)

%%%%%%%Function to predicted values for state and covariance 
%%%%%%%gain%%%%%%%%%%%%%%%

%%%%%%%%input%%%%%%%%% time_step,previous state, previous
%%%%%%%%projected_state,Projeted_covariance

%%%%%%%%output%%%%% filtered_state, Filtered Covariance%%%%


Ts = time_step;


F = [1 Ts 0.5*Ts^2 0 0 0 0 0 0;
    0 1 Ts 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 Ts 0.5*Ts^2 0 0 0;
    0 0 0 0 1 Ts 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 Ts 0.5*Ts^2
    0 0 0 0 0 0 0 1 Ts;
    0 0 0 0 0 0 0 0 1];

Q = [0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0 0 0 0 0 0;
    0.5*Ts^2 Ts^2 Ts 0 0 0 0 0 0;
    0.5*Ts^2 Ts 1 0 0 0 0 0 0;
    0 0 0 0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0 0 0;
    0 0 0 0.5*Ts^2 Ts^2 Ts 0 0 0;
    0 0 0 0.5*Ts^2 Ts 1 0 0 0;
    0 0 0 0 0 0 0.25*Ts^4 0.5*Ts^3 0.5*Ts^2;
    0 0 0 0 0 0 0.5*Ts^2 Ts^2 Ts;
    0 0 0 0 0 0 0.5*Ts^2 Ts 1].*noise^2;

if t = 1 
    %intitalize the variables
    Xi = [0 0 0 0 0 0 0 0 0]';
    
    Pint = [200 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 200];

else
    Xi = prevstate
    
    Pint = prev_cov
    
    state_pred = F*Xi;
    
    Covar_pred = F*Pint*F' + Q;
