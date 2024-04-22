clear;
clc
close all
[Timestamps, ChannelNumbers, SampleFrequencies,NumberOfValidSamples, Samples, Header] = Nlx2MatCSC('CSC13.ncs',[1 1 1 1 1], 1, 1, [] );
[EVTimestamps, EventIDs, TTLs, Extras, EventStrings, EVHeader] = Nlx2MatEV('Event.nev', [1 1 1 1 1], 1, 1, [] );
data = Samples(:);%数据换为一行

deta5 = 5*median(abs(data/0.6745));%5倍阈值d

for j = 2:length(EVTimestamps)
    EVlocs(j) = find(Timestamps>EVTimestamps(j),1);%找到到EV点在Timestamps里面的位置，
end

strlocscell = strfind(EventStrings, '10s');%匹配开始的TTL信号,需要自己输入字符串，匹配的在strlocscell里为1
EVTTL = 1;%做目标Events索引

for i=1:length(strlocscell)
    a=isempty(strlocscell{i});%一个一个的判断，看strlocs哪个位置不是空的
    if a==0
        strlocs(EVTTL,:) =  i;%找到了把位置放在Strlocs里
        EVTTL = EVTTL + 1;%找到了索引加
    end
end
%找到为1的位置，输出为其在EVTimestamps里的位置

preaddtime = 10;%设置刺激点前面时间
postaddtime = 10;%设置刺激点后面时间

EVSamplesindex = 1;%为了数据顺序重新建立索引

%截取了刺激点前后设定时间的数据
for k = strlocs'
    EVSamples = Samples(:,(EVlocs(k)-(preaddtime/0.016)):(EVlocs(k)+(postaddtime/0.016)));%找到到EV点在Timestamps里面的位置，
    EVSamplesvec(EVSamplesindex,:) = EVSamples(:);
    EVSamplesindex = EVSamplesindex + 1;
end

for j = 1:(EVTTL-1)
    dataproc = EVSamplesvec(j,:);
    [pks2,locs2] = findpeaks(abs(dataproc),'MinPeakHeight',9*deta5);%找到刺激极值点，绝对值找大的波峰和波谷
    
    %抹去光引起的信号
    for i = locs2
       dataproc((i-128):(i+128)) = 0;
    end
    
    EVSamplesvec(j+11,:) = dataproc;
    [pks,locs] = findpeaks(dataproc,'MinPeakHeight',deta5);%找到5倍阈值以上的点
    findpeaks(dataproc,32000,'MinPeakHeight',deta5);%画图

%     将极值点标为1
%     将十倍极值点标为0
    heatmapdatavec = zeros(1,length(dataproc));
    for i = locs
        heatmapdatavec(i) = 1;
    end
    heatmapdata(j,:) = heatmapdatavec;
end

save allpoint1 heatmapdata
% plot(pksdata);
% hold on ;
% plot(mean(pksdata')','linewidth',2);
real_dataproc = dataproc*0.000000030517578125000001*1000*1000;
plot(real_dataproc)

%% 提取单个脉冲附近的值
% 定义一个参数，表示需要提取的点的数量
num_points_to_extract = 200;%这个参数表示峰值附近多少个点

% 找到第一个大于阈值的脉冲的位置
first_pulse_location = find(abs(real_dataproc) > 100, 1);% 第一个参数是阈值，第2个参数改是第几个峰

% 计算提取点的开始和结束位置
start_location = max(1, first_pulse_location - num_points_to_extract/2);
end_location = min(length(real_dataproc), first_pulse_location + num_points_to_extract/2);

% 提取横纵坐标点
x_coordinates = start_location:end_location; % 横坐标
% x_coordinates = x_coordinates/32000;
y_coordinates = real_dataproc(start_location:end_location); % 纵坐标

% 创建一个索引数组，从0开始
indices = 0:(length(y_coordinates)-1);
indices = indices/32;
% 显示提取的点
figure;
plot(indices, y_coordinates);
title('Extracted Points Near the First Pulse');
xlabel('Time_ms');
ylabel('Amplitude');



% 定义一个文件名
filename = 'data_output.txt';

% 如果存在同名文件，先删除
if exist(filename, 'file')
    delete(filename);
end


% 使用fprintf写入数据到txt文件
fid = fopen(filename, 'w');

fprintf(fid, '%s\t%s\n', 'Time_ms', 'Amplitude'); % 写入列名

for i = 1:length(indices)
    fprintf(fid, '%d\t%f\n', indices(i), y_coordinates(i));
end

fclose(fid);
