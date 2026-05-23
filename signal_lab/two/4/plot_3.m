%% ============================================================
%  均匀分布随机数据的统计分析
%  生成500个均匀分布随机数据，绘制：
%  1.统计直方图  2.概率密度曲线  3.经验分布函数  4.QQ图  5.盒形图
%% ============================================================

clear; clc; close all;

%% 1. 生成数据
n = 500;
data = rand(n, 1);          % U(0,1) 均匀分布

%% 2. 计算统计量
mu = mean(data);                        % 均值
variance = var(data, 1);                % 方差
std_dev = std(data, 1);                 % 标准差

% 排序数据
sorted = sort(data);

% 四分位数
Q1 = interp1((1:n)/n, sorted, 0.25);
Q3 = interp1((1:n)/n, sorted, 0.75);
med = median(data);

% 偏度（三阶中心矩 / 标准差^3）
m3 = mean((data - mu).^3);
sk = m3 / std_dev^3;

% 峰度（四阶中心矩 / 方差^2）
m4 = mean((data - mu).^4);
ku = m4 / variance^2;

%% 3. 输出结果
fprintf('================ 统计结果 ================\n');
fprintf('样本量: %d\n', n);
fprintf('均值:   %.4f\n', mu);
fprintf('方差:   %.4f\n', variance);
fprintf('Q1:     %.4f\n', Q1);
fprintf('Q3:     %.4f\n', Q3);
fprintf('偏度:   %.4f\n', sk);
fprintf('峰度:   %.4f\n', ku);
fprintf('=========================================\n');

%% 4. 绘制5个图

% ========== 图1: 统计直方图 ==========
figure('Name', '统计直方图', 'Position', [100 550 500 400]);
[counts, edges] = histcounts(data, 20);
centers = (edges(1:end-1) + edges(2:end)) / 2;
width = edges(2) - edges(1);
bar(centers, counts, 1, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'w');
xlabel('x');
ylabel('频数');
title('统计直方图');
grid on;

% ========== 图2: 概率密度曲线 ==========
figure('Name', '概率密度曲线', 'Position', [620 550 500 400]);

% 核密度估计（Parzen窗法）
h = 1.06 * std_dev * n^(-1/5);          % Silverman带宽
x_range = linspace(-0.2, 1.2, 1000);
kernel_density = zeros(size(x_range));

for i = 1:n
    kernel_density = kernel_density + ...
        (1/sqrt(2*pi)) * exp(-0.5*((x_range - data(i))/h).^2);
end
kernel_density = kernel_density / (n * h);

% 理论PDF
x_theory = linspace(0, 1, 1000);
y_theory = ones(size(x_theory));

plot(x_range, kernel_density, 'b-', 'LineWidth', 2);
hold on;
plot(x_theory, y_theory, 'r--', 'LineWidth', 2);
xlabel('x');
ylabel('f(x)');
title('概率密度曲线');
legend('核密度估计', '理论PDF', 'Location', 'best');
grid on;
xlim([-0.2 1.2]);

% ========== 图3: 经验分布函数 ==========
figure('Name', '经验分布函数', 'Position', [1140 550 500 400]);

x_ecdf = sorted;
y_ecdf = (1:n)' / n;

stairs(x_ecdf, y_ecdf, 'b-', 'LineWidth', 1.5);
hold on;
plot([0 1], [0 1], 'r--', 'LineWidth', 2);
xlabel('x');
ylabel('F(x)');
title('经验分布函数');
legend('经验分布函数', '理论CDF', 'Location', 'best');
grid on;
xlim([-0.1 1.1]);
ylim([-0.05 1.05]);

% ========== 图4: QQ图 ==========
figure('Name', 'QQ图', 'Position', [100 50 500 400]);

p = ((1:n) - 0.5) / n;          % 分位点
q_theory = p;                   % U(0,1)理论分位数
q_sample = sorted;              % 样本分位数

scatter(q_theory, q_sample, 20, 'b', 'filled');
hold on;
plot([0 1], [0 1], 'r--', 'LineWidth', 2);
xlabel('理论分位数');
ylabel('样本分位数');
title('QQ图');
grid on;

% ========== 图5: 盒形图 ==========
figure('Name', '盒形图', 'Position', [620 50 500 400]);

min_val = min(data);
max_val = max(data);

% 箱体
rectangle('Position', [0.35, Q1, 0.3, Q3-Q1], ...
    'FaceColor', [0.8 0.9 1], 'EdgeColor', 'k', 'LineWidth', 1.5);
hold on;

% 中位线
plot([0.35 0.65], [med med], 'r-', 'LineWidth', 2.5);

% 上下须
plot([0.5 0.5], [min_val Q1], 'k-', 'LineWidth', 1.5);
plot([0.5 0.5], [Q3 max_val], 'k-', 'LineWidth', 1.5);
plot([0.45 0.55], [min_val min_val], 'k-', 'LineWidth', 1.5);
plot([0.45 0.55], [max_val max_val], 'k-', 'LineWidth', 1.5);

% 标注
text(0.7, med, sprintf('中位数=%.3f', med), 'FontSize', 10);
text(0.7, Q1, sprintf('Q1=%.3f', Q1), 'FontSize', 10);
text(0.7, Q3, sprintf('Q3=%.3f', Q3), 'FontSize', 10);

xlim([0.2 0.95]);
ylim([min_val-0.05, max_val+0.05]);
title('盒形图');
ylabel('数值');
set(gca, 'XTick', []);
grid on;
