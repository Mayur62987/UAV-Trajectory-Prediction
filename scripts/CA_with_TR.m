clc;
clear;
% load 'Kalman_test_07-31';
load 'For_linear_filter';
Ts = 5;
noise = 40;
init = 0;
flat = [x y];
predictions = zeros(10,data_points);

W = deg2rad(track_rate);

Z =[x Vx y Vy z Vz W]';

F = [1 Ts 0.5*Ts^2 0 0 0 0 0 0 0;
    0 1 Ts 0 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0 0;
    0 0 0 1 Ts 0.5*Ts^2 0 0 0 0;
    0 0 0 0 1 Ts 0 0 0 0;
    0 0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 1 Ts 0.5*Ts^2 0;
    0 0 0 0 0 0 0 1 Ts 0;
    0 0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 0 1];
    
    
% Measurement of XYZ pos XYZ velocity


H = [1 0 0 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0 0;
    0 0 0 1 0 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0 0;
    0 0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 1];

%Process noise matrix 
Q = [0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0 0 0 0 0 0 0;
    0.5*Ts^2 Ts^2 Ts 0 0 0 0 0 0 0;
    0.5*Ts^2 Ts 1 0 0 0 0 0 0 0;
    0 0 0 0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0 0 0 0;
    0 0 0 0.5*Ts^2 Ts^2 Ts 0 0 0 0;
    0 0 0 0.5*Ts^2 Ts 1 0 0 0 0;
    0 0 0 0 0 0 0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0;
    0 0 0 0 0 0 0.5*Ts^2 Ts^2 Ts 0;
    0 0 0 0 0 0 0.5*Ts^2 Ts 1 0
    0 0 0 0 0 0 0 0 0 0].*noise^2;

% R = [uncert.varx^2 0 0 0 0 0;
%     0 uncert.varvx^2 0 0 0 0;
%     0 0 uncert.vary^2 0 0 0;
%     0 0 0 uncert.varvy^2 0 0;
%     0 0 0 0 uncert.varz^2 0;
%     0 0 0 0 0 uncert.varvz^2]; 





for d = 2:Ts:data_points

    if d == 2
        Xi = [0 0 0 0 0 0 0 0 0 0]';
%intialise process covariance at t = 0
        Pint = [200 0 0 0 0 0 0 0 0 0;
            0 200 0 0 0 0 0 0 0 0;
            0 0 200 0 0 0 0 0 0 0;
            0 0 0 200 0 0 0 0 0 0;
            0 0 0 0 200 0 0 0 0 0;
            0 0 0 0 0 200 0 0 0 0;
            0 0 0 0 0 0 200 0 0 0;
            0 0 0 0 0 0 0 200 0 0;
            0 0 0 0 0 0 0 0 200 0;
            0 0 0 0 0 0 0 0 0 200];

        R = [uncert(1).varx^2 0 0 0 0 0 0;
        0 uncert(1).varvx^2 0 0 0 0 0;
        0 0 uncert(1).vary^2 0 0 0 0;
        0 0 0 uncert(1).varvy^2 0 0 0;
        0 0 0 0 uncert(1).varz^2 0 0 ;
        0 0 0 0 0 uncert(1).varvz^2 0
        0 0 0 0 0 0 0]; 
    
    end
    
        R = [uncert(1).varx^2 0 0 0 0 0 0;
        0 uncert(1).varvx^2 0 0 0 0 0;
        0 0 uncert(1).vary^2 0 0 0 0;
        0 0 0 uncert(1).varvy^2 0 0 0;
        0 0 0 0 uncert(1).varz^2 0 0 ;
        0 0 0 0 0 uncert(1).varvz^2 0
        0 0 0 0 0 0 0];   
        
%     R = [uncert(d).varx^2 0 0 0 0 0;
%     0 uncert(d).varvx^2 0 0 0 0;
%     0 0 uncert(d).vary^2 0 0 0;
%     0 0 0 uncert(d).varvy^2 0 0;
%     0 0 0 0 uncert(d).varz^2 0;
%     0 0 0 0 0 uncert(d).varvz^2]; 
  
    
    Xpred = F*Xi;
  
    predictions(:,d) = Xpred
    
    
    %update covariance matrix
    P = F*Pint*F' + Q;
    %work out kalman gain
    K = (P*H')/(H*P*H' + R)
    
   
    
    measurement_difference = (Z(:,d) - H*Xpred);
    
    Xest = Xpred + K*(measurement_difference);
    
    LinDiff = eye(10) - K*H;
    
    Pest = LinDiff*P*LinDiff' + K*R*K';
    
%     Pest = (eye(9) - K*H)*P*(eye(9)-K*H)' + K*R*K';
    
%     Pest = P - K*P;
    
    Pint = Pest;
   
    Xi = Xest;
    
   estimates(:,d) = Xest;
   
   if d == data_points
       predictions(:,d) = F*Xest;
   end
      
   
   
   
   err.x(d) = (x(d) - Xest(1))^2;
   err.y(d) = (y(d) - Xest(4))^2;
   err.z(d) = (z(d) - Xest(7))^2;
   
   err.vect(d) = (err.x(d) + err.y(d) + err.z(d))^0.5;
    
%    figure(1);
%    plot3(d,Xest(1),Xest(4),'or',d,x(d),y(d),'db');
%    hold on;
%    
%    figure(2);
%    plot(d,Xest(7),'or',d,z(d),'db');
%    hold on;
%    
%    figure(3);
%    plot(d,err.vect(d),'.');
%    hold on;
%    pause(0.01);
%     plot(x(d),y(d),'r- o','LineWidth',2);
    
   
    
%     plot(x(d),y(d),'r- o','LineWidth',2);
    

%     axis([3.96e6 4e6 -2e5 -1.3e5]);
%     llaa = ecef2lla([x(d) y(d) z(d)],'WGS84');
%     llae = ecef2lla([predictions(1,d),predictions(4,d),predictions(7,d)],'WGS84');
%     geoplot(llaa(1),llaa(2),llae(1),llae(2));
%     geobasemap streets
%     hold on
%     pause(0.1);
    
end
    
%     plot(predic
%     figure(2);tions(1,:),predictions(4,:),'-or',x,y,'-db');
pcounter = 0

for p = 2:Ts:data_points
    pcounter = pcounter+1;
    plotx(pcounter) = x(p);
    ploty(pcounter) = y(p);
    plotz(pcounter) = z(p);
    plotestx(pcounter) = predictions(1,p);
    plotesty(pcounter) = predictions(4,p);
    plotestz(pcounter) = predictions(7,p);
    ploterr(pcounter) = err.vect(p);
end

   figure(1);
   plot(plotestx,plotesty,'-or',plotx,ploty,'-db');
   title('Estimated X and Y positions vs Actual X and Y positions');
   legend({'Estimted','Actual'},'Location','southwest');
   xlabel('X Position(m)');
   ylabel('Y Position(m)');
   
   
   figure(2);
   plot(2:Ts:data_points,plotestz,'-or',2:Ts:data_points,plotz,'-db');
   title('Estimated Z vs Actual Z');
   legend({'Estimted','Actual'},'Location','southwest');
   xlabel('Timestep');
   ylabel('Altitude(m)');
   
   
   figure(3);
   plot(2:Ts:data_points,log(ploterr),'-g');
   title('Log Positional vector error');
   xlabel('Timestep');
   ylabel('error');
  
   figure(4);
   plot3(plotestx,plotesty,plotestz,'-or',plotx,ploty,plotz,'-db');
 