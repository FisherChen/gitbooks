## Spring 的一些TIPS
java的一个非常好的优势就是可以提供各种各样的别人已经封装好的东西，然后直接拿过来就可以使用了，但是目前有一个问题就是随着封装的东西越来越多，后面的人使用起来的时候就非越来越大，当大到一定的程度的时候就非觉得非常的麻烦，需要配置各类的东西，然后各类的子项目就孕育而生了。说白了还基础的技术框架上再搭建或者是组合其他的东西。

基础的部分：

Spring-framework 目前发行的稳定的版本是4.3.3版.在maven 的配置中，自动抓下来的依赖包：

> spring-context-xxx.jar
> spring-aop-xxx.jar
> spring-beans-xxx.jar
> spring-core-xxx.jar
> commons-logging-xxx.jar
> spring-expressing-xxx.jar



### 对IOC而言
`org.springframework.beans ` 基础类
`org.springframework.context`

Spring  的核心是通过一个容器来实现IOC的操作，而这个容器在一定的程度上就是一个BeanFactory，目前Spring的核心的接口是BeanFactory然后在这个接口基础上拓展出了很多的实现，其中的ApplicationContext 就是一个非常重要的子接口，目前很过常用的API都是通过这个接口来实现的。

另外的容器的实现类是非常的多的，甚至是可以使用其他容器的实现的Bean，不过的一般正常情况下很少用的到这些功能。可以通过的ApplicationContext.getBeanFactory() 来获取DefaultListableBeanFactory().

### Bean
Bean 配置的ID是唯一的但是Name 可以是这个Bean的别名，一个Bean是可以有多个别名的。但是唯一性是必须有保证的，如果不指定ID的话，那容器会自动的给一个唯一的ID，但是如果没有名称的话那就使用不起来了。 别名在项目管理中使用应该会非常的方便。同时可以使用alias 标签来管理别名，在新框架接入或者是项目整合的程序中很有用。

Bean的命名在一定的程度上还是遵循驼峰规则吧，这样后面在管理的时候会非常的省事，可以节约很多不必要的代码量。
所有的Bean的配置其实都是BeanDefinition的实例，容器通过对BeanDefinition的解析来实现Bean的创建，Bean的创建的方式主要是通过2个方式来实现，一个是通过构造函数一个是通过自己内部的static的方法来返回;同时CLASS也是可以定义内类的，通过$来固定。

### 

