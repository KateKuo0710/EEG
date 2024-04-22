clc
close all
clear
Fs = 32000;
tic; % 开始计时
%% 读取文件
% 定义要读取的文件序列
channels = [9:16, 25:32];

% 定义要保存的文件名
h5_filename = 'data_for_preprocessing.h5'; % 您可以根据需要更改文件名

% 检查文件是否存在
if exist(h5_filename, 'file') == 2
    % 如果文件存在，先删除它
    delete(h5_filename);
end

% 预先设定all_Samples的总大小，如果不可预知，则需要动态调整
totalSamples = 0; % 这需要基于您的数据预先计算或动态更新

% 初始化image_indices列表，此处为示例，具体实现需根据您的标签生成逻辑来定
image_indices_list = []; % 根据实际情况生成

% 循环遍历每个文件
for i = 1:length(channels)
    % 构造文件名
    filename = sprintf('CSC%d_0002.ncs', channels(i));
    
    % 读取文件
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = Nlx2MatCSC(filename, [1 1 1 1 1], 1, 1, []);

    % 减去Timestamps中的最小值  
    Timestamps = Timestamps - min(Timestamps);
    % 插值，要对齐到真实时间
    x = 1:numel(Timestamps);  % 原始x轴
    xi = linspace(1, numel(Timestamps), numel(Timestamps)*512);  % 新的x轴，相当于在每两个数之间插入了511个新的数
    % 线性插值
    newTimestamps = interp1(x, Timestamps, xi, 'linear');  % 插值后的数据% Timestamps = 0:16000/512:max(Timestamps);
    Timestamps = newTimestamps*1e-6;
    % 将处理后的数据存储到结构中
    % 将处理后的数据写入HDF5文件
%     currentBatchSize = size(Samples, 2); % 假设Samples是一个二维矩阵，其第二维表示样本数
    if i == 1
        h5create(h5_filename, '/all_Samples', [length(channels), length(Timestamps)]);
    end
    if length(Samples(:)') ~= length(Timestamps)
        error('Sample length for channel %d does not match expected length.', i);
    end
    % 写入当前批次的数据到HDF5文件
    h5write(h5_filename, '/all_Samples', Samples(:)', [i, 1], [1, length(Timestamps)]);
end
elapsedTime = toc; % 结束计时并获取经过的时间

fprintf('程序运行总时间： %.2f 秒。\n', elapsedTime);
