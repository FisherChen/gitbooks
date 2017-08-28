## Host_only ＋　ＮＡＴ
配置相对简单，单是有的时候，虚拟机的默认的网关是Ｈｏｓｔ Only的，导致无法正常通过ＮＡＴ的方式访问外网。需要修改下默认的路由表。


### 临时验证

```
	sudo route del default 
	sudo route add default gw 10.0.2.2
```
### 修改配置文件
	
	｀vim /etc/network/interfaces｀

### 添加

	｀up route add default gw 10.0.2.2｀


