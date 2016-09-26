### 我的学习笔记

<!-- toc -->

### 1. 批量的导入Json数据
  ```javascript
  
  mongoimport --host 127.0.0.1:27017 --db test --collection restaurants --drop --file ./primer-dataset.json 
  
  ```

---
### 2. 查询Collection
  类似于Sql的 select * ，`db.restaurant.find()`,默认是返回20个记录。

---
### 3. drop Conllection
  ```javascript
  
  db.restaurant.drop()
  
  ```

---
### 4. drop db

  ```javascript
  use db;
  db.dropDatabase()

  ```

---
### 5. 压力测试问题压力的TPS有波动。  
  mongodb 在压力测试的时候发现，其会大量的先使用内存，在使用内存的时候刚开始其TPS是很高的，不过在使用的过程中Mongodb会每隔一段时间刷数据到磁盘中，这个曲线图是波动的。刷数据时候其压力的IO上。
  > 问题是，MongoDB从内存中刷数据的频率、数据量、算法是怎样的。如何查阅及是不是参数可以配置的？

  通过咨询得到，Mongodb是每隔一段时间自动的内存中的数据同步到的磁盘上的，同步的时候IO会降下来，所以是波动的。mongodb的同步是基于数据块的LRU算法实现的。

  下面是咨询的过程：

---
### 6. 索引素据占用空间非常大，比数据还大

  mongodb 的其索引占用的空间是数据占用空间的10倍，是不是索引的参数设置或者是选型上出了问题？

---
### 7. 压力测试的问题 内存不释放
  mongodb 的性能测试的时候内存压力满了以后，停掉压力，等数据全部同步到磁盘以后，理论上内存应该是可以复用的内存，但是实际上Mongodb即没有释放这部分内存，也没有在重新加压的时候重用这部分的内存。这个问题需要查实下，确认下Mongodb的内部逻辑，Mongodb为什么会这么做。官方已经给了相关的解释了，见 5 的邮件答复。主要是因为Mongodb在写的时候需要读去大量的数据做计算，在IO的压力上，开始的时候是使用内存，内存满了以后开始刷磁盘，此时磁盘的压力是在写.（主要是因为没有历史数据的压力），当磁盘的数据量上来以后，写的IO压力就非常小了，此时IO的压力更多的是在读上，Mongodb需要读去大量的索引信息及其他数据信息到内存中进行计算。

---
### 8. 在mongodb的shell中执行脚本
  mongodb自己的shell是有本地用户环境js环境信息配置的，那问题是是不是可用利用本地的js函数配置，写一些自己的类似于存储过程的脚本呢，至少可以做一个自己的工具包吧。？学习中。
  这个是可以在mongo 命令行中，运行js文件的。 这个同时牵连出如何在现有的公司的移交框架的基础上做脚本的执行等问题。
  对于导出除了使用Mongdb自带的导出命令外，还可以先查询再导出的方式处理（还是使用到处命令来的快点，尽量不要在Mongodb调用本地的shell，太麻烦）。

  ```javascript
  
    db = db.getSiblingDB("test");
    /**
    cursor = db.collection.find();

    while ( cursor.hasNext() ) {
       printjson( cursor.next() );
    }

    dbs = db.adminCommand('listDatabases');
    var databases =dbs.databases;
    for (i=0;i<databases.length;i++){
    print(databases[i].name);
    }
    result=db.getCollection("mytest").find();
    **/
    cursor = db.mytest.find();
    while ( cursor.hasNext() ) {
       printjson( cursor.next() );
    }
    
  ```

  ```javascript
    sed -i '1,2 d' test.log
  
  ```
  
  ```javascript
    mongo test.js  2>&1 >> test.log
  
  ```

  **ps:**
  > 也可以直接在shell中直接使用load函数加载js脚本，但是加载进来的js脚本的环境变量和shell自己的是否公用呢？

  答案是公用的，但是有个问题，这个load的方式执行js脚本的话，最后会加载一个true；

  > 第二个问题，如果加载多个脚本的话，那脚本的内容可以相互调用么？

  案是肯定的，之间是可以相互调用的，这个应该是可以理解为不断的将一个个小的js在本次登陆的session中拼接成一个session

  > 如果之间有名称冲突的话，那又会如何呢？
  
  在一个js中写2个同名的函数一样后一个会把前一个给覆盖掉了。注意每次调整js的时候必须再load一次，修改的部分才能生效。
  
  > 另外因为load函数也是一个js函数，所以可以在js脚本中调用load函数加载其他的js脚本。类似于存储过程的Main函数，命名一个main.js的js，这个js中按照一定的顺序加载引入其他的js程序。这样就可以批量的执行大量的js脚本了，可以实现批量部署的功能。

  不过目前的批量的存储过程的处理，目前还是准备使用其他的语言来处理，不使用mongodb shell。

