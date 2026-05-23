%% ============================================================
%  温度测量数据处理程序
%  处理50个等精度测量数据，消除系统误差和粗大误差
%% ============================================================

clear; clc; close all;

%% 1. 读取原始数据
data = [50.1075; 50.4168; 49.6482; 50.3224; 50.2638; 49.9885; 50.2133; 50.4185; 51.1157; 51.0039;
        50.2300; 51.1570; 50.7451; 50.6374; 53.8429; 50.7090; 50.7752; 51.1479; 51.1818; 51.2334;
        51.1343; 50.8085; 51.2434; 51.4760; 51.2978; 51.4569; 51.4454; 51.2893; 51.4588; 51.2925;
        51.6777; 51.3206; 51.3862; 51.4881; 51.1111; 52.0377; 51.8650; 51.6990; 52.1741; 51.6077;
        51.9796; 52.0017; 52.1638; 52.2126; 52.0270; 52.2440; 52.2670; 52.4755; 52.6187; 52.6719];
n = length(data);

fprintf('================ 温度测量数据处理 ================\n');
fprintf('测量次数 n = %d\n', n);
fprintf('原始数据范围: %.4f ~ %.4f\n', min(data), max(data));

%% ======（1）画出原始测量数据的残余误差散点图======
figure('Name', '原始数据残余误差散点图', 'Position', [50 550 700 350]);
mean_orig = mean(data);
v_orig = data - mean_orig;

scatter(1:n, v_orig, 40, 'b', 'filled');
hold on;
plot([1 n], [0 0], 'r--', 'LineWidth', 1.5);
xlabel('测量序号 i');
ylabel('残余误差 v_i (℃)');
title('原始测量数据残余误差散点图');
grid on;
hold off;

fprintf('\n原始数据均值: %.4f ℃\n', mean_orig);

%% ======（2）检验是否存在系统误差======
fprintf('\n================（2）系统误差检验 ================\n');

% 马利科夫准则
n1 = floor(n/2);
n2 = n - n1;
M1 = sum(v_orig(1:n1));
M2 = sum(v_orig(n1+1:n));
M = M1 - M2;

fprintf('马利科夫准则:\n');
fprintf('  前半段残差和 M1 = %.4f\n', M1);
fprintf('  后半段残差和 M2 = %.4f\n', M2);
fprintf('  M = M1 - M2 = %.4f\n', M);
fprintf('  残差绝对值平均 = %.4f\n', mean(abs(v_orig)));

if abs(M) > mean(abs(v_orig))
    fprintf('  【结论】|M| > 残差绝对值平均，存在系统误差！\n');
else
    fprintf('  【结论】|M| <= 残差绝对值平均，未发现明显系统误差。\n');
end

% 线性趋势判断
p = polyfit(1:n, v_orig, 1);
fprintf('\n线性拟合斜率: %.6f\n', p(1));
if abs(p(1)) > 0.001
    fprintf('【结论】残差存在明显线性趋势，存在线性系统误差！\n');
    has_system_error = true;
else
    fprintf('【结论】残差无明显线性趋势。\n');
    has_system_error = false;
end

%% ======（3）用两端点法估计线性系统误差斜率并修正======
fprintf('\n================（3）两端点法修正线性系统误差 ================');

% 两端点法：用首尾各5个点的均值估计端点值
m = 5;  % 端点取数个数
x_start = mean(data(1:m));
x_end = mean(data(n-m+1:n));

% 线性模型: x_i = a + b*i
b_est = (x_end - x_start) / (n - 1);    % 斜率
a_est = x_start - b_est * (m+1)/2;       % 截距（修正）

fprintf('\n两端点法估计:\n');
fprintf('  前%d点均值 = %.4f ℃\n', m, x_start);
fprintf('  后%d点均值 = %.4f ℃\n', m, x_end);
fprintf('  线性系统误差斜率 b = %.6f ℃/次\n', b_est);

% 修正系统误差
i_vec = (1:n)';
system_error = b_est * (i_vec - (n+1)/2);   % 以中心为参考的线性误差
data_corrected = data - system_error;

fprintf('\n修正后数据范围: %.4f ~ %.4f\n', min(data_corrected), max(data_corrected));

%% ======（4）判别粗大误差并剔除======
fprintf('\n================（4）粗大误差判别与剔除 ================');

% 用3σ准则（莱特准则）判别粗大误差
mean_corr = mean(data_corrected);
std_corr = sqrt(sum((data_corrected - mean_corr).^2) / (n-1));  % 无偏标准差
sigma_corr = sqrt(sum((data_corrected - mean_corr).^2) / n);    % 总体标准差

v_corr = data_corrected - mean_corr;

fprintf('\n修正后数据:\n');
fprintf('  均值 = %.4f ℃\n', mean_corr);
fprintf('  标准差 σ = %.4f ℃\n', sigma_corr);

% 3σ准则
threshold = 3 * sigma_corr;
fprintf('  3σ = %.4f ℃\n', threshold);

fprintf('\n粗大误差检验:\n');
outliers = [];
for i = 1:n
    if abs(v_corr(i)) > threshold
        fprintf('  第%d个数据: %.4f, |v| = %.4f > 3σ, 【粗大误差】\n', i, data(i), abs(v_corr(i)));
        outliers = [outliers, i];
    end
end

if isempty(outliers)
    fprintf('  未发现粗大误差。\n');
    data_final = data_corrected;
