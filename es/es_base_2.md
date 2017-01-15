### 检查集群的健康情况
- _cat

`curl -XGET 'localhost:9200/_cat/health?v&pretty'

> epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
> 1483884927 22:15:27  elasticsearch yellow          1         1      6   6    0    0        6             0                  -                 50.0%

所有的接口都是基于 [RestFul API](http://www.ruanyifeng.com/blog/2014/05/restful_api.html) 做的设计，其中的_cat中列了一些集群的健康情况的接口。
_cat/XXXXX

可以通过API查询也可以通过的kibana的提示符找到需要的信息。

- 创建

	创建index 是直接通过PUT 来实现，首先index的名称必须是小写的，其次如果名称相同的话会报一个名称已经存在的错误。
	+ 仅仅创建一个空的index customer
	
		`curl -XPUT 'localhost:9200/customer?pretty'`
	
	+ 创建索引的同时把数据和type加上，ES的规则同mongodb对字段的管理的原则是一样的，没有必要一定是先建立index然后才能往其中写数据，而是可以在写数据的同时把索引也同时创建好了。

		```
			PUT  customer/test1_type/1?pretty
I					{"name":"zhangsan"}
		```

+ 删除一个index 

	` 'DELETE customer/?pretty' `


+ 获取一个idnex的结构

	直接使用`GET index` 的方式可以获取一个index的结构信息，整个算是类似于表结构的类似的味道吧。
		```
  "customer": {
    "aliases": {},
    "mappings": {
      "test2_type": {
        "properties": {
          "name": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          }
        }
      },
      "test1_type": {
        "properties": {
          "name": {
            "type": "text",
            "fields": {
              "keyword": {
                "type": "keyword",
                "ignore_above": 256
              }
            }
          }
        }
      }
    },
    "settings": {
      "index": {
        "creation_date": "1484061020197",
        "number_of_shards": "5",
        "number_of_replicas": "1",
        "uuid": "SP7AUnAMSQeleYAwRqP5zQ",
        "version": {
          "created": "5010199"
        },
        "provided_name": "customer"
      }
    }
  }
}
		```


+ 脚本的范式

	ES使用的是REstFul的接口，其是安装如下范式执行的,其中的ID并不是必须要有的，ES会自动的给每一个新增的document加上random的ID，使用者在get数据的时候，整个ID会被自动的返回：

	` <REST Verb> /<Index>/<Type>/<ID> ` 
		

+ Document的update
	
	同传统的关系型数据库最大的不同点是，ES的数据 update、insert、delete 必须是在操作后几秒钟之内才能实现效果，这个和传统的关系型数据库最大的不同点，传统的关系型数据库事物结束之后，数据就可以立即的使用了，但是ES不是。
	+ 对更新操作来说有2种模式一种是替换replace，一种是更新replace，如果没有指定_update的关键词那就是替换的操作，如果指定了那就是更新的操作。
	+ document中有几个固定的字段"_index" "_type" "_id" 是系统级别定义的结构
	+ document 的新增是有put 和 post的分别的，put是针对指定ID进行的操作，POST是ES会根据实际的_id情况然后自己再计算出uuid来。
	+ 注意当前的版本ES对update的仅仅只能支持指定ID的更新，未来的版本中会支持批量的条件更新
	> 更新的操作的是有特定的语法的，单个更新即可以更新字段，也可以新增，同时也是支持语法格式的。


+ Document的delete操作
	
	delete操作可以直接指定delete哪一个id的数据，也可以根据查询条件做批量的delete操作。同样的道理全量的删除永远没有直接index delete来的快。
	
+ 批量操作
	
	ES提供了批量操作的接口，_bulk 其规则是先有一个操作选定步骤，然后接入原始的数据，当然delete除外，delete仅仅只有一个操作。
	有一个需要注意的地方是，批量的操作是顺序的执行，即使中间有一个异常，操作的也会顺序的执行下去，一直到最后有结果为止。
	详细的API的操作文档参照官方的手册：
	https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html
	如下是官方批量导入数据的案例。
	
	` curl -POST 'localhost:9200/bank/account/_bulk?pretty&refresh' --data-binary "@/home/fisher/Downloads/accounts.json" `

