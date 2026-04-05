%combined feed of live data
clc;
clear all;
close all;
fields = {'hex', 'flight','alt_geom','gs','track','track_rate','geom_rate','lat','lon','nac_p','nac_v','seen','version'};
% load 'C:\RTL1090\dump1090-win.1.10.3010.14\test-flights\EZY89TP.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
% load 'RYR8213.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).
load 'RYR56UE.mat' -regexp ^(?!flight_table$|flightdata$|total_flights$).;

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

pt =4;

Ts = input('input prediction time step ');

while(1)
    model_sel = input('Select prediction model 1:IMM CV-CA 2:IMM CV-CV-CT 3:IMM CV-CA-CT2 ');
    if (model_sel == 1 || model_sel == 2 || model_sel == 3)
        break
    end
end
3


if model_sel == 1
    
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

        x4_pro_IMM(:,1) = [Z(:,1)];
        
        parse = 1;

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
        
        
            cy_pre = collisionCylinder(926*2,152.4*4);
            Trformpre = trvec2tform([x4_pro_IMM(1,k),x4_pro_IMM(2,k),x4_pro_IMM(3,k)]);
            cy_pre.Pose = Trformpre;

            cylintr = collisionCylinder(926*2,152*2.4*4);
            Transintr = trvec2tform([collisions(pt).x collisions(pt).y collisions(pt).z]);
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
            plot3(plotx1,ploty1,plotz1,'-ob',x4_pro_IMM(1,:),x4_pro_IMM(2,:),x4_pro_IMM(3,:),'-og');
            hold on;
            pl = plot3(collisions(pt).x,collisions(pt).y,collisions(pt).z,'ro');
            p1(1).Markersize = 20;
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
            hold on;
    end

    
    
    
end





