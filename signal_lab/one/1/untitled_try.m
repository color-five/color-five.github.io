%% 分块矩阵运算练习
clear; clc;

% 1. 定义各子矩阵
E = eye(3);              % 3×3 单位矩阵
R = rand(3, 2);          % 3×2 随机矩阵 (元素在0~1之间)
O = zeros(2, 3);         % 2×3 零矩阵
S = diag([5, 3]);        % 2×2 对角矩阵 (对角线元素设为5和3)

% 2. 构造分块矩阵 A
A = [E, R;O, S];

disp('========== 矩阵 A ==========');
disp(A);
disp('矩阵 A 的维度:');
disp(size(A));

% 3. 计算 A^2
A2 = A * A;

disp('========== A^2 (直接计算) ==========');
disp(A2);

% 4. 按公式计算右侧矩阵
% 公式: A^2 = [E, R+RS; O, S^2]
RS = R * S;              % R * S
% E_plus_RS 已去除（维度不匹配），仅保留 RS
S2 = S * S;              % S^2

% 构造右侧矩阵（按正确分块乘法）
RightSide = [E,   R + RS;
             O,   S2];

disp('========== [E, R+RS; O, S^2] (公式计算) ==========');
disp(RightSide);

% 5. 验证两者是否相等
disp('========== 验证结果 ==========');
difference = A2 - RightSide;
disp('A^2 - [E, R+RS; O, S^2] =');
disp(difference);

% 判断是否在浮点误差范围内相等
tolerance = 1e-10;
isEqual = all(abs(difference(:)) < tolerance);

if isEqual
    disp('✓ 验证通过！A^2 = [E, R+RS; O, S^2] 成立');
else
    disp('✗ 验证失败');
end

% 6. 详细展示各子块计算过程
disp(' ');
disp('========== 详细子块计算 ==========');
disp('E (单位矩阵):');
disp(E);
disp('R (随机矩阵):');
disp(R);
disp('O (零矩阵):');
disp(O);
disp('S (对角矩阵):');
disp(S);
disp('R*S =');
disp(RS);
disp('S^2 =');
disp(S2);
