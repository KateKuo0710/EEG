import os

def rename_files_and_folders(root_path):
    # 先遍历最底层的文件和文件夹，然后逐级向上
    for path, folders, files in os.walk(root_path, topdown=False):
        # 重命名文件
        for file in files:
            new_file = file.replace('n', 'A')
            os.rename(os.path.join(path, file), os.path.join(path, new_file))

        # 重命名文件夹
        for folder in folders:
            new_folder = folder.replace('n', 'A')
            os.rename(os.path.join(path, folder), os.path.join(path, new_folder))

# 定义文件路径
path = r"E:\imagent\img"

# 调用函数
rename_files_and_folders(path)
