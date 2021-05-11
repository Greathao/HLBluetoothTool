//
//  HLBTDeviceMgr.m
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import "HLBTDevice.h"
#import "HLBTCentralMgr.h"
@interface HLBTDevice ()
@property(nonatomic,strong,readwrite)CBPeripheral * cbPeripheral;
@property(nonatomic,strong,readwrite)NSArray<CBCharacteristic*> * __nullable foundCharacteristics;

@end

@implementation HLBTDevice
- (instancetype)initWithPeriphral:(CBPeripheral*__nonnull)peripheal
{
    self = [super init];
    if (self) {
        self.cbPeripheral = peripheal;
        self.identifierUUIDString = self.cbPeripheral.identifier.UUIDString;
        self.name = self.cbPeripheral.name;
        }
    return self;
}

 
#pragma  - mark public
- (void)connect{
    if (![self.delegate respondsToSelector:@selector(BTDeviceGetBTCentralManager)]){
        NSLog(@"连接失败请检查未拿到中央");
        return;
     }
    HLBTCentralMgr * center = [self.delegate BTDeviceGetBTCentralManager];
    [center connectPeripheral:self.cbPeripheral];
}

- (void)disconnect{
    if (![self.delegate respondsToSelector:@selector(BTDeviceGetBTCentralManager)]){
        NSLog(@"断开失败请检查未拿到中央");
        return;
     }
    HLBTCentralMgr * center = [self.delegate BTDeviceGetBTCentralManager];
    [center cancelConnection:self.cbPeripheral];
}

- (void)writeData:(NSData*__nonnull)data writeCharacteristicWithUUIDStr:(NSString*__nonnull)wuuid{
   CBCharacteristic * charact = [self getCharacteristicWithUUID:wuuid];
    if (!charact) {
        NSLog(@"未找到特征所以没法写");
        return;
    }
    if (charact.properties & CBCharacteristicPropertyWriteWithoutResponse
        ||charact.properties & CBCharacteristicPropertyWrite
        ||charact.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) {
        CBCharacteristicWriteType type = CBCharacteristicWriteWithResponse;
        if (charact.properties & CBCharacteristicPropertyWriteWithoutResponse) {
            type = CBCharacteristicWriteWithoutResponse;
        }
        [self.cbPeripheral writeValue:data forCharacteristic:charact type:type];  ;
    }else{
        NSLog(@"所使用的特征类型并不是 write类型");
    }
 }


- (CBCharacteristic*)getCharacteristicWithUUIDStr:(NSString*__nonnull)wuuid{
    for (CBCharacteristic * chara in self.foundCharacteristics) {
        if ([chara.UUID.UUIDString isEqualToString:wuuid]) {
            return chara;
        }
    }
    return nil;
};

- (void)addNotificationCharacteristicWithUUID:(NSArray*__nonnull)uuids{
    if (!uuids.count) {
        NSLog(@"请输入要监听的uuid");
        return;
    }
    
    for (NSString * uuid in uuids) {
        CBCharacteristic * charact = [self getCharacteristicWithUUID:uuid];
        if (charact.properties & CBCharacteristicPropertyNotify){
            if (charact.isNotifying) {
                return;
            }
            [self.cbPeripheral setNotifyValue:YES forCharacteristic:charact];
         }
    }
}

- (void)cancelNotificationCharacteristicWithUUID:(NSArray*__nonnull)uuids{
    for (NSString * uuid in uuids) {
        CBCharacteristic * charact = [self getCharacteristicWithUUID:uuid];
        if (charact.properties & CBCharacteristicPropertyNotify){
            if (!charact.isNotifying) {
                return;
            }
            [self.cbPeripheral setNotifyValue:NO forCharacteristic:charact];
         }
    }
}
 
#pragma  - mark private

-(CBCharacteristic*)getCharacteristicWithUUID:(NSString*)uuidString{
    for (CBService * service in self.cbPeripheral.services) {
        for (CBCharacteristic * characteristic in  service.characteristics) {
            if ([characteristic.UUID.UUIDString isEqualToString:uuidString]) {
                return characteristic;
            }
        }
    }
    return nil;
}
-(NSString *)propertiesString:(CBCharacteristicProperties)properties
{
    CBCharacteristicProperties temProperties = properties;
    
    NSMutableString *tempString = [NSMutableString string];
    
    if (temProperties & CBCharacteristicPropertyBroadcast) {
        [tempString appendFormat:@"Broadcast "];
    }
    if (temProperties & CBCharacteristicPropertyRead) {
        [tempString appendFormat:@"Read "];
    }
    if (temProperties & CBCharacteristicPropertyWriteWithoutResponse) {
        [tempString appendFormat:@"WriteWithoutResponse "];
    }
    if (temProperties & CBCharacteristicPropertyWrite) {
        [tempString appendFormat:@"Write "];
    }
    if (temProperties & CBCharacteristicPropertyNotify) {
        [tempString appendFormat:@"Notify "];
    }
    if (temProperties & CBCharacteristicPropertyIndicate)//notify
    {
        [tempString appendFormat:@"Indicate "];
    }
    if(temProperties & CBCharacteristicPropertyAuthenticatedSignedWrites)//indicate
    {
        [tempString appendFormat:@"AuthenticatedSignedWrites "];
    }
    if (tempString.length > 1) {
        [tempString replaceCharactersInRange:NSMakeRange(tempString.length-1, 1) withString:@""];
    }
    return tempString ;
}

#pragma -mark CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    HLBTCentralMgr * center = [self.delegate BTDeviceGetBTCentralManager];
    NSArray <CBUUID*>* uuids = [center.btfilter getFilterCharacteristicUUIDs];
    NSLog(@"%@",uuids);
      for (CBService* service in peripheral.services)  {
        NSLog(@"通过发现的服务%@ 想要过滤的特征%@",service.UUID.UUIDString,uuids);
         [peripheral discoverCharacteristics:uuids forService:service];
    }
}
 
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    NSLog(@"%@",service);
    self.foundCharacteristics = service.characteristics.copy;
    for (CBCharacteristic *characteristic in service.characteristics){
        NSLog(@"uuid:%@/%@", characteristic.UUID,[self propertiesString: characteristic.properties]);
       
    }
    if ([self.delegate respondsToSelector:@selector(btDevice:didDiscoverCharacteristics:error:)]) {
        [self.delegate btDevice:self didDiscoverCharacteristics:service.characteristics error:error];
    }
 
}
/** 订阅状态的改变 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"订阅失败\nUUID:%@",characteristic.UUID.UUIDString);

        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功\nUUID:%@",characteristic.UUID.UUIDString);
    } else {
        NSLog(@"取消订阅\nUUID:%@",characteristic.UUID.UUIDString);
    }
    if ([self.delegate respondsToSelector:@selector(btDevice:didUpdateNotificationStateForCharacteristic:error:)]) {
        [self.delegate btDevice:self didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}
///用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"=======%@",error.userInfo);
    }else{
        NSLog(@"发送数据成功");
    }
    if ([self.delegate respondsToSelector:@selector(btDevice:didWriteValueForCharacteristic:error:)]) {
        [self.delegate btDevice:self didWriteValueForCharacteristic:characteristic error:error];
    }
}
///获取外设发来的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(btDevice:didUpdateValueForCharacteristic:error:)]) {
        [self.delegate btDevice:self didUpdateValueForCharacteristic:characteristic error:error];
    }
    if (error) { NSLog(@"写入数据失败:(%@)\n error:%@",characteristic,error.userInfo);return;}
    NSData * data = characteristic.value;
    NSLog(@"收到外设来的信息%@",data);
  
    
}
@end
