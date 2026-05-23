% 清空环境
clear; clc; close all;

% 1. 产生500个 均值10，方差5 的正态分布随机数 (使用内置randn)
n = 500;
mu = 10;
sigma2 = 5;
sigma = sqrt(sigma2);   % 标准差
data = mu + sigma * randn(n, 1); % 替代 normrnd

% 2. 计算统计量 (手动计算替代统计工具箱函数)
mean_val = mean(data);           % 均值 (内置)
var_val = var(data);             % 方差 (内置)

% 手动计算上下四分位数 (替代 quantile)
sorted_data = sort(data);
n_data = length(data);
% 计算Q1 (第25百分位数)
p1 = 0.25;
index1 = p1 * (n_data + 1);
if floor(index1) == index1
    Q1 = sorted_data(index1);
else
    lower_idx = floor(index1);
    upper_idx = ceil(index1);
    weight = index1 - lower_idx;
    Q1 = (1-weight)*sorted_data(lower_idx) + weight*sorted_data(upper_idx);
end
% 计算Q3 (第75百分位数)
p2 = 0.75;
index2 = p2 * (n_data + 1);
if floor(index2) == index2
    Q3 = sorted_data(index2);
else
    lower_idx = floor(index2);
    upper_idx = ceil(index2);
    weight = index2 - lower_idx;
    Q3 = (1-weight)*sorted_data(lower_idx) + weight*sorted_data(upper_idx);
end

% 手动计算偏度 (替代 skewness)
% 偏度 = [n/((n-1)*(n-2))] * Σ((x_i - mean)/std)^3
std_val = std(data); % 样本标准差
z_scores = (data - mean_val) / std_val;
skew_val = (n / ((n-1)*(n-2))) * sum(z_scores.^3);

% 手动计算峰度 (替代 kurtosis，返回超额峰度)
% 峰度 = [n*(n+1)/((n-1)*(n-2)*(n-3))] * Σ(z^4) - [3*(n-1)^2/((n-2)*(n-3))]
k1 = (n*(n+1)) / ((n-1)*(n-2)*(n-3));
k2 = sum(z_scores.^4);
k3 = (3*(n-1)^2) / ((n-2)*(n-3));
kurt_val = k1 * k2 - k3; % 对于正态分布，此值应接近0

% 显示结果
fprintf('样本均值 = %.4f\n', mean_val);
fprintf('样本方差 = %.4f\n', var_val);
fprintf('下四分位数 Q1 = %.4f\n', Q1);
fprintf('上四分位数 Q3 = %.4f\n', Q3);
fprintf('偏度 = %.4f\n', skew_val);
fprintf('峰度 (超额峰度) = %.4f\n', kurt_val);

% 3. 画图 (使用内置绘图函数，替代统计工具箱的绘图函数)
figure('Color','w')

% 子图1：统计直方图 + 理论概率密度曲线
subplot(2,3,1)
% 使用histogram内置函数，它不属于统计工具箱
histogram(data, 'Normalization','pdf', 'BinMethod', 'auto');
hold on
x = linspace(min(data), max(data), 200);
% 手动计算理论正态分布概率密度
y = 1/(sqrt(2*pi)*sigma) * exp(-(x-mu).^2/(2*sigma^2));
plot(x, y, 'r-', 'LineWidth',2);
title('直方图 & 概率密度曲线');
xlabel('数据值'); ylabel('概率密度');
grid on

% 子图2：手动绘制经验分布函数 (替代 cdfplot)
subplot(2,3,2)
sorted_data_ecdf = sort(data);
y_ecdf = (1:n_data)' / n_data; % 经验累积概率
stairs(sorted_data_ecdf, y_ecdf, 'b-', 'LineWidth', 1.5);
hold on
% 可选：添加理论正态分布CDF作为对比
x_cdf = linspace(min(data), max(data), 200);
% 手动计算理论正态分布CDF (使用误差函数erf)
y_cdf_theory = 0.5 * (1 + erf((x_cdf - mu) / (sigma * sqrt(2))));
plot(x_cdf, y_cdf_theory, 'r--', 'LineWidth', 1.5);
title('经验分布函数 (ECDF)');
xlabel('数据值'); ylabel('累积概率');
legend('经验CDF', '理论正态CDF', 'Location', 'best');
grid on

% 子图3：手动绘制QQ图 (替代 qqplot)
subplot(2,3,3)
% 计算样本分位数
sample_quantiles = sorted_data;
% 计算理论正态分布分位数 (使用标准正态分布的反函数)
% 首先计算每个数据点对应的概率值
prob = ((1:n_data)' - 0.5) / n_data; % 常见的概率位置估计
% 使用逆误差函数计算标准正态分位数
theoretical_quantiles = sqrt(2) * erfinv(2*prob - 1);
% 调整到目标正态分布 N(mu, sigma^2)
theoretical_quantiles = mu + sigma * theoretical_quantiles;

plot(theoretical_quantiles, sample_quantiles, 'bo', 'MarkerSize', 4);
hold on
% 添加参考线 (y=x)
min_val = min([theoretical_quantiles; sample_quantiles]);
max_val = max([theoretical_quantiles; sample_quantiles]);
plot([min_val max_val], [min_val max_val], 'r-', 'LineWidth', 1.5);
title('手动QQ图');
xlabel('理论正态分位数'); ylabel('样本分位数');
grid on

% 子图4：手动绘制盒形图 (替代 boxplot)
subplot(2,3,4)
% 计算五数概括：最小值、Q1、中位数、Q3、最大值
median_val = median(data); % 中位数 (内置)
min_val = min(data);
max_val = max(data);
IQR = Q3 - Q1; % 四分位距

% 绘制箱体
box_x = [0.8 1.2 1.2 0.8 0.8];
box_y = [Q1 Q1 Q3 Q3 Q1];
fill(box_x, box_y, [0.8 0.8 0.8], 'EdgeColor', 'k', 'LineWidth', 1);
hold on
% 绘制中位数线
plot([0.8 1.2], [median_val median_val], 'k-', 'LineWidth', 2);
% 绘制须线
% 计算须的界限
lower_whisker = max(min_val, Q1 - 1.5*IQR);
upper_whisker = min(max_val, Q3 + 1.5*IQR);
% 绘制下须
plot([1 1], [lower_whisker Q1], 'k-', 'LineWidth', 1);
plot([0.9 1.1], [lower_whisker lower_whisker], 'k-', 'LineWidth', 1);
% 绘制上须
plot([1 1], [Q3 upper_whisker], 'k-', 'LineWidth', 1);
plot([0.9 1.1], [upper_whisker upper_whisker], 'k-', 'LineWidth', 1);
% 绘制异常值 (如果有)
outliers = data(data < lower_whisker | data > upper_whisker);
if ~isempty(outliers)
    plot(ones(size(outliers)), outliers, 'r+', 'MarkerSize', 8, 'LineWidth', 1.5);
end
xlim([0.5 1.5]);
title('手动盒形图');
ylabel('数据值');
set(gca, 'XTick', []); % 隐藏x轴刻度
grid on

% 子图5：普通直方图（频数）
subplot(2,3,5)
histogram(data, 'BinMethod', 'auto');
title('统计直方图 (频数)');
xlabel('数据值'); ylabel('频数');
grid on

% 调整子图间距
sgtitle('正态分布数据统计分析 (无工具箱版本)', 'FontSize', 14, 'FontWeight', 'bold');
