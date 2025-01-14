当一个错误被抛出时，周围的一些代码必须负责处理这个错误--例如，通过纠正问题，尝试其他方法，或通知用户失败。

在Swift中，有四种处理错误的方法。您可以将错误从函数传播到调用该函数的代码，使用do-catch语句处理错误，将错误处理为一个可选的值，或者断言错误不会发生。每种方法都会在下面的一节中进行描述。

当一个函数抛出错误时，它将改变你的程序流程，因此，你必须能够快速识别代码中可能抛出错误的地方。要识别代码中的这些地方，请在一段调用可能抛出错误的函数、方法或初始化器的代码前写上try关键字--或try?或try!变体。这些关键字将在下面的章节中描述。

注

Swift中的错误处理类似于其他语言中的异常处理，使用了try、catch和throw关键字。与许多语言中的异常处理--包括Objective-C--不同，Swift中的错误处理不涉及拆开调用堆栈，这个过程在计算上可能很昂贵。因此，抛出语句的性能特征与返回语句的性能特征相当。