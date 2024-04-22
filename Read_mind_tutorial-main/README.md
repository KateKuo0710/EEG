# Read_mind_tutorial
自己记录实验过程

# 提前记录在这里，一些比较坑的小问题

## 白痴信息办的把github 22端口给封了，以及一些运行问题
这样解决：
<pre>
```
ssh -T -p 443 git@ssh.github.com
测试证明可以用ssh换到443端口的方式解决
```
</pre>

<pre>
```
vim ~/.ssh/config
添加如下内容，再用git就行了
Host github.com
  Hostname ssh.github.com
  Port 443
  User git    
```
</pre>
### 新建ssh

<pre>
```
生成 Ed25519 SSH 密钥
ssh-keygen -t ed25519 -C "1557736812@qq.com"  
确保 SSH Agent 正在运行    
eval "$(ssh-agent -s)"
添加私钥到 SSH Agent
ssh-add ~/.ssh/id_ed25519
显示 SSH 公钥    
cat ~/.ssh/id_ed25519.pub    
复制到GitHub添加进去
```
</pre>

### 新建分支
<pre>
```
git fetch
查看所有    
git branch -a
本地没有，直接拉分支
git checkout -b new-branch origin/new-branch
本地有
git checkout new-branch
    
git add .
git commit -m ''
git push origin xxx
git pull

```
</pre>    
### 一般跑这个就行
#### transofrmer的
<pre>
```
python code/eeg_ldm.py --dataset V1_Sample_Fanglab --num_epoch 300 --batch_size 21 --ddim_steps 400
```
</pre> 
#### 卷积的
<pre>
python code/eeg_ldm.py --dataset V1_Sample_Fanglab --num_epoch 240 --batch_size 18 
</pre> 


## 问题！！标签采样的时候，如果设置将多次记录数据保存至一个文件，则会出现时间长度不对应的问题

![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/5aef3b86-8812-45bc-8364-2ed1ecc4d8e1)

就是在这里加入这个事件文件的读入m1ake_picture_labels.m和r1ead_spcial_channels.m

然后加两个值，参考gpt对话吧
相关代码传到

<pre>
```
这段代码中EVTimestamps是一个1*6的double，你提取出这最后两个值，这个就是实际需要的Timestamps，然后你只取实际值在这两个值之间的Timestamps以及对应的Samples，请你帮我写代码
```
</pre> 
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/939a125c-e232-45e8-8875-2fcc83e7be7b)
加这个地方，就是只采这个时间段的数据
## 问题！！ 如果记录了长的时间数据，但是生成太慢想快速看结果需要截取一段跑make_label_dataflow_long2short.m
gpt对话：
这段代码实现了根据时间戳长度创建标签的功能，但是现在我的时间戳长度大于我希望截取的时间戳长度，例如我本来记录了90分钟的数据，但是我只想要前5分钟的数据，请你帮我修改diamond，完成这个功能，让我可以任意截取我希望截取的长度。在进行完这步后，Timestamps = newTimestamps*1e-6;
Timestamps的单位就是秒

![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/67eec474-a475-4eed-9dcd-a45c09e8e33c)
这里不知道为什么会报错，先这样改了，最后可能短一点

# 数据准备
## 换名字
先是自己做的那40个类，一个类50张图片那个文件夹
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/13c66f5d-91b5-4c76-9dce-e34afb42e0f0)
然后就是这个\n的问题，*在psychopy中识别成换行符了*，所以这里先跑Change_name.py，换成A
## 做刺激的CSV
先用build_csv.py做一个类的试了试，可以
然后就用build_csv_group.py做全部的
## 用psychopy生成trails
直接用builder，一个用$image，一个选csv文件

# 1 拿到neurolyx的CSC脑电文件后，先跑show_the_32_channles.m，现在跑show_the_32_channles_60s.m这个吧
## 数据太长内存不足怎么办
直接就展示前60s的，应该都跑这个show_the_32_channles_60s.m
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/1ad5aad6-d378-45e5-9309-eae8337f36ed)
改这个

这个文件就是展示一下哪些通道是记录的，哪些通道不是（因为我是16通道电极，而现在有32通道的卡）
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/cf8198ce-3d7b-4357-9ce0-9b4e926f8ef1)
channels = [9:16, 25:32];
# ！！！注意现在不跑这个了，跑for_decoding_dataflow.m 用数据流方式处理数据
# 2 然后跑 read_spcial_channels.m 

在这个文件夹中，做到了读入csc，减去基础时间，插值时间到真实S，然后输出和时间戳长度相同的labels矩阵，再将信号拼接，和labels以及时间戳一起保存成.h5文件，注意这里标签的生成，就类别相关的，这里就放一些和gpt的对话吧

