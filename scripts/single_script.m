%combined feed of live data
clc;
clear all;
close all;
fields = {'hex', 'flight','alt_geom','gs','track','track_rate','geom_rate','lat','lon','nac_p','nac_v','seen','version'};

while 1
    data_sel = input('Data source \nSaved Data :0 \nLive Data :1\nBuild Data :2\n');
    if (data_sel == 0 || data_sel ==1 || data_sel == 2)
        break
    end
end





if data_sel == 0
    
    
    jump_processing = input('Kalman filter testing? :1 \n');
    
    if ~jump_processing
    
        load 'DATA_Storage_08_11.mat';
        data_sel = 0;

        number_data = width(flightdata);
        counter = 0;
        for z = 1:1:number_data
            instance = flightdata(z);
            unpacked = instance{:};
            total_flights(z) = length(unpacked);
            for y = 1:1:total_flights(z)
                this_flight = unpacked(y,1);
                this_flight_data = this_flight{:};
                required = isfield(this_flight_data,fields);
                if all(required)
                    counter = counter + 1;  
                    fly.hex = this_flight_data.hex;
                    fly.flight = convertCharsToStrings(this_flight_data.flight);
                    fly.alt_geom = this_flight_data.alt_geom;
                    fly.gs = this_flight_data.gs;
                    fly.track = this_flight_data.track; 
                    fly.track_rate = this_flight_data.track_rate;
                    fly.geom_rate = this_flight_data.geom_rate;
                    fly.lat = this_flight_data.lat;
                    fly.lon = this_flight_data.lon;
                    fly.nac_p = this_flight_data.nac_p;
                    fly.nac_v = this_flight_data.nac_v;
                    fly.seen = this_flight_data.seen;
                    fly.version = this_flight_data.version;
                    flight_table(counter,:) = struct2table(fly);
                end
            end
        end


        selection = unique(flight_table.flight)
        tracked = input('Select Flight Number: ')
        while ~any(strcmp(selection,tracked))
            tracked = input('select an existing flight number from the list: ' );
        end

        single_tracked = flight_table(strcmp(flight_table.flight,tracked),:); 

        alt = single_tracked.alt_geom * 0.3048; %conv ft to metersflight_table
        lat = single_tracked.lat;
        long = single_tracked.lon;
        track_rate = single_tracked.track_rate;
        speed = single_tracked.gs*0.514444; %conv knts to m/s
        heading = single_tracked.track;
        Vz = single_tracked.geom_rate*0.00508; %conv ft/min to m/s
        position_uncert = single_tracked.nac_p;
        velocity_uncrt = single_tracked.nac_v;
        posmat = [lat long alt];
        [pos] = lla2ecef(posmat,'WGS84'); %convert to x, y, z coordinates
        x = pos(:,1);
        y = pos(:,2);
        z = pos(:,3);
        data_points = length(heading);
        for j = 1:data_points 
        [uncert(j).varx,uncert(j).vary,uncert(j).varz,uncert(j).varvx,uncert(j).varvy,uncert(j).varvz] = get_uncertainty(position_uncert(j),velocity_uncrt(j));    

        heading(j)
%         if 0 < heading(j) &&  heading(j) <=90  
%     %        
%             Vy(j,1) = speed(j)*cosd(heading(j));
%             Vx(j,1) = speed(j)*sind(heading(j));
%         elseif 91 < heading(j) &&  heading(j) <=180
%     %  
%               Vx(j,1) = speed(j)*sind(180-heading(j));
%               Vy(j,1) = -speed(j)*cosd(180-heading(j));
%         elseif 181 < heading(j) &&  heading(j) <=270
% 
%               Vx(j,1) = -speed(j)*cosd(270-heading(j));
%               Vy(j,1) = -speed(j)*sind(270-heading(j));
% 
%         elseif 271 < heading(j) &&  heading(j) <=360
%     
%               Vx(j,1) = -speed(j)*sind(360-heading(j));
%               Vy(j,1) = speed(j)*cosd(360-heading(j));
% 
%         end
%         end 
0
        Vx(j) = speed(j)*cos(heading(j)*(pi./180));
        Vy(j) = speed(j)*sin(heading(j)*(pi./180));

    %      [xpred, ypred, zpred] = LinearKal(Ts,x,y,z,Vx,Vy,Vz,uncert);
        end
        end
    

% load Kalman_new_data -regexp ^(?!flight_table$|flightdata$|total_flights$).
% load 'C:\RTL1090\dump1090-win.1.10.3010.14\decoded Flights\VLG8LV.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
load 'C:\RTL1090\dump1090-win.1.10.3010.14\test-flights\EZY89TP.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
% load Kalman_new_data
%    


while 1
Dynamodel = input('\nCV Kalman :1\nCA Kalman :2\nCA-CV-CT-IMM Kalman :3\nCA-CV-IMM: 4\n');
if (Dynamodel == 1 || Dynamodel == 2 || Dynamodel == 3 || Dynamodel == 4)
    break
end
end

% Ts = input('Specify the time_step size for prediction: ');
Ts = 15;


while Ts <= 0
    Ts = input('Please specify a non-negative, non-zero time step size: ');
end


Col = input('Simulate collision\nyes :1? ');


if Dynamodel == 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CV%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
Z =[x Vx y Vy z Vz]';

% predictionsCv = zeros(6,data_points);

Velnoise = 40

FCV = [1 Ts 0 0 0 0;
        0 1 0 0 0 0;
        0 0 1 Ts 0 0;
        0 0 0 1 0 0;
        0 0 0 0 1 Ts;
        0 0 0 0 0 1];
    
    
HCV = [1 0 0 0 0 0;
   0 1 0 0 0 0;
   0 0 1 0 0 0;
   0 0 0 1 0 0;
   0 0 0 0 1 0;
   0 0 0 0 0 1];

QCV = [((Ts^2)/3) Ts*0.5 0 0 0 0;
        Ts*0.5 1 0 0 0 0;
        0 0 ((Ts^2)/3) Ts*0.5 0 0;
        0 0 Ts*0.5 1 0 0;
        0 0 0 0 ((Ts^2)/3) Ts*0.5;
        0 0 0 0 Ts*0.5 1]*Velnoise^2;
    
    
RCAV = [uncert(1).varx^2 0 0 0 0 0;
    0 uncert(1).varvx^2 0 0 0 0;
    0 0 uncert(1).vary^2 0 0 0;
    0 0 0 uncert(1).varvy^2 0 0;
    0 0 0 0 uncert(1).varz^2 0;
    0 0 0 0 0 uncert(1).varvz^2]; 

if Col
    
initial_pos = [x(1) y(1) z(1)];
intitial_vel = [Vx(1) Vy(1) Vz(1)];
% intruder_position = initial_pos + [20000 20000 -1000];
intruder_position = initial_pos +[5000 0 0];

opposing_heading = -mod(360-(heading(1)),360)-90;
plotx = [];
ploty = [];
plotz = [];


Vxop = mean(speed)*sin(opposing_heading*(pi./180));
Vyop = mean(speed)*cos(opposing_heading*(pi./180));
% 
% Vzop = Vz(1)

Vzop = -mean(Vz);

Xii = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

parse = 1;

     
 for d = 2:Ts:data_points
     
F = [1 d 0.5*d^2 0 0 0 0 0 0;
    0 1 d 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 d 0.5*d^2 0 0 0;
    0 0 0 0 1 d 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 d 0.5*d^2
    0 0 0 0 0 0 0 1 d;
    0 0 0 0 0 0 0 0 1];


 if d == 2
        Xi = Z(:,1);
%intialise process covariance at t = 0
        Pint = [200 0 0 0 0 0;
            0 200 0 0 0 0;
            0 0 200 0 0 0;
            0 0 0 200 0 0;
            0 0 0 0 200 0;
            0 0 0 0 0 200];
        
Xintruder(:,parse) = Xii;

 end
 
Xintruder(:,parse) = F*Xii;
          
Xpred = FCV*Xi;

predictionsCv(:,parse) = Xpred;


%update covariance matrix
P = FCV*Pint*FCV' + QCV;
%work out kalman gain
K = (P*HCV')/(HCV*P*HCV' + RCAV)

measurement_difference = (Z(:,d) - HCV*Xpred);

Xest = Xpred + K*(measurement_difference);

LinDiff = eye(6) - K*HCV;

Pest = LinDiff*P*LinDiff' + K*RCAV*K';

Pint = Pest;

Xi = Xest;

estimatesCV(:,d) = Xest;

err.x(d) = (x(d) - Xpred(1))^2;
err.y(d) = (y(d) - Xpred(3))^2;
err.z(d) = (z(d) - Xpred(5))^2;

err.vect(parse) = (1/parse*(err.x(d) + err.y(d) + err.z(d)))^0.5;
   
   
% cyl = collisionCylinder(9260,609.6);
% Trformint = trvec2tform([x(parse) y(parse) z(parse)]);
% cy1.Pose = Trformint;

cy_pre = collisionCylinder(926,152.4);
Trformpre = trvec2tform([predictionsCv(1,parse) predictionsCv(3,parse) predictionsCv(5,parse)]);
cy_pre.Pose = Trformpre;

