% err1 = load ploterr1.3.mat
% load ploterr2.mat
% load ploterr5.mat
% load ploterr10.mat

Ts = 15;
data_points = 565;

storedStructure = load('C:\RTL1090\dump1090-win.1.10.3010.14\Diss-Results\RYR8088\RMSECV35.mat', 'plotrmse'); % Load in ONLY the myVar variable.
ploterr1 = storedStructure.plotrmse; 
clear('storedStructure');

storedStructure = load('C:\RTL1090\dump1090-win.1.10.3010.14\Diss-Results\RYR8088\RMSECA35.mat', 'ploterr'); % Load in ONLY the myVar variable.
ploterr2 = storedStructure.ploterr; 
clear('storedStructure');

storedStructure = load('C:\RTL1090\dump1090-win.1.10.3010.14\Diss-Results\RYR8088\RMSEIMM235.mat', 'RMSE'); % Load in ONLY the myVar variable.
ploterr3 = storedStructure.RMSE; 
clear('storedStructure');

storedStructure = load('C:\RTL1090\dump1090-win.1.10.3010.14\Diss-Results\RYR8088\RMSEIMM2D35.mat', 'RMSE'); % Load in ONLY the myVar variable.
ploterr4 = storedStructure.RMSE; 
clear('storedStructure');

storedStructure = load('C:\RTL1090\dump1090-win.1.10.3010.14\Diss-Results\RYR8088\RMSEIMM3D35.mat', 'RMSE'); % Load in ONLY the myVar variable.
ploterr5 = storedStructure.RMSE; 
clear('storedStructure');

figure(5);
plot(2:Ts:data_points,ploterr1,'-b',2:Ts:data_points,ploterr2,'-r',2:Ts:data_points,ploterr3,'-k',2:Ts:data_points,ploterr4,'-m',2:Ts:data_points,ploterr5,'-g');
% plot(2:Ts:data_points,ploterr1,2:Ts:data_points,ploterr2)
grid on;
title('RMSE of Filtering Methods Flight RYR8088');
xlabel('Timestep (s)');
ylabel('RMSE (m)');
legend({'CV Filter','CA Filter','CA-CV-IMM','CA-CV-CT2D','CA-CV-CT-3D'},'Location','northwest');
