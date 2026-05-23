% 清空环境
clear; clc; close all;

% 设置绘图参数
figure('Color', 'w', 'Position', [100, 100, 800, 600]);

% 定义x轴范围（卡方分布从0开始）
x = 0:0.1:40;  % 根据自由度适当调整范围

% 定义要绘制的自由度
degrees_of_freedom = [5, 10, 20];

% 设置不同自由度的颜色和线型
colors = {'r', 'g', 'b'};
line_styles = {'-', '--', ':'};
line_widths = [2, 2, 2];

% 手动实现卡方分布概率密度函数
chi2pdf_manual = @(x, k) (x.^(k/2-1) .* exp(-x/2)) ./ (2^(k/2) * gamma(k/2));

% 绘制每条曲线
hold on;
for i = 1:length(degrees_of_freedom)
    df = degrees_of_freedom(i);
    y = chi2pdf_manual(x, df);  % 使用手动实现的函数计算概率密度
    
    % 确保x=0时的处理（当k/2-1<0时，0^负数会得到Inf）
    if df < 2
        y(x==0) = Inf;  % 当df=1时，在x=0处概率密度趋于无穷大
    else
        y(x==0) = 0;    % 当df≥2时，在x=0处概率密度为0
    end
    
    % 绘制曲线
    plot(x, y, ...
        'Color', colors{i}, ...
        'LineStyle', line_styles{i}, ...
        'LineWidth', line_widths(i), ...
        'DisplayName', sprintf('df = %d', df));
end

% 添加图形标注
xlabel('随机变量 X', 'FontSize', 12);
ylabel('概率密度 f(x)', 'FontSize', 12);
title('不同自由度的卡方分布概率密度曲线比较 (手动实现)', 'FontSize', 14, 'FontWeight', 'bold');
legend('show', 'Location', 'best', 'FontSize', 11);
grid on;
box on;

% 设置坐标轴范围
xlim([0, 40]);
ylim([0, 0.16]);

% 添加参考线（均值线）和统计量标注
for i = 1:length(degrees_of_freedom)
    df = degrees_of_freedom(i);
    mean_val = df;  % 卡方分布的均值等于自由度
    variance = 2 * df;  % 卡方分布的方差为2k
    
    % 找到对应概率密度值
    [~, idx] = min(abs(x - mean_val));
    y_val = chi2pdf_manual(mean_val, df);
    
    % 绘制垂直线标记均值
    plot([mean_val, mean_val], [0, y_val], ...
        'Color', colors{i}, ...
        'LineStyle', ':', ...
        'LineWidth', 1, ...
        'HandleVisibility', 'off');
    
    % 添加统计量标注
    text(mean_val+1, y_val+0.005, ...
        sprintf('μ=%.0f, σ²=%.0f', mean_val, variance), ...
        'Color', colors{i}, 'FontSize', 9, 'BackgroundColor', 'white');
end

% 添加分布特性说明
text(30, 0.14, '卡方分布特性:', 'FontSize', 11, 'FontWeight', 'bold');
text(30, 0.13, '1. 仅取非负值 (x ≥ 0)', 'FontSize', 10);
text(30, 0.12, '2. 均值 = 自由度 k', 'FontSize', 10);
text(30, 0.11, '3. 方差 = 2k', 'FontSize', 10);
text(30, 0.10, '4. 随k增大趋近正态分布', 'FontSize', 10);

hold off;