cylintr = collisionCylinder(926,152.4);
Transintr = trvec2tform([Xintruder(1,parse) Xintruder(4,parse) Xintruder(7,parse)]);
cylintr.Pose = Transintr;

[areIntersecting,dist,witnessPoints] = checkCollision(cy_pre,cylintr);

if areIntersecting
    fprintf('Collision at %f seconds',d);
    break
end

plotx1(parse) = x(d);
ploty1(parse) = y(d);
plotz1(parse) = z(d);

figure(5);
plot3(plotx1,ploty1,plotz1,'-ob',Xintruder(1,:),Xintruder(4,:),Xintruder(7,:),'-or',predictionsCv(1,:),predictionsCv(3,:),predictionsCv(5,:),'-og');
xlim([x(1)-80000 x(1)+80000]);
ylim([y(1)-80000 y(1)+80000]);
zlim([z(1)-80000 z(1)+80000]);
title('Collision simulation');
legend({'Actual trajectory','Simulated Intruder trajectory','Kalman-Predicted trajectory'},'Location','southwest');
xlabel('X Position(m)');
ylabel('Y Position(m)');
zlabel('Y Position(m)');

figure(6);
[~,patchObj] = show(cy_pre);
patchObj.FaceColor = [0 1 1];
patchObj.EdgeColor = 'none';
show(cylintr);
xlim([4.015e6 4.03e6]);
ylim([-9e4 -7e4]);
zlim([4.935e6 4.945e6]);

hold on;



plotestx(parse) = predictionsCv(1,parse);
plotesty(parse) = predictionsCv(3,parse);
plotestz(parse) = predictionsCv(5,parse);
ploterr(parse) = err.vect(parse);



pause(0.25);
parse = parse+1;

   
 end


    
else

for d = 2:Ts:data_points

    if d == 2
        Xi = [0 0 0 0 0 0]';
%intialise process covariance at t = 0
        Pint = [200 0 0 0 0 0;
            0 200 0 0 0 0;
            0 0 200 0 0 0;
            0 0 0 200 0 0;
            0 0 0 0 200 0;
            0 0 0 0 0 200];
    end
        
    Xpred = FCV*Xi;
  
    predictionsCv(:,d) = Xpred
    
    
    %update covariance matrix
    P = FCV*Pint*FCV' + QCV;
    %work out kalman gain
    K = (P*HCV')/(HCV*P*HCV' + RCAV)
    
    measurement_difference = (Z(:,d) - HCV*Xpred);
    
    Xest = Xpred + K*(measurement_difference);
    
    LinDiff = eye(6) - K*HCV;
    
    Pest = LinDiff*P*LinDiff' + K*RCAV*K';
    
    Pint = Pest;
   
    Xi = Xest;
    
   estimatesCV(:,d) = Xest;
    
   err.x(d) = (x(d) - Xest(1))^2;
   err.y(d) = (y(d) - Xest(3))^2;
   err.z(d) = (z(d) - Xest(5))^2;
   
   err.vect(d) = (err.x(d) + err.y(d) + err.z(d))^0.5;
   
end
end
end

    


if Dynamodel == 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

noise = 100;
Z =[x Vx y Vy z Vz]';

FCA = [1 Ts 0.5*Ts^2 0 0 0 0 0 0;
    0 1 Ts 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 Ts 0.5*Ts^2 0 0 0;
    0 0 0 0 1 Ts 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 Ts 0.5*Ts^2;
    0 0 0 0 0 0 0 1 Ts;
    0 0 0 0 0 0 0 0 1];

% Measurement of XYZ pos XYZ velocity


HCA = [1 0 0 0 0 0 0 0 0;
    0 1 0 0 0 0 0 0 0;
    0 0 0 1 0 0 0 0 0;
    0 0 0 0 1 0 0 0 0;
    0 0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 1 0];

%Process noise matrix 
QCA = [0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0 0 0 0 0 0;
    0.5*Ts^3 Ts^2 Ts 0 0 0 0 0 0;
    0.5*Ts^2 Ts 1 0 0 0 0 0 0;
    0 0 0 0.25*Ts^4 0.5*Ts^3 0.5*Ts^2 0 0 0;
    0 0 0 0.5*Ts^3 Ts^2 Ts 0 0 0;
    0 0 0 0.5*Ts^2 Ts 1 0 0 0;
    0 0 0 0 0 0 0.25*Ts^4 0.5*Ts^3 0.5*Ts^2;
    0 0 0 0 0 0 0.5*Ts^3 Ts^2 Ts;
    0 0 0 0 0 0 0.5*Ts^2 Ts 1].*noise^2;


    R = [uncert(1).varx^2 0 0 0 0 0;
    0 uncert(1).varvx^2 0 0 0 0 ;
    0 0 uncert(1).vary^2 0 0 0 ;
    0 0 0 uncert(1).varvy^2 0 0 ;
    0 0 0 0 uncert(1).varz^2 0 ;
    0 0 0 0 0 uncert(1).varvz^2]; 

if Col
    
initial_pos = [x(1) y(1) z(1)];
intitial_vel = [Vx(1) Vy(1) Vz(1)];
% intruder_position = initial_pos + [20000 20000 -2000];
intruder_position = initial_pos +[5000 0 0];
opposing_heading = -mod(360-(heading(1)),360)-90;
plotx = [];
ploty = [];
plotz = [];


Vxop = mean(speed)*sin(opposing_heading*(pi./180));
Vyop = mean(speed)*cos(opposing_heading*(pi./180));
% Vzop = Vz(1);
Vzop = -mean(Vz);

Xii = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

parse = 1;

for d = 2:Ts:data_points
    
    Fi = [1 d 0.5*d^2 0 0 0 0 0 0;
    0 1 d 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 d 0.5*d^2 0 0 0;
    0 0 0 0 1 d 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 d 0.5*d^2
    0 0 0 0 0 0 0 1 d;
    0 0 0 0 0 0 0 0 1];

    if d == 2
        
    
    Xi = [Z(1,1) Z(2,1) 0 Z(3,1) Z(4,1) 0 Z(5,1) Z(6,1) 0]'; 
%intialise process covariance at t = 0
        Pint = [200 0 0 0 0 0 0 0 0;
            0 200 0 0 0 0 0 0 0;
            0 0 200 0 0 0 0 0 0;
            0 0 0 200 0 0 0 0 0;
            0 0 0 0 200 0 0 0 0;
            0 0 0 0 0 200 0 0 0;
            0 0 0 0 0 0 200 0 0;
            0 0 0 0 0 0 0 200 0;
            0 0 0 0 0 0 0 0 200];
        
        Xintruder(:,parse) = Xii;
    end
    
    Xintruder(:,parse) = Fi*Xii;
    Xpred = FCA*Xi;
    predictions(:,parse) = Xpred;
    
    
    %update covariance matrix
    P = FCA*Pint*FCA' + QCA;
    %work out kalman gain
    K = (P*HCA')/(HCA*P*HCA' + R);
    
   
    
    measurement_difference = (Z(:,d) - HCA*Xpred);
    
    Xest = Xpred + K*(measurement_difference);
    
    LinDiff = eye(9) - K*HCA;
    
    Pest = LinDiff*P*LinDiff' + K*R*K';
    
    Pint = Pest;
   
    Xi = Xest;
    
    
   err.x(d) = (x(d) - Xest(1))^2;
   err.y(d) = (y(d) - Xest(4))^2;
   err.z(d) = (z(d) - Xest(7))^2;
   
   err.vect(d) = (err.x(d) + err.y(d) + err.z(d))^0.5;
   
   
cy_pre = collisionCylinder(926,152.4);
Trformpre = trvec2tform([predictions(1,parse) predictions(4,parse) predictions(7,parse)]);
cy_pre.Pose = Trformpre;

cylintr = collisionCylinder(926,152.4);
Transintr = trvec2tform([Xintruder(1,parse) Xintruder(4,parse) Xintruder(7,parse)]);
cylintr.Pose = Transintr;

[areIntersecting,dist,witnessPoints] = checkCollision(cy_pre,cylintr);

if areIntersecting
    fprintf('Collision at %f seconds',d);
    break
end

plotx1(parse) = x(d);
ploty1(parse) = y(d);
plotz1(parse) = z(d);

figure(5);
plot3(plotx1,ploty1,plotz1,'-ob',Xintruder(1,:),Xintruder(4,:),Xintruder(7,:),'-or',predictions(1,:),predictions(4,:),predictions(7,:),'-og');
xlim([x(1)-80000 x(1)+80000]);
ylim([y(1)-80000 y(1)+80000]);
zlim([z(1)-80000 z(1)+80000]);
grid('on');
title('Collision simulation');
legend({'Actual trajectory','Simulated Intruder trajectory','Kalman-Predicted trajectory'},'Location','southwest');
xlabel('X Position(m)');
ylabel('Y Position(m)');
zlabel('Z Position(m)');

figure(6);
[~,patchObj] = show(cy_pre);
patchObj.FaceColor = [0 1 1];
patchObj.EdgeColor = 'none';
show(cylintr);
xlim([4.015e6 4.03e6]);
ylim([-9e4 -7e4]);
zlim([4.935e6 4.945e6]);
hold on;



