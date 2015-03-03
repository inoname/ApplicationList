# ApplicationList
##实现简单的图像下载功能
###所谓经验，不是指能找到一条通向目标的捷径，而是在通向目标的过程中能够有效避开各种“坑”
###下面的部分记录了网络图片加载的实现以及优化步骤

开始的状态：同步加载网络图片

问题： 1. 如果网速慢，会给用户非常明显的"卡"的感觉<br>
&emsp;&emsp;&emsp;&ensp; 2. 每次显示 cell，都会重新加载图片<br>
解决思路： 使用多线程加载


问题：   3.tableviewCell需要交互一下才能显示出图片<br>
解决思路： 使用占位图像，除了能够设置图像，还能够把 imageView 的 frame 给撑开！


问题：  4.如果图片下载速度不一样，用户又来回滚动cell，可能出现"图片错行"的问题<br>
解决思路： 不能直接改变视图，给模型中增加一个image的属性，通过模型来控制视图，在图像下载完成之后，刷新指定的行。


问题：  5.如果某张下载速度非常慢，用户快速来回滚动表格，会造成下载操作会重复创建！<br>
解决思路： 用字典做一个"下载操作缓冲池"(图片url做key)，创建下载操作之前先判断池中有没有已经存在的操作。


问题：  6.目前图片下载完成之后，是保存在模型中的！如果应用程序运行过程中，出现内存警告需要释放内存的时候，不好释放。<br>
解决思路： 图片不能保存在模型中，建立图片缓冲池。如果内存警告，直接清空图片缓存即可！



问题：  7."下载操作缓冲池"中的内容，在下载完成之后没有删除，造成内存浪费。如果一个下载操作失败，下次刷新的时候不能够重新下载。<br>
解决思路： 下载完成之后，清除缓冲池！


问题：  8.创建操作时使用了block，容易引起循环引用的问题<br>
解决思路： 借助 dealloc 辅助判断，没有出现循环引用。因为下载操作在执行完毕之后会从"下载操作缓冲池"中移除，打破了循环引用。
