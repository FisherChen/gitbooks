# Linux Shell Command

<!-- toc -->

### 1. disk command
  - `sudo blkid` : get disk UUID;
  - `/etc/fstab` : mount disk on installation
  - `df` : get disk info
  - 'sudo fdisk -l ': list all partitions include unmount parts.

### 2. Unity reset:
	- 第一种
		是添加PPA源，安装unity-reset
			```
			$ sudo add-apt-repository ppa:amith/ubuntutools
			$ sudo apt-get update
			$ sudo apt-get install unity-reset
			```
		安装好了在终端执行
			`$ unity-reset`

	- 第二种
		如果不想添加PPA源，可以使用dconf-tools: 
		`$ sudo apt-get install dconf-tools`

		然后执行命令重置
			`$ dconf reset -f /org/compiz/`

		最后，重启或运行此命令使其生效
			`$ setsid unity`



### 3. Wifi的重启
	有的时候通过键盘或者是图标可以禁用wifi，但是重启的时候就有可能失灵，可以通过如下的方式重启Wifi：
	`sudo rfkill unblock all`

