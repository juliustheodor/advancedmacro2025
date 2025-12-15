%% Simulate three AR(1) processes (T=200) 
% Julius Schoelkopf, M.Sc. (December 2025) 

% y_t = phi * y_{t-1} + eps_t,  eps_t ~ N(0,1)

clear; clc; close all;

%% Parameters
T   = 200;
phi = [0.8, 0.1, 1];      % AR coefficients
rng(1,'twister');           % reproducibility


% Simulation

epsi = randn(T, numel(phi));    
y    = zeros(T, numel(phi));

% Initial condition 
y(1,:) = epsi(1,:);

for t = 2:T
    y(t,:) = phi .* y(t-1,:) + epsi(t,:);
end


%% Figure 
tgrid = 1:T;

figure('Color','w');
    plot(tgrid, y(:,2), 'LineWidth', 1.2, 'Color', 'r', 'LineWidth', 2); hold on 
    plot(tgrid, y(:,1), 'LineWidth', 1.2, 'Color', 'b', 'LineWidth', 2);
    plot(tgrid, y(:,3), 'LineWidth', 1.2, 'Color', 'k', 'LineWidth', 2);
    grid on; box on;
    xlim([1 T]);
    xlabel('$t$');
    legend('$\rho = 0.1$',  '$\rho = 0.8$',  '$\rho = 1$', 'Interpreter','latex',  'FontSize', 20, 'Color', 'w', 'TextColor', 'k');
    set(gcf,'color','w',  'Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    set(gca, 'FontSize', 20, 'TickLabelInterpreter','latex',  'color', 'w',  'XColor', 'k', 'YColor', 'k')
    title('Simulated AR(1) processes', 'Interpreter','latex');
    saveas(gcf,'figures/Figure0.png')