if model_sel == 2
    tsteps = 0:Ts:data_points;
    Z = [x y z Vx Vy Vz]';
    Turnnoise1 = 10;
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

    w1 = 1;

  
    FCT1 = [1, 0, 0, sind(w1*Ts)/w1, (cosd(w1*Ts) - 1)/w1, 0 0;
            0, 1, 0, (1 - cosd(w1*Ts))/w1, sind(w1*Ts)/w1, 0, 0;
            0, 0, 1, 0, 0,Ts,0 ;
            0, 0, 0, cosd(w1*Ts), -sind(w1*Ts), 0, 0;
            0, 0, 0, sind(w1*Ts), cosd(w1*Ts), 0, 0;
            0, 0, 0, 0, 0, 1, 0
            0, 0, 0, 0, 0, 0, 1];   



    w2 = -1;

    FCT2 = [1, 0, 0, sind(w2*Ts)/w2, (cosd(w2*Ts) - 1)/w2, 0 0;
            0, 1, 0, (1 - cosd(w2*Ts))/w2, sind(w2*Ts)/w2, 0, 0;
            0, 0, 1, 0, 0,Ts,0 ;
            0, 0, 0, cosd(w2*Ts), -sind(w2*Ts), 0, 0;
            0, 0, 0, sind(w2*Ts), cosd(w2*Ts), 0, 0;
            0, 0, 0, 0, 0, 1, 0
            0, 0, 0, 0, 0, 0, 1];  


    HCA = [1 0 0 0 0 0 0 0 0;
           0 1 0 0 0 0 0 0 0;
           0 0 1 0 0 0 0 0 0;
           0 0 0 1 0 0 0 0 0;
           0 0 0 0 1 0 0 0 0;
           0 0 0 0 0 1 0 0 0];




    HCV = eye(6);

    HCT = [1 0 0 0 0 0 0;
           0 1 0 0 0 0 0;
           0 0 1 0 0 0 0;
           0 0 0 1 0 0 0;
           0 0 0 0 1 0 0;
           0 0 0 0 0 1 0];


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
        0 0 0 0 0 0 0] *Turnnoise1^2;

    R = [uncert(1).varx^2 0 0 0 0 0;
        0 uncert(1).vary^2 0 0 0 0;
        0 0 uncert(1).varz^2 0 0 0;
        0 0 0 uncert(1).varvx^2 0 0;
        0 0 0 0 uncert(1).varvy^2 0;
        0 0 0 0 0 uncert(1).varvz^2]; 

    RCT = [uncert(1).varx^2 0 0 0 0 0 0;
        0 uncert(1).vary^2 0 0 0 0 0;
        0 0 uncert(1).varz^2 0 0 0 0;
        0 0 0 uncert(1).varvx^2 0 0 0;
        0 0 0 0 uncert(1).varvy^2 0 0;
        0 0 0 0 0 uncert(1).varvz^2 0;
        0 0 0 0 0 0 0]; 


    x4_pro_IMM = zeros(6,length(tsteps));
    uIMM = zeros(4,length(tsteps));

    x4_pro_IMM(:,1) = Z(:,1);

    uIMM(:,1)  = [0.25 0.25 0.25 0.25]';

    XCV = Z(:,1);

    XCA = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0 0 0]' ;

    XCT1 = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0]';

    XCT2 = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0]';

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

    PCT1 = [200 0 0 0 0 0 0;
        0 200 0 0 0 0 0;
        0 0 200 0 0 0 0;
        0 0 0 200 0 0 0;
        0 0 0 0 200 0 0;
        0 0 0 0 0 200 0;
        0 0 0 0 0 0 0];

    PCT2 = [200 0 0 0 0 0 0;
        0 200 0 0 0 0 0;
        0 0 200 0 0 0 0;
        0 0 0 200 0 0 0;
        0 0 0 0 200 0 0;
        0 0 0 0 0 200 0;
        0 0 0 0 0 0 0];



    PIMM = zeros(9,9);



    Hij4 =      [0.6 0.2 0.1 0.1;
                0.1 0.6 0.15 0.15;
                0.2 0.3 0.3 0.15;
                0.2 0.3 0.15 0.3];

    jump = length(tsteps);
     parse = 1;
        for k = 2:jump

                C_4 = Hij4'*uIMM(:,k-1);

                X4_CV = (Hij4(1,1)*uIMM(1,k-1)*XCV(1:6,1) + Hij4(2,1)*uIMM(2,k-1)*XCA(1:6,1) +...
                    Hij4(3,1)*uIMM(3,k-1)*XCT1(1:6,1) + Hij4(4,1)*uIMM(4,k-1)*XCT2(1:6,1)) /C_4(1);

                X4_CA = (Hij4(1,2)*uIMM(1,k-1)*[XCV;0;0;0] + Hij4(2,2)*uIMM(2,k-1)*XCA +...
                Hij4(3,2)*uIMM(3,k-1)*[XCT1(1:6);0;0;0] + Hij4(4,2)*uIMM(4,k-1)*[XCT2(1:6);0;0;0])/C_4(2);

                X4_CT1 = (Hij4(1,3)*uIMM(1,k-1)*[XCV;0] + Hij4(2,3)*uIMM(2,k-1)*[XCA(1:6,1);0] +...
                Hij4(3,3)*uIMM(3,k-1)*XCT1 +  Hij4(4,3)*uIMM(4,k-1)*XCT2)/C_4(3);

                X4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*[XCV;0] + Hij4(2,4)*uIMM(2,k-1)*[XCA(1:6,1);0] +...
                Hij4(3,4)*uIMM(3,k-1)*XCT1 +  Hij4(4,4)*uIMM(4,k-1)*XCT2)/C_4(4);


                P4_CV = (Hij4(1,1)*uIMM(1,k-1)*(PCV +(X4_CV - XCV)*((X4_CV - XCV)'))...
                    + Hij4(2,1)*uIMM(2,k-1)*(PCA(1:6,1:6)+(X4_CA(1:6) - XCV)*((X4_CA(1:6) - XCV)'))...
                    + Hij4(3,1)*uIMM(3,k-1)*(PCT1(1:6,1:6) +(X4_CT1(1:6) - XCV)*((X4_CT1(1:6) - XCV)'))...
                    + Hij4(4,1)*uIMM(4,k-1)*(PCT2(1:6,1:6) +(X4_CT2(1:6) - XCV)*((X4_CT2(1:6) - XCV)')))/C_4(1);

                P4_CA = (Hij4(1,2)*uIMM(1,k-1)*([PCV,zeros(6,3);zeros(3,9)]+([X4_CV;0;0;0] - XCA) * (([X4_CV;0;0;0] - XCA)'))...
                    + Hij4(2,2)*uIMM(2,k-1)*(PCA + (X4_CA - XCA)*((X4_CA - XCA)'))...
                    + Hij4(3,2)*uIMM(3,k-1)*([PCT1,zeros(7,2);zeros(2,9)]+([X4_CT1(1:6);0;0;0] - XCA) * ([X4_CT1(1:6);0;0;0] - XCA)')...
                    + Hij4(4,2)*uIMM(4,k-1)*([PCT2,zeros(7,2);zeros(2,9)]+([X4_CT2(1:6);0;0;0] - XCA) * ([X4_CT2(1:6);0;0;0] - XCA)'))/C_4(2);

                P4_CT1 = (Hij4(1,3)*uIMM(1,k-1)*([PCV,zeros(6,1);zeros(1,7)] +([X4_CV;0] - XCT1) *(([X4_CV;0] - XCT1)'))...
                    + Hij4(2,3)*uIMM(2,k-1)*([PCA(1:6,1:6),zeros(6,1);zeros(1,7)] +([X4_CA(1:6);0] - XCT1) *(([X4_CA(1:6);0] - XCT1)'))...
                    + Hij4(3,3)*uIMM(3,k-1)*(PCT1 +(X4_CT1 - XCT1) * ((X4_CT1 - XCT1)'))...
                    + Hij4(4,3)*uIMM(4,k-1)*(PCT2 +(X4_CT2 - XCT1) * ((X4_CT2 - XCT1)')))/C_4(3);

                P4_CT2 = (Hij4(1,4)*uIMM(1,k-1)*([PCV,zeros(6,1);zeros(1,7)] +([X4_CV;0] - XCT2) *(([X4_CV;0] - XCT2)'))...
                + Hij4(2,4)*uIMM(2,k-1)*([PCA(1:6,1:6),zeros(6,1);zeros(1,7)] +([X4_CA(1:6);0] - XCT2) *(([X4_CA(1:6);0] - XCT2)'))...
                + Hij4(3,4)*uIMM(3,k-1)*(PCT1 +(X4_CT1- XCT2) * ((X4_CT1 - XCT2)'))...
                + Hij4(4,4)*uIMM(4,k-1)*(PCT2 +(X4_CT2 - XCT2) * ((X4_CT2 - XCT2)')))/C_4(4);


 
                XCVpred = FCV*X4_CV;

                XCApred = FCA*X4_CA;

                XCT1pred = FCT1*X4_CT1;

                XCT2pred = FCT2*X4_CT2;


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




                PCT1 = FCT1*P4_CT1*FCT1' + QCT;
                %work out kalman gain

                SCT1 = HCT*PCT1*HCT' + R;

                KCT1 = (PCT1*HCT')/(SCT1);

                DiffCT1 = (Z(:,tsteps(k)) - HCT*XCT1pred);

                XCT1 = XCT1pred +KCT1*(DiffCT1);

                LindiffCT1 = eye(7) - KCT1*HCT;

                PCT1 = LindiffCT1*PCT1*LindiffCT1' + KCT1*R*KCT1';



                PCT2 = FCT2*P4_CT2*FCT2' + QCT;
                %work out kalman gain

                SCT2 = HCT*PCT2*HCT' + R;

                KCT2 = (PCT2*HCT')/(SCT2);

                DiffCT2 = (Z(:,tsteps(k)) - HCT*XCT2pred);

                XCT2 = XCT2pred +KCT2*(DiffCT2);

                LindiffCT2 = eye(7) - KCT2*HCT;

                PCT2 = LindiffCT2*PCT2*LindiffCT2' + KCT2*R*KCT2';



                uIMM(:,k) = Model_Likelihood_Updt(DiffCV,DiffCA,DiffCT1,DiffCT2,SCV,SCA,SCT1,SCT2,C_4);

                [x4_pro_IMM(:,k),P4] = Model_mix(uIMM,XCV,XCA(1:6,1),XCT1(1:6,1),XCT2(1:6,1),PCV,PCA(1:6, 1:6),PCT1(1:6, 1:6),PCT2(1:6, 1:6));

            cy_pre = collisionCylinder(926*2,152.4*4);
            Trformpre = trvec2tform([x4_pro_IMM(1,k),x4_pro_IMM(2,k),x4_pro_IMM(3,k)]);
            cy_pre.Pose = Trformpre;

            cylintr = collisionCylinder(926*2,152*2.4*4);
            Transintr = trvec2tform([collisions(pt).x collisions(pt).y collisions(pt).z]);
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
            plot3(plotx1,ploty1,plotz1,'-ob',x4_pro_IMM(1,:),x4_pro_IMM(2,:),x4_pro_IMM(3,:),'-og');
            hold on;
            pl = plot3(collisions(pt).x,collisions(pt).y,collisions(pt).z,'ro');
            
            p1(1).Markersize = 20;
            title('Collision simulation');
            legend({'Actual trajectory','Simulated Intruder trajectory','Kalman-Predicted trajectory'},'Location','southwest');
            ylabel('Y Position(m)');
            zlabel('Z Position(m)'); 
            xlabel('X Position');

%             figure(6);
%             [~,patchObj] = show(cy_pre);
%             patchObj.FaceColor = [0 1 1];
%             patchObj.EdgeColor = 'none';
%             show(cylintr);
%             hold on;

    end
    
    

end


if model_sel == 3

    tsteps = 0:Ts:data_points;
    Z = [x y z Vx Vy Vz]';
    
    Turnnoise1 = 22;
    acc_noise = 10;
    Velnoise = 10;

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

w1 = 0.0001;

w2 = -0.0001;

%[x,y,z,vx,vy,vz,w];

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
    
% QCT = [(Ts^4)/4 0 0 ((Ts^3)/2) 0 0 0;
%     0 (Ts^4)/4 0 0 (Ts^3)/2 0 0;
%     0 0 (Ts^4)/4 0 0 (Ts^3)/2 0;
%     (Ts^3)/2 0 0 Ts^2 0 0 0;
%     0 (Ts^3)/2 0 0 Ts^2 0 0;
%     0 0 (Ts^3)/2 0 0 Ts^2 0
%     0 0 0 0 0 0 Ts^2] *Turnnoise1^2;

QCT  = [(Ts^4)/4 0 0 Ts^3/2 0 0 Ts^2/2 0 0 0;
         0 (Ts^4)/4 0 0 Ts^3/2 0 0 Ts^2/2 0 0;
         0 0 (Ts^4)/4 0 0 Ts^3/2 0 0 Ts^2/2 0;
         Ts^3/2 0 0 Ts^2 0 0 Ts 0 0 0;
         0 Ts^3/2 0 0 Ts^2 0 0 Ts 0 0;
         0 0 Ts^3/2 0 0 Ts^2 0 0 Ts 0;
         Ts^2/2 0 0 Ts 0 0 1 0 0 0;
         0 Ts^2/2 0 0 Ts 0 0 1 0 0;
         0 0 Ts^2/2 0 0 Ts 0 0 1 0;
         0 0 0 0 0 0 0 0 0 0]*Turnnoise1^2;
   

       
R = [uncert(1).varx^2 0 0 0 0 0;
    0 uncert(1).vary^2 0 0 0 0;
    0 0 uncert(1).varz^2 0 0 0;
    0 0 0 uncert(1).varvx^2 0 0;
    0 0 0 0 uncert(1).varvy^2 0;
    0 0 0 0 0 uncert(1).varvz^2]; 

RCT = [uncert(1).varx^2 0 0 0 0 0 0;
    0 uncert(1).vary^2 0 0 0 0 0;
    0 0 uncert(1).varz^2 0 0 0 0;
    0 0 0 uncert(1).varvx^2 0 0 0;
    0 0 0 0 uncert(1).varvy^2 0 0;
    0 0 0 0 0 uncert(1).varvz^2 0;
    0 0 0 0 0 0 25]; 

% RCA = [uncert(1).varx^2 0 0 0 0 0 0;
%     0 uncert(1).varvx^2 0 0 0 0 0;
%     0 0 uncert(1).vary^2 0 0 0 0;
%     0 0 0 uncert(1).varvy^2 0 0 0;
%     0 0 0 0 uncert(1).varz^2 0 0;
%     0 0 0 0 0 uncert(1).varvz^2 0
%     0 0 0 0 0 0 10]; 

x4_pro_IMM = zeros(6,length(tsteps));

x4_pro_IMM(:,1) = Z(:,1);

uIMM = zeros(4,length(tsteps));

uIMM(:,1)  = [0.25 0.25 0.25 0.25]';

XCV = Z(:,1);

XCA = [Z(:,1);0;0;0];

XCT1 = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0 0 0 0]';

XCT2 = [Z(1,1) Z(2,1) Z(3,1) Z(4,1) Z(5,1) Z(6,1) 0 0 0 0]';

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
    0 0 0 0 0 0 0 0 0 0];

PCT2 = [200 0 0 0 0 0 0 0 0 0;
    0 200 0 0 0 0 0 0 0 0;
    0 0 200 0 0 0 0 0 0 0;
    0 0 0 200 0 0 0 0 0 0;
    0 0 0 0 200 0 0 0 0 0;
    0 0 0 0 0 200 0 0 0 0;
    0 0 0 0 0 0 200 0 0 0;
    0 0 0 0 0 0 0 200 0 0;
    0 0 0 0 0 0 0 0 200 0;
    0 0 0 0 0 0 0 0 0 0];



PIMM = zeros(9,9);


Hij4 =      [0.6 0.2 0.1 0.1;
            0.1 0.6 0.15 0.15;
            0.2 0.3 0.3 0.15;
            0.2 0.3 0.15 0.3]; %inital mixing matrix 
        
jump = length(tsteps)
parse = 1;

    for k = 2:jump

        C_4 = Hij4'*uIMM(:,k-1);

        X4_CV = (Hij4(1,1)*uIMM(1,k-1)*XCV(1:6,1) + Hij4(2,1)*uIMM(2,k-1)*XCA(1:6,1) +...
            Hij4(3,1)*uIMM(3,k-1)*XCT1(1:6,1) + Hij4(4,1)*uIMM(4,k-1)*XCT2(1:6,1)) /C_4(1);

        X4_CA = (Hij4(1,2)*uIMM(1,k-1)*[XCV;0;0;0] + Hij4(2,2)*uIMM(2,k-1)*XCA +...
        Hij4(3,2)*uIMM(3,k-1)*[XCT1(1:6);0;0;0] + Hij4(4,2)*uIMM(4,k-1)*[XCT2(1:6);0;0;0])/C_4(2);

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

         cy_pre = collisionCylinder(926*2,152.4*2);
            Trformpre = trvec2tform([x4_pro_IMM(1,k),x4_pro_IMM(2,k),x4_pro_IMM(3,k)]);
            cy_pre.Pose = Trformpre;

            cylintr = collisionCylinder(926*2,152*2.4*2);
            Transintr = trvec2tform([collisions(pt).x collisions(pt).y collisions(pt).z]);
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
            plot3(plotx1,ploty1,plotz1,'-ob',x4_pro_IMM(1,:),x4_pro_IMM(2,:),x4_pro_IMM(3,:),'-og');
            hold on;
            pl = plot3(collisions(pt).x,collisions(pt).y,collisions(pt).z,'ro');
            
            p1(1).Markersize = 20;
            title('Collision simulation');
            legend({'Actual trajectory','Simulated Intruder trajectory','Kalman-Predicted trajectory'},'Location','southwest');
            ylabel('Y Position(m)');
            zlabel('Z Position(m)'); 
            xlabel('X Position');


    end

    
    
end