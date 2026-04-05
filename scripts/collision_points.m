clc;
clear;
Ts = 15;
% load 'C:\RTL1090\dump1090-win.1.10.3010.14\test-flights\EZY89TP.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
load 'RYR56UE.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
% load 'C:\RTL1090\dump1090-win.1.10.3010.14\test-flights\EZY89TP.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
posi = [x(2:Ts:data_points),y(2:Ts:data_points),z(2:Ts:data_points)];


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



% 
% [3981713.53958342,-167575.231341419,4964906.92782540]

% [3974365.53367427,-186209.390128740,4970988.43372086]
% 
% [3980618.49856494,-168481.950838153,4965807.03293118]

% [3984085.85579962,-170296.816327359,4962680.44926812]
% 
% [3985012.57240939,-172767.510697841,4961719.95311794]

figure(9);

plot(x,y);
hold on;
p = plot(collisions(1).x, collisions(1).y,'ro',collisions(2).x, collisions(2).y,'ro',collisions(3).x, collisions(3).y,'ro',collisions(4).x, collisions(4).y,'ro');
p(1).MarkerSize = 20;
p(2).MarkerSize = 20;
p(3).MarkerSize = 20;
p(4).MarkerSize = 20;
xlabel('X (m)');
ylabel('Y (m)');
grid on;
title('Flight '+tracked+'simulated collision zones');

% figure(2);
%     for i = 2:length(lat)
%     geoplot([lat(i-1) lat(i)],[long(i-1) long(i)],'-b','LineWidth',4);
%     geobasemap('topographic');
%     hold on
%     end
