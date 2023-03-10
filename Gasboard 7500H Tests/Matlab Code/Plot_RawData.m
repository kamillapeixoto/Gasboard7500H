%% Plot the Raw Data

    file_name = 'UP_7500HABC_15BMP50_1.csv';
%file_name = 'UP_15BMP50_5.csv';
%file_name = 'test_ts01_75h_10bmp_Set_5to025.csv'

sensor = 1;

% Data format:
% [current_time o2_concentration o2_flow o2_temperature status]
data = readmatrix(file_name);

title_str = {"Gasboard 7500H"; "Gasboard 7500HA-BC"};

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


time_lim = 125;


% Initiate graphs
figure();

subplot(3,1,1)
plot(data(:, time_idx), data(:, conc_idx),'k', 'LineWidth',2);
title (title_str{sensor},'interpreter','latex');
ylabel("$O_2$ Concentration ($\%$)",'interpreter','latex');
grid on 
set(gca,'ytick',[0:5*conc_accuracy:100])
grid minor
ylim([0,100]);
xlim([0 time_lim])
xlabel("Time (s)")

subplot(3,1,2)
plot(data(:, time_idx), data(:, flow_idx),'k', 'LineWidth',2);
ylabel("$O_2$ Flow (L/min )",'interpreter','latex');
grid on 
%set(gca,'ytick',[0:5*flow_accuracy(sensor):x_max])
grid minor
ylim([0,flow_range(sensor)+10]);
xlabel("Time (s)")
xlim([0 time_lim])

subplot(3,1,3)
plot(data(:, time_idx), data(:, temp_idx),'k', 'LineWidth',2);
ylabel("$O_2$ Temperature ( $^{\circ}C$)",'interpreter','latex');
xlabel("Time (s)");
grid on 
set(gca,'ytick',[0:5*temp_accuracy:50])
grid minor
ylim([25,30]);
xlim([0 time_lim])

