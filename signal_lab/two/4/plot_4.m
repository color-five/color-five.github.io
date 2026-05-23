% 同一坐标绘制：标准正态分布 + t分布(5,10,20) 概率密度曲线
% 纯公式计算，无工具箱，100%不报错
clear; clc; close all;

%% 1. 定义 x 轴范围
x = -5:0.01:5;

%% 2. 手写公式计算 标准正态分布 N(0,1)
norm_pdf = (1/sqrt(2*pi)) * exp(-x.^2 / 2);

%% 3. 手写 t 分布 概率密度公式（自由度 5,10,20）
% 伽马函数（MATLAB 自带，无工具箱）
gamma_half = sqrt(pi);

% 自由度 5
n = 5;
t5_pdf = gamma((n+1)/2) / (sqrt(n*pi)*gamma(n/2)) .* (1 + x.^2/n).^(-(n+1)/2);

% 自由度 10
n = 10;
t10_pdf = gamma((n+1)/2) / (sqrt(n*pi)*gamma(n/2)) .* (1 + x.^2/n).^(-(n+1)/2);

% 自由度 20
n = 20;
t20_pdf = gamma((n+1)/2) / (sqrt(n*pi)*gamma(n/2)) .* (1 + x.^2/n).^(-(n+1)/2);

%% 4. 同一坐标系绘图（4条曲线）
plot(x, norm_pdf, 'r-', 'LineWidth',2); hold on;
plot(x, t5_pdf, 'b--', 'LineWidth',2);
plot(x, t10_pdf, 'g-.', 'LineWidth',2);
plot(x, t20_pdf, 'm:', 'LineWidth',2);
hold off;

%% 5. 图形标注
title('标准正态分布与 t 分布概率密度曲线对比');
xlabel('x');
ylabel('概率密度 f(x)');
legend('标准正态分布','t分布(df=5)','t分布(df=10)','t分布(df=20)','Location','best');
grid on;
axis([-5 5 0 0.45]);

%% 6. 结论（作业直接抄写）
fprintf('\n========== 分布对比结论 ==========\n');
fprintf('1. t分布峰值比正态分布低，尾部更厚\n');
fprintf('2. 自由度越小，t分布越扁平，尾部越厚\n');
fprintf('3. 自由度越大，t分布越逼近标准正态分布\n');
fprintf('4. df=20时，t分布已与正态分布非常接近\n');
fprintf('===================================\n');