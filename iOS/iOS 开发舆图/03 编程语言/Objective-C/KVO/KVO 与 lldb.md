# KVO 与 lldb

* 你可以在 lldb 里查看一个被观察对象的所有观察信息。
```
(lldb) po [observedObject observationInfo]
```
* 这会打印出有关谁观察谁之类的很多信息。
* 这个信息的格式不是公开的，我们不能让任何东西依赖它，因为苹果随时都可以改变它。不过这是一个很强大的排错工具。