<pre>
```
我现在已经得到了相同长度的Timestamps和Neruo_data,然后我还需要制作一个labels矩阵，用于存储每个时间点上的标签，我的Timestamps的单位是秒，一共是有48037376个点，大概是25分钟，然后这是一个视觉刺激实验，就是我的一个周期是6s，前2s给小鼠看一张图，然后4秒黑屏，然后是下一张图，依次类推。我每个类有50张图片，也就是一个类要刺激300s，然后一共刺激了5个类，现在你需要根据Timestamps的值来帮我生成这个labels矩阵，5个类的label分别用1 2 3 4 5来表示黑屏用0表示，例如前2s所有的时刻点都应该是1，然后紧接着4s 0 然后又是1，依次类推，请你生成matlab代码



这个代码段按照如下逻辑工作：

为每个时间点初始化一个标签数组。
对于Timestamps数组中的每个时间点，计算它在当前类别周期和当前周期内的位置。
如果时间点在图片显示的2秒内，分配当前类别的标签。
如果时间点在4秒的黑屏期内，标签为0。
在每个类别的最后一个周期开始时，更新类别标签。
请确保Timestamps是以秒为单位的，并且代表了实验开始以来的绝对时间。这个代码段假定Timestamps从0开始，如果实际的时间戳是从其他值开始的，您需要相应地调整代码。

```
</pre>
# 3 然后就是在jupyter notebook中跑decoding.ipynb

这里用的inception ，跑的82%分类准确率
![M P86WK) DS`Y3S7%CZAMRW](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/eec5b693-44ec-481c-9429-d2e271ed4ab6)

# 验证解码后，就是做生成的修改了

# 插个dlc，如何在linux服务器上跑jupyter 这里懒得解决内存不足的问题了
这里我直接远程的，没做端口映射
### 1直接git clone Read_mind_tutorial的ssh链接
### 2 把用matlab处理好的数据拷过去，硬盘考的
### 3 改路径，直接跑decoding.py
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/07808d6f-25d0-4762-b699-37b4d361ed68)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/463bad2b-8970-48cc-bcbb-7c7d3efd9208)
还改了这个
主要问题就是要配环境，这里就配tsai
直接按照这个里面做的
https://github.com/timeseriesAI/tsai
直接pip install ，然后为了适应代码pandas版本换1.5.3

source ~/anaconda3/bin/activate


conda create -n tsai python==3.10.0
conda activate tsai


装ipykernl
pip install ipykernel
python -m ipykernel install --user --name=tsai --display-name "Python (tsai)"
然后jupyter notebook环境就和tsai同步了，linux系统就是好torch自动装cuda版本

20240228 
前18类分类结果

解码能到72%，我觉得非常关键的一步是做了标准化
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/ac2613ca-8de7-4ec4-8bbc-10ecabdf4522)

虽然震荡，但是最后能高5个点
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/58bbba49-6d82-4a7f-b396-8c3b7e30637e)
最后能收敛
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/f28f579e-726f-4baa-ac5a-9aa205b9bc7c)

![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/6e9aff47-9dc6-44d0-a919-e8d527a289ab)
为什么临近的数据会分类相似呢？这很可能是因为黑屏的时间不够

滤波后数据
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/4eced5ec-360a-43ba-b3e4-8cd4be049dea)

# 4 在matlab中制作图像image_indices_list标签，和时间戳对齐。

简单放一下和GPT的对话，看一下在干啥
<pre>
```
这段代码实现了我的所有功能，但是现在对于这个存满了标签的simplified_labels，我不打算保存他，我准备只保存这个对应的图像索引，因为我发现存储字符串浪费大量的内存，我会在python中再通过索引与字符串的映射关系再映射回来。所以这样：现在对于csv中的每个路径，只需要保存其索引，例如第一张图片是D:\1Fanglab\1Read_mind\imagent_trail\done\A01440764\A01440764_105.JPEG
这个就变成1，第二张图是D:\1Fanglab\1Read_mind\imagent_trail\done\A01440764\A01440764_1108.JPEG，这个就变成2，所以你再新建一个变量，给我保存这个索引信息，然后将这个索引信息保存成后

