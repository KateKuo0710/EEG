# 部署Llama3 8b
<pre>
conda create --name llama3_8b python=3.11 # 创建虚拟环境
conda activate llama3_8b #激活虚拟环境
git clone https://github.com/hiyouga/LLaMA-Factory.git # 下载LLaMA-Factory项目文件
cd LLaMA-Factory
pip install -r requirements.txt --index-url https://mirrors.huaweicloud.com/repository/pypi/simple 
mkdir model #新建文件夹用于存放模型
cd model
git clone https://www.modelscope.cn/LLM-Research/Meta-Llama-3-8B.git # 下载llama3 8b模型
</pre>
参考：https://blog.csdn.net/fzzsh/article/details/138479005  
