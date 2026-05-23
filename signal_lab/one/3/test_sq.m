% 命令M文件：直接运行，自动测试
clear; clc;

% 自动计算并输出
a = 2;
res = sq(a);
fprintf('sqrt(%g) = %.6f\n', a, res);

a = 4;
res = sq(a);
fprintf('sqrt(%g) = %.6f\n', a, res);

a = 9;
res = sq(a);
fprintf('sqrt(%g) = %.6f\n', a, res);