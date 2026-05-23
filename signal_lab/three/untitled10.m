%% ============================================================
%  系统误差判别分析
%  方法1: 残余误差观察法（散点图）
%  方法2: 马利科夫准则
%  方法3: 不同公式计算标准差比较法
%% ============================================================

clear; clc; close all;

%% 1. 输入测量数据
x = [20.06, 20.07, 20.06, 20.08, 20.10, 20.12, ...
     20.11, 20.14, 20.18, 20.18, 20.21, 20.19];
n = length(x);

fprintf('================ 测量数据 ================\n');
fprintf('测量次数 n = %d\n', n);
fprintf('数据: '); fprintf('%.2f ', x); fprintf('\n');

%% 2. 计算算术平均值
x_bar = mean(x);
fprintf('\n算术平均值: %.4f\n', x_bar);

%% 3. 计算残余误差（残差）
v = x - x_bar;          % 残差 vi = xi - x_bar
fprintf('\n残余误差 vi:\n');
for i = 1:n
    fprintf('v%d = %.4f\n', i, v(i));
end

%% ==================== 方法1: 残余误差观察法（散点图）====================
figure('Name', '残余误差观察法', 'Position', [100 550 700 400]);

scatter(1:n, v, 50, 'b', 'filled');
hold on;
plot([1 n], [0 0], 'r--', 'LineWidth', 1.5);  % 零线

xlabel('测量序号 i', 'FontSize', 12);
ylabel('残余误差 v_i', 'FontSize', 12);
title('残余误差观察法（散点图）', 'FontSize', 14);

