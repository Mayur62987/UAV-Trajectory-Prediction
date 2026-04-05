clc;
clear;

for i = 1:100;
    
xt = i*100;
yt = i*100;
zt = i*100;

cy1 = collisionCylinder(9260,609.6);
Trans1 = trvec2tform([xt yt zt]);
cy1.Pose = Trans1;
show(cy1);
plot3(xt,yt,zt,'.');

pause(0.1);
end