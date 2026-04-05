clear;
clc;
% load 'Kalman_new_data';
% load data-turn-4 -regexp ^(?!flight_table$|flightdata$|total_flights$).;
% load 'C:\RTL1090\dump1090-win.1.10.3010.14\decoded Flights\VLG8LV.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
load 'C:\RTL1090\dump1090-win.1.10.3010.14\test-flights\EZY89TP.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
% initial_pos = [x(1) y(1) z(1)];
% intitial_vel = [Vx(1) Vy(1) Vz(1)];
% opposing_heading = -mod(360-(heading(1)),360)-90;

% 
% intruder_position = initial_pos +[8000 0 0]

collisions(1).x = (3970836.55377263+200);
collisions(1).y = (-147496.118598481-200);
collisions(1).z = 4975720.76622430;
collisions(2).x = (3971849.87951279+200);
collisions(2).y = (-164667.040525701-200);
collisions(2).z = 4974333.54930285;
collisions(3).x = (3978047.55166706+200);
collisions(3).y = (-167327.742869311-200);
collisions(3).z = 4968067.10671154;
collisions(4).x = (3985003.99846266+200);
collisions(4).y = (-172351.556397272-200);
collisions(4).z = 4961663.15179152;




plotx = [];
ploty = [];
plotz = [];
% 
%     if 0 < opposing_heading &&  opposing_heading <=90     
%         Vyop = speed(1)*cosd(opposing_heading);
%         Vxop = speed(1)*sind(opposing_heading);
%     elseif 91 < opposing_heading &&  opposing_heading <=180
%         Vyop = -speed(1)*cosd(180-opposing_heading);
%         Vxop = speed(1)*sind(180-opposing_heading);
%     elseif 181 < opposing_heading &&  opposing_heading <=270
%         Vxop = -speed(1)*cosd(270-opposing_heading);
%         Vyop = -speed(1)*sind(270-opposing_heading);
%     elseif 271 < opposing_heading &&  opposing_heading <=360
%         Vxop = -speed(1)*sind(360-opposing_heading);
%         Vyop = speed(1)*cosd(360-opposing_heading);
%     end

Vxop = mean(speed)*sin(opposing_heading*(pi./180));
Vyop = mean(speed)*cos(opposing_heading*(pi./180));

Vzop = -mean(Vz);


% Xi = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';

parse = 0

for Ts = 1:1:data_points

parse = parse + 1; 

% F = [1 Ts 0.5*Ts^2 0 0 0 0 0 0;
%     0 1 Ts 0 0 0 0 0 0;
%     0 0 1 0 0 0 0 0 0;
%     0 0 0 1 Ts 0.5*Ts^2 0 0 0;
%     0 0 0 0 1 Ts 0 0 0;
%     0 0 0 0 0 1 0 0 0;
%     0 0 0 0 0 0 1 Ts 0.5*Ts^2
%     0 0 0 0 0 0 0 1 Ts;
%     0 0 0 0 0 0 0 0 1];
% 
% if Ts ==1 
%    Xintruder(parse,:) = Xi;
% else
%    Xintruder(parse,:) = F*Xi;
% end

cy1 = collisionCylinder(926,152.4);
Trformint = trvec2tform([x(parse) y(parse) z(parse)]);
cy1.Pose = Trformint;

cylintr = collisionCylinder(926,152.4);
Transintr = trvec2tform([collisions(1).x collisions(1).y collisions(1).z]);
cylintr.Pose = Transintr;

[areIntersecting,dist,witnessPoints] = checkCollision(cy1,cylintr)

if areIntersecting
   fprintf('Collision at ');
   Ts
   break
end

% else
%    fprintf('SaFE');
% end



plotx(parse) = x(parse);
ploty(parse) = y(parse);
plotz(parse) = z(parse);



figure(4);
plot3(plotx,ploty,plotz,'-ob');
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

% plot(plotx,ploty,Xintruder(:,1),Xintruder(:,4));
% plot3(x,y,z,Xintruder(:,1),Xintruder(:,4),Xintruder(:,7));

