---
title: GJLightBlueTooth——一个轻量级的iOS蓝牙开发库
tags: 蓝牙
categories: 蓝牙
abbrlink: 18107
date: 2018-03-24 12:01:03
---

从上家公司离职已经快半年了，与蓝牙打了一年的交道，从小白一个到略知一二。最近在整理上一家公司做的一些项目，突发奇想，自己封装一个蓝牙库，方便以后的使用。说干就干，**如果需要项目代码，猛击这里[GJLightBlueTooth](https://github.com/manofit/GJLightBlueTooth)。如果有用，请赏颗小星星。**

## GJLightBlueTooth架构

当初为了不在一个类里面同时处理发送与接收逻辑，也本着对外封闭的原则，为了给使用库的人一个简单的类，就设计了：

```
用户 ——> GJLightBlueTooth ——> CoreBlueTooth ——> GJLightBlueTooth ——> 用户
复制代码
```

这样的架构

其中：

- GJLightBlueTooth：相当于一个中介，架起来自页面用户的指令和系统CoreBlueTooth交互的桥梁，这里的交互包括向蓝牙设备发送指令和设置回调。
- GJLBTCentralManager：所有与系统CoreBlueTooth的沟通都在这里进行，这里将指令发出去，也在这里获取回调，通过block回传。

另外，在Demo中，你还会看到MyBLETool这个类，这是为了将Demo项目中页面与业务分离而单独出来的一个类，可以理解为设备类。为了我们不需要在具体的页面中去设置回传的block。



<!-- more -->

## 使用

在创建页面后，你应该初始化GJLightBlueTooth蓝牙工具：self.BLE = [[GJLightBlueTooth alloc] init]。

在获取到Characteristic后，你应该根据实际读写的Characteristic匹配出设备上的CBCharacteristic，保存在本地，用于后面的写与读。

```
[self.BLE setBlockWhenDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        strongify(self);
        for (CBCharacteristic *cha in service.characteristics){
            if ([cha.UUID.UUIDString isEqualToString:CharacteristicUUIDWrite]){
                self.writeCharacter = cha;
            }
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DiscoverCharacteristics" object:service];
    }];
复制代码
```

### 扫描

```
[self.BLE scan]
复制代码
```

### 停止扫描

```
[self.BLE stopScan]
复制代码
```

### 连接设备

```
[self.BLE connectWithPeripheral:peri]
复制代码
```

### 断开连接

```
[self.BLE cancelConnectWithPeripheral:peri]
复制代码
```

### 读取信号量

```
[self.BLE readRSSIWithPeriperal:peri]
复制代码
```

### 发送数据

```
[self.BLE sendDataToPeriperal:peri WriteCharacteristic:self.writeCharacter Command:command NSEncoding:encoding]
复制代码
```

这里针对现在很多公司提出需要手机与设备有心跳的要求，开启了一个线程队列。该队列设置能够同时存在的指令数为3。

```
NSData *cmdData = [[NSString stringWithFormat:@"%@",command] dataUsingEncoding:encoding];
    
    NSOperation *opration = [NSBlockOperation blockOperationWithBlock:^{
        [peripheral writeValue:cmdData
            forCharacteristic:writeCharacteristics
                         type:CBCharacteristicWriteWithoutResponse];
        /*
         * you can set thread time interval.but the order while delay when there are a lot of orders.
         */
        //[NSThread sleepForTimeInterval:SleepTimeGap];
    }];
    
    [self.writeQueue addOperation:opration];
复制代码
```

你也可以设置指令间隔时间，但是这样会造成因心跳刷新过快造成的延迟发送。

## 注意

- 在新版本的iOS中，已经不允许通过peripheral.RSSI来获取设备的信号量，必须在用[peripheral readRSSI]后，使用回调来获取。这就会造成在扫描到设备时候无法显示信号量。所以专门创建了一个分类CBPeripheral+RSSI，利用Runtime来动态给peripheral创建了一个rssi属性。

```
char nameKey;

- (void)setRssi:(NSNumber *)rssi{
    objc_setAssociatedObject(self, &nameKey, rssi, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSNumber *)rssi{
    return objc_getAssociatedObject(self, &nameKey);
}
复制代码
```

- 在MyBLETool中，需要设置GJLBTCentralManager回调流，这里为了防止循环引用，需要进行weak-strong dance。

```
weakify(self);

[self.BLE setBlockWhenDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        strongify(self);
        for (CBCharacteristic *cha in service.characteristics){
            if ([cha.UUID.UUIDString isEqualToString:CharacteristicUUIDWrite]){
                self.writeCharacter = cha;
            }
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"DiscoverCharacteristics" object:service];
    }];
复制代码
```

## 最后是两张demo的效果

![Xnip2020-11-06_14-11-42](https://gitee.com/coderiding/picbed/raw/master/uPic/Xnip2020-11-06_14-11-42.jpg)


![Xnip2020-11-06_14-11-58](https://gitee.com/coderiding/picbed/raw/master/uPic/Xnip2020-11-06_14-11-58.jpg)