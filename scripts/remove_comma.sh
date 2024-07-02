#!/bin/bash

# 设置要遍历的文件夹路径
folder_path="$1"

# 遍历文件夹中的所有文件
for file in "$folder_path"/*
do
    filename=$(basename "$file")
    
    # 匹配 LxCLB 或 LxLB 的文件名，并处理不同的后缀格式
    if [[ "$filename" =~ ^(L[0-9]C?LB)_([0-9]+),([0-9]+),([0-9]+),([0-9]+)(_R[0-9])?\.fq\.gz$ ]]; then
        prefix="${BASH_REMATCH[1]}"
        first_num="${BASH_REMATCH[2]}"
        last_num="${BASH_REMATCH[5]}"
        read_number="${BASH_REMATCH[6]}"
        
        # 根据是否有 _R 后缀生成新文件名
        if [ -z "$read_number" ]; then
            new_filename="${prefix}_${first_num}-${last_num}.fq.gz"
        else
            new_filename="${prefix}_${first_num}-${last_num}${read_number}.fq.gz"
        fi
        
        # 重命名文件
        mv "$file" "$folder_path/$new_filename"
        echo "Renamed: $filename to $new_filename"
    fi
done

echo "Renaming complete."