plotestx(parse) = predictions(1,parse);
plotesty(parse) = predictions(4,parse);
plotestz(parse) = predictions(7,parse);
ploterr(parse) = err.vect(parse);



pause(0.25);
parse = parse+1;
end


else
    
    for d = 2:Ts:data_points

    if d == 2
        Xi = [0 0 0 0 0 0 0 0 0]';
%intialise process covariance at t = 0
        Pint = [200 0 0 0 0 0 0 0 0;
            0 200 0 0 0 0 0 0 0;
            0 0 200 0 0 0 0 0 0;
            0 0 0 200 0 0 0 0 0;
            0 0 0 0 200 0 0 0 0;
            0 0 0 0 0 200 0 0 0;
            0 0 0 0 0 0 200 0 0;
            0 0 0 0 0 0 0 200 0;
            0 0 0 0 0 0 0 0 200];


    
    end
    Xpred = F*Xi;
    predictions(:,d) = Xpred
    
    
    %update covariance matrix
    P = F*Pint*F' + Q;
    %work out kalman gain
    K = (P*H')/(H*P*H' + R)
    
   
    
    measurement_difference = (Z(:,d) - H*Xpred);
    
    Xest = Xpred + K*(measurement_difference);
    
    LinDiff = eye(9) - K*H;
    
    Pest = LinDiff*P*LinDiff' + K*R*K';
    
   err.x(d) = (x(d) - Xest(1))^2;
   err.y(d) = (y(d) - Xest(4))^2;
   err.z(d) = (z(d) - Xest(7))^2;
   
   err.vect(d) = (err.x(d) + err.y(d) + err.z(d))^0.5;
end
    
end
end


if Dynamodel ==3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CT%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tsteps = 0:Ts:data_points;
Z = [x y z Vx Vy Vz]';
Turnnoise1 = 220;
acc_noise = 100;
Velnoise = 100;
FCV = [1 0 0 Ts 0 0;
       0 1 0 0 Ts 0;
       0 0 1 0 0 Ts;
       0 0 0 1 0 0;
       0 0 0 0 1 0;
       0 0 0 0 0 1];
        


FCA = [1 0 0 Ts 0 0 (Ts^2)/2 0 0;
       0 1 0 0 Ts 0 0 (Ts^2)/2 0;
       0 0 1 0 0 Ts 0 0 (Ts^2)/2;
       0 0 0 1 0 0 Ts 0 0;
       0 0 0 0 1 0 0 Ts 0;
       0 0 0 0 0 1 0 0 Ts;
       0 0 0 0 0 0 1 0 0;
       0 0 0 0 0 0 0 1 0;
       
       0 0 0 0 0 0 0 0 1];
FCint = [1 Ts 0.5*Ts^2 0 0 0 0 0 0;
    0 1 Ts 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 Ts 0.5*Ts^2 0 0 0;
    0 0 0 0 1 Ts 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 Ts 0.5*Ts^2;
    0 0 0 0 0 0 0 1 Ts;
    0 0 0 0 0 0 0 0 1];
   
   
w1 = 1;

w2 = 1;
FCT1 = [1, 0, 0, sind(w1*Ts)/w1, 0, 0, (1 - cosd(w1*Ts))/(w1^2), 0, 0, 0;
    0, 1, 0, 0, sind(w1*Ts)/w1, 0, 0, (1 - cosd(w1*Ts))/(w1^2), 0, 0;
    0, 0, 1, 0, 0, sind(w1*Ts)/w1, 0, 0, (1 - cosd(w1*Ts))/(w1^2), 0;
    0, 0, 0, cosd(w1*Ts), 0, 0, sind(w1*Ts)/w1, 0, 0, 0;
    0, 0, 0, 0, cosd(w1*Ts), 0, 0, sind(w1*Ts)/w1, 0, 0;
    0, 0, 0, 0, 0, cosd(w1*Ts), 0, 0, sind(w1*Ts)/w1, 0;
    0, 0, 0, -sind(w1*Ts)*w1, 0, 0, cosd(w1*Ts), 0, 0, 0;
    0, 0, 0, 0, -sind(w1*Ts)*w1, 0, 0, cosd(w1*Ts), 0, 0;
    0, 0, 0, 0, 0, -sind(w1*Ts)*w1, 0, 0, cosd(w1*Ts), 0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1];  
    
FCT2 = [1, 0, 0, sind(w2*Ts)/w2, 0, 0, (1 - cosd(w2*Ts))/(w2^2), 0, 0, 0;
    0, 1, 0, 0, sind(w2*Ts)/w2, 0, 0, (1 - cosd(w2*Ts))/(w2^2), 0, 0;
    0, 0, 1, 0, 0, sind(w2*Ts)/w2, 0, 0, (1 - cosd(w2*Ts))/(w2^2), 0;
    0, 0, 0, cosd(w2*Ts), 0, 0, sind(w2*Ts)/w2, 0, 0, 0;
    0, 0, 0, 0, cosd(w2*Ts), 0, 0, sind(w2*Ts)/w2, 0, 0;
    0, 0, 0, 0, 0, cosd(w2*Ts), 0, 0, sind(w2*Ts)/w2, 0;
    0, 0, 0, -sind(w2*Ts)*w2, 0, 0, cosd(w2*Ts), 0, 0, 0;
    0, 0, 0, 0, -sind(w2*Ts)*w2, 0, 0, cosd(w2*Ts), 0, 0;
    0, 0, 0, 0, 0, -sind(w2*Ts)*w2, 0, 0, cosd(w2*Ts), 0
    0, 0, 0, 0, 0, 0, 0, 0, 0, 1];  
   

      
HCA = [1 0 0 0 0 0 0 0 0;
       0 1 0 0 0 0 0 0 0;
       0 0 1 0 0 0 0 0 0;
       0 0 0 1 0 0 0 0 0;
       0 0 0 0 1 0 0 0 0;
       0 0 0 0 0 1 0 0 0];


HCV = eye(6);

HCT = [1 0 0 0 0 0 0 0 0 0;
       0 1 0 0 0 0 0 0 0 0;
       0 0 1 0 0 0 0 0 0 0;
       0 0 0 1 0 0 0 0 0 0;
       0 0 0 0 1 0 0 0 0 0;
       0 0 0 0 0 1 0 0 0 0];



QCA = [eye(3,3)*Ts^4/4, eye(3,3)*Ts^3/2, eye(3,3)*Ts^2/2;
    eye(3,3)*Ts^3/2, eye(3,3)*Ts^2, eye(3,3)*Ts;
    eye(3,3)*Ts^2/2, eye(3,3)*Ts, eye(3,3)]*acc_noise^2;

QCV = [(Ts^4)/4 0 0 ((Ts^3)/2) 0 0;
        0 (Ts^4)/4 0 0 (Ts^3)/2 0;
        0 0 (Ts^4)/4 0 0 (Ts^3)/2;
        (Ts^3)/2 0 0 Ts^2 0 0;
        0 (Ts^3)/2 0 0 Ts^2 0;
        0 0 (Ts^3)/2 0 0 Ts^2]*Velnoise^2;
    
QCT = [(Ts^4)/4 0 0 ((Ts^3)/2) 0 0 0;
    0 (Ts^4)/4 0 0 (Ts^3)/2 0 0;
    0 0 (Ts^4)/4 0 0 (Ts^3)/2 0;
    (Ts^3)/2 0 0 Ts^2 0 0 0;
    0 (Ts^3)/2 0 0 Ts^2 0 0;
    0 0 (Ts^3)/2 0 0 Ts^2 0
    0 0 0 0 0 0 Ts^2] *Turnnoise1^2;

QCT  = [(Ts^4)/4 0 0 Ts^3/2 0 0 Ts^2/2 0 0 0;
         0 (Ts^4)/4 0 0 Ts^3/2 0 0 Ts^2/2 0 0;
         0 0 (Ts^4)/4 0 0 Ts^3/2 0 0 Ts^2/2 0;
         Ts^3/2 0 0 Ts^2 0 0 Ts 0 0 0;
         0 Ts^3/2 0 0 Ts^2 0 0 Ts 0 0;
         0 0 Ts^3/2 0 0 Ts^2 0 0 Ts 0;
         Ts^2/2 0 0 Ts 0 0 1 0 0 0;
         0 Ts^2/2 0 0 Ts 0 0 1 0 0;
         0 0 Ts^2/2 0 0 Ts 0 0 1 0;
         0 0 0 0 0 0 0 0 0 1]*Turnnoise1^2;
   

       
R = [uncert(1).varx^2 0 0 0 0 0;
    0 uncert(1).vary^2 0 0 0 0;
    0 0 uncert(1).varz^2 0 0 0;
    0 0 0 uncert(1).varvx^2 0 0;
    0 0 0 0 uncert(1).varvy^2 0;
    0 0 0 0 0 uncert(1).varvz^2]; 

x4_pro_IMM = zeros(6,length(tsteps));

% x4_pro_IMM(:,1) = [Z(:,1)];

uIMM = zeros(4,length(tsteps));

