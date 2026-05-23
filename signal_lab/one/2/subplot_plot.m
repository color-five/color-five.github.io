% 作业：subplot分图绘制概率密度曲线
% 1) 标准正态分布 N(0,1)
% 2) 反正弦分布 a=1
clear; clc; close all;%清空内存变量，清空屏幕文字，关掉所有图

% ========== 子图1：标准正态分布 N(0,1) ==========
subplot(2,1,1);  % 2行1列，第1个图
x = -4:0.01:4;   % 取值范围
y_norm = (1/sqrt(2*pi)) * exp(-x.^2/2); % 正态分布密度公式
plot(x, y_norm, 'b-', 'LineWidth',1.5);
title('正态分布 N(0,1) 概率密度函数');  % 写标题
xlabel('x');
ylabel('f(x)');
grid on;

% ========== 子图2：反正弦分布 a=1 ==========
subplot(2,1,2);  % 2行1列，第2个图
x = 0.01:0.001:0.99; % 避开0和1，防止分母为0
a = 1;
y_arc = 1 ./ (pi * sqrt(x .* (a - x))); % 反正弦分布密度公式
plot(x, y_arc, 'r-', 'LineWidth',1.5);
title('反正弦分布 (a=1) 概率密度函数');  % 写标题
xlabel('x');
ylabel('f(x)');
grid on;

% 总标题
sgtitle('两种分布的概率密度曲线');