---
### 9. 性能监控的命令
  > mongodb的性能监控工具及命令有哪些哪些？
  这些在官方的文档中有个主题是介绍这块的，目前还没有学习的到

---
### 10. data 时间的格式化
  > mongodb 如何对ISO的date进行格式化？
  暂时没找到直接数据库层面格式化的方案，这个格式化应该同不同的驱动器有直接的关联关系。

---
### 11. mongodb的随机函数ObjectId
  ObjectIds are small, likely unique, fast to generate, and ordered. ObjectId values consists of 12-bytes, where the first four bytes are a timestamp that reflect the ObjectId’s creation, 

  specifically:
      - a 4-byte value representing the seconds since the Unix epoch,
      - a 3-byte machine identifier,
      - a 2-byte process id, and
      - a 3-byte counter, starting with a random value.
  
  来源： https://docs.mongodb.com/manual/reference/bson-types/#objectid

---
### 12. db.getSiblingDB()
  非常有意思的一个函数，可以跨 db访问。单词 “sibling”：兄弟姐妹家族的意思。

---
### 13. 查询数据结构 
  mongod因为是基于文档型的数据库，其collection是没有固定的结构的，及没有shema，如果非要查询的话，可以通过一些工具来快速的分析数据结构。比如variety.js（http://blog.mongodb.org/post/21923016898/meet-variety-a-schema-analyzer-for-mongodb）
  但是mongodb可以通过命令查看有多少个索引。

---
### 14. Insert 数据 1
  对mongodb自带的shell而言，insert 有insert 、insertone、insertmany三种操作方式，其中insert 和后两种的主要的区别是返回值的不同，后两种会返回insert的结果，通常带有ObjectId。
  但是这类的操作对其他的终端而言是否适用就不清楚了。自己在日常运维操作中可以使用后两者来处理，比较方便。

---
### 15. Insert 数据2
  mongodb 的insert（）和bathinsert（）函数，仅支持48MB的数据传输，对于大于48MB的数据处理，驱动器会将其拆分为多次insert。
  
  这个是需要注意的:
  批量插入的时候需要注意，**如果其中一个脚本执行出错，剩下的脚本是否可以继续执行的问题，其他的驱动器是有一个continueOnError的选项来配置是否发生错误的时候继续执行。**
  
  但是这个参数选项Mongodb的shell并不支持（？）

---
### 16. 单个Document的大小
  MongoDb的单个document的大小是不能超过16MB的(整个应该是可以修改的)，且编码格式是必须是UTF-8 支持，且 如果插入的时候没有ID选项是自动的加一个ObjectId。

---
### 17. insertMany()
  insertMany()函数，如果其中有个记录出现问题的话，那这个记录之前后的所有记录都不会执行。

---
### 18. 非正常的Collection命名规则
  有很多的时候，会出现并没有正常命名的Collection的名称，如Undefined 、[Object BSON] 等，这些名称不正确的coll可以同使用`db[].drop`的方式清理掉或只是Rename掉；

---
### 19.  查询的返回字段
  find()查询的时候，附加的查询返回“projection ”其配置是比较特别，要不是指定都是1或者都是0 ，不可以使用Mix的方式配置。但是针对`_id`字段比较特殊，这个是可以mix的，0和1 均可以，默认是1；

---
### 20. $slice
  $slice n 返回是一个数据前多少位数据，如果的是N是负数据的话那就是后多少位。同时  $slice[N,M]前面的N是skip数据，后面是取多少数据，同样有正负号之分；

