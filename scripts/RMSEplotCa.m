data_points = 626
Ts = 5;
storedStructure = load('aploterr1.mat', 'ploterr'); % Load in ONLY the myVar variable.
ploterr1 = storedStructure.ploterr; 
clear('storedStructure');

storedStructure = load('aploterr10.mat', 'ploterr'); % Load in ONLY the myVar variable.
ploterr2 = storedStructure.ploterr; 
clear('storedStructure');

storedStructure = load('aploterr100.mat', 'ploterr'); % Load in ONLY the myVar variable.
ploterr3 = storedStructure.ploterr; 
clear('storedStructure');

storedStructure = load('aploterr1000.mat', 'ploterr'); % Load in ONLY the myVar variable.
ploterr4 = storedStructure.ploterr; 
clear('storedStructure');

figure(5);
   plot(2:Ts:data_points,ploterr1,'-g',2:Ts:data_points,ploterr2,'-b',2:Ts:data_points,ploterr3,'-r',2:Ts:data_points,ploterr4,'-');
   grid on;
   title('RMSE of position');
   xlabel('Timestep (s)');
   ylabel('RMSE(m)');
   legend({'sigma j = 1 (m/s^3)^2','sigma j = 10 (m/s^3)^2','sigma j = 100 (m/s^3)^2','sigma j = 1000 (m/s^3)^2'},'Location','northeast');
