print("hell a python")

def matrix_multiply(A, B):
    """
    实现矩阵A与矩阵B相乘，返回结果矩阵C
    A、B、C均为二维列表
    """
    # 获取矩阵维度 - 修正语法错误 + 空矩阵防护
    rows_A = len(A)
    # 修复：正确获取A的列数，空矩阵/非法矩阵直接报错
    cols_A = len(A[0]) if rows_A > 0 else 0
    rows_B = len(B)
    # 修复：正确获取B的列数
    cols_B = len(B[0]) if rows_B > 0 else 0
    
    # 检查矩阵维度是否匹配
    if cols_A != rows_B:
        raise ValueError(f"矩阵A的列数({cols_A})必须等于矩阵B的行数({rows_B})")
    
    # 初始化结果矩阵（避免浅拷贝问题）
    C = [[0 for _ in range(cols_B)] for _ in range(rows_A)]
    
    # 矩阵乘法三重循环
    for i in range(rows_A):
        for j in range(cols_B):
            for k in range(cols_A):
                C[i][j] += A[i][k] * B[k][j]
    
    return C