% hex = [] 
% flight = [] 
% spd = []
% head = []
% lat = []
% long = [] 
% sig = []
% hex ,,,flight,spd,head,lat,long,sig,,,,, = 
clear all
lat = [];
long = [];
alt = [];
spd = [];
flg = {};
tim = [];
% dos('dump1090.bat');
% server = tcpserver("localhost",30003)
% read(server,server.NumBytesAvailable)
% while true 
%     data = urlread('http:/localhost:8080');
%     planes = fromjson(data);
%     
%     N = leng 

for z = 1:7200
    
    data = webread('http://192.168.0.25:8080/data.json');
    N = length(data);
    %     plane_data = jsondecode(data)
    %     min_updt = 2000
%         if data(y).validposition & data(y).validtrack
    stored{z,1} = data;
        %          end
 
    
      
 
     
%             stored(count,:) = struct2cell(data(i));
%             count = count + 1 
%             if 0 < data(i).seen < min_updt
%                 min_updt = data(i).seen
%             end

    pause(1)
end

h = prunedata(stored)
     


       
   
            
     
        
        
        %stored(i,1) = data(i).flight;
%         stored(i,2) = data(i).squawk;
%         stored(i,3) = data(i).hex;
%         stored(i,4) = data(i).lat;
%         stored(i,4) = data(i).lon;
%         stored(i,5) = data(i).altitude*0.3048; %convert ft to m
%         stored(i,6) = data(i).speed*0.514444; %convert knts to m/s
%         stored(i,7) = data(i).vert_rate*0.00508; %convert ft/min to m/s
%         stored(i,8) = data(i).seen;
      

    

        
% planes = jsondecode(data);

% N = length(data);
% 
% val = 0;
% for i = 1:N
%     if data(i).validposition
%         val = val + 1;
%         lat = [lat, data(i).lat];
%         lon = [data(i).lon];
%         alt = [data(i).altitude];
%         spd = [data(i).speed];
%         tim = [tim now];
%         flg{length(lat)} = data(i).flight;
%     end
% end




%     disp([num2str(N) ' planes detected with ' num2str(val) ' valid coords'])
%     
%     % Save and continue
%     save('coords.mat','lat','lon','alt','spd','flg','tim')
%     pause(1)
% end
