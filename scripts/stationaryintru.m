clear;
clc;
% load 'Kalman_new_data';
% load data-turn-4 -regexp ^(?!flight_table$|flightdata$|total_flights$).;
% load 'RYR8213.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
load 'RYR56UE.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).;
% load 'C:\RTL1090\dump1090-win.1.10.3010.14\test-flights\EZY89TP.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
% initial_pos = [x(1) y(1) z(1)];
% intitial_vel = [Vx(1) Vy(1) Vz(1)];
% opposing_heading = -mod(360-(heading(1)),360)-90;

pos = [x y z];

% intruder_position = initial_pos +[8000 0 0]

collisions(1).x = (3974365.53367427+600);
collisions(1).y = (-186209.390128740-400);
collisions(1).z = 4970988.43372086;
collisions(2).x = (3980618.49856494-800);
collisions(2).y = (-168481.950838153-450);
collisions(2).z = 4965807.03293118;
collisions(3).x = (3981713.53958342+600);
collisions(3).y = (-167575.2313414199+800);
collisions(3).z = 4964906.9278254;
collisions(4).x = (3985012.57240939+400);
collisions(4).y = (-172767.510697841-600);
collisions(4).z = 4961719.95311794;



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

% Vxop = mean(speed)*sin(opposing_heading*(pi./180));
% Vyop = mean(speed)*cos(opposing_heading*(pi./180));
% 
% Vzop = -mean(Vz);
% 
% 
% Xi = [intruder_position(1) Vxop 0 intruder_position(2) Vyop 0 intruder_position(3) Vzop 0]';
% 
parse = 0;

for Ts = 2:1:3

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

cy1 = collisionCylinder(926*2,152.4*2);
Trformint = trvec2tform([x(Ts) y(Ts) z(Ts)]);
cy1.Pose = Trformint;

cylintr = collisionCylinder(926,152.4);
Transintr = trvec2tform([collisions(4).x collisions(4).y collisions(4).z]);
cylintr.Pose = Transintr;

[areIntersecting,dist,witnessPoints] = checkCollision(cy1,cylintr);

if areIntersecting
   fprintf('Collision at ');
   Ts
   break
end

% else
%    fprintf('SaFE');
% end



plotx(parse) = x(Ts);
ploty(parse) = y(Ts);
plotz(parse) = z(Ts);



% figure(4);
% plot3(plotx,ploty,plotz,'-ob');
% hold on;
% p = plot3(collisions(3).x,collisions(3).y,collisions(3).z,'ro');
% p(1).MarkerSize = 20;
% grid on;
% title('Collision simulation Flight VLG8LV');
% legend({'Actual trajectory','Simulated Intruder trajectory'},'Location','southwest');
% xlabel('X Position(m)');
% ylabel('Y Position(m)');
% zlabel('Z Position(m)');
% 




figure(5);
[~,patchObj] = show(cylintr);
patchObj.FaceColor = [0 1 1];
patchObj.EdgeColor = 'none';
show(cy1);
title('Separation Volume collision cylinder');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
legend({'Aircraft Separation volume'},'Location','southwest');
hold on;





end

% hold on;
% plot(4020658.52433672,-77677.6651383102,'r*');
% viscircles([2,4],10)
% hold on;
% title("Point of Collision Flight ",);
% xlabel('X (m)');
% ylabel('Y (m)');
% legend({'Actual trajectory', 'Simulated intruder'},'Location','southwest');

% figure(2);
% plot(1:parse,plotz,1:parse,Xintruder(:,7));
% title("Point of Collision Flight Altitude",tracked);
% xlabel('Timestep(s)');
% ylabel('Z (m)');
% legend({'Actual trajectory', 'Simulated intruder'},'Location','southwest');

% plot(plotx,ploty,Xintruder(:,1),Xintruder(:,4));
% plot3(x,y,z,Xintruder(:,1),Xintruder(:,4),Xintruder(:,7));