```
</pre>

这里就还是直接用neurolyx导出的CSC文件，直接跑make_picture_labels.m

然后会生成.h5文件，
<pre>
``h5_filename = 'data_for_deep_learning.h5'; % 您可以根据需要更改文件名
% 确保 image_indices 是一个列向量
image_indices_list = image_indices(:)'; % 将其变形为一个列向量
% image_indices_list = image_indices_list';
% 检查文件是否存在
if exist(h5_filename, 'file') == 2
    % 如果文件存在，先删除它
    delete(h5_filename);
end

% 创建HDF5文件并写入image_indices
h5create(h5_filename, '/image_indices', [1, length(image_indices_list)]);
h5write(h5_filename, '/image_indices', image_indices_list);


% 保存 all_Samples
h5create(h5_filename, '/all_Samples', size(all_Samples));
h5write(h5_filename, '/all_Samples', all_Samples);
`

  
```
</pre>
## 内存不足
### 运行时间：18类，处理时间20分钟
上面代码只能在类少的时候弄，类多了就不行了，所以这时候需要做数据流，即不将所有数据一次性全部放入内存中，而是在遍历每个文件时循环保存至每一行，如果遇到内存不足的问题就跑make_label_dataflow.m
成功的话是这样：
总共有 18 个类别。
类别 A01440764 出现了 3200006 次。
类别 A01514668 出现了 3199928 次。
类别 A01530575 出现了 3200101 次。
类别 A01630670 出现了 3200197 次。
类别 A01641577 出现了 3199917 次。
类别 A01664065 出现了 3200052 次。
类别 A01697457 出现了 3199925 次。
类别 A01728572 出现了 3199890 次。
类别 A01796340 出现了 3200017 次。
类别 A01806143 出现了 3199900 次。
类别 A01847000 出现了 3200003 次。
类别 A01860187 出现了 3199994 次。
类别 A01871265 出现了 3200087 次。
类别 A01872401 出现了 3200018 次。
类别 A01877812 出现了 3199945 次。
类别 A01882714 出现了 3200122 次。
类别 A01910747 出现了 3200003 次。
类别 A01943899 出现了 3199937 次。
索引 -1 出现了 115229142 次。
索引 1 出现了 64003 次。
索引 2 出现了 63999 次。
索引 3 出现了 63997 次。
索引 4 出现了 63996 次。
索引 5 出现了 64005 次。
索引 6 出现了 64009 次。
索引 7 出现了 63991 次。
索引 8 出现了 63996 次。
索引 9 出现了 63993 次。
索引 10 出现了 63991 次。
索引 11 出现了 63995 次。
索引 12 出现了 64011 次。
索引 13 出现了 63996 次。
索引 14 出现了 63994 次。
索引 15 出现了 63981 次。
索引 16 出现了 64001 次。
索引 17 出现了 64000 次。
索引 18 出现了 64011 次。
索引 19 出现了 63995 次。
索引 20 出现了 63994 次。
索引 21 出现了 64013 次。
索引 22 出现了 63990 次。
索引 23 出现了 64006 次。
索引 24 出现了 63996 次。
索引 25 出现了 63989 次。
索引 26 出现了 64015 次。
索引 27 出现了 63993 次。
![B)`@9HDCQ53CB{AICTI)O0D](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/802d3c8d-3f75-45e0-965d-7d36083459dc)


# 5 在python中用滑动窗口做数据增强，并生成图像标签和数据样本对，以及分割文件，都在make_labels_generation.ipynb中写好了几步
生成了两个.pth
一个是数据一个是分割集合
## 内存不足的解决方法
这里写了新的make_labels_generation_dataflow.ipynb
主要就是用数据流的方式处理数据，不再直接生成全部的数据X_all和y_all后保存，而是分批保存数据，并且在这个文件中有每次读入数据后的验证方式。
原理是先生成多个.pth。然后再将其合并到一个.pth中
<mark>注意信号要用tensor格式！</mark>
# 6 修改生成大模型代码 在dreamdiffusion文件夹中，要改的东西很多

## 首先就是重写dataset，这个要跟数据集有关
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/ad0f530d-ee51-4c32-87be-9f6d8211e849)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/b619ddbb-7e2d-4df8-8186-b6d66a474c48)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/a409e21e-bc08-416e-a388-02cf63f65c6c)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/c92fb49e-b272-46d9-911b-cc36d19fc41d)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/393ad3e1-71cb-431d-baea-2bf5745c6b5c)
这个dataset中的splitter的属性要改
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/c5a5eb7d-6b81-463e-8c98-2ad4c6a9cdb3)
这个要改路径
改这几个函数

