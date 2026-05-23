%% ============================================================
%  秩和检验法（Wilcoxon-Mann-Whitney检验）
%  判断两组数据间是否存在系统误差（无图形版）
%% ============================================================

clear; clc;

%% 1. 输入数据
x = [14.7, 14.8, 15.2, 15.6];   % 第一组数据，样本量 n1=4
y = [14.6, 15.0, 15.1];          % 第二组数据，样本量 n2=3

n1 = length(x);
n2 = length(y);
n = n1 + n2;

fprintf('================ 秩和检验法 ================\n');
fprintf('第一组数据 x: '); fprintf('%.1f ', x); fprintf('  (n1=%d)\n', n1);
fprintf('第二组数据 y: '); fprintf('%.1f ', y); fprintf('  (n2=%d)\n', n2);

%% 2. 合并数据并求秩
data = [x, y];
group = [ones(1,n1), 2*ones(1,n2)];

[sorted_data, sort_idx] = sort(data);
group_sorted = group(sort_idx);

fprintf('\n----- 合并排序与求秩 -----\n');
fprintf('序号\t数据\t组别\t秩\n');

ranks = zeros(1, n);
i = 1;
while i <= n
    j = i;
    while j <= n && sorted_data(j) == sorted_data(i)
        j = j + 1;
    end
    rank_avg = (i + j - 1) / 2;
    for k = i:(j-1)
        ranks(k) = rank_avg;
        group_name = 'x';
        if group_sorted(k) == 2
            group_name = 'y';
        end
        fprintf('%d\t%.1f\t%s\t%.1f\n', k, sorted_data(k), group_name, rank_avg);
    end
    i = j;
end

%% 3. 计算各组秩和
ranks_x = ranks(group_sorted == 1);
ranks_y = ranks(group_sorted == 2);

T_x = sum(ranks_x);
T_y = sum(ranks_y);

fprintf('\n----- 秩和计算 -----\n');
fprintf('x组秩: '); fprintf('%.1f ', ranks_x); fprintf('\n');
fprintf('y组秩: '); fprintf('%.1f ', ranks_y); fprintf('\n');
fprintf('x组秩和 T_x = %.1f\n', T_x);
fprintf('y组秩和 T_y = %.1f\n', T_y);
fprintf('验证: T_x + T_y = %.1f, 理论值 n(n+1)/2 = %d\n', T_x+T_y, n*(n+1)/2);

%% 4. 确定检验统计量
T = T_x;
n_small = n1;
group_name = 'x';

fprintf('\n----- 检验统计量 -----\n');
fprintf('取样本量较小的组 (%s组, n=%d) 的秩和 T = %.1f\n', group_name, n_small, T);

%% 5. 查表确定临界值
fprintf('\n----- 临界值比较 -----\n');

% n1=4, n2=3, α=0.05双侧查表
T_L = 7;
T_U = 17;

fprintf('小样本情况 (n1=%d, n2=%d)\n', n1, n2);
fprintf('查表得 α=0.05 双侧临界值范围: [%d, %d]\n', T_L, T_U);
fprintf('检验统计量 T = %.1f\n', T);

if T < T_L || T > T_U
    fprintf('【结论】T = %.1f 不在 [%d, %d] 范围内\n', T, T_L, T_U);
    fprintf('      拒绝原假设，两组数据存在显著差异！\n');
    fprintf('      ===> 存在系统误差 <===\n');
else
    fprintf('【结论】T = %.1f 在 [%d, %d] 范围内\n', T, T_L, T_U);
    fprintf('      接受原假设，两组数据无显著差异。\n');
    fprintf('      ===> 无系统误差 <===\n');
end

%% 6. 补充均值分析
fprintf('\n================ 补充分析 ================\n');
mean_x = mean(x);
mean_y = mean(y);
fprintf('x组均值: %.4f\n', mean_x);
fprintf('y组均值: %.4f\n', mean_y);
fprintf('均值差: %.4f\n', abs(mean_x - mean_y));
