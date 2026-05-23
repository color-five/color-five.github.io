%% ============================================================
%  二自由度机械臂：关节角随机误差传播分析
%  两个关节角随机误差均服从 N(0, 0.01²)
%% ============================================================

clear; clc; close all;

%% 1. 参数设置
a1 = 1.0;           % 臂1长度 (m)
a2 = 0.8;           % 臂2长度 (m)
sigma_theta = 0.01; % 关节角随机误差标准差 (rad)

% 关节角范围
theta1 = linspace(0, pi/2, 100);      % 0~90°
theta2 = linspace(-pi/2, pi/2, 100);  % -90°~+90°
[TH1, TH2] = meshgrid(theta1, theta2);

%% 2. 随机误差传播公式推导
% 末端位置:
%   x = a1*cos(θ1) + a2*cos(θ1+θ2)
%   y = a1*sin(θ1) + a2*sin(θ1+θ2)
%
% 误差传播系数（偏导数）:
%   ∂x/∂θ1 = -a1*sin(θ1) - a2*sin(θ1+θ2)
%   ∂x/∂θ2 = -a2*sin(θ1+θ2)
%   ∂y/∂θ1 =  a1*cos(θ1) + a2*cos(θ1+θ2)
%   ∂y/∂θ2 =  a2*cos(θ1+θ2)
%
% 随机误差独立，方差合成:
%   σx² = (∂x/∂θ1)²·σθ1² + (∂x/∂θ2)²·σθ2²
%   σy² = (∂y/∂θ1)²·σθ1² + (∂y/∂θ2)²·σθ2²
%
% 总位置标准差:
%   σp = sqrt(σx² + σy²)

% 计算偏导数
dx_dth1 = -a1*sin(TH1) - a2*sin(TH1 + TH2);
dx_dth2 = -a2*sin(TH1 + TH2);
dy_dth1 =  a1*cos(TH1) + a2*cos(TH1 + TH2);
dy_dth2 =  a2*cos(TH1 + TH2);

% x方向方差
sigma_x2 = dx_dth1.^2 * sigma_theta^2 + dx_dth2.^2 * sigma_theta^2;
sigma_x = sqrt(sigma_x2);

% y方向方差
sigma_y2 = dy_dth1.^2 * sigma_theta^2 + dy_dth2.^2 * sigma_theta^2;
sigma_y = sqrt(sigma_y2);

% 总位置标准差
sigma_p = sqrt(sigma_x2 + sigma_y2);

fprintf('================ 随机误差传播分析 ================\n');
fprintf('臂长: a1=%.1fm, a2=%.1fm\n', a1, a2);
fprintf('关节角随机误差: σθ = %.4frad (%.3f°)\n', sigma_theta, rad2deg(sigma_theta));

%% 3. x方向标准差曲面
figure('Name', 'x方向标准差曲面', 'Position', [50 550 600 450]);

surf(rad2deg(TH1), rad2deg(TH2), sigma_x*1000, 'EdgeColor', 'none');
colorbar;
xlabel('\theta_1 (°)', 'FontSize', 12);
ylabel('\theta_2 (°)', 'FontSize', 12);
zlabel('\sigma_x (mm)', 'FontSize', 12);
title('x方向位置标准差', 'FontSize', 13);
colormap(jet);
shading interp;

fprintf('\nx方向标准差范围: %.4f ~ %.4f mm\n', min(sigma_x(:))*1000, max(sigma_x(:))*1000);

%% 4. y方向标准差曲面
figure('Name', 'y方向标准差曲面', 'Position', [700 550 600 450]);

surf(rad2deg(TH1), rad2deg(TH2), sigma_y*1000, 'EdgeColor', 'none');
colorbar;
xlabel('\theta_1 (°)', 'FontSize', 12);
ylabel('\theta_2 (°)', 'FontSize', 12);
zlabel('\sigma_y (mm)', 'FontSize', 12);
title('y方向位置标准差', 'FontSize', 13);
colormap(jet);
shading interp;

fprintf('y方向标准差范围: %.4f ~ %.4f mm\n', min(sigma_y(:))*1000, max(sigma_y(:))*1000);

%% 5. 总位置标准差曲面
figure('Name', '总位置标准差曲面', 'Position', [50 50 600 450]);

surf(rad2deg(TH1), rad2deg(TH2), sigma_p*1000, 'EdgeColor', 'none');
colorbar;
xlabel('\theta_1 (°)', 'FontSize', 12);
ylabel('\theta_2 (°)', 'FontSize', 12);
zlabel('\sigma_p (mm)', 'FontSize', 12);
title('末端位置总标准差', 'FontSize', 13);
colormap(jet);
shading interp;

fprintf('总位置标准差范围: %.4f ~ %.4f mm\n', min(sigma_p(:))*1000, max(sigma_p(:))*1000);

%% 6. 误差特性分析
fprintf('\n================ 误差特性分析 ================\n');

% 极值位置
[max_sig, max_idx] = max(sigma_p(:));
[max_i, max_j] = ind2sub(size(TH1), max_idx);
fprintf('最大总标准差: %.4f mm\n', max_sig*1000);
fprintf('  出现在 θ1=%.1f°, θ2=%.1f°\n', rad2deg(TH1(max_i,max_j)), rad2deg(TH2(max_i,max_j)));

[min_sig, min_idx] = min(sigma_p(:));
[min_i, min_j] = ind2sub(size(TH1), min_idx);
fprintf('最小总标准差: %.4f mm\n', min_sig*1000);
fprintf('  出现在 θ1=%.1f°, θ2=%.1f°\n', rad2deg(TH1(min_i,min_j)), rad2deg(TH2(min_i,min_j)));

% 理论验证
fprintf('\n理论验证:\n');
% 总方差 = [(dx_dth1)²+(dx_dth2)²+(dy_dth1)²+(dy_dth2)²] * σθ²
% 展开化简:
% (dx_dth1)²+(dy_dth1)² = a1² + a2² + 2*a1*a2*cos(θ2)
% (dx_dth2)²+(dy_dth2)² = a2²
% 所以: σp² = [a1² + 2*a2² + 2*a1*a2*cos(θ2)] * σθ²

fprintf('  理论公式: σp² = [a1² + 2a2² + 2a1·a2·cos(θ2)] · σθ²\n');
fprintf('  当θ2=0°时: σp = %.4f mm\n', sqrt(a1^2+2*a2^2+2*a1*a2)*sigma_theta*1000);
fprintf('  当θ2=±90°时: σp = %.4f mm\n', sqrt(a1^2+2*a2^2)*sigma_theta*1000);
fprintf('  当θ2=±180°时: σp = %.4f mm\n', sqrt(a1^2+2*a2^2-2*a1*a2)*sigma_theta*1000);