uIMM(:,1)  = [0.25 0.25 0.25 0.25]';

% XCV = [Z(:,1)];
% 
% XCA = [Z(:,1);0;0;0];

XCV = zeros(6,1);

XCA = zeros(9,1);

XCT1 = zeros(10,1);

XCT2 = zeros(10,1);

PCV = [200 0 0 0 0 0;
    0 200 0 0 0 0;
    0 0 200 0 0 0;
    0 0 0 200 0 0;
    0 0 0 0 200 0;
    0 0 0 0 0 200];
       
PCA = [200 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 200];

PCT1 = [200 0 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0 0;
    0 0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 0 200];

PCT2 = [200 0 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0 0;
    0 0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 0 200];



PIMM = zeros(9,9);


Hij4 =      [0.6 0.2 0.1 0.1;
            0.1 0.7 0.1 0.1;
            0.1 0.2 0.45 0.25;
            0.1 0.2 0.25 0.45]; %inital mixing matrix 
        
jump = length(tsteps);


if Col
    
initial_pos = [x(1) y(1) z(1)];
intitial_vel = [Vx(1) Vy(1) Vz(1)];
% intruder_position = initial_pos + [20000 20000 -1000];
% opposing_heading = 360 - heading(1);
opposing_heading = -mod(360-(heading(1)),360)-90;
intruder_position = initial_pos +[5000 0 0];
plotx = [];
ploty = [];
plotz = [];

Vxop = mean(speed)*sin(opposing_heading*(pi./180));
Vyop = mean(speed)*cos(opposing_heading*(pi./180));
% Vzop = Vz(1)
Vzop = -mean(Vz);

Xii = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

parse = 1;

