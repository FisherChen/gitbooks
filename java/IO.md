### Java IO

- Q1 所有的读取和输出都是基于 InputStram 和 OutputStream 的实现的。

- Q2 FileInputStream 和 OutPut 是基于底层byte 处理的, FileReader 和FileWriter 也是基于FileInputStream的功能实现，
还是一个个byte的读取数据，只不过实现了根据编码格式的读取，防止出现所谓的乱码的问题。

- Q3 BuffereReader 虽然底层也是读取，但是使用了缓存的理念，减少了应用和操作系统的交互的次数。Buffer的关键的概念是将数据存储在操作系统的
buffer区中，减少了磁盘的交互。提升性能。但是这样就必须在写完成的时候将刷到磁盘上。Flushing





