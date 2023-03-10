%% Estimate sensor model

% Kamilla Peixoto, Scaleo Medical
% v1 - 08/03/2023

clear all
close all

%% Import Experimental Data from  CSV file

% Define if the input was an step up (From ambient concentration to
% concentrator) or an step down (turning of the concentrator)

%% DEFINED MANUALY BY THE USER 

%The name of the file MUST start with 'U' for Step Up and 'D' for Step Down 
file_name = 'Down_15BMP50_1.csv';
%file_name = 'UP_15BMP50_5.csv';

% The moment which the experimental conditions changes in seconds
step_time = 13.7; %Down_15BMP50_1.csv'
%step_time = 16; %Down_15BMP50_2.csv'
%step_time = 42.4;%'UP_15BMP50_5.csv';

% Number of poles of the estimated model
conc_np = 1;
flow_np = 1;
temp_np = 1;

%%
% Data format:
% [current_time o2_concentration o2_flow o2_temperature status]
data = readmatrix(file_name);

%Index to access data
time_idx = 1;
conc_idx = 2;
flow_idx = 3;
temp_idx = 4;

% Get the sample time
ts = data(2,time_idx) - data (1,time_idx);



% Define the input
step_in = zeros(1,length(data));

if (file_name(1) == 'U') %Step Up

    % Remove initial values
    offset = mean(data(1:step_time/ts, conc_idx));
    data(:, conc_idx) = data(:, conc_idx)-offset;

    step_in(step_time/ts:end) = 1;
  
else % Step Down

    % Remove final values
    offset = mean(data((step_time+3)/ts:end, conc_idx));
   data(:, conc_idx) = data(:, conc_idx)-offset;

    step_in(1:step_time/ts) = 1;

end

% Concentration
concentration_tf =  tfest(step_in',data(:, conc_idx),conc_np,'Ts',ts)
concentration_ss =  ssest(step_in',data(:, conc_idx),conc_np,'Ts',ts)

figure()
plot(data(:, time_idx), data(:, conc_idx), 'LineWidth',2);
hold on
plot(data(:, time_idx), lsim(concentration_ss,step_in,data(:, time_idx)),'LineWidth',2);
plot(data(:, time_idx), lsim(concentration_tf,step_in,data(:, time_idx)),'LineWidth',2);
legend('Experimental', 'Estimated SS',  'Estimated TF','interpreter','latex');
ylabel("$O_2$ Concentration ($\%$)",'interpreter','latex');
grid on 
conc_accuracy  = 1.5;
set(gca,'ytick',[0:5*conc_accuracy:100])
grid minor
ylim([0,100]);
xlabel("Time (s)", 'interpreter','latex')
title("Gasboard 7500H", 'interpreter','latex');

