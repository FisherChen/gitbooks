+ ES的安装：
	
	1. 是需要Oracle的JDK 1.8 以上的版本；

	2. ES的配置相对简单而且很多的配置文件都是可以实时的在线修正的。[Cluster Update Settings](https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-update-settings.html)

	3. 详细的配置可以参照官方的文档.（https://www.elastic.co/guide/en/elasticsearch/reference/current/settings.html#_environment_variable_subsitution）

+ 安装过程中的一些注意事项：

	1. data目录和log目录 不要使用默认的配置，因为有可能在升级的时候出现被覆盖等问题。所有的文档应该都是有这些问题的。

	2. 因为ES的是在JAVA上运行的，所以起占用的空间都是JVM的虚拟机的占用的空间。当操作系统的内存不足的时候，有时候是需要把一些内存中的数据同swap交换的方式交换到swap分区上的，而这个时候整个操作系统的性能是有很大的性能问题的。所以需要配置一些特殊的操作系统级别的参数，让JVM可以锁定占用的内存，从而不会被交换出去。
	当前的解决方案官方提供了三种，一种是限制死空间的大小，但是这样当发生空间不足的时候会导致进程直接死掉了，另外一种是直接禁用掉swap，同第一种情况一样，也有这么个问题，而且这种方式也是不可取的，最红一种是通过sysctl的功能设置vm.swappiness=1的方式让操作系统尽量不置换swap，除非非常紧急的情况下再置换出去。详细的方案见[官方的文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/setup-configuration-memory.html#mlockall)

	3. 几个关键的参数的解释：
		cluster.name 集群的名称
		
		node.name 节点名称
		
		network.host 本机器绑定的网络的地址，正常情况下绑定一个局域网的地址就可以了，但是有的时候需要绑定多个地址

		discovery.zen.ping.unicast.hosts 需要广播的IP地址，主要是讲自己广播到集群中，需要配置集群的IP地址的列表，当然如果集群非常大的情况下可以直接使用域名的方式进行配置，这样就会方便很多。
		transport.profiles.default.port 正常情况下每个node之间的通信都是通过tcp协议进行，然后默认的端口是9300 ，整个正常情况下无需调整

		discovery.zen.minimum_master_nodes 最小的主节点的数量，也就是说你的集群被分为了多少了主节点，默认的情况下参数值是：(master_eligible_nodes / 2) + 1 避免脑裂的发生。
		
		> ES的节点根据功能的第定义上分为 master node、data node、ingest node 前两者在日常是使用中尤其的重要，master 节点主要是对集群的信息的维护和监控，data 节点主要的是做数据的相关的计算。默认的情况下所有的节点是可以可以选举为master节点的，但是为了master的节点的稳定性，最好是讲data节点和master节点分开来定义。而且正常的情况下 3 副本master节点应该就是足够使用的了。
		> 如果资源充值那就是三副本都是仅仅当mater 节点使用，但是如果在资源不足的情况下，可以先让一台好的机器先启动充当mater节点，然后再不从补充其他的data节点充当mater 节点。这样如果主节点出现了问题，造成的应当也仅仅是临时的性能的下降。
		
		


+ ES工程的目录结构

	通过下面的目录结构可以知道，ES的文件是存在data目录下的，且data目录的文件是按照node的存放的，而node中数据的存放是按照indices中的index存放的，每个index有自己的uuid（这uuid可以根据 _cat/indices 获取的到），如上的结构我们是可以清楚的知道，在安装的ES的时候，整个目录的IO是比较高的，所以需要把这个目录的磁盘做成SAN的存储或者是上SSD。

	> 补充一个问题，通过虚拟机安装的ES的时候，发现当虚拟机中JAVA 虚拟机的可用内存小于2GB的时候，ES是启动不起来的，这个也从另外的一方面间接的证明了ES是需要大的内存空间的。

```

fisher@czc:elasticsearch-5.1.1$ tree
.
├── bin
│   ├── elasticsearch
│   ├── elasticsearch.bat
│   ├── elasticsearch.in.bat
│   ├── elasticsearch.in.sh
│   ├── elasticsearch-plugin
│   ├── elasticsearch-plugin.bat
│   ├── elasticsearch-service.bat
│   ├── elasticsearch-service-mgr.exe
│   ├── elasticsearch-service-x64.exe
│   ├── elasticsearch-service-x86.exe
│   ├── elasticsearch-systemd-pre-exec
│   ├── elasticsearch-translog
│   └── elasticsearch-translog.bat
├── config
│   ├── elasticsearch.yml
│   ├── jvm.options
│   ├── log4j2.properties
│   └── scripts
├── data
│   └── nodes
│       └── 0
│           ├── indices
│           │   ├── a9_QqrQeQamuifm9qVjClw
│           │   │   ├── 0
│           │   │   │   ├── index
│           │   │   │   │   ├── _0.cfe
│           │   │   │   │   ├── _0.cfs
│           │   │   │   │   ├── _0.si
│           │   │   │   │   ├── segments_3
│           │   │   │   │   └── write.lock
│           │   │   │   ├── _state
│           │   │   │   │   └── state-0.st
│           │   │   │   └── translog
│           │   │   │       ├── translog-2.tlog
│           │   │   │       └── translog.ckp
│           │   │   └── _state
│           │   │       └── state-3.st
│           │   └── EQB5qaNdQRSoLvVaBeLhxA
│           │       ├── 0
│           │       │   ├── index
│           │       │   │   ├── segments_1
│           │       │   │   └── write.lock
│           │       │   ├── _state
│           │       │   │   └── state-0.st
│           │       │   └── translog
│           │       │       ├── translog-1.tlog
│           │       │       └── translog.ckp
│           │       ├── 1
│           │       │   ├── index
│           │       │   │   ├── segments_1
│           │       │   │   └── write.lock
│           │       │   ├── _state
│           │       │   │   └── state-0.st
│           │       │   └── translog
│           │       │       ├── translog-1.tlog
│           │       │       └── translog.ckp
│           │       ├── 2
│           │       │   ├── index
│           │       │   │   ├── segments_1
│           │       │   │   └── write.lock
│           │       │   ├── _state
│           │       │   │   └── state-0.st
│           │       │   └── translog
│           │       │       ├── translog-1.tlog
│           │       │       └── translog.ckp
│           │       ├── 3
│           │       │   ├── index
│           │       │   │   ├── segments_1
│           │       │   │   └── write.lock
│           │       │   ├── _state
│           │       │   │   └── state-0.st
│           │       │   └── translog
│           │       │       ├── translog-1.tlog
│           │       │       └── translog.ckp
│           │       ├── 4
│           │       │   ├── index
│           │       │   │   ├── segments_1
│           │       │   │   └── write.lock
│           │       │   ├── _state
│           │       │   │   └── state-0.st
│           │       │   └── translog
│           │       │       ├── translog-1.tlog
│           │       │       └── translog.ckp
│           │       └── _state
│           │           └── state-3.st
│           ├── node.lock
│           └── _state
│               ├── global-4.st
│               └── node-4.st
├── lib
│   ├── elasticsearch-5.1.1.jar
│   ├── HdrHistogram-2.1.6.jar
│   ├── hppc-0.7.1.jar
│   ├── jackson-core-2.8.1.jar
│   ├── jackson-dataformat-cbor-2.8.1.jar
│   ├── jackson-dataformat-smile-2.8.1.jar
│   ├── jackson-dataformat-yaml-2.8.1.jar
│   ├── jna-4.2.2.jar
│   ├── joda-time-2.9.5.jar
│   ├── jopt-simple-5.0.2.jar
│   ├── jts-1.13.jar
│   ├── log4j-1.2-api-2.7.jar
│   ├── log4j-api-2.7.jar
│   ├── log4j-core-2.7.jar
│   ├── lucene-analyzers-common-6.3.0.jar
│   ├── lucene-backward-codecs-6.3.0.jar
│   ├── lucene-core-6.3.0.jar
│   ├── lucene-grouping-6.3.0.jar
│   ├── lucene-highlighter-6.3.0.jar
│   ├── lucene-join-6.3.0.jar
│   ├── lucene-memory-6.3.0.jar
│   ├── lucene-misc-6.3.0.jar
│   ├── lucene-queries-6.3.0.jar
│   ├── lucene-queryparser-6.3.0.jar
│   ├── lucene-sandbox-6.3.0.jar
│   ├── lucene-spatial3d-6.3.0.jar
│   ├── lucene-spatial-6.3.0.jar
│   ├── lucene-spatial-extras-6.3.0.jar
│   ├── lucene-suggest-6.3.0.jar
│   ├── securesm-1.1.jar
│   ├── snakeyaml-1.15.jar
│   ├── spatial4j-0.6.jar
│   └── t-digest-3.0.jar
├── LICENSE.txt
├── logs
│   ├── elasticsearch-2017-01-02.log
│   ├── elasticsearch_deprecation.log
│   ├── elasticsearch_index_indexing_slowlog.log
│   ├── elasticsearch_index_search_slowlog.log
│   ├── elasticsearch.log
│   ├── fisherES_deprecation.log
│   ├── fisherES_index_indexing_slowlog.log
│   ├── fisherES_index_search_slowlog.log
│   └── fisherES.log
├── modules
│   ├── aggs-matrix-stats
│   │   ├── aggs-matrix-stats-5.1.1.jar
│   │   └── plugin-descriptor.properties
│   ├── ingest-common
│   │   ├── ingest-common-5.1.1.jar
│   │   ├── jcodings-1.0.12.jar
│   │   ├── joni-2.1.6.jar
│   │   └── plugin-descriptor.properties
│   ├── lang-expression
│   │   ├── antlr4-runtime-4.5.1-1.jar
│   │   ├── asm-5.0.4.jar
│   │   ├── asm-commons-5.0.4.jar
│   │   ├── asm-tree-5.0.4.jar
│   │   ├── lang-expression-5.1.1.jar
│   │   ├── lucene-expressions-6.3.0.jar
│   │   ├── plugin-descriptor.properties
│   │   └── plugin-security.policy
│   ├── lang-groovy
│   │   ├── groovy-2.4.6-indy.jar
│   │   ├── lang-groovy-5.1.1.jar
│   │   ├── plugin-descriptor.properties
│   │   └── plugin-security.policy
│   ├── lang-mustache
│   │   ├── compiler-0.9.3.jar
│   │   ├── lang-mustache-5.1.1.jar
│   │   ├── plugin-descriptor.properties
│   │   └── plugin-security.policy
│   ├── lang-painless
│   │   ├── antlr4-runtime-4.5.1-1.jar
│   │   ├── asm-debug-all-5.1.jar
│   │   ├── lang-painless-5.1.1.jar
│   │   ├── plugin-descriptor.properties
│   │   └── plugin-security.policy
│   ├── percolator
│   │   ├── percolator-5.1.1.jar
│   │   └── plugin-descriptor.properties
│   ├── reindex
│   │   ├── commons-codec-1.10.jar
│   │   ├── commons-logging-1.1.3.jar
│   │   ├── httpasyncclient-4.1.2.jar
│   │   ├── httpclient-4.5.2.jar
│   │   ├── httpcore-4.4.5.jar
│   │   ├── httpcore-nio-4.4.5.jar
│   │   ├── plugin-descriptor.properties
│   │   ├── reindex-5.1.1.jar
│   │   └── rest-5.1.1.jar
│   ├── transport-netty3
│   │   ├── netty-3.10.6.Final.jar
│   │   ├── plugin-descriptor.properties
│   │   ├── plugin-security.policy
│   │   └── transport-netty3-5.1.1.jar
│   └── transport-netty4
│       ├── netty-buffer-4.1.6.Final.jar
│       ├── netty-codec-4.1.6.Final.jar
│       ├── netty-codec-http-4.1.6.Final.jar
│       ├── netty-common-4.1.6.Final.jar
│       ├── netty-handler-4.1.6.Final.jar
│       ├── netty-resolver-4.1.6.Final.jar
│       ├── netty-transport-4.1.6.Final.jar
│       ├── plugin-descriptor.properties
│       ├── plugin-security.policy
│       └── transport-netty4-5.1.1.jar
├── NOTICE.txt
├── plugins
└── README.textile



``` 








