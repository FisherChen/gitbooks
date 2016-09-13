
# get img only in ![<imgname>][<num>] fomat

img_type=".png"
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
	echo "" >> $file_name
	echo "" >> $file_name
	n="1"
	str_temp=""
	for str in ` cat $file_name |grep "\!\[.*\]\[.*\]$"   | awk -F'[][]' '{for(i=2;i<NF;i+=2) print $i}' `
		do
			if [ "$n" = "1" ]
			then
				str_temp="./img/"$str$img_type
				n="2"
			else
				str_temp="["${str}"]:"$str_temp
				echo $str_temp >> $file_name
				str_temp=""
				n="1"
			fi
	done
	echo Done.
else
	echo "your file not exists or can't be writed,Please check your file."
fi


