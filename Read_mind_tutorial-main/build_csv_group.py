import os
import csv

# 设置包含图片文件夹的根目录
root_image_dir = r'D:\1Fanglab\1Read_mind\imagent_trail'

# CSV文件保存的路径
csv_file_path = r'D:\1Fanglab\1Read_mind\imagent_trail\Wuhaofan_labels\image_list_group.csv'

# 创建或覆盖CSV文件，并写入图片路径
with open(csv_file_path, mode='w', newline='', encoding='utf-8') as file:
    writer = csv.writer(file)
    writer.writerow(['image'])  # 写入表头

    # 遍历根目录下所有目录和子目录
    for subdir, dirs, files in os.walk(root_image_dir):
        for filename in files:
            if filename.lower().endswith(('.jpeg', '.jpg', '.png')):  # 检查文件是否为图片
                file_path = os.path.join(subdir, filename)
                writer.writerow([file_path])  # 将完整路径写入CSV

print(f"所有图片路径的CSV文件已创建在 {csv_file_path}")
