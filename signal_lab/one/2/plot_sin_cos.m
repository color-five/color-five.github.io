% 练习：在同一个坐标系绘制两条三角函数曲线
% y1 = sin(2π×1×t)
% y2 = cos(2π×10×t)
clear; clc; close all;%清空内存变量，清空屏幕文字，关掉所有图

% 1. 定义时间 t（范围0~1秒，足够显示波形）
t = 0:0.001:1;  

% 2. 计算两条曲线
y1 = sin(2*pi*1*t);   % 正弦信号 1Hz
y2 = cos(2*pi*10*t);  % 余弦信号 10Hz

% 3. 在同一个坐标系绘图
plot(t, y1, 'r-', 'LineWidth',2);   % 红色实线：sin
hold on;                            % 保持画布，画第二条
plot(t, y2, 'b--', 'LineWidth',2);  % 蓝色虚线：cos
hold off;

% 4. 加标注
title('sin(2π×1×t) 和 cos(2π×10×t) 波形对比');  % 图标题
xlabel('时间 t (秒)');         % X轴标注
ylabel('幅值');               % Y轴标注
legend('sin(2\pi×1×t)','cos(2\pi×10×t)'); % 图例
grid on;                      % 显示网格