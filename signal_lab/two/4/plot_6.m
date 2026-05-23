%% ============================================================
%  不同参数F分布的概率密度曲线比较
%  F(4,5), F(10,20), F(50,50)
%% ============================================================

clear; clc; close all;

%% 1. 定义参数
params = [4, 5;      % F(4,5)
          10, 20;    % F(10,20)
          50, 50];   % F(50,50)

colors = {'b', 'r', 'g'};
labels = {'F(4, 5)', 'F(10, 20)', 'F(50, 50)'};

%% 2. 手动计算F分布概率密度函数
% f(x; d1, d2) = (d1/d2)^(d1/2) * x^(d1/2-1) * B(d1/2, d2/2)^(-1) 
%                * (1 + d1*x/d2)^(-(d1+d2)/2)

% 使用Beta函数：B(a,b) = gamma(a)*gamma(b)/gamma(a+b)

figure('Name', 'F分布概率密度曲线', 'Position', [100 100 800 600]);
hold on;

for i = 1:size(params, 1)
    d1 = params(i, 1);      % 第一自由度
    d2 = params(i, 2);      % 第二自由度
    
    % x范围（F分布定义域x>0，根据参数调整上限）
    if i == 1
        x = linspace(0.01, 8, 1000);    % F(4,5)尾部较重
    elseif i == 2
        x = linspace(0.01, 5, 1000);    % F(10,20)
    else
        x = linspace(0.01, 3, 1000);    % F(50,50)更集中
    end
    
    % 计算PDF
    a = d1 / 2;
    b = d2 / 2;
    
    % Beta函数
    B = gamma(a) * gamma(b) / gamma(a + b);
    
    % F分布PDF
    pdf = ((d1/d2)^a) .* (x.^(a-1)) .* (1 + d1.*x./d2).^(-(d1+d2)/2) ./ B;
    
    % 绘制曲线
    plot(x, pdf, 'Color', colors{i}, 'LineWidth', 2, ...
        'DisplayName', labels{i});
end

%% 3. 图形设置
xlabel('x', 'FontSize', 12);
ylabel('f(x)', 'FontSize', 12);
title('不同参数的F分布概率密度曲线', 'FontSize', 14);
legend('Location', 'best', 'FontSize', 11);
grid on;
hold off;

%% 4. 输出统计特征
fprintf('================ F分布统计特征 ================\n');
for i = 1:size(params, 1)
    d1 = params(i, 1);
    d2 = params(i, 2);
    
    % 均值（d2 > 2时存在）
    if d2 > 2
        mean_val = d2 / (d2 - 2);
    else
        mean_val = Inf;
    end
    
    % 方差（d2 > 4时存在）
    if d2 > 4
        var_val = (2 * d2^2 * (d1 + d2 - 2)) / (d1 * (d2 - 2)^2 * (d2 - 4));
    else
        var_val = Inf;
    end
    
    fprintf('F(%d, %d):  均值 = %.4f,  方差 = %.4f\n', d1, d2, mean_val, var_val);
end
fprintf('===============================================\n');
