%% Plot the Raw Data

close all
clear all

% Step DOWN
% file_nameH = 'Down_15BMP50_1.csv';
% file_nameHABC = 'Down_7500HABC_15BMP50_4.csv';
% time_lim = 20;
% move_t = 1.5;
% move_tabc =0;

% Step UP
file_nameH = 'UP_15BMP50_5.csv';
file_nameHABC = 'UP_7500HABC_15BMP50_1.csv';
move_t = 32;
time_lim = 27;
move_tabc = 94.7;

%Continuous
% file_nameH = '7500H_25BMP100.csv';
% file_nameHABC = '7500HABC_25BMP100.csv';
% time_lim = 35;
% move_t = 0.2;
% move_tabc = 0;


% Data format:
% [current_time o2_concentration o2_flow o2_temperature status]
dataH = readmatrix(file_nameH);
dataHABC = readmatrix(file_nameHABC);

%STEP UP
dataHABC = dataHABC(947:end, :);


% Define sensor parameters
% Accuracy
conc_accuracy  = 1.5;
flow_accuracy  = [0.2, 0.1]; % 7500H,7500HA-BC
temp_accuracy  = 1; % Not specified on the datasheet

% Range
flow_range = [10, 2];

%Index to access data
time_idx = 1;
conc_idx = 2;
flow_idx = 3;
temp_idx = 4;





% Initiate graphs
figure();
plot(dataH(:, time_idx)-move_t, dataH(:, conc_idx),'b', 'LineWidth',2);
hold on 
plot(dataHABC(:, time_idx)- move_tabc, dataHABC(:, conc_idx),'G', 'LineWidth',2);
title ('\textbf{Concentration}','interpreter','latex');
ylabel("$O_2$ ($\%$)",'interpreter','latex');
grid on 
set(gca,'ytick',[0:5*conc_accuracy:100])
grid minor
%ylim([80,100]);
ylim([0,100]);
xlim([0 time_lim])
xlabel("Time (s)")
legend("Gasboard 7500H", "Gasboard 7500HA-BC");

figure();
plot(dataH(:, time_idx)-move_t, dataH(:, flow_idx),'b', 'LineWidth',2);
hold on 
plot(dataHABC(:, time_idx)- move_tabc, dataHABC(:, flow_idx),'G', 'LineWidth',2);
title(" \textbf{Flow}",'interpreter','latex');
ylabel("Flow (L/min)",'interpreter','latex');
grid on 
set(gca,'ytick',[0:5*flow_accuracy(1):flow_range(1)])
grid minor
ylim([0,flow_range(1)]);
xlabel("Time (s)")
xlim([0 time_lim])
legend("Gasboard 7500H", "Gasboard 7500HA-BC");

figure();
plot(dataH(:, time_idx)-move_t, dataH(:, temp_idx),'b', 'LineWidth',2);
hold on 
plot(dataHABC(:, time_idx)-move_tabc, dataHABC(:, temp_idx),'G', 'LineWidth',2);
title("\textbf{Temperature}",'interpreter','latex')
ylabel("$O_2$ Temperature ( $^{\circ}C$)",'interpreter','latex');
xlabel("Time (s)");
grid on 
set(gca,'ytick',[0:5*temp_accuracy:50])
grid minor
ylim([20,30]);
xlim([0 time_lim])
legend("Gasboard 7500H", "Gasboard 7500HA-BC");
