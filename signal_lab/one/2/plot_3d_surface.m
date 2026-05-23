% 三维曲面绘图：z = sin( pi * sqrt(x^2 + y^2) )
clear; clc; close all;%清空内存变量，清空屏幕文字，关掉所有图

% 1. 生成网格坐标（定义x,y范围）
x = -2:0.1:2;   % x从-2到2
y = -2:0.1:2;   % y从-2到2
[X,Y] = meshgrid(x,y);  % 生成网格矩阵

% 2. 计算z值
R = sqrt(X.^2 + Y.^2);  % 计算 sqrt(x²+y²)
Z = sin( pi * R );     % z = sin( π·√(x²+y²) )

% 3. 绘制3D曲面
mesh(X, Y, Z);   % 网格曲面图

% 4. 图形标注
title('三维曲面 z = sin(\pi\sqrt{x^2+y^2})');
xlabel('X 轴');
ylabel('Y 轴');
zlabel('Z 轴');
grid on;         % 显示网格
colorbar;        % 显示颜色条