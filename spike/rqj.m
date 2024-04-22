clc
clear
close all
%% 
% jet bar可调
% 50hz滤波太狠了
%%
% 数据读入处理

% [Timestamps, ChannelNumbers, SampleFrequencies,NumberOfValidSamples, Samples, Header] = Nlx2MatCSC('CSC7_baseline.ncs',[1 1 1 1 1], 1, 1, [] );

[Timestamps, ChannelNumbers, SampleFrequencies,NumberOfValidSamples, Samples, Header] = Nlx2MatCSC('833.ncs',[1 1 1 1 1], 1, 1, [] );


%% 处理时间戳 

base_time = min(Timestamps);
Timestamps = Timestamps - base_time;


%% 处理采样数据
% Timestamps = Timestamps*1e-6;
% 数据成一行
data = Samples(:);%数据换为一行
% data = avg_Samples1;
% 时间戳插值匹配数据


% 创建新的x轴，以31.25递增
x = 1:numel(Timestamps);  % 原始x轴
xi = linspace(1, numel(Timestamps), numel(Timestamps)*512);  % 新的x轴，相当于在每两个数之间插入了511个新的数

% 线性插值
newTimestamps = interp1(x, Timestamps, xi, 'linear');  % 插值后的数据% Timestamps = 0:16000/512:max(Timestamps);
Timestamps = newTimestamps*1e-6;

% % 创建新的x轴，以31.25递增
% x = 1:numel(Timestamps);  % 原始x轴
% xi = 1:(1/512):(numel(Timestamps));  % 新的x轴，相当于在每两个数之间插入了511个新的数
% 
% % 线性插值
% newData = interp1(x, Timestamps, xi, 'linear');  % 插值后的数据



% data = avg_Samples1;

% data = readtable('D:\1Fanglab\WBF\第二次分段数据\分段数据/凝胶29.txt');

time = Timestamps;  % 第一列是采样时间
sensorData = data;  % 第二列是传感器的数值

% 
% time = data.Time_sec_;  % 第一列是采样时间
% sensorData = data.Voltage_mV_;  % 第二列是传感器的数值
% time = data.Time_sec_(1:40000);  % 第一列是采样时间
% sensorData = data.Voltage_mV_(1:40000);  % 第二列是传感器的数值
%%
% 原始数据显示
figure
plot(time,sensorData)
% xticks(min(time):1000:max(time));  % 设置x轴刻度
xlim([min(time) max(time)]);
ylim([min(sensorData) ,max(sensorData)]);
title('Raw data')
% 计算采样频率
Fs = 1 / mean(diff(time));  % diff(time) 计算相邻采样时间的差
% Fs = 32000
% FFT分析
n = length(sensorData); % 信号长度
Y = fft(sensorData); % 快速傅里叶变换
P2 = abs(Y/n); % 双侧频谱
P1 = P2(1:n/2+1); % 单侧频谱
P1(2:end-1) = 2*P1(2:end-1);

% 频率轴
f = Fs*(0:(n/2))/n;

% 绘制频域分析结果
figure;
plot(f,P1);
xlim([min(f) 500]);
title('Frequency Domain Analysis');
xlabel('Frequency (Hz)');
ylabel('Amplitude');

% 调整字体大小和字体类型
set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');



%% 生成功率频率图

% 
movingwin=[2 .01];
params.Fs=32000;
params.tapers=[3 5];
params.fpass=[0 48];%改频率范围
[S1,t,f]=mtspecgramc(sensorData,movingwin,params); 
plot_matrix(S1,t,f);
xlabel('Time (s)');
ylabel('Frequency (Hz)');
% colormap(jet);
caxis([15 55]);%改功率范围
h = colorbar;  % 在右边显示功率的颜色条
ylabel(h,'Power (dB)');  % 修改颜色条的Y标签为"Power (dB)"
