### change host name
`sudo vim hostname`

### change static net
`sudo vim /etc/network/interfaces`
>
> auto enp0s8
> iface enp0s8 inet static
> address 192.168.56.103
> netmask 255.255.255.0
> gateway 192.168.56.1

### use commond login ubuntu free Ｍ

编辑grub
`sudo vim /etc/default/grub`
将下面的启动参数
`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"`
更换为
`GRUB_CMDLINE_LINUX_DEFAULT="text"`
取消下面一行的注释
`#GRUB_TERMINAL=console`
更新grub
`sudo update-grub`
更默认启动模式
`sudo systemctl set-default multi-user.target`
重启动
sudo reboot
重启之后，你应该直接进入到了纯命令行；要启动到桌面，执行：
`sudo service lightdm restart`

