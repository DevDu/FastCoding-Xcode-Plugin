**该功能主要是根据java的开发工具 eclipse 快速生成属性的getter ,setter 方法有感而发.**
####安装
1. 下载并打开该项目
2. Command+B (build项目) 
3. 重启Xcode,在弹框中选择load插件
生成的插件在此路径下  ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins

####用法

- 快速生成set,get方法
- 根据所声明的属性,选择生成get,set,lazy初始化方法.

####快捷键
(Product ->Select  Generate )或者( Command + =) 弹出选择属性弹窗, 选择要生成的属性以及对应方法.

![screenshot](https://github.com/DevDu/FastCoding-Xcode-Plugin/blob/master/screenshot/screenShot3.png?raw=true)

####卸载
卸载此插件
~/Library/Application Support/Developer/Shared/Xcode/Plug-ins 路径下删除对应的插件即可.