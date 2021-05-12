//
//  HLBTDevice.h
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import "HLBTFilterRulesProtocol.h"
 
 
NS_ASSUME_NONNULL_BEGIN

@class HLBTCentralMgr;
@class HLBTDevice;
@protocol HLBTDeviceDelegate <NSObject>

@required
-(HLBTCentralMgr*)BTDeviceGetBTCentralManager;

@optional

///发现服务 /或错误
-(void)btDevice:(HLBTDevice*)device didDiscoverServices:(NSError *)error;

///发现完特征 回调
-(void)btDevice:(HLBTDevice*)device didDiscoverCharacteristics:(NSArray<CBCharacteristic*>* )characteristic error:(nullable NSError *)error;
///订阅响应
-(void)btDevice:(HLBTDevice*)device didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
///写入回调响应
-(void)btDevice:(HLBTDevice*)device didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
///收到蓝牙设备反馈信息；
-(void)btDevice:(HLBTDevice*)device didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;
@end

@interface HLBTDevice : NSObject<CBPeripheralDelegate>

@property(nonatomic,copy)NSString * name;
/*kCBAdvDataManufacturerData*/
@property(nonatomic,copy)NSString * macAddess;
@property(nonatomic,copy)NSString * RSSI;
@property(nonatomic,copy)NSString * identifierUUIDString;

@property(nonatomic,strong,readonly)CBPeripheral * cbPeripheral;

@property(nonatomic,strong,readonly)NSArray<CBCharacteristic*> * __nullable foundCharacteristics;
 
@property(nonatomic,weak)id<HLBTDeviceDelegate>delegate;

@property(nonatomic,weak)id<HLBTFilterRulesProtocol>filterRulesDelegate;

- (instancetype)initWithPeriphral:(CBPeripheral*__nonnull)peripheal;
- (void)connect;
- (void)disconnect;
- (void)writeData:(NSData*__nonnull)data writeCharacteristicWithUUIDStr:(NSString*__nonnull)wuuid;
- (CBCharacteristic*__nullable)getCharacteristicWithUUIDStr:(NSString*__nonnull)wuuid;
- (void)addNotificationCharacteristicWithUUID:(NSArray*__nonnull)uuids;
- (void)cancelNotificationCharacteristicWithUUID:(NSArray*__nonnull)uuids;
 
@end

NS_ASSUME_NONNULL_END
