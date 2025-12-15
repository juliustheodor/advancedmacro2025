%% Problem Set 8, Exercise 1
% Julius Schoelkopf, M.Sc. (December 2025) 

% Code for decomposing GDP, consumption, and investment time series into
% trend and cyclical component using the HP filter.

% Clean up and delete previous results 
clear; close all; clc;

% Path where the figures will be saved
addpath 'figures/'

%% Download Data from FRED 
% You need the Datafeed package to download the Data from FRED

fredfetch   = fred('https://fred.stlouisfed.org/');

fredfetch.DataReturnFormat = 'table';
fredfetch.DatetimeType = 'datetime';

startdate = '01/01/1996';
enddate = '09/01/2025';

GDP = fetch(fredfetch,'CLVMNACSCAB1GQDE',startdate,enddate); 

% Consumption and Investment are not available on FRED until Q2:2025 
startdate = '01/01/1996';
enddate = '01/01/2025';

Consumption = fetch(fredfetch,'DEUPFCEQDSNAQ',startdate,enddate); 
Investment = fetch(fredfetch,'DEUGFCFQDSNAQ',startdate,enddate); 
close(fredfetch);

%% Extract time series of interest
gdp = GDP.Data{1};         % GDP
cons = Consumption.Data{1}; % Consumption
invest = Investment.Data{1};  % Investment

y = table2array(gdp(:,2));  % GDP
c = table2array(cons(:,2)); % Consumption
i = table2array(invest(:,2)); % Investment

% We want to save the downloaded data
save macrodata.mat 

% Specify time variable.
t = (1996.0:0.25:2025.5)';

%% Figure 1: Time series of German GDP 
figure 
    plot(t, log(y), 'k', 'LineWidth', 2);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex',  'color', 'w',  'XColor', 'k', 'YColor', 'k')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('$\log(GDP)$', 'Interpreter','latex', 'FontSize', 20, 'Color', 'w', 'TextColor', 'k');
    xlim([1996 2026])           % sets visible range
    xticks(2000:5:2025)         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex')
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex')
    saveas(gcf,'figures/Figure1GermanGDP.png')

%% Question 1.2 & Figure 2: Linear trend for German GDP 
% Define trend variable 
x = (1:length(y))';
% Add a column of ones to x for the intercept
x_with_const = [ones(size(x, 1), 1), x];

% estimate linear trend for the whole sample: 
% log(GDP_t) = beta_0  + beta_1*t 
b = regress(log(y),x_with_const);
lin =  b(1) + b(2)*x ;

