clc;
clear;
load flight_table;

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
        [pos] = lla2ecef(posmat,'WGS84'); %convert altto x, y, z coordinates
        x = pos(:,1);
        y = pos(:,2);
        z = pos(:,3);
        data_points = length(heading);
        Vx = zeros(data_points,1);
        Vy = zeros(data_points,1);
        for j = 1:data_points 
        [uncert(j).varx,uncert(j).vary,uncert(j).varz,uncert(j).varvx,uncert(j).varvy,uncert(j).varvz] = get_uncertainty(position_uncert(j),velocity_uncrt(j));    
        Vx(j) = speed(j)*sin(heading(j)*(pi./180));
        Vy(j) = speed(j)*cos(heading(j)*(pi./180));
        
%         heading(j)
%         if 0 < heading(j) &&  heading(j) <=90  
% 
%             Vy(j,1) = speed(j)*cosd(heading(j));
%             Vx(j,1) = speed(j)*sind(heading(j));
%         elseif 91 < heading(j) &&  heading(j) <=180
% 
%               Vx(j,1) = speed(j)*sind(180-heading(j));
%               Vy(j,1) = -speed(j)*cosd(180-heading(j));
%         elseif 181 < heading(j) &&  heading(j) <=270
% 
%               Vx(j,1) = -speed(j)*cosd(270-heading(j));
%               Vy(j,1) = -speed(j)*sind(270-heading(j));
% 
%         elseif 271 < heading(j) &&  heading(j) <=360
%   
% 
%               Vx(j,1) = -speed(j)*sind(360-heading(j));
%               Vy(j,1) = speed(j)*cosd(360-heading(j));
% 
%         end
        end 
