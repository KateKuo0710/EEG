clc
clear
close all

% 定义文件夹中的文件名
fileNames = [];
for i = 1:32
    fileNames = [fileNames; {sprintf('CSC%d.ncs', i)}];
end

% 创建一个大图来包含所有子图
figure('Units', 'normalized', 'Position', [0, 0, 1, 1]);
% 这个单位是s
time_show = 240;
% 循环处理每个文件
for i = 1:length(fileNames)
    % 读取数据
    [Timestamps, ChannelNumbers, SampleFrequencies,NumberOfValidSamples, Samples, Header] = Nlx2MatCSC(fileNames{i}, [1 1 1 1 1], 1, 1, []);

    % 处理时间戳和数据
    base_time = min(Timestamps);
    Timestamps = (Timestamps - base_time) * 1e-6;
    data = Samples(:);

    % 创建新的x轴
    xi = linspace(1, numel(Timestamps), numel(Timestamps) * 512);
    newTimestamps = interp1(1:numel(Timestamps), Timestamps, xi, 'linear');

    
        % 找到60秒内的数据
    idx_60s = find(newTimestamps <= time_show, 1, 'last'); % 找到不超过60秒的最后一个索引
    if isempty(idx_60s)
        disp(['No data within 60 seconds for file ' fileNames{i}]);
        continue; % 如果没有数据在60秒内，则跳过这个文件
    end
    newTimestamps_60s = newTimestamps(1:idx_60s);
    data_60s = data(1:idx_60s);
    
    % 绘制子图
    subplot(4, 8, i);
    plot(newTimestamps_60s, data_60s);
    xlim([min(newTimestamps_60s) max(newTimestamps_60s)]);
    ylim([min(data_60s), max(data_60s)]);
    title(sprintf('File: %s', fileNames{i}));

    % 清理变量以节省内存
    clear Timestamps data newTimestamps
end
