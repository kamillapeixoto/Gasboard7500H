%% Serial Communication
% This program aims to read data from Oxygen Sensors via Serial
% Communication and store them on a CSV file with the format:
% [current_time o2_concentration o2_flow o2_temperature status]

% Kamilla Peixoto, Scaleo Medical
% v1 - 03/03/2023
% v2 - 06/03/2023 - Visualization improvement
% v3 - 08/03/2023 - Pos processing

%close all
clear all

%% Setup
%% Gasboard 7500H-series

% Define sensor parameters
% Accuracy
conc_accuracy  = 1.5;
flow_accuracy  = [0.2, 0.1]; % 7500H,7500HA-BC
temp_accuracy  = 1; % Not specified on the datasheet

% Range
flow_range = [10, 2];

title_str = {"Gasboard 7500H"; "Gasboard 7500HA-BC"};


ts = 0.1;  % Sample time in seconds. Default is 0.5
count = 0; % Count the inst read data
count_total = 0; % Count the total read data


% Amount of points to plot
n_sample = 100;
x_min = 0; 
x_max = n_sample*ts; % Maximum time to plot


% Store Data
% Instantaneous variables to avoid resizing and big storage during the
% online processing because it makes the plotting slow
o2_concentration = zeros(1,n_sample);
o2_flow          = zeros(1,n_sample);
o2_temperature   = zeros(1,n_sample);
status           = zeros(1,n_sample); % Zero meansn a correct reading
current_time     = zeros(1,n_sample);
overtime         = 0; % How many times the loop took longer than expected

% Permanent variables to store all data and save it later on a file
o2_concentration_tot = [];
o2_flow_tot          = [];
o2_temperature_tot   = [];
status_tot           = [];
current_time_tot     = [];

%% Initiation

% Start Serial Communication
% Baud Rate: 9600, Data Bits: 8, Stop Bits: 1, Parity: No, Flow Control: No
baud_rate = 9600;
s = serialport(serialportlist("available"),baud_rate);

% The sensor only will send data when requested
keyword = [0x11 0x01 0x07 0xE7];
write(s,keyword,"uint8"); 
flush(s);

% Chose the Sensor
sensor    = menu("Sensor:","7500H","7500HA-BC");

% Chose the reading mode
mode      = menu("Range","Default","Expanded");


% Initiate graphs
figure();

subplot(3,1,1)
title (title_str{sensor},'interpreter','latex');
ylabel("$O_2$ Concentration ($\%$)",'interpreter','latex');
grid on 
%ax = gca;
%ax.XGrid = 'off';
set(gca,'ytick',[0:5*conc_accuracy:100])
grid minor
%ax = gca;
%ax.XGrid = 'off';
xlim([0, x_max]);
ylim([0,100]);
%xlabel("Time (s)")
hold on

subplot(3,1,2)
ylabel("$O_2$ Flow (L/min )",'interpreter','latex');
grid on 
set(gca,'ytick',[0:5*flow_accuracy(sensor):x_max])
grid minor
xlim([0, x_max]);
ylim([0,flow_range(sensor)+2]);
%xlabel("Time (s)")
hold on

subplot(3,1,3)
ylabel("$O_2$ Temperature ( $^{\circ}C$)",'interpreter','latex');
xlabel("Time (s)");
grid on 
set(gca,'ytick',[0:5*temp_accuracy:50])
grid minor
xlim([0, x_max]);
ylim([0,50]);
hold on


%% Readings

while (true)
    tic

    count = count + 1;
    count_total = count_total + 1; %It would be interesting to change the logic to have only one counter

    current_time(count) = count_total*ts;

    % Calculate parameters
    [o2_concentration(count), o2_flow(count), o2_temperature(count), status(count)] = read_o2(s,mode);


    % Plot data
    subplot(3,1,1)
    plot(current_time(count), o2_concentration(count),'-ok', 'MarkerSize', 1);
    hold on

    subplot(3,1,2)
    plot(current_time(count), o2_flow(count),'-ok', 'MarkerSize', 1);
    hold on
    
    subplot(3,1,3)
    plot(current_time(count), o2_temperature(count),'-ok', 'MarkerSize', 1);
    hold on

    if (count_total == x_max/ts)
        % Update the plot range
        x_min = x_min + n_sample*ts/2;
        x_max = x_max + n_sample*ts/2;

        subplot(3,1,1)
        xlim([x_min, x_max])
        hold on

        subplot(3,1,2)
        xlim([x_min, x_max])
        hold on

        subplot(3,1,3)
        xlim([x_min, x_max])
        hold on

        %Copy and clean instantaneous variables
        o2_concentration_tot = [o2_concentration_tot o2_concentration];
        o2_flow_tot          = [o2_flow_tot o2_flow];
        o2_temperature_tot   = [o2_temperature_tot o2_temperature];
        status_tot           = [status_tot status];
        current_time_tot     = [current_time_tot current_time];

        %clear o2_concentration o2_flow o2_temperature status
        o2_concentration = zeros(1,n_sample/2);
        o2_flow          = zeros(1,n_sample/2);
        o2_temperature   = zeros(1,n_sample/2);
        status           = zeros(1,n_sample/2); % Zero means a correct reading
        current_time     = zeros(1,n_sample/2);

        count = 0;
    end
    
    % Guarantees the same duration for all the loops
    pause_time = ts-toc;
    if pause_time >= 0
        pause(pause_time);
    else 
        overtime = overtime +1;
    end

end

%% Store

% Get the remaining data that wasn't stored
if (count ~= x_max/ts)
        o2_concentration_tot = [o2_concentration_tot o2_concentration(1:count-1)];
        o2_flow_tot          = [o2_flow_tot o2_flow(1:count-1)];
        o2_temperature_tot   = [o2_temperature_tot o2_temperature(1:count-1)];
        status_tot           = [status_tot status(1:count-1)];
        current_time_tot     = [current_time_tot current_time(1:count-1)];
end
        
file_name = 'UP_7500HABC_15BMP50_1.csv'; 
% file_name = 'UP_15BMP50_9.csv'; %SMALL HOSE

writematrix([current_time_tot; o2_concentration_tot; o2_flow_tot; o2_temperature_tot; status_tot]', file_name)
