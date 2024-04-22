# Programmer : Haofan Wu
# Institutions :  The Institute for Biomedical Engineering & Nano Science, School of Medicine, Tongji University, Shanghai, 200092 China
# Data : 2024/1/12

import os
import csv

# Set the directory where the images are located
image_dir = r'E:\imagent\img\A01530575'
images = os.listdir(image_dir)

# The path where you want to save the CSV file
csv_file_path = r'E:\imagent\Wuhaofan_labels\\image_list1.csv'

# Create a CSV file with the image paths
with open(csv_file_path, mode='w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['image'])  # Write the header
    for img in images:
        if img.lower().endswith('.jpeg'):  # Check if the file is a .jpeg image
            writer.writerow([os.path.join(image_dir, img)])  # Write the full path

print(f"CSV file created at {csv_file_path}")
