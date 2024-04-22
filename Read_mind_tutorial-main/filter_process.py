# Programmer : Haofan Wu
# Institutions :  Fanglab
# Data : 2024/2/28

# from tsai.all import *
import h5py
import numpy as np
from scipy.signal import butter, filtfilt
import pandas as pd
# 读取 HDF5 文件
# with h5py.File(r'D:\HaofanWu\2023_ai_for_brain_science\way_eeg_gal\process\P1/combined_data.h5', 'r') as f:
#     eeg_sig = f['/combined_data'][:]
with h5py.File(r'D:\matlab\software\bin\m\WHF\1jubang_from1_to_18_class\data_for_decoding.h5', 'r') as f:
    eeg_sig = f['/all_Samples'][:]




# with h5py.File(r'D:\matlab\software\bin\m\WHF\1jubang_from1_to_18_class\data_for_decoding.h5', 'r') as f:
#     TaskData = f['/labels'][:]
# 现在 data 是一个 numpy 数组，包含了 Samples 的数据



# 白化后全局标准化
mean_eeg = eeg_sig.mean(axis=0)
std_eeg = eeg_sig.std(axis=0)
eeg_sig_normalized_only = (eeg_sig - mean_eeg) / std_eeg

# 保存处理后的数据到一个新的 HDF5 文件
output_filename_only = 'neuro_data_normalized_only.h5'
with h5py.File(output_filename_only, 'w') as hdf_file:
    hdf_file.create_dataset('all_data', data=eeg_sig_normalized_only)

print('finish normalization and save only')






#  Median-subtraction to remove common-mode noise from the continuous traces

# 计算所有通道在每个时间点的中值
median_of_channels = np.median(eeg_sig, axis=1)

# 因为median_of_channels是一维数组，我们需要扩展其维度以便从eeg_sig中减去
median_of_channels = median_of_channels[:, np.newaxis]

# 执行中值减法来去除共模噪声
eeg_sig_denoised = eeg_sig - median_of_channels

# eeg_sig_denoised现在是去除共模噪声的信号


# 分批处理数据
batch_size = 10000  # 或者你可以选择一个适合你系统内存的其他大小
num_batches = eeg_sig.shape[0] // batch_size

# 创建一个空数组来存储去噪后的数据
eeg_sig_denoised = np.empty_like(eeg_sig)

for i in range(num_batches):
    # 计算当前批次的开始和结束索引
    start_idx = i * batch_size
    end_idx = start_idx + batch_size

    # 获取当前批次的数据
    batch_data = eeg_sig[start_idx:end_idx, :]

    # 执行中值减法
    median_of_channels = np.median(batch_data, axis=1)[:, np.newaxis]
    eeg_sig_denoised[start_idx:end_idx, :] = batch_data - median_of_channels

# 处理最后一个批次（如果有的话）
if eeg_sig.shape[0] % batch_size != 0:
    batch_data = eeg_sig[end_idx:, :]
    median_of_channels = np.median(batch_data, axis=1)[:, np.newaxis]
    eeg_sig_denoised[end_idx:, :] = batch_data - median_of_channels

# 现在 eeg_sig_denoised 包含了去除共模噪声的信号
print('finish Median-subtraction')




# 高通滤波


# 高通滤波函数
def highpass_filter(data, fs, cutoff=150, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = butter(order, normal_cutoff, btype='high', analog=False)
    filtered_data = filtfilt(b, a, data, axis=0)
    return filtered_data


# 白化

# 白化处理函数
def whiten_data(data):
    # 计算协方差矩阵
    cov_matrix = np.cov(data, rowvar=False)
    # 进行特征分解
    eigvals, eigvecs = np.linalg.eigh(cov_matrix)
    # 构造白化矩阵
    whitening_matrix = np.dot(eigvecs, np.diag(1.0 / np.sqrt(eigvals)))
    # 应用白化矩阵
    whitened_data = np.dot(data, whitening_matrix)
    return whitened_data

# # 假设 eeg_sig_denoised 是经过中值滤波后的数据
# fs = 32000  # 采样率
#
# # 高通滤波
# eeg_sig_filtered = highpass_filter(eeg_sig_denoised, fs)
# print('finish high pass')
# # 白化处理
# eeg_sig_whitened = whiten_data(eeg_sig_filtered)
#
# print('finish whiten')
#




# 白化后全局标准化
mean = eeg_sig_denoised.mean(axis=0)
std = eeg_sig_denoised.std(axis=0)
eeg_sig_normalized = (eeg_sig_denoised - mean) / std

# 保存处理后的数据到一个新的 HDF5 文件
output_filename = 'filter_processed_median_normalized.h5'
with h5py.File(output_filename, 'w') as hdf_file:
    hdf_file.create_dataset('all_data', data=eeg_sig_normalized)

print('finish normalization and save')


#
# # 定义输出的.h5文件名
# output_filename = 'filter_processed_neuro_data.h5'
#
# # 创建一个新的 HDF5 文件并写入处理后的数据
# with h5py.File(output_filename, 'w') as hdf_file:
#     hdf_file.create_dataset('all_data', data=eeg_sig_whitened)
#