else
    fprintf('  共发现 %d 个粗大误差，予以剔除。\n', length(outliers));
    % 剔除粗大误差
    keep_idx = setdiff(1:n, outliers);
    data_final = data_corrected(keep_idx);
    n_final = length(data_final);
    fprintf('  剔除后剩余 %d 个数据。\n', n_final);
end

%% ======（5）画出修正后的测量数据散点图======
figure('Name', '修正后数据散点图', 'Position', [800 550 700 350]);

if ~isempty(outliers)
    keep_idx = setdiff(1:n, outliers);
    scatter(keep_idx, data_final, 40, 'b', 'filled');
    hold on;
    scatter(outliers, data_corrected(outliers), 60, 'r', 'x', 'LineWidth', 2);
    legend('保留数据', '剔除的粗大误差', 'Location', 'best');
else
    scatter(1:n, data_final, 40, 'b', 'filled');
end

xlabel('测量序号 i');
ylabel('温度 (℃)');
title('修正系统误差和剔除粗大误差后的数据散点图');
grid on;
hold off;

%% ======（6）正态性检验并画出统计直方图======
fprintf('\n================（6）正态性检验与统计直方图 ================');

n_final = length(data_final);
mean_final = mean(data_final);
std_final = sqrt(sum((data_final - mean_final).^2) / (n_final-1));

fprintf('\n最终数据:\n');
fprintf('  样本量 n = %d\n', n_final);
fprintf('  均值 = %.4f ℃\n', mean_final);
fprintf('  标准差 = %.4f ℃\n', std_final);

% 偏度和峰度检验
m3 = mean((data_final - mean_final).^3);
m4 = mean((data_final - mean_final).^4);
skew = m3 / std_final^3;
kurt = m4 / std_final^4;

fprintf('  偏度 = %.4f (理论: 0)\n', skew);
fprintf('  峰度 = %.4f (理论: 3)\n', kurt);

if abs(skew) < 0.5 && abs(kurt - 3) < 1
    fprintf('  【结论】偏度和峰度接近理论值，数据近似服从正态分布。\n');
else
    fprintf('  【结论】偏度或峰度偏离较大，正态性一般。\n');
end

% 统计直方图
figure('Name', '统计直方图', 'Position', [50 50 600 400]);
[counts, edges] = histcounts(data_final, 10);
centers = (edges(1:end-1) + edges(2:end)) / 2;
width = edges(2) - edges(1);

bar(centers, counts, 1, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'w');
hold on;

% 叠加正态分布曲线
x_norm = linspace(min(data_final)-0.5, max(data_final)+0.5, 200);
y_norm = (1/(std_final*sqrt(2*pi))) * exp(-(x_norm - mean_final).^2 / (2*std_final^2));
y_norm = y_norm * width * n_final;  % 缩放与直方图匹配

plot(x_norm, y_norm, 'r-', 'LineWidth', 2);
xlabel('温度 (℃)');
ylabel('频数');
title('统计直方图与正态分布曲线');
legend('直方图', '正态分布', 'Location', 'best');
grid on;
hold off;

%% ======（7）求算术平均值的标准差======
fprintf('\n================（7）算术平均值的标准差 ================');

sigma_xbar = std_final / sqrt(n_final);
fprintf('算术平均值的标准差 σ_x̄ = σ/√n = %.4f/√%d = %.6f ℃\n', ...
    std_final, n_final, sigma_xbar);

%% ======（8）求算术平均值的极限误差（95%置信概率）======
fprintf('\n================（8）算术平均值的极限误差（95%置信概率）================');

% 95%置信概率，正态分布
% 对于大样本(n>30)，用正态分布: z = 1.96
% 对于小样本，用t分布
if n_final > 30
    z = 1.96;
    fprintf('\n大样本(n=%d>30)，采用正态分布:\n', n_final);
else
    % 手动计算t分布临界值（95%双侧）
    z = t_inv_95(n_final - 1);
    fprintf('\n小样本(n=%d<=30)，采用t分布:\n', n_final);
end

delta_lim = z * sigma_xbar;
fprintf('  置信概率 P = 95%%\n');
fprintf('  置信系数 z/t = %.4f\n', z);
fprintf('  极限误差 δ_lim = z * σ_x̄ = %.4f * %.6f = %.6f ℃\n', z, sigma_xbar, delta_lim);

%% ======（9）输出最后测量结果======
fprintf('\n================（9）最终测量结果 ================');
fprintf('\n【测量结果】（95%%置信概率）\n');
fprintf('  温度 = %.4f ± %.4f ℃\n', mean_final, delta_lim);
fprintf('  即: %.4f ℃ ~ %.4f ℃\n', mean_final - delta_lim, mean_final + delta_lim);
fprintf('  置信概率: 95%%\n');
fprintf('  样本量: %d\n', n_final);

%% ==================== 辅助函数 ====================

function t_val = t_inv_95(nu)
    % t分布95%双侧临界值（近似公式）
    % 对于大样本趋近于1.96
    if nu > 30
        t_val = 1.96;
    elseif nu > 0
        % 常用t值表插值
        t_table = [12.706; 4.303; 3.182; 2.776; 2.571; 2.447; 2.365; 2.306; 2.262; 2.228;
                   2.201; 2.179; 2.160; 2.145; 2.131; 2.120; 2.110; 2.101; 2.093; 2.086;
                   2.080; 2.074; 2.069; 2.064; 2.060; 2.056; 2.052; 2.048; 2.045; 2.042];
        if nu <= 30
            t_val = t_table(nu);
        else
            t_val = 1.96;
        end
    else
        t_val = 1.96;
    end
end
