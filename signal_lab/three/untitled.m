%% ============================================================
%  t检验法判断两组数据间是否存在系统误差（纯基础版，无需工具箱）
%% ============================================================

clear; clc;

%% 1. 输入数据
x = [1.9, 0.8, 1.1, 0.1, -0.1, 4.4, 5.5, 1.6, 4.6, 3.4];
y = [0.7, -1.6, -0.2, -1.2, -0.1, 3.4, 3.7, 0.8, 0, 2.0];

n1 = length(x);
n2 = length(y);

fprintf('================ t检验法判断系统误差 ================\n');
fprintf('第一组数据 x: '); fprintf('%.1f ', x); fprintf('  (n1=%d)\n', n1);
fprintf('第二组数据 y: '); fprintf('%.1f ', y); fprintf('  (n2=%d)\n', n2);

%% 2. 计算基本统计量
mean_x = mean(x);
mean_y = mean(y);
var_x = sum((x - mean_x).^2) / (n1 - 1);      % 无偏方差
var_y = sum((y - mean_y).^2) / (n2 - 1);
std_x = sqrt(var_x);
std_y = sqrt(var_y);

fprintf('\n----- 基本统计量 -----\n');
fprintf('x组: 均值=%.4f, 方差=%.4f, 标准差=%.4f\n', mean_x, var_x, std_x);
fprintf('y组: 均值=%.4f, 方差=%.4f, 标准差=%.4f\n', mean_y, var_y, std_y);

%% 3. F检验（方差齐性检验）
fprintf('\n================ 第一步: F检验（方差齐性检验）================\n');

if var_x >= var_y
    F = var_x / var_y;
    df1 = n1 - 1;
    df2 = n2 - 1;
else
    F = var_y / var_x;
    df1 = n2 - 1;
    df2 = n1 - 1;
end

fprintf('F统计量 = %.4f\n', F);
fprintf('自由度: df1=%d, df2=%d\n', df1, df2);

% 手动计算F临界值（使用二分法求逆CDF）
F_crit = f_inv(0.975, df1, df2);
fprintf('F临界值 (α=0.05, 双侧): %.4f\n', F_crit);

if F > F_crit
    fprintf('【F检验结论】F=%.4f > F_crit=%.4f，方差不齐\n', F, F_crit);
    equal_var = false;
else
    fprintf('【F检验结论】F=%.4f <= F_crit=%.4f，方差齐性\n', F, F_crit);
    equal_var = true;
end

%% 4. t检验
fprintf('\n================ 第二步: t检验 ================\n');

if equal_var
    fprintf('【采用合并方差t检验】\n');
    Sp2 = ((n1-1)*var_x + (n2-1)*var_y) / (n1 + n2 - 2);
    Sp = sqrt(Sp2);
    t = (mean_x - mean_y) / (Sp * sqrt(1/n1 + 1/n2));
    df = n1 + n2 - 2;
    fprintf('合并方差 Sp² = %.4f\n', Sp2);
else
    fprintf('【采用Welch t检验】\n');
    t = (mean_x - mean_y) / sqrt(var_x/n1 + var_y/n2);
    df = (var_x/n1 + var_y/n2)^2 / ...
         ((var_x/n1)^2/(n1-1) + (var_y/n2)^2/(n2-1));
    fprintf('调整自由度 df = %.4f\n', df);
end

fprintf('t统计量 = %.4f\n', t);
fprintf('自由度 df = %.4f\n', df);

%% 5. 临界值比较
alpha = 0.05;
t_crit = t_inv(1 - alpha/2, df);    % 手动计算t临界值

fprintf('\n----- 临界值比较 -----\n');
fprintf('显著性水平 α = %.2f\n', alpha);
fprintf('t临界值 (双侧): ±%.4f\n', t_crit);
fprintf('|t| = %.4f\n', abs(t));

if abs(t) > t_crit
    fprintf('\n【结论】|t| = %.4f > t_crit = %.4f\n', abs(t), t_crit);
    fprintf('        拒绝原假设，两组均值存在显著差异\n');
    fprintf('        ===> 存在系统误差 <===\n');
else
    fprintf('\n【结论】|t| = %.4f <= t_crit = %.4f\n', abs(t), t_crit);
    fprintf('        接受原假设，两组均值无显著差异\n');
    fprintf('        ===> 无系统误差 <===\n');
end

%% 6. 综合结论
fprintf('\n================ 综合结论 ================\n');
fprintf('x组均值: %.4f\n', mean_x);
fprintf('y组均值: %.4f\n', mean_y);
fprintf('均值差: %.4f\n', abs(mean_x - mean_y));
fprintf('t统计量: %.4f\n', t);
fprintf('临界值: ±%.4f\n', t_crit);

if abs(t) > t_crit
    fprintf('\n【最终结论】两组数据间存在系统误差！\n');
else
    fprintf('\n【最终结论】两组数据间无系统误差。\n');
end

%% ==================== 辅助函数 ====================

function x = t_inv(p, nu)
    % t分布逆CDF（二分法）
    % 使用正态近似作为初始值
    x_low = -10;
    x_high = 10;
    tol = 1e-6;
    
    while x_high - x_low > tol
        x_mid = (x_low + x_high) / 2;
        if t_cdf(x_mid, nu) < p
            x_low = x_mid;
        else
            x_high = x_mid;
        end
    end
    x = (x_low + x_high) / 2;
end

function p = t_cdf(x, nu)
    % t分布CDF（使用不完全beta函数）
    if x > 0
        p = 1 - 0.5 * betainc(nu / (nu + x^2), nu/2, 0.5);
    elseif x == 0
        p = 0.5;
    else
        p = 0.5 * betainc(nu / (nu + x^2), nu/2, 0.5);
    end
end

function x = f_inv(p, d1, d2)
    % F分布逆CDF（二分法）
    x_low = 0.001;
    x_high = 100;
    tol = 1e-6;
    
    while x_high - x_low > tol
        x_mid = (x_low + x_high) / 2;
        if f_cdf(x_mid, d1, d2) < p
            x_low = x_mid;
        else
            x_high = x_mid;
        end
    end
    x = (x_low + x_high) / 2;
end

function p = f_cdf(x, d1, d2)
    % F分布CDF（使用不完全beta函数）
    z = d1 * x / (d1 * x + d2);
    p = betainc(z, d1/2, d2/2);
end
