clc
close all
clear
Fs = 32000;
tic; % 开始计时
%% 读取文件
% 定义要读取的文件序列
channels = [9:16, 25:32];

% 定义要保存的文件名
h5_filename = 'data_for_deep_learning.h5'; % 您可以根据需要更改文件名

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
    % 判断Samples的长度与Timestamps的长度是否相等
    if length(Samples(:)') ~= length(Timestamps)
        error('Sample length for channel %d does not match expected length.', i);
    end
    % 写入当前批次的数据到HDF5文件
    h5write(h5_filename, '/all_Samples', Samples(:)', [i, 1], [1, length(Timestamps)]);
end



%% 标签 这里根据实验时的csv自动生成，这是用于生成的标签



% 指定文件路径
filename = 'D:\HaofanWu\WHFcode\dreamdiffusion\datasets\V1_sample_Fanglab\labels\image_list_from1class_12class.csv'; % 请替换为实际的文件路径

% 打开文件以进行读取
fid = fopen(filename, 'rt');

% 确保文件成功打开
if fid == -1
    error('File %s cannot be opened.', filename);
end

% 读取整个文件，跳过第一行，并将每行作为一个单独的字符串
C = textscan(fid, '%s', 'Delimiter', '\n', 'HeaderLines', 1);
fclose(fid); % 不要忘记关闭文件

% 将数据存储在一个表中
tbl = cell2table(C{1}, 'VariableNames', {'image'});

% 显示表格的前几行以确认读取正确
head(tbl)


% Extract the 'image' column from the table
image_names = tbl.image;

% Initialize the labels array
labels = strings(1, length(Timestamps));
% 初始化变量
current_image_index = 1; % 当前图像索引
current_period_start_time = 0; % 当前周期的开始时间

% 实验参数
image_duration = 2; % 图像显示2秒
black_duration = 4; % 黑屏4秒
period_duration = image_duration + black_duration; % 一个周期6秒
images_per_class = 50; % 每个类50张图片
class_duration = images_per_class * period_duration; % 每个类的持续时间
total_classes = 18; % 总共5个类别
cycle_per_class = class_duration / period_duration; % 每个类的周期数
% 存储每个类的周期计数
class_cycle_counts = zeros(1, total_classes);



% 初始化 image_indices，这将存储每个图像标签的索引
image_indices = zeros(1, length(Timestamps)); % 预分配为0




% 遍历Timestamps分配标签
for i = 1:length(Timestamps)
    % 当前时间点
    current_time = Timestamps(i);
%     实际误差
    step = Timestamps(i+1) - Timestamps(i);
%     step = i < length(Timestamps) ? Timestamps(i+1) - Timestamps(i) : 0;
    % 计算当前时间在当前周期内的位置
    time_in_period = mod(current_time, period_duration);
    
    if time_in_period < image_duration 
        % 如果在图像显示期间
        image_labels(i) = image_names(current_image_index); % 分配当前图像标签
        image_indices(i) = current_image_index; % 保存图像索引
    else
        image_labels{i} = 'black'; % 黑屏期间
        image_indices(i) = -1; % 'black'的情况用-1填充
    end
    
    % 检查是否需要进入下一个周期
    if time_in_period >= period_duration - step
        % 如果当前周期结束，切换到下一个周期
        current_period_start_time = current_period_start_time + period_duration;
        current_image_index = current_image_index + 1; % 移动到下一个图像
        if current_image_index > height(tbl)
            % 如果所有图片都已经使用，停止分配
            break;
        end
    end
end

% 如果循环提前退出，将剩余部分标记为黑屏
if i < length(Timestamps)
    for j = (i+1):length(Timestamps)
        image_labels{j} = 'black';
        image_indices(j) = -1; % 'black'的情况用-1填充
    end
end

% 展示一些标签确保它们看起来是正确的
disp(image_labels(1:100)); % 只显示前100个标签作为检查



%% 验证
% 验证，并生成simple标签用于深度学习
% 初始化一个新的 cell 数组来存储简化后的标签
simplified_labels = cell(size(image_labels));

% 初始化一个空的 cell 数组来收集类名
class_names = {};

% 遍历 image_labels 并提取所需信息
for i = 1:length(image_labels)
    if ~strcmp(image_labels{i}, 'black')  % 如果不是 'black'
        % 提取文件名（不包含扩展名）
        [~, name, ~] = fileparts(image_labels{i});
        simplified_labels{i} = name;

        % 提取并存储类名
        path_parts = strsplit(image_labels{i}, '\');
        class_name = path_parts{end-1};
        class_names{end+1} = class_name;
    else
        simplified_labels{i} = 'black';
    end
end


% 去除重复的类名并统计数量
[unique_classes, ~, idx] = unique(class_names);
total_classes = length(unique_classes);

% 计算每个类别的频次
class_counts = accumarray(idx, 1);

% 打印总共的类别数量
fprintf('总共有 %d 个类别。\n', total_classes);

% 显示每个类别及其频次
for i = 1:length(unique_classes)
    fprintf('类别 %s 出现了 %d 次。\n', unique_classes{i}, class_counts(i));
end
% 验证image_indices的情况
% 计算独特值及其出现的次数
[unique_indices, ~, ic] = unique(image_indices);
counts = accumarray(ic, 1);

% 显示结果
for i = 1:length(unique_indices)
    fprintf('索引 %d 出现了 %d 次。\n', unique_indices(i), counts(i));
end


%% 保存
image_indices_list = image_indices(:)'; % 将其变形为一个列向量

% 创建HDF5文件并写入image_indices
h5create(h5_filename, '/image_indices', [1, length(image_indices_list)]);
h5write(h5_filename, '/image_indices', image_indices_list);


% 确认文件保存
disp(['image_indices 和 all_Samples 已保存到文件：' h5_filename]);

elapsedTime = toc; % 结束计时并获取经过的时间

fprintf('程序运行总时间： %.2f 秒。\n', elapsedTime);