## 改关键字，这里我故意的，防止有错误
![`JK $@GL8EZG7X3PND$93$H](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/572a01b2-9c69-4108-a3ed-84e4f96a912f)
![4@F{ZEP KF1LC6F0E4%(Q$A](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/de31358c-0350-467f-8ba3-039aa8c59ad6)

这是第一个改关键字的地方


这时候如果直接跑会这样报错：
![UR}ATXWV93@Y{J@P5B7POJ8](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/45b0ac81-5c38-4815-9b19-fafff1035f4a)

但是不用改，改外面传进去的参数
直接这样改就行了：

![9~~P4257KOFU2})D}()@TKD](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/43c1a85e-5968-4191-8d57-e91fa745ee58)

这是第二个改关键字的地方



然后改这里：
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/5315045a-d2c0-4993-8829-6e30e8e3ef20)

![O@S{PEU~3J$UAS3VT9 {KJ4](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/8bf15d2f-7459-43e5-9f74-4015388bdc1b)
注意这里必须要改，因为默认的config文件中是eeg
![N}EHTRV 5TZY1RCGCLZW7OO](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/42e87cee-fdcc-415b-a0fc-65cc5ed9762c)
这里的关键词也要改一下

这是第三个改关键字的地方


![2V37RQ~D1ZPHNVPIV4}ISEN](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/64c5d13c-6264-4b26-9148-5f7cc2d0b34a)
最后还要改第一个卷积层的映射维度，第四个


# 接下来写一些训练的坑，刚开始遇到这个
<pre>
```
Traceback (most recent call last):
  File "/root/anaconda3/envs/dreamdiffusion/lib/python3.8/site-packages/pandas/core/indexes/range.py", line 391, in get_loc
    return self._range.index(new_key)
ValueError: 250 is not in range
```
</pre>
这个报错就是标签没对齐，因为python的索引是凑够0开始，而你做的标签是从1开始，所以代码中要-1
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/5eb9c260-8219-493b-8fb7-ed6148533716)
改训练参数设置就调这两个参数：
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/dcc61e90-226b-4b7d-becb-2893a51e2f88)
## 报错文件路径是因为linux系统不认识windows路径
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/ca0c2f42-c190-4e62-aff4-0961b6de6ba2)
这里改成linux兼容的：
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/d24e6903-a0b4-4854-bfd1-5b24c32ae485)


# 接下里准备拼凑多次实验数据，并且调试transofrmer的参数，或者换成卷积做
# 拼接数据
就是matlab中这个
## 改make_label_dataflow.m
一个是改csv文件路径，就是两次实验的csv文件拼接起来
然后改当前图像索引，加上前一次实验的次数
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/155ecdc4-8f4d-4240-bc11-ea1fe28747e9)

然后就还是跑make_labels_generation_dataflow.m就行，但是这里生成.pth chunk的序号不对
我这里先手动改了，如果后面这个实验做的多就要再写个代码处理。
传上去就改3个值
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/50d5fd10-f800-4285-8e49-9d04ed1e60a7)
改.pth路径和csv文件路径
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/42fdd44c-d829-4f06-9034-75d402ed4d31)

# 改ddim_step貌似要能被1000整除，不知道为啥，回头再研究
这个值默认是250，能正常跑
300就报错IndexError: index 1000 is out of bounds for dimension 0 with size 1000
500也能正常跑
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/49789055-78c9-4843-8131-7a6eb8a32da2)


# 效果记录
## 第一次好的结果，目测有70%+准确率
是2024年的一月，只有前5类的数据，分别是鸡，鱼，鸟，青蛙和娃娃鱼，只有1巨棒的数据。当时滑动窗口取得是8001，stride是8000，每张图片有7个时间序列数据。用的是全参数微调，epoch300，pathch_size 是8001/127。
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/84ee2459-c4e4-4776-9f0e-06c864359bbe)
这个训练集效果都是这样的
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/ca4861d2-5738-40cf-8594-eeb3f668ff86)
测试集也能有如此效果
这是一次很好的效果，因为当时做这个实验的时候干扰非常大，师兄在旁边拿电钻，这都生成出来了，说明很可能能做出来。
是1月24日这次实验的效果。
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/e481d08f-c096-469c-a7f8-255e80834ad8)


==可以看到大部分图片还有一些不清楚，因此可能是需要增加ddip_step 现在都是用的默认的250==
## 第二次提交了大量数据训练,但是效果不好
这里放了巨棒经过大量训练后，并且是在安静的环境下采集的，同样只有1巨棒的数据，滑动窗口取的是32000（1s），stride也是32000，每张图片只有2个时间序列数据，全参数微淘，epoch300，pathch_size是32000/128，数据是两段1-18类，这类图片之前给巨棒看过很多次了，还有一段是19-38类，这段图片是巨棒第一次看。

训练集就这样，还是有没生成清楚的，但是错的也多，也知道是windows长度的问题，还是种类多了就容易错
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/0a0e3526-c37f-4eea-a3e1-bc830434c348)

测试集如下：
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/f594e452-879b-4b9e-badd-650349492411)
可以看到还是有不清晰的，ddip_step都调高点试试
感觉也还行，可能人看不一定准，还是要做个AI判断
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/f6574bf2-22eb-455e-8387-f14988bf3cef)
感觉也还行了，生成出真的还是挺震撼的



# 数据预处理
在2024年2月27日，又一次仔细观看了allen_sdk的数据预处理过程，计划使用预处理
https://allensdk.readthedocs.io/en/latest/visual_coding_neuropixels.html#

![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/3696d419-38f9-4451-a6a8-8fd594f25035)
跑only_save_sample_data.m直接保存data，然后在python做处理，方便一下## 这个现在不用了，就是测试的时候用了一下


## 这里我是直接跑的同时生成解码标签的代码，然后做滤波跑filter_process.py
分别经过 中值减法，高通150hz，白化，具体可见代码

由于数据量太大，还是在105服务器上跑的，只有中值滤波做了batch处理，其他的懒得做了，直接跑，目前能运行2024年2月28日
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/0f2cfbb4-0e7d-487e-b45f-929c61e179ed)
这个维度都是对的
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/8d0773ca-025a-4c8f-98b6-b1ed4705c076)
可以通过注释不同的代码块分别生成只经过特定步骤处理的信号
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/b4bb25f4-393d-4251-a86e-8a4eace05b68)
类似这样的

## 2024年3月4日思路
## 这是用transformer算的！！！
发现虽然将eeg_encoder完全替换成conv后对于训练集有着很好的表现，并且验证集也有一致性。
但是今天又仔细看了结果，发现1月24日那次transformer验证集也有一致性，这里我就有点怀疑之前是不是记错了，所以把滤波后的数据用transformer再跑一遍，看看transofrmer如果直接训练condition和全参数效果如何

用的5类filter的数据，分别跑了condition和全参数，由下到上依次对应
ddip 250 epoch 300 
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/fb8e24bd-0cd3-4ca8-9257-e808aae77f57)

现在的想法是等卷积的结果出来，看情况还是否需要上有初始权重的卷积。

## 2024年3月5日
## 这是用transformer算的！！！
提交了only_norm 分别condition训练和全参数训练的版本
从下往上依次对应
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/f56ea95d-3b9d-4cb8-ab8a-1b8f40fbf28a)

## 2024年3月7日观察结果

感觉做了标准化后transformer效果非常好？？？
transofrmer效果好于卷积！！！
并且condition训练的效果好于全参数！！！


看transformer only_condition的结果：
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/e84b0c63-8ef6-4fa4-b9f5-2fe06f2c12fe)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/b7809f60-7493-4288-a9b5-03af0bb45bf6)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/ff68c7b7-cf4f-44c2-977b-5c2ae550e039)
我这验证集从来没这么好过
感觉就是数据质量的问题，可能加个瞳孔追踪就行了

## 2024年3月10日 重大突破！！ 标准化，神来之笔
知道了之前的问题，就是因为全参数微调导致的，只训练condition,并且使用transformer，只做标准化，准确率达到45.6% sota！
![SJREP`9(LP6E$1)2RPSZU4B](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/67b63c69-f617-47ef-a65c-20aae9e0348f)
三个条件：
1 transformer
2 神经信号标准化，8000windows 一张图片8个采样
3 condition训练，不要动一点stable diffusion
采样的文件夹是
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/4b122171-a6f4-4914-94e7-dcd24c70028c)
人眼看127/200=63.5%准确率
测试集效果：
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/95b0ba43-965b-4799-8e5f-41447c66807c)




相关transformer参数
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/cefe4722-5abb-4cbb-9a81-c5a3a78ba385)
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/4358fa63-5415-40a6-93e2-0ac2fcce77d8)

目前就是
ddim_step = 250
epoch = 300
已经效果很好了，我猜更长的步长可能还有用
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/69a7d886-8422-4dc0-8dfc-1f21c7f84104)
这是fiter 300步的情况，only_norm的300步训练曲线丢了。。。不知道为啥没上传到wandb
![image](https://github.com/RyanWu31/Read_mind_tutorial/assets/110294962/87e133fc-40b6-488a-843f-23b51b8f8c72)


至此，记录一下所有的操作过程：
0 做老鼠手术，植入电极
1 采数据，做csv，编写physo那个软件的刺激程序（用郭碧函挑选的图片）50类，每类40张图
2 将所有图片跑Changename，变成done文件夹
3 采数据，做成生成格式，然后做标准化
4 标准化数据生成，在Read_mind工程中，条件就见这个小标题中的内容