---
### 21. null
  `db.users.find( { name: null } )` 和`db.users.find( { name : { $type: 10 } } )`是两个不同逻辑，前者会把即使不包含这个字段的Colletion也查询出来，而后者会仅查询值是null的数据。这个就提醒我们如何设计MongoDb的数据结构。

  对于各个不同的外围系统，其上送的记录中每个系统的字段可能不一样，单个系统单个字段又可能是没有值的。

  那对于这些没有值的数据，在insert的时候是否有必要初始化程null值呢，还是直接这个字段都不需要了，同字段值为null 和没字段 这两者在数据量上有多大的分别内？

  从数据结构上看，有字段但是值为null感觉还是好点,从数据结构上看不使用的字段的情况下存储的空间更小。设计上还是不在数据库层有意的加这个null了。

  - **注意1 $type**
    
    这个`$type`需要注意，Mongodb每个字段都是有对应的属性值的，要特别区分你查询的数据的类型。
    比如`_Id`字段，刚接触的时候会认为这个就是一个String，但是在Mongdb的数据库中这个是一个对象，一个ObjectId 对象，同样的道理一个数字，如果不特殊说明的话，Mongodb会默认这个是字符串。

    当然我的理解是这个同使用的客户端（驱动器）也是有关联的，不同的驱动对这些默认的处理可能是有所分别的，但是MongoDB 数据库中存放的数据是属于什么类型的，这个是一定要清楚的。

  - **注意2 typeof 是属于shell 的方法**
    
    Mongdb的shell中的`typeof`不能够直接作用在field的字段上，必须先findone然后再typeof，但是即使这个findone的type of也是有问题的。主要是因为这个typeof是运行在shell的js环境的，返回的信息都是js。（js会默认的将所有的整数转换成double类型）同样的道理，任何的整数数据在shell的js存入mongodb的数据库的时候也都用被自动类型转换的这么一个问题。如何想直接的在shell 中验证的话，那只能通过 `instance of` 的返回值来确认了。

  - **注意3 字段量在单表中是不受控制的**

    mongdob的结构是文档型的，从传统关心型的数据库的角度上看它也是有字段的，但是这个字段非彼字段。mongodb中字段更倾向于是一个Dcument Object的一个简单的属性值，即每条记录都有自己的属性值，而传统的关系型数据库的字段是在table上的，是同表结构绑定的。同一个collection中，相同的字段可以是不同的类型。甚至可以说 不同的docment所拥有的字段完全是可以不一样的。这个说白了也是mongodb所谓文档型数据库的的特性吧。

  - **注意4 同样的field 可以拥有不同的type属性** 
    
    虽然不同的document相同field可以用不同的type属性，但是在做数据库设计的时候完全的不推荐这么去做处理，因为这样做的话会给使用方带来很大的问题。

  - **注意5 shell中 NumberInt()或者是NumberLong()**
  
    对于 js 对数字默认是转换成了double的类型，如果要想存储整数的话，在shell的客户端中可以使用的NumberInt（）或者是NumberLong() 来做转换。

---
### 22. $exists
  $exists: <boolean> 这个比较有意思，不同于sql，这个的是查询是否包含某个字段属性。注意如果一个doc有某个字段，但是字段为null的话，那还是代表其含有这个字段，而非什么都没有。

---
### 23. cursor
  Mongodb将提供了cursor【游标】，将查询结果放在游标中然后再使用，同Oracle的pl\sql类似的处理方案。
  
  **TP1**
  但是要注意cursor的操作是占用内存的，另外cursor 如何超过10min没有被操作的话，那Mongdb的会自动的将其释放掉（至少在 Shell 中是这样的）。另外所谓的占用内存我理解应该占用驱动器所处终端的内存，而非mongodb自己数据库的内存。（？）其中这个10min的计算应当是数据库数据全部读取到内存以后，然后开始计算的。
  
  **TP2**
  > 那有个问题: 如果数据量巨大如何处理呢？
  
  批次读概念，同时引发了mongodb慢热的一个设计概念Cursor Batches或者是读的时候有写呢？官方提供了【snapshot mode.】

  **TP3**
  另外,终端也是设置了禁止自动释放的`cursor.noCursorTimeout()`的函数，让用户自行的管理cursor。使用显示的cursor.close()或者是循环完成后自动的释放。这个设计应当是比较有利于大批量的数据操作处理。

  **TP4**
  hasNext()的理念，同Oracle的设计理念一样。

  **TP5**
  可以使用`db.serverStatus().metrics.cursor`做监控。

---
### 24. db.serverStatus() 的解读
  如何解读各类的状态监控数据？db.serverStatus()

---
### 25. update and replace
  mongodb的更新操作有update和replace 两种，那这两种的分别是什么呢？从字面上看一个仅仅是更新现有的字段的值，其他没有被涉及到的字段应该是没有调整或者是改变的，而replace 应该是直接替换的意思。

  mongdodb的更新操作的数据如果大于原来数据分配的空间的话，那这个新的数据就会被整个分布在磁盘上。对这种场景的话有2个问题：
  补：原来的数据所占的空间是否被释放了，如果释放的话，那原来的空间是否可能会被其他的新的数据所利用，如果会被利用的话，那这个数据会不会比较“孤立”以后读取的时候会不会有磁盘索引的性能问题。

  >  a. 这个应该就涉及到Mongodb在对单collection数据分布的时候，对磁盘是如何写的，是不是连续的写还是比较随机的写。【不同的写法对不同类型的磁盘的压力是不同的】

  对于删除或者个挪腾数据，mongodb的处理方法是先标记此数据是作废的数据，但是并不会实际的释放掉。

  >  b. 在写数据或者是任何的新增document的时候，mongodb会不会冗余一些空间出来，如果冗余的话，冗余空间的大小又是如何设计的呢？

---
### 26. merge & update 属性
  mongodb的update操作中有个	Upsert的属性，如果为ture的话，那其效果就如同在Oracle中常用的merge，如果存在则更新，不存在则插入。非常方便的一个做法。