% Figure 2 
figure
    h = plot(t, [log(y) lin],'LineWidth',1.5);
    set(h(1),'color','b');
    set(h(2),'color','r'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex',  'color', 'w',  'XColor', 'k', 'YColor', 'k')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('$\log(GDP)$', 'Trend', 'Interpreter','latex',  'FontSize', 20 , 'Color', 'w', 'TextColor', 'k'); 
    xlim([1996 2026])           % sets visible range
    xticks(2000:5:2025)         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex')
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex')
    saveas(gcf,'figures/Figure2GermanGDPLinearTrend.png')

%% Figure 3: Estimate linear trend for different samples 

% take first part of the sample: 1996-2002 
b_begin = regress(log(y(1:29)),x_with_const(1:29,:));
lin_begin = b_begin(1) + b_begin(2)*x ;

% take another part of the sample 2003-2014 (Great Recession) 
b_middle = regress(log(y(30:76)),x_with_const(30:76,:));
lin_middle = b_middle(1) + b_middle(2)*x ;

% take the pre-Covid and Covid period (2015-2023)
b_cov = regress(log(y(77:109)),x_with_const(77:109,:));
lin_cov = b_cov(1) + b_cov(2)*x ;

% take the last part of the sample (2022-2025) 
b_end = regress(log(y(105:end)),x_with_const(105:end,:));
lin_end = b_end(1) + b_end(2)*x ;

% Plot the different estimated trends with the trend for the full sample
figure
    h = plot(t, [log(y) lin lin_begin lin_middle lin_cov lin_end],'LineWidth',1.5);
    set(h(1),'color','b', 'LineWidth', 3);
    set(h(2),'color','r', 'LineWidth', 3);
    set(h(3),'color','c')
    set(h(4),'color','k')
    set(h(5),'color', 'm')
    set(h(6),'color', 'g')
    line([2003, 2003], ylim, 'Color', 'c', 'LineWidth', 2, 'LineStyle', '--'); 
    line([2015, 2015], ylim, 'Color', 'm', 'LineWidth', 2, 'LineStyle', '--'); 
    line([2022, 2022], ylim, 'Color', 'g', 'LineWidth', 2, 'LineStyle', '--'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex',  'color', 'w',  'XColor', 'k', 'YColor', 'k')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('$\log(GDP)$', 'Trend (1996-2025)', 'Trend (1996-2002)', 'Trend (2003-2014)', 'Trend (2015-2023)', 'Trend (2022-2025)' , 'Interpreter','latex',  'FontSize', 20, 'Color', 'w', 'TextColor', 'k');
    xlim([1996 2026]);        % sets visible range
    xticks(2000:5:2025);          % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex')
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex')
    saveas(gcf,'figures/Figure3GermanGDPLinearTrendSamples.png')

%% Question 1.3.: Using the HP filter 
% Set smoothing parameter for the HP filter.
% lambda = 1600 is suggested for quarterly data by Ravn and Uhlig (2002) 
lambda = 1600;

%% Filter the time series for GDP, consumption and investment 
% [Trend,Cyclical] = hpfilter(Y) returns the additive trend and cyclical
% components (from the Econometrics Toolbox) 
[y_trend, y_cyc] = hpfilter(log(y), Smoothing = lambda);
[c_trend, c_cyc] = hpfilter(log(c), Smoothing = lambda);
[i_trend, i_cyc] = hpfilter(log(i), Smoothing = lambda);


%% Question 1.4.: Plot time series and trend component.
figure
subplot(3,1,1)
    h(1) = plot(t, log(y), 'b', 'LineWidth', 3);
    hold on
    h(2) = plot(t, y_trend, 'b--', 'LineWidth', 3);
    hold off 
    axis tight
    legend('GDP','Trend GDP', 'Location', 'Northwest', 'Interpreter','latex', 'Color', 'w', 'TextColor', 'k', 'Color', 'w');
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex',  'color', 'w',  'XColor', 'k', 'YColor', 'k');
    title(['GDP Series and Trend Component ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex',   'Color', 'k')

subplot(3,1,2)
    h(3) = plot(t(1:113), log(c), 'r', 'LineWidth', 3);
    hold on
    h(4) = plot(t(1:113), c_trend, 'r--', 'LineWidth', 3);
    hold off
    legend('Consumption','Trend Consumption', 'Location', 'Northwest', 'Interpreter','latex', 'TextColor', 'k', 'Color', 'w');
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex'); 
    axis tight
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex', 'color', 'w',  'XColor', 'k', 'YColor', 'k');
    title(['Consumption Series and Trend Component ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex',   'Color', 'k')

subplot(3,1,3)
    h(5) = plot(t(1:113), log(i), 'k', 'LineWidth', 3);
    hold on
    h(6) = plot(t(1:113), i_trend, 'k--', 'LineWidth', 3);
    legend('Investment','Trend Investment', 'Location', 'Northwest', 'Interpreter','latex', 'TextColor', 'k', 'Color', 'w' );
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex', 'color', 'w',  'XColor', 'k', 'YColor', 'k');
    title(['Investment Series and Trend Component ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex',  'Color', 'k'); 
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

saveas(gcf,'figures/Figure4.png')

%% Plot cyclical component of the time series.
figure
subplot(3,1,1)
    plot(t, y_cyc, 'b', 'LineWidth', 3);
    axis tight
    set(gca, 'FontSize', 15)
    legend('GDP', 'Interpreter','latex', 'Color', 'w', 'TextColor', 'k', 'Location', 'southwest'); 
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gca, 'FontSize', 15, 'TickLabelInterpreter','latex', 'color', 'w',  'XColor', 'k', 'YColor', 'k');
    title('Cyclical Component of GDP','interpreter','latex', 'FontWeight', 'bold',   'Color', 'k'); 

subplot(3,1,2)
    plot(t, y_cyc, 'b', 'LineWidth', 3);
    hold on
    plot(t(1:113), c_cyc, 'r--', 'LineWidth', 3);
    axis tight
    legend('GDP','Consumption', 'Interpreter','latex', 'Color', 'w', 'TextColor', 'k', 'Location', 'southwest' );
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gca, 'FontSize', 15, 'TickLabelInterpreter','latex', 'color', 'w',  'XColor', 'k', 'YColor', 'k'); 
    title('Cyclical Component of Consumption','interpreter','latex', 'FontWeight', 'bold',   'Color', 'k'); 

subplot(3,1,3)
    plot(t, y_cyc, 'b', 'LineWidth', 3);
    hold on
    plot(t(1:113), i_cyc, 'r--', 'LineWidth', 3);
    axis tight
    legend('GDP','Investment', 'Interpreter','latex', 'Color', 'w', 'TextColor', 'k', 'Location', 'southwest');
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    title('Cyclical Component of Investment','interpreter','latex', 'FontWeight', 'bold',   'Color', 'k'); 
    set(gca, 'FontSize', 15, 'TickLabelInterpreter','latex', 'color', 'w',  'XColor', 'k', 'YColor', 'k');
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);

saveas(gcf,'figures/Figure5.png')

%% Question 1.6. & Figure 6: Illustrating the effect of lambda 
% Decompose GDP using lambda = 10 (almost no cycle) and lambda = 10000 
% (close to linear trend) 
[y_trend_10, y_cyc_10] = hpfilter(log(y), Smoothing = 10);
[y_trend_10000, y_cyc_10000] = hpfilter(log(y), Smoothing = 10000);

figure 
    h(1) = plot(t, log(y), 'k', 'LineWidth', 3);
    hold on 
    h(2) = plot(t, y_trend, 'r', 'LineWidth', 2);
    hold on 
    h(3) = plot(t, y_trend_10, 'g', 'LineWidth', 2);
    hold on 
    h(4) = plot(t, y_trend_10000, 'b', 'LineWidth', 2);
    hold off
    set(gca, 'FontSize', 20, 'TickLabelInterpreter', 'latex', 'color', 'w',  'XColor', 'k', 'YColor', 'k');
    xlim([1996 2026]);           % sets visible range
    xticks(2000:5:2025);         % sets tick positions
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    ylabel('log(GDP)', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    legend('GDP','Trend $\lambda = 1600$','Trend $\lambda = 10$','Trend $\lambda = 10000$', 'Interpreter','latex',  'FontSize', 20, 'TextColor', 'k', ...
        'Color', 'w', 'Location', 'southeast')
    saveas(gcf,'figures/Figure6.png')

%% Question 1.6. & Figure 7 and 8: Illustrating the instability at the margin 

y_trend = cell(1, 118);
y_cycle   = cell(1, 118);

for n = 95:118
    [y_trend{n}, y_cycle{n}] = hpfilter(log(y(1:n)), Smoothing=lambda);
end

% Figure for trend 
figure
    h(1) = plot(t, log(y), 'k', 'LineWidth', 3);
    hold on

    % Plot each progressively longer trend
    for n = 95:118
        h(end+1) = plot(t(1:n), y_trend{n}, 'b', 'LineWidth', 1);
    end
    xlim([2015 2026]);           % sets visible range
    xticks(2015:2:2025);         % sets tick positions
    set(gca, 'FontSize', 20, 'TickLabelInterpreter', 'latex', ...
         'XColor', 'k', 'YColor', 'k', 'Color', 'w')
    set(gcf, 'Color', 'w', 'Units', 'Normalized', ...
         'OuterPosition', [0, 0.04, 1, 0.96]);
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    title(['Trend Component of GDP ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex',   'Color', 'k')
    saveas(gcf, 'figures/Figure7.png')

% Figure for cycle 
figure
    hold on
    % Plot each progressively longer cycle 
    for n = 95:118
        h(end+1) = plot(t(1:n), y_cycle{n}, 'b', 'LineWidth', 1);
    end

    set(gca, 'FontSize', 20, 'TickLabelInterpreter', 'latex', ...
         'XColor', 'k', 'YColor', 'k', 'Color', 'w')
    set(gcf, 'Color', 'w', 'Units', 'Normalized', ...
         'OuterPosition', [0, 0.04, 1, 0.96]);
    xlim([2015 2026]);           % sets visible range
    xticks(2015:2:2025);         % sets tick positions
    yline(0, '--k', 'LineWidth', 1.5);   % dashed black line at zero
    xlabel('Year', 'Color', 'k', 'Interpreter', 'latex'); 
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex')
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    title(['Cyclical Component of GDP ($\lambda$ = ' ,num2str(lambda),')'],'interpreter','latex',   'Color', 'k')
    saveas(gcf,'figures/Figure8.png')

%% Question 1.6: Compute standard deviations (relative to the standard deviation of GDP).
std_y = std(y_cyc(1:113));
std_c = std(c_cyc) / std(y_cyc(1:113));
std_i = std(i_cyc) / std(y_cyc(1:113));

disp(['Standard deviation of output: ' num2str(std(y_cyc))]) 
disp(['Standard deviation of investment: ' num2str(std(i_cyc))]) 
disp(['Standard deviation of consumption: ' num2str(std(c_cyc))]) 
disp(['Standard deviation of consumption relative to output: ' num2str(std_c)]) 
disp(['Standard deviation of investment relative to output: ' num2str(std_i)]) 