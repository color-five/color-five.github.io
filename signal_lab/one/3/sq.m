% 函数M文件：sq.m
% 功能：用迭代法求 a 的平方根
% 输入：a - 被开平方的数 (a>0)
% 输出：x - a的平方根
function x = sq(a)
    % 安全判断：如果没输入，自动提示错误
    if nargin < 1
        error('请输入要开平方的数字，例如 sq(2)');
    end
    % 安全判断：a必须大于0
    if a <= 0
        error('a必须大于0');
    end

    % 迭代初始值
    x0 = a;
    % 第一次迭代
    x1 = 0.5 * (x0 + a / x0);
    
    % 迭代循环
    while abs(x1 - x0) >= 1e-5
        x0 = x1;
        x1 = 0.5*(x0 + a/x0);
    end
    
    x = x1;
end