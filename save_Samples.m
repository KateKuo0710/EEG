clc
close all
clear
tic; % 开始计时
%% 读取文件
% 定义要读取的文件序列
channels = [9:16, 25:32];

% 定义要保存的文件名
h5_filename = 'data_for_deep_learning.h5'; % 您可以根据需要更改文件名
% 预先设定all_Samples的总大小，如果不可预知，则需要动态调整
totalSamples = 0; % 这需要基于您的数据预先计算或动态更新

% 初始化image_indices列表，此处为示例，具体实现需根据您的标签生成逻辑来定
image_indices_list = []; % 根据实际情况生成

total_timestamp = 115199878;
% 循环遍历每个文件
for i = 1:length(channels)
    % 构造文件名
    filename = sprintf('CSC%d_0002.ncs', channels(i));
    
    % 读取文件
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = Nlx2MatCSC(filename, [1 1 1 1 1], 1, 1, []);
    Samples = Samples(:)';%数据展开成一行
    if i == 1
        h5create(h5_filename, '/all_Samples', [length(channels), total_timestamp]);
    end
    % 写入当前批次的数据到HDF5文件
    h5write(h5_filename, '/all_Samples', Samples(1:total_timestamp), [i, 1], [1, total_timestamp]);
end
% 确认文件保存
disp(['Samples已保存到文件：' h5_filename]);

elapsedTime = toc; % 结束计时并获取经过的时间

fprintf('程序运行总时间： %.2f 秒。\n', elapsedTime);