for k = 2:jump
    if parse == 1
        Xintruder(:,parse) = Xii;
    else
    Xintruder(:,parse) = FCint*Xintruder(:,parse-1);   
    end
    C_4 = Hij4'*uIMM(:,k-1);
   
    X4_CV = (Hij4(1,1)*uIMM(1,k-1)*XCV(1:6,1) + Hij4(2,1)*uIMM(2,k-1)*XCA(1:6,1) +...
        Hij4(3,1)*uIMM(3,k-1)*XCT1(1:6,1)+ Hij4(4,1)*uIMM(4,k-1)*XCT2(1:6,1)) /C_4(1);
    
    X4_CA = (Hij4(1,2)*uIMM(1,k-1)*[XCV;0;0;0] + Hij4(2,2)*uIMM(2,k-1)*XCA +...
    Hij4(3,2)*uIMM(3,k-1)*[XCT1(1:6);0;0;0] + Hij4(4,2)*uIMM(4,k-1)*[XCT2(1:6);0;0;0]) /C_4(2);

    X4_CT1 = (Hij4(1,3)*uIMM(1,k-1)*[XCV;0;0;0;0] + Hij4(2,3)*uIMM(2,k-1)*[XCA(1:6,1);0;0;0;0] +...
    Hij4(3,3)*uIMM(3,k-1)*XCT1 + Hij4(4,3)*uIMM(4,k-1)*XCT2)/C_4(3);

    X4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*[XCV;0;0;0;0] + Hij4(2,4)*uIMM(2,k-1)*[XCA(1:6,1);0;0;0;0] +...
    Hij4(3,4)*uIMM(3,k-1)*XCT1 + Hij4(4,4)*uIMM(4,k-1)*XCT2)/C_4(4);
    
    
    P4_CV = (Hij4(1,1)*uIMM(1,k-1)*(PCV +(X4_CV - XCV)*((X4_CV - XCV)'))...
        + Hij4(2,1)*uIMM(2,k-1)*(PCA(1:6,1:6)+(X4_CA(1:6) - XCV)*((X4_CA(1:6) - XCV)'))...
        + Hij4(3,1)*uIMM(3,k-1)*(PCT1(1:6,1:6) +(X4_CT1(1:6) - XCV)*((X4_CT1(1:6) - XCV)'))...
        + Hij4(4,1)*uIMM(4,k-1)*(PCT2(1:6,1:6) +(X4_CT2(1:6) - XCV)*((X4_CT2(1:6) - XCV)')))/C_4(1);
   
    P4_CA = (Hij4(1,2)*uIMM(1,k-1)*([PCV,zeros(6,3);zeros(3,9)]+([X4_CV;0;0;0] - XCA) * (([X4_CV;0;0;0] - XCA)'))...
        + Hij4(2,2)*uIMM(2,k-1)*(PCA + (X4_CA - XCA)*((X4_CA - XCA)'))...
        + Hij4(3,2)*uIMM(3,k-1)*((PCT1(1:9,1:9)+(X4_CT1(1:9) - XCA) * (X4_CT1(1:9) - XCA)')...
        + Hij4(4,2)*uIMM(4,k-1)*((PCT2(1:9,1:9)+(X4_CT2(1:9) - XCA) * (X4_CT2(1:9) - XCA)'))))/C_4(2);
    
    P4_CT1 = (Hij4(1,3)*uIMM(1,k-1)*([PCV,zeros(6,4);zeros(4,10)] +([X4_CV;0;0;0;0] - XCT1) *(([X4_CV;0;0;0;0] - XCT1)'))...
        + Hij4(2,3)*uIMM(2,k-1)*([PCA(1:6,1:6),zeros(6,4);zeros(4,10)] +([X4_CA(1:6);0;0;0;0] - XCT1) *(([X4_CA(1:6);0;0;0;0] - XCT1)'))...
        + Hij4(3,3)*uIMM(3,k-1)*(PCT1 +(X4_CT1 - XCT1) * ((X4_CT1 - XCT1)'))...
        + Hij4(4,3)*uIMM(4,k-1)*(PCT2 +(X4_CT2 - XCT1) * ((X4_CT2 - XCT1)')))/C_4(3);
    
    P4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*([PCV,zeros(6,4);zeros(4,10)] +([X4_CV;0;0;0;0] - XCT2) *(([X4_CV;0;0;0;0] - XCT2)'))...
        + Hij4(2,4)*uIMM(2,k-1)*([PCA(1:6,1:6),zeros(6,4);zeros(4,10)] +([X4_CA(1:6);0;0;0;0] - XCT2) *(([X4_CA(1:6);0;0;0;0] - XCT2)'))...
        + Hij4(3,4)*uIMM(3,k-1)*(PCT1 +(X4_CT1 - XCT2) * ((X4_CT1 - XCT2)'))...
        + Hij4(4,4)*uIMM(4,k-1)*(PCT2 +(X4_CT2 - XCT2) * ((X4_CT2 - XCT2)')))/C_4(4);

    
%     P4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*(PCV * (X4_CV - XCV) + ((X4_CV - XCV)'))...
%     + Hij4(2,4)*uIMM(2,k-1)*(PCA * (X4_CA - XCA) + ((X4_CA - XCA)'))...
%     + Hij4(3,4)*uIMM(3,k-1)*(PCT1 * (X4_CT1 - XCT1) + ((X4_CT1 - XCT1)'))...
%     + Hij4(4,4)*uIMM(4,k-1)*(PCT2 * (X4_CT2 - XCT2) + ((X4_CT2 - XCT2)')))/C_4(4);

%filter cycles

    XCVpred = FCV*X4_CV;
    
    XCApred = FCA*X4_CA;
    
    XCT1pred = FCT1*X4_CT1;
    
    XCT2pred = FCT2*X4_CT2;
    
    
    PCV = FCV*P4_CV*FCV' + QCV;
    %work out kalman gain
    
    SCV = HCV*PCV*HCV' + R; %s1
    
    KCV = (PCV*HCV')/(SCV);
    
    DiffCV = (Z(:,tsteps(k)) - HCV*XCVpred); %r1
    
    XCV = XCVpred + KCV*(DiffCV);
    
    LindiffCV = eye(6) - KCV*HCV;
    
    PCV = LindiffCV*PCV*LindiffCV' + KCV*R*KCV';
    
    
    
    PCA = FCA*P4_CA*FCA' + QCA;
    %work out kalman gain
    
    SCA = HCA*PCA*HCA' + R;
    
    KCA = (PCA*HCA')/(SCA);
    
    DiffCA = (Z(:,tsteps(k)) - HCA*XCApred);
    
    XCA = XCApred +KCA*(DiffCA);
    
    LindiffCA = eye(9) - KCA*HCA;
    
    PCA = LindiffCA*PCA*LindiffCA' + KCA*R*KCA';
    
   
    
    
    PCT1 = FCT1*P4_CT1*FCT1' + QCT;
    %work out kalman gain
    
    SCT1 = HCT*PCT1*HCT' + R;
    
    KCT1 = (PCT1*HCT')/(SCT1);
    
    DiffCT1 = (Z(:,tsteps(k)) - HCT*XCT1pred);
    
    XCT1 = XCT1pred +KCT1*(DiffCT1);
    
    LindiffCT1 = eye(10) - KCT1*HCT;
    
    PCT1 = LindiffCT1*PCT1*LindiffCT1' + KCT1*R*KCT1';
    
    
    PCT2 = FCT2*P4_CT1*FCT2' + QCT;
    %work out kalman gain
    
    SCT2 = HCT*PCT2*HCT' + R;
    
    KCT2 = (PCT2*HCT')/(SCT2);
    
    DiffCT2 = (Z(:,tsteps(k)) - HCT*XCT2pred);
    
    XCT2 = XCT2pred +KCT2*(DiffCT1);
    
    LindiffCT2 = eye(10) - KCT2*HCT;
    
    PCT2 = LindiffCT2*PCT2*LindiffCT2' + KCT1*R*KCT2';
    
    
    
    uIMM(:,k) = Model_Likelihood_Updt(DiffCV,DiffCA,DiffCT1,DiffCT2,SCV,SCA,SCT1,SCT2,C_4);
    
    [x4_pro_IMM(:,k),P4] = Model_mix(uIMM,XCV,XCA(1:6,1),XCT1(1:6,1),XCT2(1:6,1),PCV,PCA(1:6, 1:6),PCT1(1:6, 1:6),PCT2(1:6, 1:6));
    
    error(1,k-1) = (x4_pro_IMM(1,k) - x(k-1))^2;
    error(2,k-1) = (x4_pro_IMM(2,k) - y(k-1))^2;
    error(3,k-1) = (x4_pro_IMM(3,k) - z(k-1))^2;
    error(4,k-1) = error(1,k-1)+error(2,k-1)+error(3,k-1);
%     RMSE(1,k-1) = sqrt((sum(error(1,k-1),error(2,k-1),error(3,k-1))));
    RMSE(1,k-1) = sqrt((1/jump*error(4,k-1)));
    
    
    cy_pre = collisionCylinder(926/2,152.4);
    Trformpre = trvec2tform([x4_pro_IMM(1,k),x4_pro_IMM(2,k),x4_pro_IMM(3,k)]);
    cy_pre.Pose = Trformpre;

    cylintr = collisionCylinder(926/2,152.4);
    Transintr = trvec2tform([Xintruder(1,parse) Xintruder(4,parse) Xintruder(7,parse)]);
    cylintr.Pose = Transintr;

    [areIntersecting,dist,witnessPoints] = checkCollision(cy_pre,cylintr);
    
    

if areIntersecting
    fprintf('Collision at %f seconds',tsteps(k));
    break
end



plotx1(parse) = x(tsteps(k));
ploty1(parse) = y(tsteps(k));
plotz1(parse) = z(tsteps(k));
parse = parse + 1; 


figure(5);
plot3(plotx1,ploty1,plotz1,'-ob',Xintruder(1,:),Xintruder(4,:),Xintruder(7,:),'-or',x4_pro_IMM(1,:),x4_pro_IMM(2,:),x4_pro_IMM(3,:),'-og');
xlim([x(1)-80000 x(1)+80000]);
ylim([y(1)-80000 y(1)+80000]);
zlim([z(1)-80000 z(1)+80000]);
title('Collision simulation');
legend({'Actual trajectory','Simulated Intruder trajectory','Kalman-Predicted trajectory'},'Location','southwest');
xlabel('X Position(m)');
ylabel('Y Position(m)');
zlabel('Z Position(m)');


figure(6);
[~,patchObj] = show(cy_pre);
patchObj.FaceColor = [0 1 1];
patchObj.EdgeColor = 'none';
show(cylintr);
xlim([4.015e6 4.03e6]);
ylim([-9e4 -7e4]);
zlim([4.935e6 4.945e6]);
hold on;

end
else
    
        initial_pos = [x(1) y(1) z(1)];
        intitial_vel = [Vx(1) Vy(1) Vz(1)];
        intruder_position = initial_pos + [20000 20000 -1000];
        opposing_heading = 360 - heading(1);
        plotx = [];
        ploty = [];
        plotz = [];

        Vxop = mean(speed)*sin(opposing_heading*(pi./180));
        Vyop = mean(speed)*cos(opposing_heading*(pi./180));
        Vzop = Vz(1);

        Xii = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

        parse = 1;

        for k = 2:jump
           

            C_4 = Hij4'*uIMM(:,k-1);

            X4_CV = (Hij4(1,1)*uIMM(1,k-1)*XCV(1:6,1) + Hij4(2,1)*uIMM(2,k-1)*XCA(1:6,1) +...
                Hij4(3,1)*uIMM(3,k-1)*XCT1(1:6,1)+ Hij4(4,1)*uIMM(4,k-1)*XCT2(1:6,1)) /C_4(1);

            X4_CA = (Hij4(1,2)*uIMM(1,k-1)*[XCV;0;0;0] + Hij4(2,2)*uIMM(2,k-1)*XCA +...
            Hij4(3,2)*uIMM(3,k-1)*[XCT1(1:6);0;0;0] + Hij4(4,2)*uIMM(4,k-1)*[XCT2(1:6);0;0;0]) /C_4(2);

            X4_CT1 = (Hij4(1,3)*uIMM(1,k-1)*[XCV;0;0;0;0] + Hij4(2,3)*uIMM(2,k-1)*[XCA(1:6,1);0;0;0;0] +...
            Hij4(3,3)*uIMM(3,k-1)*XCT1 + Hij4(4,3)*uIMM(4,k-1)*XCT2)/C_4(3);

            X4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*[XCV;0;0;0;0] + Hij4(2,4)*uIMM(2,k-1)*[XCA(1:6,1);0;0;0;0] +...
            Hij4(3,4)*uIMM(3,k-1)*XCT1 + Hij4(4,4)*uIMM(4,k-1)*XCT2)/C_4(4);


            P4_CV = (Hij4(1,1)*uIMM(1,k-1)*(PCV +(X4_CV - XCV)*((X4_CV - XCV)'))...
                + Hij4(2,1)*uIMM(2,k-1)*(PCA(1:6,1:6)+(X4_CA(1:6) - XCV)*((X4_CA(1:6) - XCV)'))...
                + Hij4(3,1)*uIMM(3,k-1)*(PCT1(1:6,1:6) +(X4_CT1(1:6) - XCV)*((X4_CT1(1:6) - XCV)'))...
                + Hij4(4,1)*uIMM(4,k-1)*(PCT2(1:6,1:6) +(X4_CT2(1:6) - XCV)*((X4_CT2(1:6) - XCV)')))/C_4(1);

            P4_CA = (Hij4(1,2)*uIMM(1,k-1)*([PCV,zeros(6,3);zeros(3,9)]+([X4_CV;0;0;0] - XCA) * (([X4_CV;0;0;0] - XCA)'))...
                + Hij4(2,2)*uIMM(2,k-1)*(PCA + (X4_CA - XCA)*((X4_CA - XCA)'))...
                + Hij4(3,2)*uIMM(3,k-1)*((PCT1(1:9,1:9)+(X4_CT1(1:9) - XCA) * (X4_CT1(1:9) - XCA)')...
                + Hij4(4,2)*uIMM(4,k-1)*((PCT2(1:9,1:9)+(X4_CT2(1:9) - XCA) * (X4_CT2(1:9) - XCA)'))))/C_4(2);

            P4_CT1 = (Hij4(1,3)*uIMM(1,k-1)*([PCV,zeros(6,4);zeros(4,10)] +([X4_CV;0;0;0;0] - XCT1) *(([X4_CV;0;0;0;0] - XCT1)'))...
                + Hij4(2,3)*uIMM(2,k-1)*([PCA(1:6,1:6),zeros(6,4);zeros(4,10)] +([X4_CA(1:6);0;0;0;0] - XCT1) *(([X4_CA(1:6);0;0;0;0] - XCT1)'))...
                + Hij4(3,3)*uIMM(3,k-1)*(PCT1 +(X4_CT1 - XCT1) * ((X4_CT1 - XCT1)'))...
                + Hij4(4,3)*uIMM(4,k-1)*(PCT2 +(X4_CT2 - XCT1) * ((X4_CT2 - XCT1)')))/C_4(3);

            P4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*([PCV,zeros(6,4);zeros(4,10)] +([X4_CV;0;0;0;0] - XCT2) *(([X4_CV;0;0;0;0] - XCT2)'))...
                + Hij4(2,4)*uIMM(2,k-1)*([PCA(1:6,1:6),zeros(6,4);zeros(4,10)] +([X4_CA(1:6);0;0;0;0] - XCT2) *(([X4_CA(1:6);0;0;0;0] - XCT2)'))...
                + Hij4(3,4)*uIMM(3,k-1)*(PCT1 +(X4_CT1 - XCT2) * ((X4_CT1 - XCT2)'))...
                + Hij4(4,4)*uIMM(4,k-1)*(PCT2 +(X4_CT2 - XCT2) * ((X4_CT2 - XCT2)')))/C_4(4);


        %     P4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*(PCV * (X4_CV - XCV) + ((X4_CV - XCV)'))...
        %     + Hij4(2,4)*uIMM(2,k-1)*(PCA * (X4_CA - XCA) + ((X4_CA - XCA)'))...
        %     + Hij4(3,4)*uIMM(3,k-1)*(PCT1 * (X4_CT1 - XCT1) + ((X4_CT1 - XCT1)'))...
        %     + Hij4(4,4)*uIMM(4,k-1)*(PCT2 * (X4_CT2 - XCT2) + ((X4_CT2 - XCT2)')))/C_4(4);

        %filter cycles

            XCVpred = FCV*X4_CV;

            XCApred = FCA*X4_CA;

            XCT1pred = FCT1*X4_CT1;

            XCT2pred = FCT2*X4_CT2;


            PCV = FCV*P4_CV*FCV' + QCV;
            %work out kalman gain

            SCV = HCV*PCV*HCV' + R;

            KCV = (PCV*HCV')/(SCV);

            DiffCV = (Z(:,tsteps(k)) - HCV*XCVpred); %r1

            XCV = XCVpred + KCV*(DiffCV);

            LindiffCV = eye(6) - KCV*HCV;

            PCV = LindiffCV*PCV*LindiffCV' + KCV*R*KCV';



            PCA = FCA*P4_CA*FCA' + QCA;
            %work out kalman gain

            SCA = HCA*PCA*HCA' + R;

            KCA = (PCA*HCA')/(SCA);

            DiffCA = (Z(:,tsteps(k)) - HCA*XCApred);

            XCA = XCApred +KCA*(DiffCA);

            LindiffCA = eye(9) - KCA*HCA;

            PCA = LindiffCA*PCA*LindiffCA' + KCA*R*KCA';




            PCT1 = FCT1*P4_CT1*FCT1' + QCT;
            %work out kalman gain

            SCT1 = HCT*PCT1*HCT' + R;

            KCT1 = (PCT1*HCT')/(SCT1);

            DiffCT1 = (Z(:,tsteps(k)) - HCT*XCT1pred);

            XCT1 = XCT1pred +KCT1*(DiffCT1);

            LindiffCT1 = eye(10) - KCT1*HCT;

            PCT1 = LindiffCT1*PCT1*LindiffCT1' + KCT1*R*KCT1';


            PCT2 = FCT2*P4_CT1*FCT2' + QCT;
            %work out kalman gain

            SCT2 = HCT*PCT2*HCT' + R;

            KCT2 = (PCT2*HCT')/(SCT2);

            DiffCT2 = (Z(:,tsteps(k)) - HCT*XCT2pred);

            XCT2 = XCT2pred +KCT2*(DiffCT1);

            LindiffCT2 = eye(10) - KCT2*HCT;

            PCT2 = LindiffCT2*PCT2*LindiffCT2' + KCT1*R*KCT2';



            uIMM(:,k) = Model_Likelihood_Updt(DiffCV,DiffCA,DiffCT1,DiffCT2,SCV,SCA,SCT1,SCT2,C_4);

            [x4_pro_IMM(:,k),P4] = Model_mix(uIMM,XCV,XCA(1:6,1),XCT1(1:6,1),XCT2(1:6,1),PCV,PCA(1:6, 1:6),PCT1(1:6, 1:6),PCT2(1:6, 1:6));

            error(1,k-1) = (x4_pro_IMM(1,k) - x(k-1))^2;
            error(2,k-1) = (x4_pro_IMM(2,k) - y(k-1))^2;
            error(3,k-1) = (x4_pro_IMM(3,k) - z(k-1))^2;
            error(4,k-1) = error(1,k-1)+error(2,k-1)+error(3,k-1);
        %     RMSE(1,k-1) = sqrt((sum(error(1,k-1),error(2,k-1),error(3,k-1))));
            RMSE(1,k-1) = sqrt((1/jump*error(4,k-1)));


        end
    end
end



if Dynamodel == 4 
    
    Z = [x y z Vx Vy Vz]';
    acc_noise = 100;
    Velnoise = 100;

    FCV = [1 0 0 Ts 0 0;
           0 1 0 0 Ts 0;
           0 0 1 0 0 Ts;
           0 0 0 1 0 0;
           0 0 0 0 1 0;
           0 0 0 0 0 1];
       
    FCA = [1 0 0 Ts 0 0 (Ts^2)/2 0 0;
       0 1 0 0 Ts 0 0 (Ts^2)/2 0;
       0 0 1 0 0 Ts 0 0 (Ts^2)/2;
       0 0 0 1 0 0 Ts 0 0;
       0 0 0 0 1 0 0 Ts 0;
       0 0 0 0 0 1 0 0 Ts;
       0 0 0 0 0 0 1 0 0;
       0 0 0 0 0 0 0 1 0;
       0 0 0 0 0 0 0 0 1];
   
   
   FCint = [1 Ts 0.5*Ts^2 0 0 0 0 0 0;
    0 1 Ts 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 Ts 0.5*Ts^2 0 0 0;
    0 0 0 0 1 Ts 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 Ts 0.5*Ts^2;
    0 0 0 0 0 0 0 1 Ts;
    0 0 0 0 0 0 0 0 1];
   

      
    HCA = [1 0 0 0 0 0 0 0 0;
           0 1 0 0 0 0 0 0 0;
           0 0 1 0 0 0 0 0 0;
           0 0 0 1 0 0 0 0 0;
           0 0 0 0 1 0 0 0 0;
           0 0 0 0 0 1 0 0 0];
       
       
    HCV = eye(6);



    QCA = [eye(3,3)*Ts^4/4, eye(3,3)*Ts^3/2, eye(3,3)*Ts^2/2;
        eye(3,3)*Ts^3/2, eye(3,3)*Ts^2, eye(3,3)*Ts;
        eye(3,3)*Ts^2/2, eye(3,3)*Ts, eye(3,3)]*acc_noise^2;

    QCV = [(Ts^4)/4 0 0 ((Ts^3)/2) 0 0;
            0 (Ts^4)/4 0 0 (Ts^3)/2 0;
            0 0 (Ts^4)/4 0 0 (Ts^3)/2;
            (Ts^3)/2 0 0 Ts^2 0 0;
            0 (Ts^3)/2 0 0 Ts^2 0;
            0 0 (Ts^3)/2 0 0 Ts^2]*Velnoise^2;


    R = [uncert(1).varx^2 0 0 0 0 0;
        0 uncert(1).vary^2 0 0 0 0;
        0 0 uncert(1).varz^2 0 0 0;
        0 0 0 uncert(1).varvx^2 0 0;
        0 0 0 0 uncert(1).varvy^2 0;
        0 0 0 0 0 uncert(1).varvz^2]; 
    
    
    
    tsteps = 0:Ts:data_points;




uIMM = zeros(2,length(tsteps));



uIMM(:,1)  = [0.5 0.5]';

XCV = Z(:,1);

XCA = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0 0 0]' ;



PCV = [200 0 0 0 0 0;
    0 200 0 0 0 0;
    0 0 200 0 0 0;
    0 0 0 200 0 0;
    0 0 0 0 200 0;
    0 0 0 0 0 200];
       
PCA = [200 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 200];


PIMM = zeros(9,9);

Hij4 =      [0.6 0.4;
             0.2 0.8]; %inital mixing matrix 
         
         

         
      
jump = length(tsteps);


if Col
    
initial_pos = [x(1) y(1) z(1)];
intitial_vel = [Vx(1) Vy(1) Vz(1)];
% intruder_position = initial_pos + [20000 20000 -1000];
% opposing_heading = 360 - heading(1);
opposing_heading = -mod(360-(heading(1)),360)-90;
intruder_position = initial_pos +[5000 0 0];
plotx = [];
ploty = [];
plotz = [];

Vxop = mean(speed)*sin(opposing_heading*(pi./180));
Vyop = mean(speed)*cos(opposing_heading*(pi./180));
% Vzop = Vz(1)
Vzop = -mean(Vz);

Xii = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

parse = 1;


x4_pro_IMM(:,1) = [Z(:,1)];
x4_predict(:,1) = [Z(:,1)];

for k = 2:jump
    if parse == 1
     Xintruder(:,parse) = Xii;
    else
    Xintruder(:,parse) = FCint*Xintruder(:,parse-1);   
    end
            
    
    C_4 = Hij4'*uIMM(:,k-1);
    
    X4_CV = (Hij4(1,1)*uIMM(1,k-1)*XCV(1:6,1) + Hij4(2,1)*uIMM(2,k-1)*XCA(1:6,1)) /C_4(1);
    
    X4_CA = (Hij4(1,2)*uIMM(1,k-1)*[XCV;0;0;0] + Hij4(2,2)*uIMM(2,k-1)*XCA) /C_4(2);

 
    P4_CV = (Hij4(1,1)*uIMM(1,k-1)*(PCV +(X4_CV - XCV)*((X4_CV - XCV)'))...
        + Hij4(2,1)*uIMM(2,k-1)*(PCA(1:6,1:6)+(X4_CA(1:6) - XCV)*((X4_CA(1:6) - XCV)'))/C_4(1));
   
    P4_CA = (Hij4(1,2)*uIMM(1,k-1)*([PCV,zeros(6,3);zeros(3,9)]+([X4_CV;0;0;0] - XCA) * (([X4_CV;0;0;0] - XCA)'))...
        + Hij4(2,2)*uIMM(2,k-1)*(PCA + (X4_CA - XCA)*((X4_CA - XCA)')))/C_4(2);
    
    

    XCVpred = FCV*X4_CV;
    
    XCApred = FCA*X4_CA;
    
        
    PCV = FCV*P4_CV*FCV' + QCV;
    %work out kalman gain
    
    SCV = HCV*PCV*HCV' + R %s1
    
    KCV = (PCV*HCV')/(SCV);
    
    DiffCV = (Z(:,tsteps(k)) - HCV*XCVpred); %r1
    
    XCV = XCVpred + KCV*(DiffCV);
    
    LindiffCV = eye(6) - KCV*HCV;
    
    PCV = LindiffCV*PCV*LindiffCV' + KCV*R*KCV';
    
    
    
    PCA = FCA*P4_CA*FCA' + QCA;
    %work out kalman gain
    
    SCA = HCA*PCA*HCA' + R;
    
    KCA = (PCA*HCA')/(SCA);
    
    DiffCA = (Z(:,tsteps(k)) - HCA*XCApred);
    
    XCA = XCApred +KCA*(DiffCA);
    
    LindiffCA = eye(9) - KCA*HCA;
    
    PCA = LindiffCA*PCA*LindiffCA' + KCA*R*KCA';
    
   
    uIMM(:,k) = Model_Likelihood_Updt2(DiffCV,DiffCA,SCV,SCA,C_4);
    
    [x4_predict(:,k),~] =  Model_mix2(uIMM,XCVpred,XCApred(1:6,1),PCV,PCA(1:6, 1:6));
    [x4_pro_IMM(:,k),P4] = Model_mix2(uIMM,XCV,XCA(1:6,1),PCV,PCA(1:6, 1:6));
    
    
%     error(1,k-1) = (x4_pro_IMM(1,k) - x(k))^2
%     error(2,k-1) = (x4_pro_IMM(2,k) - y(k))^2
%     error(3,k-1) = (x4_pro_IMM(3,k) - z(k))^2
%     error(4,k-1) = error(1,k-1)+error(2,k-1)+error(3,k-1)
% %     RMSE(1,k-1) = sqrt((sum(error(1,k-1),error(2,k-1),error(3,k-1))));
%     RMSE(1,k-1) = sqrt((1/data_points)*error(4,k-1));
%     pause(1);

%       pause(1);



    cy_pre = collisionCylinder(1000,152.4*2);
    Trformpre = trvec2tform([x4_pro_IMM(1,k),x4_pro_IMM(2,k),x4_pro_IMM(3,k)]);
%     Trformpre = trvec2tform([x4_predict(1,k),x4_predict(2,k),x4_predict(3,k)]);
    cy_pre.Pose = Trformpre;

    cylintr = collisionCylinder(1000,152.4*2);
    Transintr = trvec2tform([Xintruder(1,parse) Xintruder(4,parse) Xintruder(7,parse)]);
    cylintr.Pose = Transintr;

    [areIntersecting,dist,witnessPoints] = checkCollision(cy_pre,cylintr);
    
    

if areIntersecting
    fprintf('Collision at %f seconds',tsteps(k));
    break
end



plotx1(parse) = x(tsteps(k));
ploty1(parse) = y(tsteps(k));
plotz1(parse) = z(tsteps(k));
parse = parse + 1; 


figure(5);
plot3(plotx1,ploty1,plotz1,'-ob',Xintruder(1,:),Xintruder(4,:),Xintruder(7,:),'-or',x4_pro_IMM(1,:),x4_pro_IMM(2,:),x4_pro_IMM(3,:),'-og');
% plot3(plotx1,ploty1,plotz1,'-ob',Xintruder(1,:),Xintruder(4,:),Xintruder(7,:),x4_predict(1,:),x4_predict(2,:),x4_predict(3,:),'og');
% xlim([x(1)-80000 x(1)+80000]);
% ylim([y(1)-80000 y(1)+80000]);
% zlim([z(1)-80000 z(1)+80000]);
title('Collision simulation');
legend({'Actual trajectory','Simulated Intruder trajectory','Kalman-Predicted trajectory'},'Location','southwest');
xlabel('X Position(m)');
ylabel('Y Position(m)');
zlabel('Z Position(m)');
grid on;


figure(6);
[~,patchObj] = show(cy_pre);
patchObj.FaceColor = [0 1 1];
patchObj.EdgeColor = 'none';
show(cylintr);
xlim([4.015e6 4.03e6]);
ylim([-9e4 -7e4]);
zlim([4.935e6 4.945e6]);
hold on;
end

else
    Z = [x y z Vx Vy Vz]';

%XCA = XCT = [x y z Vx Vy Vz Ax Ay Az]


acc_noise = 100;
Velnoise = 100;

FCV = [1 0 0 Ts 0 0;
       0 1 0 0 Ts 0;
       0 0 1 0 0 Ts;
       0 0 0 1 0 0;
       0 0 0 0 1 0;
       0 0 0 0 0 1];
        


FCA = [1 0 0 Ts 0 0 (Ts^2)/2 0 0;
       0 1 0 0 Ts 0 0 (Ts^2)/2 0;
       0 0 1 0 0 Ts 0 0 (Ts^2)/2;
       0 0 0 1 0 0 Ts 0 0;
       0 0 0 0 1 0 0 Ts 0;
       0 0 0 0 0 1 0 0 Ts;
       0 0 0 0 0 0 1 0 0;
       0 0 0 0 0 0 0 1 0;
       0 0 0 0 0 0 0 0 1];

      
HCA = [1 0 0 0 0 0 0 0 0;
       0 1 0 0 0 0 0 0 0;
       0 0 1 0 0 0 0 0 0;
       0 0 0 1 0 0 0 0 0;
       0 0 0 0 1 0 0 0 0;
       0 0 0 0 0 1 0 0 0];
    



HCV = eye(6);



QCA = [eye(3,3)*Ts^4/4, eye(3,3)*Ts^3/2, eye(3,3)*Ts^2/2;
    eye(3,3)*Ts^3/2, eye(3,3)*Ts^2, eye(3,3)*Ts;
    eye(3,3)*Ts^2/2, eye(3,3)*Ts, eye(3,3)]*acc_noise^2;

QCV = [(Ts^4)/4 0 0 ((Ts^3)/2) 0 0;
        0 (Ts^4)/4 0 0 (Ts^3)/2 0;
        0 0 (Ts^4)/4 0 0 (Ts^3)/2;
        (Ts^3)/2 0 0 Ts^2 0 0;
        0 (Ts^3)/2 0 0 Ts^2 0;
        0 0 (Ts^3)/2 0 0 Ts^2]*Velnoise^2;
    
       
R = [uncert(1).varx^2 0 0 0 0 0;
    0 uncert(1).vary^2 0 0 0 0;
    0 0 uncert(1).varz^2 0 0 0;
    0 0 0 uncert(1).varvx^2 0 0;
    0 0 0 0 uncert(1).varvy^2 0;
    0 0 0 0 0 uncert(1).varvz^2]; 

% R = [900 0 0 0 0 0; 0 900 0 0 0 0; 0 0 2025 0 0 0; 0 0 0 100 0 0; 0 0 0 0 100 0; 0 0 0 0 0 231.04];




tsteps = 0:Ts:data_points;




uIMM = zeros(2,length(tsteps));



uIMM(:,1)  = [0.5 0.5]';

XCV = Z(:,1);

XCA = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0 0 0]' ;



PCV = [200 0 0 0 0 0;
    0 200 0 0 0 0;
    0 0 200 0 0 0;
    0 0 0 200 0 0;
    0 0 0 0 200 0;
    0 0 0 0 0 200];
       
PCA = [200 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 200];


PIMM = zeros(9,9);

Hij4 =      [0.6 0.4;
             0.2 0.8]; %inital mixing matrix 
         
         
      
jump = length(tsteps);

x4_pro_IMM(:,1) = [Z(:,1)];

for k = 2:jump
    
    C_4 = Hij4'*uIMM(:,k-1);
    
    X4_CV = (Hij4(1,1)*uIMM(1,k-1)*XCV(1:6,1) + Hij4(2,1)*uIMM(2,k-1)*XCA(1:6,1)) /C_4(1);
    
    X4_CA = (Hij4(1,2)*uIMM(1,k-1)*[XCV;0;0;0] + Hij4(2,2)*uIMM(2,k-1)*XCA) /C_4(2);

 
    P4_CV = (Hij4(1,1)*uIMM(1,k-1)*(PCV +(X4_CV - XCV)*((X4_CV - XCV)'))...
        + Hij4(2,1)*uIMM(2,k-1)*(PCA(1:6,1:6)+(X4_CA(1:6) - XCV)*((X4_CA(1:6) - XCV)'))/C_4(1));
   
    P4_CA = (Hij4(1,2)*uIMM(1,k-1)*([PCV,zeros(6,3);zeros(3,9)]+([X4_CV;0;0;0] - XCA) * (([X4_CV;0;0;0] - XCA)'))...
        + Hij4(2,2)*uIMM(2,k-1)*(PCA + (X4_CA - XCA)*((X4_CA - XCA)')))/C_4(2);
    
    

    XCVpred = FCV*X4_CV;
    
    XCApred = FCA*X4_CA;
    
        
    PCV = FCV*P4_CV*FCV' + QCV;
    %work out kalman gain
    
    SCV = HCV*PCV*HCV' + R %s1
    
    KCV = (PCV*HCV')/(SCV);
    
    DiffCV = (Z(:,tsteps(k)) - HCV*XCVpred); %r1
    
    XCV = XCVpred + KCV*(DiffCV);
    
    LindiffCV = eye(6) - KCV*HCV;
    
    PCV = LindiffCV*PCV*LindiffCV' + KCV*R*KCV';
    
    
    
    PCA = FCA*P4_CA*FCA' + QCA;
    %work out kalman gain
    
    SCA = HCA*PCA*HCA' + R;
    
    KCA = (PCA*HCA')/(SCA);
    
    DiffCA = (Z(:,tsteps(k)) - HCA*XCApred);
    
    XCA = XCApred +KCA*(DiffCA);
    
    LindiffCA = eye(9) - KCA*HCA;
    
    PCA = LindiffCA*PCA*LindiffCA' + KCA*R*KCA';
    
   
    uIMM(:,k) = Model_Likelihood_Updt2(DiffCV,DiffCA,SCV,SCA,C_4);
    
    [x4_pro_IMM(:,k),P4] = Model_mix2(uIMM,XCV,XCA(1:6,1),PCV,PCA(1:6, 1:6));
    
%     error(1,k-1) = (x4_pro_IMM(1,k) - x(k))^2
%     error(2,k-1) = (x4_pro_IMM(2,k) - y(k))^2
%     error(3,k-1) = (x4_pro_IMM(3,k) - z(k))^2
%     error(4,k-1) = error(1,k-1)+error(2,k-1)+error(3,k-1)
% %     RMSE(1,k-1) = sqrt((sum(error(1,k-1),error(2,k-1),error(3,k-1))));
%     RMSE(1,k-1) = sqrt((1/data_points)*error(4,k-1));
%     pause(1);

%       pause(1);
end
end
end

% pcounter = 1;
% for p = 2:Ts:data_points
%     plotx(pcounter) = x(p);
%     ploty(pcounter) = y(p);
%     plotz(pcounter) = z(p);
%     plotestx(pcounter) = predictionsCv(1,p);
%     plotesty(pcounter) = predictionsCv(3,p);
%     plotestz(pcounter) = predictionsCv(5,p);
%     ploterr(pcounter) = err.vect(p);
%     pcounter = pcounter+1;
% end
% 
% linespace = 2:Ts:d-d;
% 
% figure(1);
% plot(plotestx,plotesty,'-or',plotx,ploty,'-db');
% title('Estimated X and Y positions vs Actual X and Y positions');
% legend({'Estimted','Actual'},'Location','southwest');
% xlabel('X Position(m)');
% ylabel('Y Position(m)');
%    
%    
% figure(2);
% plot(linespace,'-or',2:Ts:d,plotz,'-db');
% title('Estimated Z vs Actual Z');
% legend({'Estimted','Actual'},'Location','southwest');
% xlabel('Timestep');
% ylabel('Altitude(m)');
% 
%    
% figure(3);
% plot(linespace,ploterr,'-g');
% title('Log Positional vector error');
% xlabel('Timestep');
% ylabel('error');
% 
% figure(4);
% plot3(plotestx,plotesty,plotestz,'-or',plotx,ploty,plotz,'-db');
    
end




    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Livedata%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if data_sel == 1
    count = 0;
    stepc = 0;
    while stepc < 10
      read = webread('http://192.168.0.47:8080/data/aircraft.json');
      data = read.aircraft;
      number_flights = length(data);
      if number_flights >= 1
          for r = 1:number_flights
              single_flight = data(r);
              this_flight_data = single_flight{:};
              required(r,:) = isfield(this_flight_data,fields);
              if all(required(r,:))
                count = count+1;
                fly.hex = this_flight_data.hex;
                fly.flight = convertCharsToStrings(this_flight_data.flight);
                flight_table(count,:) = struct2table(fly);
              end
          end
      stepc = stepc + 1;
      if mod(stepc,2) == 0
        fprintf('Finding planes.........\n')
      end
         pause(1);
      end
      end

    selection = unique(flight_table.flight)
    tracked = input('Select Flight Number: ')
    while ~any(strcmp(selection,tracked))
        tracked = input('Select an existing flight number from the list: ' );
    end
    
    time2track = ceil(input('Length of time to track flight in positive integer seconds: '));
    while time2track < 0 || ~isnumeric(time2track)
        time2track = ceil(input('Length of time to track positive integerflight in seconds: '));
    end 

count = 0;
time = 0;
while time < time2track
%     count = count+1;
    time = time+1;
    read = webread('http://192.168.0.47:8080/data/aircraft.json');
    data = read.aircraft;
    number_flights = length(data);
      if number_flights >= 1
          for r = 1:number_flights
              single_flight = data(r);
              this_flight_data = single_flight{:};
              required(r,:) = isfield(this_flight_data,fields);
              isflight = strcmp(this_flight_data,tracked);
              if all(required(r,:)) && isflight
                count = count+1;
                fly.hex = this_flight_data.hex;
                fly.flight = convertCharsToStrings(this_flight_data.flight);
                fly.alt_geom = this_flight_data.alt_geom;
                fly.gs = this_flight_data.gs;
                fly.track = this_flight_data.track; 
                fly.track_rate = this_flight_data.track_rate;
                fly.geom_rate = this_flight_data.geom_rate;
                fly.lat = this_flight_data.lat;
                fly.lon = this_flight_data.lon;
                fly.nac_p = this_flight_data.nac_p;
                fly.nac_v = this_flight_data.nac_v;
                fly.seen = this_flight_data.seen;
                fly.version = this_flight_data.version;
                flight_table(count,:) = struct2table(fly);
              end
          end
      else
          fprintf('flight no longer available');
          break;
          
      end
  
    tracked_flight = flight_table(strcmp(flight_table.flight,tracked),:);
    tracked_flight_data(count,:) = tracked_flight;
    fprintf('onestep \n');
    
    alt = single_tracked.alt_geom * 0.3048; %conv ft to metersflight_table
    lat = single_tracked.lat;
    long = single_tracked.lon;
    track_rate = single_tracked.track_rate;
    speed = single_tracked.gs*0.514444; %conv knts to m/s
    heading = single_tracked.track;
    Vz = single_tracked.geom_rate*0.00508; %conv ft/min to m/s
    position_uncert = single_tracked.nac_p;
    velocity_uncrt = single_tracked.nac_v;
    posmat = [lat long alt];
    [pos] = lla2ecef(posmat,'WGS84'); %convert to x, y, z coordinates
    x = pos(1)
    y = pos(2)
    z = pos(3)
    
    switch heading(count)
        case num2cell(0:90)
            heading(count)
            Vx = speed*cosd(heading(count));
            Vy = speed*sind(heading(count));
        case num2cell(91:180)
            heading(count)
            Vx = speed*cosd(heading(count)-90);
            Vy = -speed*sind(heading(count)-90);
        case num2cell(181:270)
            heading(count)
            Vx = -speed*cosd(heading(count)-180);
            Vy = -speed*sind(heading(count)-180);
        case num2cell(271:360)
            heading(count)
            Vx = -speed*sind(heading(count)-270);
            Vy = speed*cosd(heading(count)-270);
    end
    
    
    
    [uncert.varx,uncert.vary,uncert.varz,uncert.varvx,uncert.varvy,uncert.varvz] = get_uncertainty(position_uncert,velocity_uncert)
    
    
%     geoplot(lat,long);
%     geobasemap streets
%     hold on
%     geoplot(lat,long)
%     geobasemap streets
%     if timestep == 0;
%         minstep = 1;
%     else 
%         minstep = timestep;
%     end
    pause(1);
end
    end


if data_sel == 2
    counter = 0;
    %fields = {'track','lat','lon','gs','alt_geom','nac_p','nac_v','geom_rate'};
%         data = webread('http://192.168.0.25:8080/data.json');
    while counter < 14400
        counter = counter + 1 
        data = webread('http://192.168.0.47:8080/data/aircraft.json');
        flightdata{counter} = data.aircraft;
%         counter = counter+1
%         information = data.aircraft;
%         number_timestep_flights = length(information);
%         for z = 1:number_timestep_flights
%             thiscell = information(z);
%             unpacked = thiscell{:};
%                                                                         %             istrue = isfield(unpacked,fields)
%                                                                         %             alltrue = all(istrue);
%             fds = length(fieldnames(unpacked));
%                                                                         %                       fns = fieldnames(information(z))
%             if number_timestep_flights >= 1
%                 if fds == 38
%                     flight_table = vertcat(unpacked);
%                                                                         %           flight_table = struct2table(unpacked);
%                                                                         %           filtered_flights = flight_table((flight_table.validposition == 1) & (flight_table.validtrack == 1), :);
%                                                                         %           safeflights_data{counter} = filtered_flights;
%                     safeflights_data{counter} = flight_table;
%                 end
%                 safeflights_data{counter} = 0;
%             else
%             safeflights_data{counter} = 0;
%             end
%         end
        pause(1)
    end

    save('DATA_Storage_08_11');

    end
