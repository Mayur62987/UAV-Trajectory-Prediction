clear;
clc;
% load 'Kalman_new_data';
% load data-turn-4 -regexp ^(?!flight_table$|flightdata$|total_flights$).;
load 'C:\RTL1090\dump1090-win.1.10.3010.14\decoded Flights\VLG8LV.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
initial_pos = [x(1) y(1) z(1)];
intitial_vel = [Vx(1) Vy(1) Vz(1)];
opposing_heading = -mod(360-(heading(1)),360)-90;


intruder_position = initial_pos +[8000 0 -200]

plotx = [];
ploty = [];
plotz = [];


Vxop = mean(speed)*sin(opposing_heading*(pi./180));
Vyop = mean(speed)*cos(opposing_heading*(pi./180));

Vzop = -mean(Vz);


Xi = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

parse = 0

for Ts = 1:1:data_points

parse = parse + 1; 

F = [1 Ts 0.5*Ts^2 0 0 0 0 0 0;
    0 1 Ts 0 0 0 0 0 0;
    0 0 1 0 0 0 0 0 0;
    0 0 0 1 Ts 0.5*Ts^2 0 0 0;
    0 0 0 0 1 Ts 0 0 0;
    0 0 0 0 0 1 0 0 0;
    0 0 0 0 0 0 1 Ts 0.5*Ts^2
    0 0 0 0 0 0 0 1 Ts;
    0 0 0 0 0 0 0 0 1];

if Ts ==1 
   Xintruder(parse,:) = Xi;
else
   Xintruder(parse,:) = F*Xi;
end

cy1 = collisionCylinder(926/2,152.4);
Trformint = trvec2tform([x(parse) y(parse) z(parse)]);
cy1.Pose = Trformint;

cylintr = collisionCylinder(926/2,152.4);
Transintr = trvec2tform([Xintruder(parse,1) Xintruder(parse,4) Xintruder(parse,7)]);
cylintr.Pose = Transintr;

[areIntersecting,dist,witnessPoints] = checkCollision(cy1,cylintr)

if areIntersecting
   fprintf('Collision at ');
   Ts
   break
end



plotx(parse) = x(parse);
ploty(parse) = y(parse);
plotz(parse) = z(parse);



figure(4);
plot3(plotx,ploty,plotz,'-ob',Xintruder(:,1),Xintruder(:,4),Xintruder(:,7),'-or');
grid on;
title('Collision simulation Flight VLG8LV');
legend({'Actual trajectory','Simulated Intruder trajectory'},'Location','southwest');
xlabel('X Position(m)');
ylabel('Y Position(m)');
zlabel('Z Position(m)');





figure(5);
[~,patchObj] = show(cylintr);
patchObj.FaceColor = [0 1 1];
patchObj.EdgeColor = 'none';
show(cy1);
title('Propagation of Separation Volume');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
legend({'Simulated intruder volume', 'Actual volume'},'Location','southwest');
hold on;





end
figure(1);
plot(plotx,ploty,Xintruder(:,1),Xintruder(:,4));
title("Point of Collision Flight ",tracked);
xlabel('X (m)');
ylabel('Y (m)');
legend({'Actual trajectory', 'Simulated intruder'},'Location','southwest');

figure(2);
plot(1:parse,plotz,1:parse,Xintruder(:,7));
title("Point of Collision Flight Altitude",tracked);
xlabel('Timestep(s)');
ylabel('Z (m)');
legend({'Actual trajectory', 'Simulated intruder'},'Location','southwest');



