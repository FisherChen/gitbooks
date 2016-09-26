# 获取简单书的图片rul

file_name=""

if [ "$1" = "" ]
then
	echo Please enter your file_name:
	read file_name 
else
	file_name=$1
fi

if [ -w $file_name ]
then

	flag="1"
	flag2="1"
	head_url=""
	name_url=""
	name2_url=""
	jianshu_url=""
	
	echo 

	for str in `awk -F '[/.]' '/img/ {print $1,$4}' $file_name `
	do
		if [ "$flag" = "1" ]; then
			head_url=$str
			flag="2"
		else
			name_url=$str	
			flag="1"
		
			# 第一笔记录已经整理好了，下面开始循环匹配，这样的设计性能有点不行	
			for str2 in `grep -v img $file_name | grep \( |awk -F '[\\\[\\\]()]' '{ print $2,$4}'`
			do
				if [ "$flag2" = "1" ]
				then
					name2_url=$str2
				# 剔除文件的后缀名
					name2_url=` echo $name2_url|awk -F '.' '{print $1}'`
					flag2="2"
				else
					jianshu_url=$str2
					flag2="1"
				# 开始比较并输出
					if [ "$name2_url" = "$name_url" ]
					then
						echo $head_url$jianshu_url 
					fi
				fi
			done
		fi
	done
echo 
echo Done.
else
	echo "your file not exists or can't be writed,Please check your file."
fi
