clc
close all
clear
Fs = 32000;
%% 读取文件
% 定义要读取的文件序列
channels = [1:8, 17:24];
% [EVTimestamps, EventIDs, TTLs, Extras, EventStrings, EVHeader] = Nlx2MatEV('Events.nev', [1 1 1 1 1], 1, 1, [] );
% 用于存储每个文件数据的结构
data = struct();
all_Samples = [];  % 空矩阵，用于后续拼接所有通道的数据
% 循环遍历每个文件
for i = 1:length(channels)
    % 构造文件名
    filename = sprintf('CSC%d_0001.ncs', channels(i));
    
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
    data(i).Timestamps = Timestamps;
%     data(i).ChannelNumbers = ChannelNumbers;
%     data(i).SampleFrequencies = SampleFrequencies;
%     data(i).NumberOfValidSamples = NumberOfValidSamples;
%     data(i).Samples = Samples;
%     data(i).Header = Header;
    data(i).Neruo_data = Samples(:)';%数据展开成一行
    
    all_Samples = cat(1, all_Samples, data(i).Neruo_data);
    
end



%% 标签 用于解码验证的标签
% 初始化labels矩阵
labels = zeros(1, length(Timestamps));

% 实验参数
image_duration = 2; % 图像显示2秒
black_duration = 4; % 黑屏4秒
period_duration = image_duration + black_duration; % 一个周期6秒
images_per_class = 50; % 每个类50张图片
class_duration = images_per_class * period_duration; % 每个类的持续时间
total_classes = 13; % 总共5个类别
cycle_per_class = class_duration / period_duration; % 每个类的周期数
% 存储每个类的周期计数
class_cycle_counts = zeros(1, total_classes);

% 当前类别和周期计数器
current_class_label = 1;
current_cycle_count = 0;

% 遍历Timestamps分配标签
for i = 1:length(Timestamps)
    % 当前时间点
    current_time = Timestamps(i);
    % 计算当前时间与下一个时间点的间隔
    step = Timestamps(i+1) - Timestamps(i);
    if step ~= 1/Fs
%         fprintf('Step error at index %d: Timestamps(%d) = %f, Timestamps(%d) = %f\n', i, i, Timestamps(i), i+1, Timestamps(i+1));
%         error('Timestamps step interval is not consistent with 1/Fs.');
    end
    % 计算当前时间在当前周期内的位置
    time_in_period = mod(current_time, period_duration);
    
    % 根据时间在周期内的位置分配标签
    if time_in_period < image_duration 
        labels(i) = current_class_label;
    else
        labels(i) = 0; % 黑屏
    end
    
    % 如果当前周期结束，更新周期计数器和检查是否切换类别
    % 注意这里，大于一个周期减采样率
    if time_in_period > period_duration - step
        current_cycle_count = current_cycle_count + 1;
        % 检查是否需要切换到下一个类别
        if current_cycle_count >= cycle_per_class
            class_cycle_counts(current_class_label) = current_cycle_count; % 保存当前类的周期计数
            current_cycle_count = 0; % 重置周期计数器
            current_class_label = current_class_label + 1; % 切换到下一个类别
            if current_class_label > total_classes
                fprintf('Ending label creation at index %d, Timestamps(%d) = %f\n', i, i, Timestamps(i));
                break; % 如果超过总类别数，结束循环
            end
        end
    end
end

% 打印每个类的周期计数
disp('Cycle counts for each class:');
disp(class_cycle_counts);
% 找出labels中的独特值
unique_labels = unique(labels);

% 计算每个独特值的个数
label_counts = histc(labels, unique_labels);
label_counts_sum = 0;
% 显示结果
for k = 1:length(unique_labels)
    fprintf('Label %d: %d occurrences\n', unique_labels(k), label_counts(k));
    if unique_labels(k)~=0
        label_counts_sum = label_counts_sum +label_counts(k);
    end
end

fprintf('Labels Counts %d \n',label_counts_sum*2)
%% 保存
% 定义文件名
all_samples_file = 'all_Samples.h5';
timestamps_file = 'Timestamps.h5';
labels_file = 'labels.h5';

% 检查文件是否存在，如果存在则删除
if exist(all_samples_file, 'file') == 2
    delete(all_samples_file);
end
if exist(timestamps_file, 'file') == 2
    delete(timestamps_file);
end
if exist(labels_file, 'file') == 2
    delete(labels_file);
end

% 保存all_Samples到HDF5文件中
h5create(all_samples_file, '/dataset', size(all_Samples));
h5write(all_samples_file, '/dataset', all_Samples);

% 保存Timestamps到HDF5文件中
h5create(timestamps_file, '/dataset', size(Timestamps));
h5write(timestamps_file, '/dataset', Timestamps);

% 保存labels到HDF5文件中
h5create(labels_file, '/dataset', size(labels));
h5write(labels_file, '/dataset', labels);