---
### 27. system.js 存储的function的地方
  发现了一个有意思的问题，使用 mongo shell  的funtion功能新建了一个`system.js`的Colletion，但是当我回头想删除的时候，却删除不了，返回的错误是不可以删除system相关的信息，但是回头我却是可以直接rename的。rename完成后就可以直接drop掉了。在自己insert好function以后，还要db.loadServerScripts()`刷下。

  不过 system.js这个应该如何使用，还有待学习。

  另外Mongodb不建议将JavaScript脚本放在数据库中的，官方的说法是有一些性能功能上的限制，当然如果非要用的话，也可以。这样的做法本职上就是将**数据库逻辑同业务逻辑分开。让更复杂的业务操作由专门的终端程序来出来**。

  这种思想乍看上去同Oracle是有分别的，因为Oracle的存储过程中，经常是放了大量的业务逻辑在其中的，不过其实Oracle也是这种思想，只不过Oracle封装的更好。从底层的功能上存储过程并不是Oracle的数据库数据存储及操作的核心，存储过程是PL\SQL的核心。PL\SQL和Oracle数据处理应该是两个不同的技术组建，PL\SQL对存储过程的解析处理，就如同Mongodb的Shell对JavaScipt的解析处理。只不过Oracle的产品封装的好，感觉上就是一个东西罢了。

  > pl/sql--procedural language extension to sql 
  > SQL的过程式语言扩展，以语句块的方式编写和执行，这是sql不具备的功能，是sql的扩展。

---
### 28. 并非所有的_id都是ObjectId
  一个小的思维定势，并非所有的_id都是ObjectId。
  ```

  db.system.js.find({_id:("myfunctest")})
  db.mytest.find({_id:ObjectId("57c82508b2e243af646a9cb5")})
  
  ```

---
### 29. _id 是不可以修改的
  mongodb的_id 是不可以修改的。

---
### 30. 对多接口的一点理解
  Mongodb原先都是已经有了update，insert函数，但是后面又新增的insertOne、insertMany，updateOne，updateMany等函数，这些函数本质上都是可以用原先的函数加一些参数或者是限制就可以做到，但是现在直接开了很多的新函数，其主要的目的还是在于逐渐的接口化管理，尽量的降低参数化的概念，参数化的处理更像是Linux的操作。

---
### 31. delete 操作
  delete 操作并不清除索引，假设我把表的数据清空了，使用delete的方式，那索引是否还全部存在呢？如果回收索引空间的话，那回收的机制呢？

  > ?????

  大规模的delete可以使用复制在drop的方式执行，这个原理同Oracle没多大的分别。delete的成本会高一点。另外被delete的数据的其空间并不会被直接的释放出来，而仅仅是被打了被删除的标签。

---
### 32. getLastError 应当和非应答
  mongodb的写入方式分为应答和非应答两种方式，**ackonwleged write & unnackonwleged write.**

  特别是对于shell 而言，对非仅仅对最后的一次的操作（unackonwleged write）做是否错误的验证，如果前面的操作都是错误的但是最后一次的操作是正确的，那shell就认为最后i一次的操作是正确的。可以通过`getLastError`的方式进行检查。
 
---
### 33. 数组可以当作多种数据结构来设计使用
  monogo db 对数组的一些特殊的操作，$ 站位，$each ，$addToSet,$pop,$pull,$...等等的数据操作。数据在MongDb中的作用，即可以是一个set，也可以是一个正常的数据，也可以是一个队列或者是窄。在不同的场景中提供了不同的操作方式。正确的理解数据组的用途可以帮助我们跟好的设计数据结构。
 
---
### 34. _id 是默认返回的
  find 命令默认都是返回_id的，但是可以可以通过限制条件 设置_id:0，不让其返回。

---
### 35. 日期的格式化
  mongodb是有日期格式的，在shell 查询的时候最好将日期格式化下；Date（“20160201”）

---
### 36. 比较
  查询中的比较符号，lt,lte，ne

---
### 37. IN 和 OR 性能
  同字段的情况下$in的效果比OR好。主要应该是指单字段的情况下。

---
### 38. 限制运算
  $not,$in,$or,$lt,$lte,$gt,$gte  

---
### 39. 语句的运算模式 限制 和 修改
  条件语句是内存文档的键，修改器是外层文档的键值。

--- 
### 40. $and 优化问题
  查询优化器并不会对$and进行优化，需要好好的体会下面的2个查询：
  
  `db.users.find({"$and":[{"X":{"$lt":1}},{"x":4}])`
  `db.users.find({"x":{"$lt":1,"$in":[4]}})`

---
### 41. Like和正则表达式
  mongodb 没有提供like 查询但是提供了正则表达式，其中需要注意的是，mongodb的正则表达式的引擎是同perl兼容的pcre。

---
### 42. 精确匹配 和 $all
  需要注意数组查询中精确匹配的概念。精确匹配的数据，顺序、内容、长度等都需要保持一致。一般正常情况下，使用$all就可以了。 

---
### 42. $inc 操作
  Mongodb 操作中$inc 是非常快的，在设计的时候可以尝试适当的冗余相关的数据。

---
### 43. 基于单个记录doc的事物管理模式
  基于单个记录doc的事物管理模式

---
### 44. $isolated 将数据隔离出来
  1. $isolated 仅仅都非shard的数据起作用。这个操作在一定意义上类似于 update 和 bitmap 在做数据修改的时候都会锁定一部分的数据，只不过所有的数据范围和方式不同罢了。

  2. 还有一个十分特别的就是，即使是对于此类的锁定操作也仅仅是对数据做隔离不被其他的进程处理，但是如果本进程处理的过程中出现异常的话，它也不会做多记录回滚的，说白了就是MongoDb是无事务的。

  3. 暂时想不出有哪些地方可以用的到。

   ```javascript
     db.foo.update(
       { status : "A" , $isolated : 1 },
       { $inc : { count : 1 } },
       { multi: true }
     ) 
   ```


---
### 45. Mongodb的间接事物的实现
  事务的间接实现，Two Pase Commits：
  案例：  从A账户转账到B账户
  Conllections：accounts 、transactions 
  
  - STP1: 初始化账户数据

    ```javascript
    db.accounts.insert(
     [
       { _id: "A", balance: 1000, pendingTransactions: [] },
       { _id: "B", balance: 1000, pendingTransactions: [] }
     ]
    )
    ```


  - STP2: 初始化事务

    transactions collection的结构：
    
    ```javascript
    db.transactions.insert(
      { _id: 1, source: "A", destination: "B", value: 100, state: "initial", lastModified: new Date() }
    )
    ```

  
  - STP3: 取得当前事务状态（初始化）
  
    ```javascript
    var t = db.transactions.findOne( { state: "initial" } )

    ```


  - STP4: 修改事务状态
    ```javascript
      db.transactions.update(
      { _id: t._id, state: "initial" },
      {
        $set: { state: "pending" },
        $currentDate: { lastModified: true }
      }
      )
    ```
  
    > 此处是需要注意，如果并没有成功的更新这个事务说明有其他的进程在处理，那直接返回STP3 再重新开始找一个事务；


  - STP5：将事务绑定到数据记录上：
  
    这个有一点需要特别说明的是，其中的pendingTransactions使用到了$ne，主要是防止重复执行。
    
    ```javascript
      db.accounts.update(
         { _id: t.source, pendingTransactions: { $ne: t._id } },
         { $inc: { balance: -t.value }, $push: { pendingTransactions: t._id } }
      )

    ```
    
    同样的道理在收款人账户上增加数据
    
    ```javascript
      db.accounts.update(
         { _id: t.destination, pendingTransactions: { $ne: t._id } },
         { $inc: { balance: t.value }, $push: { pendingTransactions: t._id } }
      )
    ```

  
  - STP6：更新事务状态
  
    ```javascript
      db.transactions.update(
      { _id: t._id, state: "pending" },
         {
           $set: { state: "applied" },
           $currentDate: { lastModified: true }
         }
      )
    ```

  
  - STP7: 将绑定在数据上的事务回收
    
    ```javascript
      db.accounts.update(
         { _id: t.source, pendingTransactions: t._id },
         { $pull: { pendingTransactions: t._id } }
      )
    ```

    ```javascript
      db.accounts.update(
         { _id: t.destination, pendingTransactions: t._id },
         { $pull: { pendingTransactions: t._id } }
    )
    ```


  - STP8: 更新事务状态为done
  
    ```javascript
      db.transactions.update(
       { _id: t._id, state: "applied" },
       {
         $set: { state: "done" },
         $currentDate: { lastModified: true }
       }
      )
    ```

  
  其实上面的几个步骤关键的目的主要是能够给回滚创造条件，只要其中有一个步骤出现问题，那整个事务就可以完全回滚掉。从另外的一个层面上来讲 此种方案实现的事务只不过是一个colletcions的抽象，留下蛛丝马迹可以让后面回滚掉，属于业务层级的事务处理。这种方式实现起来比较麻烦。


---
### 46. 数据模型的设计 及 行迁移
  mongodb是基于文档类型的数据库的设计理念，一般正常情况下把一些关系数据都存放在一个collections中，这样以后可以很方便的查找及**事物管理**。但是凡事不能一概而论，如果数据量比较大或者数据冗余的程度非常的高的话，那就要考虑拆分不同的数据模型。还是要根据实际的需求来定。mongodb的在存储单个doc的时候会预留一定的冗余空间来，如果后面再新增字段内容进来，如果新增的内容同字段荣冗余的内容比较一致的话，那就不会发生行迁移，如果超过的话那就好做行迁移了，行迁移的成本是很高的。

---
### 47. Capped Collection
  这个collection更像是一种数据结构，其多整个colletion的大小做了限制，可以根据实际的需求来做输入输出的顺序控制，但是这个colletion不可以shard。一般比较合适日志等数据的记录。

---
### 48. 限制表结构 db.createCollection() 
  可以在创建collection的时候对字段进行限制，但是这样的限制还是要根据实际的业务数据情况来定。如何的限制在数据插入的时候都是会有校验，都是会有性能损耗的，而且随着的业务的场景的调整，对以往的限制条件的维护也是一个需要考虑的问题，不做的话数据质量会有问题，做的话会带来运维的成本和性能上的压力，那还是需要甄别出那些是非常重要的数据必须要求进行校验的，且这些数据的量也不应当太大。


  ```javascript

      db.createCollection( "contacts",
       { validator: { $or:
          [
             
             { email: { $regex: /@mongodb\.com$/ } },
             { status: { $in: [ "Unknown", "Incomplete" ] } }
          ]
       }
    } )

  ```

  > 如果查询当前数据库的collection 的校验条件

    `db.getCollectionInfos({name:"contacts"})`

  > 如何修改已经创建的校验规则么？

    可以参考下面的这个文章，mongdb的validator 是可以覆盖和调整的，不过需要执行collMond.

    ```javascript

      var newRule = { email: { $exists: true, $type: "string", $regex: /^\w+@\w+\.gov$/  } }
      db.runCommand( { collMod: "customer", validator: newRule} )

    ```

    
    http://plusnconsulting.com/post/MongoDB-3-2-Goodies-coming-your-way-Schema-Validator/

---
### 49. mongodb 的执行计划概述
  mongodb的计划解析器其原理同Oracle的差不错 ，都是根据之前的统计信息然后按照一定的规则做查询方案的优化设计，并可以通过各样的参数及HIT之类的做法对查询方案做一系列的干预和优化。

  > 但是的不知道mongodb是否有执行计划变更，需要固定执行计划等问题。

  另外mongodb有一个非常直观的expain执行计划表述，比Oracle直观很多。


---
### 50. 执行计划的特别之处

  1. mongodb是的执行计划都是cache的，如果数据库重启了那执行计划就会丢失，mongodb并不会将执行计划持久化到数据库中。

  > 这个可能就有一个问题，如果mongodb重启的话，会对整个性能造成很大影响么？
  
  应该不会有影响，mongodb的执行计划计算的耗时应该是微乎其微的，同时mongodb的把执行计划缓存起来以后并不是会一成不变的
  ，后面还有有专门的选举机制对执行计划进行管理及变更，这个机制主要是进行广播比较及选举，至于如何比较，什么时间会触发让执行计划的重新cache，如何人工的介入干扰执行计划，后面都是有待学习。

  2. 索引和hint 这些硬性的指标，计划解析器对命令的计划优先级还是非常高的，如果命中了索引或者是hint 那基本上就不会选择其他的plan了.

  > 如果即有索引也有hint的话，那mongodb又是如何选择的呢？

  3. 在直接通过 explain()的时候mongodb并不是从cache中抽取已经cache的执行计划，而是重新的发起一次执行计划的选举获取，那就有一个问题，假如同样的一个查询脚本，是否有可能在内存中正在执行的执行计划是old的，而现在的新选举的执行计划是新的效率高的。我觉得完全是有可能的，这个同Oracle的机制是一样的，再次查询优化比较得到的执行计划，可能并不是内存中正在执行的查询计划，

  > 那又如何知道一个正在执行的语句它选择的执行计划呢？
  
  这个就是的explian(<MODE>)的模式选择问题了，默认的情况下执行的是quaryPlanner Mode -- 直接的选举一个新的plan，但是executionStats Mode 则是从cash中直接取当前的执行计划。这个解决的问题同Oracle都是一样的（即：获取执行中 和 当前的执行计划），但是其容易度就不一样了，Oracle获取的当前正在执行的SQL的执行计划会麻烦点（定位session，找到sqlid，然后用dba的包拉）

  > mongodb是如何直接的killsession的，假如有一个性能非常糟糕的请求在占用资源的话？

  4. allPlansExecution Mode 
  这个模式会将所有的plan都打印出来，包括那些竞争失败的执行计划，这个功能感觉上一般用于检查执行计划到底为何没有按照预订的方案执行，可以了解到查询优化器到底是否生成了设计中的计划，然后再查找竞争失败的原因。

  5. code case:
    - 普通模式
      ```javascript
          db.products.explain().count( { quantity: { $gt: 50 } } )
      ```
      ```javascript
          db.products.explain("executionStats").find(
           { quantity: { $gt: 50 }, category: "apparel" }
          )
      ```
      ```javascript
          db.products.explain("allPlansExecution").update(
           { quantity: { $lt: 1000}, category: "apparel" },
           { $set: { reorder: true } }
          )
      ```

    - 添加过滤器
      ```javascript
        db.products.explain("executionStats").find(
         { quantity: { $gt: 50 }, category: "apparel" }
        ).sort( { quantity: -1 } ).hint( { category: 1, quantity: -1 } )
      ```
      可以通过`db.collection.explain().find().help()` 查询可用的过滤清单。

---
### 51. 性能优化建议
  性能优化中也是尽量合理的使用索引，但是任何的索引都是有代价的，过多的索引会引起数据插入上的低效。另外Mongodb中是使用Query Selectivity这个概念，在Oracle数据库中则是使用 聚簇因子，虽然其底层的数据的结构可能不一样，但是其目的是一样的，那就是通过一定的算法，让优化器能够去v量化比较那一种执行计划更有效率。而很多的执行计划的变更，或者是查询的优化，都是基于这种理念做的改造调整。

---
### 52. Mongodb Profiler 性能监控工具
  主要用于监控mongodb当前数据库的执行操作，其通过LEVEL 进行了控制：

  |Level|Setting|
  |-----|-------|
  |0|Off. No profiling|
  |1|On. On. Only includes “slow” operations|
  |2|Off. On. Includes all operations|

  通过 shell `db.setProfilingLevel(1)` 来进行设置。

  至于如何进行设置及使用 Profiler 后面再学习补充

---
### 53. 查询优化的索引的效能
  mongodb的索引，特别是组合索引其前后顺手还是有一点的关联性的，如果的数据区分度高的在第一个的话，那后面的查询效率会提升很多，但是如果是数据区分读低的在地一个的话，那后面的数据区分度就并不会太高。

  ```javascript
  db.inventory.createIndex( { quantity: 1, type: 1 } )
  db.inventory.createIndex( { type: 1, quantity: 1 } )
  ```

  上面就是2种完全不同的索引的组合，其查询的性能也是会根据数据的实际情况有所区分。这类的组合索引在设计的时候，需呀尽量的考虑使用的具体场景。

---
### 54. Tailable Cursors
  这个是在Oracle中没有发现的新特性。其主要的目的感觉是在与不断的读取输送，同Linux上的tail命令类似。其是不走索引的，第一次检索的时候会非常的慢，但是后面的话会增量的顺序读数据。这个同capped colletions结合起来，会是非常不错的流程出来工具。不过其也有很大的局限性，有异常的清除动作，就会引起这个cursor的失效。

  - Consider the following behaviors related to tailable cursors:
  Tailable cursors do not use indexes and return documents in natural order.

  - Because tailable cursors do not use indexes, the initial scan for the query may be expensive; but, after initially exhausting the cursor, subsequent retrievals of the newly added documents are inexpensive.

  - Tailable cursors may become dead, or invalid, if either:

    + the query returns no match.
    + the cursor returns the document at the “end” of the collection and then the application deletes that document.

    A dead cursor has an id of 0.

---
### 55. mongodb 的 text 全文检索
  可以使用text索引来进行全局索引，目前mongodb也支持中文的全局索引及分词，但是其中文的分词算法和逻辑是基于basistech.com 的技术，所以要支持中文的全局需要购买basistech的SDK的工具包。

  另外的text属性的索引一个colleciton中仅仅只能有一个，如果多个字段需要做此类的索引的话，那就要建立一个组合的索引。

  我认为还是不在mongodb上做此类的索引为好，第一需要购买额外的sdk，sdk的支持情况也不清楚是如何的，还有就是如果在交易表的基础上新建这样的索引，应当对insert性能有很大的影响。如果要做专业的查询的话，还是使用其他的搜索比较好。

---
### 56. 数据模型的设计 之 数据嵌套
  数据的嵌套在一定的程度上是可以减少数据的数据操作次数和客户端的访问次数的，但是也不能够将所有的宝都压在这个结构上。当数据越来越多的时候，插入的性能就会下降，同时还是引起数据碎片的问题。

  However, embedding related data in documents may lead to situations where documents grow after creation. With the MMAPv1 storage engine, document growth can impact write performance and lead to data fragmentation.

---
### 57. 数据模型的设计 之 关系
  mongdb 可以使用 refrences 来设计多表之间的关系。使用Normalized模型可以有效的减少数据的重复性，但是为了解析关系就必须同时数据库产生多次的交互，这样就会带来读取性能的损耗。同嵌入模型比较起来算是以时间换空间了吧。既然现在已经是弱关系的管理模式了，适当的存储数据应当是没有问题的。

---
### 58. 设计上的一些问题
  因为mongddb的存储引擎（MMAPv1）的设计，在数据的update修改的时候，如果新增的数据内容大于之前留存的数据内容的时候就会发生数据的迁移，这个对性能的影响是很大的。那有没有什么方法可以避免这种情况呢，特别是明明已经知道会有批量的数据的新增。

  上述的问题是基于MMAPv1存储引擎的，但是从mongodb3.2 开始，默认的存储引擎已经变更为WiredTiger了。存储引擎的特性需要多了解下。

  官方给的意见是如果更新的动作非常的频繁，引起了数据的大规模的迁移，那就要考虑使用 normalized的设计模式取代refrences的设计模式。不过这个东西还是需要根据实际的数据使用场景来定，看看是否可以通过置换的方式处理数据。

  还有一个方案是通过预先固定的方式处理。预先固定数据的预留空间，但是实际上并不是所有的记录都需要被更新的，如果固定空间的话，是不是容易引起空间的大幅度浪费。

---
### 59. 存储引擎
  在mongdb3.2之前的存储引擎是MMAPv1 ,3.2版本开始使用的WiredTiger引擎。

  WiredTiger
    - 每60秒或者是内存数据超过2g的时候将数据同步到磁盘。同oracle类型的cheakpoint的机制，主要是mongodb的健壮性的配置。
    在恢复的时候moongdb是先检查cheakpoint的，然后再利用日志来恢复chekpoint之后发生的种种问题。
    
    - 因为有了replica set ，在性能需要的时候可以关闭 journal么？

    - 压缩是按照块来压缩的，可以压缩数据也可以压缩索引。

---
### 60. 字段的名称尽量的小
  因为mongodb是把每个字段都存储在collection中了，所以有时候字段名称都占了很多的空间，如果为了减少空间的使用的话，尽量使用简短的字段名称。当然可读性也是不能忽略的。

---
### 61. 可以设置数据失效日期
  可以设置数据失效日期来控制数据的生命周期。（归档的场景下比较用有，因为不需要手工的清洗数据，但是的控制不好会比较危险）

  还有就是90%以上的场景是针对最近的操作做的管理 ，此类的操作使用Capped Collections是最合理的，但是旧的数据又不能清理掉。如果分接口处理的话，又及其的麻烦，非常的难维护。

  如何使用 Capped Collections 呢？

---
### 62. 关于join查询
  mongodb是不支持join查询的，但是可以使用DBRefs将不同的表关联起来，然后在使用的时候利用drivers将其自动的查询出来，但是还是不建议自动处理这种逻辑。官方给的意见是能自己手工出来的还是自己手工处理。即使是用drivers来处理也是查询两次。这个在形式上更像是herbinate。

---
### 63. 索引Index
  重要的事情永远放在后面，mongodb的索引：

  首先索引之索引快主要是因为其是顺序的，可以急速的找打需要的数据。mongodb的索引机制同其他的数据库的索引机制无太本质的分别。

  - you can not drop index on the **_id** filed. 如果没有的话会自动的新增一个。mongodb的uuid。

  - mongdb 的索引是B-TREE 索引

  - Single Field 索引。单字段索引。对于单字段索引，sort asc 或者是 desc 都没有什么大关系。

  - compound 索引 ，组合索引。那组合索引的情况下，数据的排序有影响么？

    组合索引对排序的性能是有影响的，尽量让排序同索引保持一致。比较坑呀。

    > You can specify a sort on all the keys of the index or on a subset; however, the sort keys must be listed in the same order as they appear in the index. For example, an index key pattern { a: 1, b: 1 } can support a sort on { a: 1, b: 1 } but not on { b: 1, a: 1 }.

    > The sort must specify the same sort direction (i.e.ascending/descending) for all its keys as the index key pattern or specify the reverse sort direction for all its keys as the index key pattern. For example, an index key pattern { a: 1, b: 1 } can support a sort on { a: 1, b: 1 } and { a: -1, b: -1 } but not on { a: -1, b: 1 }.

  - Multikey Index 索引为数组而生
    这个索引的机制及性能如何需要再挖下

  - Geospatial Index 二位的地理位置索引。场景比较特殊。

  - Text Indexes 是给全文检索使用的。因为中文的全文检索需要额外的购买分词算法，目前估计暂时用不到。

  - Hashed Indexes 使用hash算法来索引数据，但是本身应当也是有一定的显示的，比如应当没办法支持范围查询及可能出现不同的数据相同的hash值的场景。

  - 索引的属性 --Unique Indexes ，顾名思义，唯一性约束的索引

  - 索引的属性 --Partial Indexes ，这个是mongodb3.2 因引入的一个属性概念，对于不存在的数据无需建立索引。这个是非常不错的一个理念。

  - 索引的属性 --Sparse Indexes ，稀疏索引，仅仅索引有含有这个fild的数据（有fild但是无值估计也会被索引），不过这个索引应当慢慢的退出历史舞台了，因为mongodb的官方提供了 paitial index，官方的建议是首选partial。

    > Partial indexes offer a superset of the functionality of sparse indexes and should be preferred over sparse indexes.
  
  - 索引的属性 --TTL Indexes ，设置数据的超时日期，然后自动消除，这个对数据的生命周期管理而言会非常的方便。

  mongodb 是会自动的选择走什么样的索引，

---
### 63. 其他的索引限制

  




