%% ============================================================
%  二自由度机械臂：两个关节角零偏误差同时影响的传播分析
%% ============================================================

clear; clc; close all;

%% 1. 参数设置
a1 = 1.0;
a2 = 0.8;
dtheta = 0.05;

theta1 = linspace(0, pi/2, 100);
theta2 = linspace(-pi/2, pi/2, 100);
[TH1, TH2] = meshgrid(theta1, theta2);

%% 2. 误差传播公式
% 两个关节角同时存在零偏误差，误差独立传播，方差合成
%
% ∂x/∂θ1 = -a1*sin(θ1) - a2*sin(θ1+θ2)
% ∂x/∂θ2 = -a2*sin(θ1+θ2)
% ∂y/∂θ1 =  a1*cos(θ1) + a2*cos(θ1+θ2)
% ∂y/∂θ2 =  a2*cos(θ1+θ2)

dx_dth1 = -a1*sin(TH1) - a2*sin(TH1 + TH2);
dy_dth1 =  a1*cos(TH1) + a2*cos(TH1 + TH2);
dx_dth2 = -a2*sin(TH1 + TH2);
dy_dth2 =  a2*cos(TH1 + TH2);

% 独立误差方差合成
Delta_x = sqrt(dx_dth1.^2 + dx_dth2.^2) * dtheta;
Delta_y = sqrt(dy_dth1.^2 + dy_dth2.^2) * dtheta;
Delta_total = sqrt(Delta_x.^2 + Delta_y.^2);

fprintf('================ 两关节零偏误差同时影响 ================\n');
fprintf('零偏误差: Δθ1=Δθ2=%.4frad (%.2f°)\n', dtheta, rad2deg(dtheta));

%% 3. x方向误差曲面
figure('Name', 'x方向误差曲面(两关节)', 'Position', [50 550 600 450]);
surf(rad2deg(TH1), rad2deg(TH2), abs(Delta_x)*1000, 'EdgeColor', 'none');
colorbar; xlabel('\theta_1 (°)'); ylabel('\theta_2 (°)');
zlabel('|\Delta x| (mm)'); title('两关节零偏误差引起的x方向位置误差');
colormap(jet); shading interp;

fprintf('\nx方向误差范围: %.4f ~ %.4f mm\n', min(abs(Delta_x(:)))*1000, max(abs(Delta_x(:)))*1000);

%% 4. y方向误差曲面
figure('Name', 'y方向误差曲面(两关节)', 'Position', [700 550 600 450]);
surf(rad2deg(TH1), rad2deg(TH2), abs(Delta_y)*1000, 'EdgeColor', 'none');
colorbar; xlabel('\theta_1 (°)'); ylabel('\theta_2 (°)');
zlabel('|\Delta y| (mm)'); title('两关节零偏误差引起的y方向位置误差');
colormap(jet); shading interp;

fprintf('y方向误差范围: %.4f ~ %.4f mm\n', min(abs(Delta_y(:)))*1000, max(abs(Delta_y(:)))*1000);

%% 5. 总位置误差曲面
figure('Name', '总位置误差曲面(两关节)', 'Position', [50 50 600 450]);
surf(rad2deg(TH1), rad2deg(TH2), Delta_total*1000, 'EdgeColor', 'none');
colorbar; xlabel('\theta_1 (°)'); ylabel('\theta_2 (°)');
zlabel('|\Delta p| (mm)'); title('两关节零偏误差引起的总位置误差');
colormap(jet); shading interp;

fprintf('总位置误差范围: %.4f ~ %.4f mm\n', min(Delta_total(:))*1000, max(Delta_total(:))*1000);

%% 6. 误差特性分析
fprintf('\n================ 误差特性分析 ================\n');

[max_err, max_idx] = max(Delta_total(:));
[max_i, max_j] = ind2sub(size(TH1), max_idx);
fprintf('最大总误差: %.4f mm\n', max_err*1000);
fprintf('  出现在 θ1=%.1f°, θ2=%.1f°\n', rad2deg(TH1(max_i,max_j)), rad2deg(TH2(max_i,max_j)));

[min_err, min_idx] = min(Delta_total(:));
[min_i, min_j] = ind2sub(size(TH1), min_idx);
fprintf('最小总误差: %.4f mm\n', min_err*1000);
fprintf('  出现在 θ1=%.1f°, θ2=%.1f°\n', rad2deg(TH1(min_i,min_j)), rad2deg(TH2(min_i,min_j)));

% 理论验证
fprintf('\n理论验证:\n');
fprintf('  合成误差 = sqrt(Δθ1影响² + Δθ2影响²)\n');
fprintf('  最大: sqrt((a1+a2)² + a2²) * Δθ = %.4f mm\n', sqrt((a1+a2)^2+a2^2)*dtheta*1000);
fprintf('  最小: sqrt((a1-a2)² + a2²) * Δθ = %.4f mm\n', sqrt((a1-a2)^2+a2^2)*dtheta*1000);
