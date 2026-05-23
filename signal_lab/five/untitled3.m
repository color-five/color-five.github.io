%% ============================================================
%  二自由度机械臂关节角零偏误差传播分析
%  仅考虑关节角1的零偏误差影响
%% ============================================================

clear; clc; close all;

%% 1. 参数设置
a1 = 1.0;           % 臂1长度 (m)
a2 = 0.8;           % 臂2长度 (m)
dtheta = 0.05;      % 零偏误差 (rad)

% 关节角范围
theta1 = linspace(0, pi/2, 100);      % 0~90°
theta2 = linspace(-pi/2, pi/2, 100);  % -90°~+90°

[TH1, TH2] = meshgrid(theta1, theta2);

%% 2. 系统误差传播公式推导
% 末端位置:
%   x = a1*cos(θ1) + a2*cos(θ1+θ2)
%   y = a1*sin(θ1) + a2*sin(θ1+θ2)
%
% 仅θ1存在零偏误差Δθ1时，对x,y求偏导:
%
%   ∂x/∂θ1 = -a1*sin(θ1) - a2*sin(θ1+θ2)
%   ∂y/∂θ1 =  a1*cos(θ1) + a2*cos(θ1+θ2)
%
% 误差传播:
%   Δx = (∂x/∂θ1) * Δθ1 = [-a1*sin(θ1) - a2*sin(θ1+θ2)] * Δθ
%   Δy = (∂y/∂θ1) * Δθ1 = [ a1*cos(θ1) + a2*cos(θ1+θ2)] * Δθ

% 计算偏导数（误差传播系数）
dx_dth1 = -a1*sin(TH1) - a2*sin(TH1 + TH2);
dy_dth1 =  a1*cos(TH1) + a2*cos(TH1 + TH2);

% 末端位置误差
Delta_x = dx_dth1 * dtheta;
Delta_y = dy_dth1 * dtheta;

% 总位置误差（欧氏距离）
Delta_total = sqrt(Delta_x.^2 + Delta_y.^2);

fprintf('================ 关节角1零偏误差传播分析 ================\n');
fprintf('臂长: a1=%.1fm, a2=%.1fm\n', a1, a2);
fprintf('零偏误差: Δθ=%.4frad (%.2f°)\n', dtheta, rad2deg(dtheta));

%% 3. 绘制x方向误差曲面
figure('Name', 'x方向误差曲面', 'Position', [50 550 600 450]);

surf(rad2deg(TH1), rad2deg(TH2), abs(Delta_x)*1000, 'EdgeColor', 'none');
colorbar;
xlabel('\theta_1 (°)', 'FontSize', 12);
ylabel('\theta_2 (°)', 'FontSize', 12);
zlabel('|\Delta x| (mm)', 'FontSize', 12);
title('关节角1零偏误差引起的x方向位置误差', 'FontSize', 13);
colormap(jet);
shading interp;

fprintf('\nx方向误差范围: %.4f ~ %.4f mm\n', min(abs(Delta_x(:)))*1000, max(abs(Delta_x(:)))*1000);

%% 4. 绘制y方向误差曲面
figure('Name', 'y方向误差曲面', 'Position', [700 550 600 450]);

surf(rad2deg(TH1), rad2deg(TH2), abs(Delta_y)*1000, 'EdgeColor', 'none');
colorbar;
xlabel('\theta_1 (°)', 'FontSize', 12);
ylabel('\theta_2 (°)', 'FontSize', 12);
zlabel('|\Delta y| (mm)', 'FontSize', 12);
title('关节角1零偏误差引起的y方向位置误差', 'FontSize', 13);
colormap(jet);
shading interp;

fprintf('y方向误差范围: %.4f ~ %.4f mm\n', min(abs(Delta_y(:)))*1000, max(abs(Delta_y(:)))*1000);

%% 5. 绘制总位置误差曲面
figure('Name', '总位置误差曲面', 'Position', [50 50 600 450]);

surf(rad2deg(TH1), rad2deg(TH2), Delta_total*1000, 'EdgeColor', 'none');
colorbar;
xlabel('\theta_1 (°)', 'FontSize', 12);
ylabel('\theta_2 (°)', 'FontSize', 12);
zlabel('|\Delta p| (mm)', 'FontSize', 12);
title('关节角1零偏误差引起的总位置误差', 'FontSize', 13);
colormap(jet);
shading interp;

fprintf('总位置误差范围: %.4f ~ %.4f mm\n', min(Delta_total(:))*1000, max(Delta_total(:))*1000);

%% 6. 误差特性分析
fprintf('\n================ 误差特性分析 ================\n');

% 极值位置
[max_err, max_idx] = max(Delta_total(:));
[max_i, max_j] = ind2sub(size(TH1), max_idx);
fprintf('最大总误差: %.4f mm\n', max_err*1000);
fprintf('  出现在 θ1=%.1f°, θ2=%.1f°\n', rad2deg(TH1(max_i,max_j)), rad2deg(TH2(max_i,max_j)));

[min_err, min_idx] = min(Delta_total(:));
[min_i, min_j] = ind2sub(size(TH1), min_idx);
fprintf('最小总误差: %.4f mm\n', min_err*1000);
fprintf('  出现在 θ1=%.1f°, θ2=%.1f°\n', rad2deg(TH1(min_i,min_j)), rad2deg(TH2(min_i,min_j)));

% 验证: 总误差 = a1*dtheta (与θ1,θ2无关!)
% 因为: Δx² + Δy² = [dx_dth1² + dy_dth1²] * dtheta²
%      dx_dth1² + dy_dth1² = a1² + a2² + 2*a1*a2*cos(θ2)
% 所以总误差与θ1无关，仅与θ2有关

fprintf('\n理论验证:\n');
fprintf('  总误差 = sqrt(a1² + a2² + 2*a1*a2*cos(θ2)) * Δθ\n');
fprintf('  当θ2=0°时: 误差=%.4f mm\n', (a1+a2)*dtheta*1000);
fprintf('  当θ2=±90°时: 误差=%.4f mm\n', sqrt(a1^2+a2^2)*dtheta*1000);
fprintf('  当θ2=±180°时: 误差=%.4f mm\n', abs(a1-a2)*dtheta*1000);
