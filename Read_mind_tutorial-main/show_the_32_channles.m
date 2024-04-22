clc
clear
close all

% 定义文件夹中的文件名
fileNames = [];
for i = 1:32
    fileNames = [fileNames; {sprintf('CSC%d_0001.ncs', i)}];
end

% 创建一个大图来包含所有子图
figure('Units', 'normalized', 'Position', [0, 0, 1, 1]);

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

    % 绘制子图
    subplot(4, 8, i);
    plot(newTimestamps, data);
    xlim([min(newTimestamps) max(newTimestamps)]);
    ylim([min(data), max(data)]);
    title(sprintf('File: %s', fileNames{i}));

    % 清理变量以节省内存
    clear Timestamps data newTimestamps
end
