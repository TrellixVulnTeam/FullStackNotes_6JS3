---
title: ios蓝牙开发（三）app作为外设被连接的实现
tags: 蓝牙
categories: 蓝牙
abbrlink: 18114
date: 2016-06-01 12:01:03
---

> 再上一节说了app作为central连接peripheral的情况，这一节介绍如何使用app发布一个peripheral，给其他的central连接

![img](http://liuyanwei.jumppo.com/assets/uploads/CoreBluetoothFramework.jpeg)

还是这张图，central模式用的都是左边的类，而peripheral模式用的是右边的类

## peripheral模式的流程

------

```
1. 打开peripheralManager，设置peripheralManager的委托
2. 创建characteristics，characteristics的description 创建service，把characteristics添加到service中，再把service添加到peripheralManager中
3. 开启广播advertising
4. 对central的操作进行响应
    - 4.1 读characteristics请求
    - 4.2 写characteristics请求
    - 4.4 订阅和取消订阅characteristics
```

## 准备环境

```
  1 xcode
  2 开发证书和手机（蓝牙程序需要使用使用真机调试，使用模拟器也可以调试，但是方法很蛋疼，我会放在最后说），如果不行可以使用osx程序调试
  3 蓝牙外设
```

<!-- more -->

## 实现步骤

#### 1. 打开peripheralManager，设置peripheralManager的委托

设置当前ViewController实现CBPeripheralManagerDelegate委托

```
    @interface BePeripheralViewController : UIViewController<CBPeripheralManagerDelegate>
```

初始化peripheralManager

```
     /*
     和CBCentralManager类似，蓝牙设备打开需要一定时间，打开成功后会进入委托方法
     - (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral;
     模拟器永远也不会得CBPeripheralManagerStatePoweredOn状态
     */
    peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
```

#### 2. 创建characteristics，characteristics的description ，创建service，把characteristics添加到service中，再把service添加到peripheralManager中

在委托方法 `- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral`中，当peripheral成功打开后，才可以配置service和characteristics。 这里创建的service和chara对象是CBMutableCharacteristic和CBMutableService。他们的区别就像NSArray和NSMutableArray区别类似。 我们先创建characteristics和description，description是characteristics的描述，描述分很多种， 这里不细说了，常用的就是CBUUIDCharacteristicUserDescriptionString。

```
//peripheralManager状态改变
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    switch (peripheral.state) {
            //在这里判断蓝牙设别的状态  当开启了则可调用  setUp方法(自定义)
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"powered on");
            [info setText:[NSString stringWithFormat:@"设备名%@已经打开，可以使用center进行连接",LocalNameKey]];
            [self setUp];
            break;
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"powered off");
            [info setText:@"powered off"];
            break;

        default:
            break;
    }
}
 //配置bluetooch的
 -(void)setUp{

        //characteristics字段描述
        CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];

        /*
         可以通知的Characteristic
         properties：CBCharacteristicPropertyNotify
         permissions CBAttributePermissionsReadable
         */
        CBMutableCharacteristic *notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:notiyCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];

        /*
         可读写的characteristics
         properties：CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead
         permissions CBAttributePermissionsReadable | CBAttributePermissionsWriteable
         */
        CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readwriteCharacteristicUUID] properties:CBCharacteristicPropertyWrite | CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable | CBAttributePermissionsWriteable];
        //设置description
        CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
        [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];


        /*
         只读的Characteristic
         properties：CBCharacteristicPropertyRead
         permissions CBAttributePermissionsReadable
         */
        CBMutableCharacteristic *readCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:readCharacteristicUUID] properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];


        //service1初始化并加入两个characteristics
        CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID1] primary:YES];
        [service1 setCharacteristics:@[notiyCharacteristic,readwriteCharacteristic]];

        //service2初始化并加入一个characteristics
        CBMutableService *service2 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:ServiceUUID2] primary:YES];
        [service2 setCharacteristics:@[readCharacteristic]];

        //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
        [peripheralManager addService:service1];
        [peripheralManager addService:service2];
 }
```

#### 3. 开启广播advertising

```
//perihpheral添加了service
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        serviceNum++;
    }

    //因为我们添加了2个服务，所以想两次都添加完成后才去发送广播
    if (serviceNum==2) {
        //添加服务后可以在此向外界发出通告 调用完这个方法后会调用代理的
        //(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
        [peripheralManager startAdvertising:@{
                                              CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:ServiceUUID1],[CBUUID UUIDWithString:ServiceUUID2]],
                                              CBAdvertisementDataLocalNameKey : LocalNameKey
                                             }
         ];

    }

}

//peripheral开始发送advertising
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    NSLog(@"in peripheralManagerDidStartAdvertisiong");
}
```

#### 4. 对central的操作进行响应

```
- 4.1 读characteristics请求
- 4.2 写characteristics请求
- 4.3 订阅和取消订阅characteristics
//订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"订阅了 %@的数据",characteristic.UUID);
    //每秒执行一次给主设备发送一个当前时间的秒数
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendData:) userInfo:characteristic  repeats:YES];
}

//取消订阅characteristics
-(void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"取消订阅 %@的数据",characteristic.UUID);
    //取消回应
    [timer invalidate];
}

//发送数据，发送当前时间的秒数
-(BOOL)sendData:(NSTimer *)t {
    CBMutableCharacteristic *characteristic = t.userInfo;
    NSDateFormatter *dft = [[NSDateFormatter alloc]init];
    [dft setDateFormat:@"ss"];
    NSLog(@"%@",[dft stringFromDate:[NSDate date]]);

    //执行回应Central通知数据
    return  [peripheralManager updateValue:[[dft stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:(CBMutableCharacteristic *)characteristic onSubscribedCentrals:nil];

}


//读characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"didReceiveReadRequest");
    //判断是否有读数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        [request setValue:data];
        //对请求作出成功响应
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}


//写characteristics请求
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests{
    NSLog(@"didReceiveWriteRequests");
    CBATTRequest *request = requests[0];

    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        //需要转换成CBMutableCharacteristic对象才能进行写值
        CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        [peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
    }else{
        [peripheralManager respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }


}
```

## 代码下载:

我博客中大部分示例代码都上传到了github，地址是：https://github.com/coolnameismy/demo，[点击跳转代码下载地址](https://github.com/coolnameismy/demo)