
function [ u ] = Model_Likelihood_Updt3(r1, r2,r3,S1, S2,S3, c_i)


% if det(2*pi*S1) > 0
%     Lfun1 = (1/(sqrt(det(2*pi*S1))))*exp((-0.5*((r1')*((S1^-1)*(r1)))))
% end   

if det(2*pi*S1) > 0
    Lfun1 = (1/(sqrt(det(2*pi*S1))))*exp((-0.5*((r1')*((S1^-1)*(r1)))))
else
    Lfun1 = 0;
end
    
% if det(2*pi*S2) > 0
%     Lfun2 = (1/(sqrt(det(2*pi*S2))))*exp((-0.5*((r2')*((S2^-1)*(r2)))))
% end
%  

if det(2*pi*S2) > 0
    Lfun2 = (1/(sqrt(det(2*pi*S2))))*exp((-0.5*((r2')*((S2^-1)*(r2)))));
else
    Lfun2 =0;
end
 

if det(2*pi*S3) > 0
    Lfun3 = (1/(sqrt(det(2*pi*S3))))*exp((-0.5*((r3')*((S3^-1)*(r3)))));
else
    Lfun3 =0;
end
 

% 
% Lfun2 = (1/sqrt(abs(2*pi*det(S2))))*exp(-1/2*(r2'*inv(S2)*r2))
% Lfun3 = (1/sqrt(abs(2*pi*det(S3))))*exp(-1/2*(r3'*inv(S3)*r3))
% Lfun4 = (1/sqrt(abs(2*pi*det(S4))))*exp(-1/2*(r4'*inv(S4)*r4))

if Lfun1 == 0 && Lfun2 == 0
    Lfun1 = 0.1;
    Lfun2 = 0.1;

end


if Lfun1 > 0 && Lfun2 == 0 && Lfun3 == 0 
    Lfun1 = 1;
    Lfun2 = 0;
    Lfun3 = 0;
end

if Lfun2 > 0 && Lfun1 == 0 && Lfun3 == 0 
    Lfun1 = 0;
    Lfun2 = 1;
    Lfun3 = 0;
end

if Lfun3 > 0 && Lfun1 == 0 && Lfun2 == 0 
    Lfun1 = 0;
    Lfun2 = 0;
    Lfun3 = 1;
end


sumVal = Lfun1 + Lfun2 + Lfun3;
Lfun1 = Lfun1 / sumVal;
Lfun2 = Lfun2 / sumVal;
Lfun3 = Lfun3 / sumVal;

c = [Lfun1, Lfun2,Lfun3] * c_i;
u = (1/c).*[Lfun1, Lfun2,Lfun3]'.*c_i;
end