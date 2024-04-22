clc
close all
clear
Fs = 32000;
%% 读取文件
% 定义要读取的文件序列
channels = [1:8, 18:24];

% 用于存储每个文件数据的结构
data = struct();
all_Samples = [];  % 空矩阵，用于后续拼接所有通道的数据
% 循环遍历每个文件
for i = 1:length(channels)
    % 构造文件名
    filename = sprintf('CSC%d.ncs', channels(i));
    
    % 读取文件
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = Nlx2MatCSC(filename, [1 1 1 1 1], 1, 1, []);

    % 减去Timestamps中的最小值  
    Timestamps = Timestamps - min(Timestamps);
    % 插值，要对齐到真实时间
%     x = 1:numel(Timestamps);  % 原始x轴
%     xi = linspace(1, numel(Timestamps), numel(Timestamps)*512);  % 新的x轴，相当于在每两个数之间插入了511个新的数
    % 线性插值
%     newTimestamps = interp1(x, Timestamps, xi, 'linear');  % 插值后的数据% Timestamps = 0:16000/512:max(Timestamps);
%     Timestamps = newTimestamps*1e-6;
    % 将处理后的数据存储到结构中
    data(i).Timestamps = Timestamps;
%     data(i).ChannelNumbers = ChannelNumbers;
%     data(i).SampleFrequencies = SampleFrequencies;
%     data(i).NumberOfValidSamples = NumberOfValidSamples;
%     data(i).Samples = Samples;
%     data(i).Header = Header;
    data(i).Neruo_data = mean(Samples,1);%数据展开成一行
    
    all_Samples = cat(1, all_Samples, data(i).Neruo_data);
    
end


%% read event data
[EVTimestamps, EventIDs, TTLs, Extras, EventStrings, EVHeader] = Nlx2MatEV('Events.nev', [1 1 1 1 1], 1, 1, [] );

% Timestamps太大了，先减去仪器设定的值
% avg_sample = mean(Samples,1);
base_time = min(EVTimestamps);

EVTimestamps = EVTimestamps - base_time;


%% 


% 初始化 labels 矩阵，全部设置为 0
labels = zeros(size(Timestamps));

% 从第二个值开始，按照对的方式处理 Eventstamps
for i = 2:2:length(EVTimestamps)-1
    % 找到每个事件开始和结束时间戳在 Timestamps 中的最接近值的索引
    [~, start_idx] = min(abs(Timestamps - EVTimestamps(i)));
    [~, end_idx] = min(abs(Timestamps - EVTimestamps(i+1)));

    % 将 labels 中对应的值设置为 1
    labels(start_idx:end_idx) = 1;
end



%% save 
% Samples = Samples';
% Timestamps = Timestamps';
% labels = labels';
% 将 需要的文件 保存为 HDF5 文件，后续python读的快
h5create('Samples.h5', '/dataset', size(Samples));
h5write('Samples.h5', '/dataset', Samples);


h5create('Timestamps.h5', '/dataset', size(Timestamps));
h5write('Timestamps.h5', '/dataset', Timestamps);


h5create('labels.h5', '/dataset', size(labels));
h5write('labels.h5', '/dataset', labels);