% 标注各点数值
for i = 1:n
    text(i, v(i)+0.003, sprintf('%.4f', v(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9);
end

grid on;
hold off;

% 观察分析
fprintf('\n================ 方法1: 残余误差观察法 ================\n');
fprintf('观察散点图规律:\n');

% 检查残差符号变化
sign_changes = sum(diff(sign(v)) ~= 0);
fprintf('残差符号变化次数: %d\n', sign_changes);

% 判断趋势
if v(end) > v(1)
    trend = '递增';
else
    trend = '递减';
end
fprintf('残差整体趋势: %s\n', trend);

% 线性拟合判断趋势
p = polyfit(1:n, v, 1);
fprintf('线性拟合斜率: %.6f\n', p(1));

if abs(p(1)) > 0.001
    fprintf('【结论】残差呈现明显%s趋势，怀疑存在线性系统误差！\n', trend);
else
    fprintf('【结论】残差无明显趋势，未发现系统误差。\n');
end

%% ==================== 方法2: 马利科夫准则 ====================
fprintf('\n================ 方法2: 马利科夫准则 ================\n');

% 将数据分为前后两半
n1 = floor(n/2);        % 前半部分个数
n2 = n - n1;            % 后半部分个数

% 计算前后两组的残差和
M1 = sum(v(1:n1));      % 前半部分残差和
M2 = sum(v(n1+1:n));    % 后半部分残差和

% 马利科夫统计量
M = M1 - M2;

fprintf('前半部分 (i=1~%d): 残差和 M1 = %.4f\n', n1, M1);
fprintf('后半部分 (i=%d~%d): 残差和 M2 = %.4f\n', n1+1, n, M2);
fprintf('马利科夫统计量 M = M1 - M2 = %.4f\n', M);

% 判断准则
% 计算残差绝对值平均值
v_avg_abs = mean(abs(v));
fprintf('残差绝对值平均值: %.4f\n', v_avg_abs);

if abs(M) > v_avg_abs
    fprintf('【结论】|M| = %.4f > %.4f (残差绝对值平均值)\n', abs(M), v_avg_abs);
    fprintf('      存在系统误差！\n');
else
    fprintf('【结论】|M| = %.4f <= %.4f (残差绝对值平均值)\n', abs(M), v_avg_abs);
    fprintf('      未发现系统误差。\n');
end

%% ==================== 方法3: 不同公式计算标准差比较法 ====================
fprintf('\n================ 方法3: 不同公式标准差比较法 ================\n');

% 公式1: 贝塞尔公式（最常用）
sigma_bessel = sqrt(sum(v.^2) / (n - 1));
fprintf('公式1 (贝塞尔公式):      σ = sqrt(Σvi²/(n-1)) = %.6f\n', sigma_bessel);

% 公式2: 彼得斯公式
sigma_peters = sqrt(sum(v.^2) / (n - 1)) * sqrt(pi/2) / sqrt(n);
% 或者简化为: 1.253 * sqrt(sum(v.^2) / (n*(n-1)))
sigma_peters = 1.253 * sqrt(sum(v.^2) / (n * (n - 1)));
fprintf('公式2 (彼得斯公式):      σ = 1.253 * sqrt(Σvi²/(n(n-1))) = %.6f\n', sigma_peters);

% 公式3: 极差法
R = max(x) - min(x);    % 极差
d_n = [0, 0, 1.128, 1.693, 2.059, 2.326, 2.534, 2.704, 2.847, 2.970, ...
       3.078, 3.173, 3.258, 3.336, 3.407, 3.472, 3.532, 3.588, 3.640, 3.689];
if n <= 20
    d = d_n(n);
else
    d = sqrt(n) - 0.5;  % 近似公式
end
sigma_range = R / d;
fprintf('公式3 (极差法):          σ = R/dn = %.4f/%.3f = %.6f\n', R, d, sigma_range);

% 公式4: 最大残差法
v_max = max(abs(v));
K_n = [0, 0, 1.77, 2.00, 2.24, 2.44, 2.62, 2.78, 2.92, 3.05, ...
       3.16, 3.26, 3.36, 3.45, 3.53, 3.61, 3.68, 3.75, 3.82, 3.88];
if n <= 20
    K = K_n(n);
else
    K = sqrt(n - 0.5);  % 近似
end
sigma_maxres = v_max / K;
fprintf('公式4 (最大残差法):      σ = |v|max/Kn = %.4f/%.3f = %.6f\n', v_max, K, sigma_maxres);

% 比较分析
fprintf('\n----- 标准差比较 -----\n');
sigmas = [sigma_bessel, sigma_peters, sigma_range, sigma_maxres];
sigma_mean = mean(sigmas);
fprintf('各公式标准差平均值: %.6f\n', sigma_mean);

% 计算各公式与平均值的相对偏差
fprintf('\n各公式与平均值的相对偏差:\n');
labels_sigma = {'贝塞尔', '彼得斯', '极差法', '最大残差法'};
for i = 1:4
    dev = abs(sigmas(i) - sigma_mean) / sigma_mean * 100;
    fprintf('%s公式: %.2f%%\n', labels_sigma{i}, dev);
end

% 判断是否存在系统误差
max_dev = max(abs(sigmas - sigma_mean)) / sigma_mean * 100;
threshold = 10;  % 10%阈值

if max_dev > threshold
    fprintf('\n【结论】各公式计算的标准差差异较大（最大偏差 %.2f%% > %.0f%%）\n', max_dev, threshold);
    fprintf('      测量列中存在系统误差！\n');
else
    fprintf('\n【结论】各公式计算的标准差基本一致（最大偏差 %.2f%% <= %.0f%%）\n', max_dev, threshold);
    fprintf('      未发现明显系统误差。\n');
end

%% ==================== 综合结论 ====================
fprintf('\n================ 综合结论 ================\n');
fprintf('1. 残余误差观察法: 残差呈%s趋势，斜率=%.6f\n', trend, p(1));
fprintf('2. 马利科夫准则: M = %.4f\n', M);
fprintf('3. 标准差比较法: 最大相对偏差 = %.2f%%\n', max_dev);

% 综合判断
system_error_count = 0;
if abs(p(1)) > 0.001, system_error_count = system_error_count + 1; end
if abs(M) > v_avg_abs, system_error_count = system_error_count + 1; end
if max_dev > threshold, system_error_count = system_error_count + 1; end

fprintf('\n三种方法中，%d种方法判断存在系统误差。\n', system_error_count);
if system_error_count >= 2
    fprintf('【最终结论】该测量列中存在系统误差！\n');
else
    fprintf('【最终结论】该测量列中未发现明显系统误差。\n');
end
