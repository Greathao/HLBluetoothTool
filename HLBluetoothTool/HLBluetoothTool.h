//
//  HLBluetoothTool.h
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLBTFilterRulesProtocol.h"
#import "HLBTDevice.h"

NS_ASSUME_NONNULL_BEGIN
 
@protocol HLBTToolDelegate <NSObject>

@optional
 
/// 时时响应扫描过程中的结果
/// @param devices 扫描到的设备
- (void)btToolScanResbonsWithDevice:(NSArray<HLBTDevice *> *__nullable)devices;
 
/// 扫描结束后的响应
/// @param devices 扫描到的设备
/// @param reason 停止扫描的原因
- (void)btToolScanEndResbonsWithDevice:(NSArray<HLBTDevice *> *__nullable)devices why:(HLBTScanEndReason)reason;
  
/// 设备连接状态响应 成功/失败
/// @param isConnected 成功/失败
/// @param device 连接的设备实体
- (void)btToolIsConnected:(BOOL)isConnected withDevice:(HLBTDevice *)device;

/// 扫描完设备特征之后的响应
/// @param device 设备
- (void)btToolDiscoverCharacteristicsEndWithDevice:(HLBTDevice*)device;
 
/// 订阅消息的响应
/// @param device 设备
/// @param uuidStr 特征标识
/// @param error  错误
- (void)btToolNotificationStatefromDevice:(HLBTDevice*)device characteristicUUIDsString:(NSString*)uuidStr error:(NSError *)error;


/// 当写入为它的时候可用此检测是否写入成功
/// CBCharacteristicWriteWithResponse:
/// @param device 设备
/// @param uuidStr 特征标识
/// @param error 错误
- (void)btToolDidWriteValuefromDevice:(HLBTDevice*)device characteristicUUIDsString:(NSString*)uuidStr error:(NSError *)error;

 
/// 设备连接后 断开的响应
/// @param device 断开的设备实体
/// @param error 错误信息
- (void)btToolDisconnected:(HLBTDevice *)device error:(nullable NSError *)error;
 
/// 收到外设来的消息
/// @param device 设备
/// @param uuidStr 特征标识
/// @param data 内容
/// @param error 错误
- (void)btToolDidUpdateFrom:(HLBTDevice*)device characteristicUUIDsString:(NSString*)uuidStr value:(NSData*)data error:(NSError *)error;


/// ping 倒计时 次数
/// @param sec miao
- (void)btToolPingBTStatusTimeCountdown:(NSTimeInterval)sec;
/// 监听手机硬件信息
/// @param isOn 好的/坏的
/// @param des 原因
- (void)BTState:(BOOL)isOn describe:(NSString*)des;

@end

@interface HLBluetoothTool : NSObject

@property(nonatomic,weak)id<HLBTFilterRulesProtocol>filterDelegate;

@property(nonatomic,strong,readonly)NSMutableArray<HLBTDevice*> * __nullable connectPeripherals;

@property(nonatomic,weak)id<HLBTToolDelegate>delegate;
///扫描时长
@property(nonatomic,assign)NSTimeInterval scanSeconds;
///等待用户开启蓝牙时长
@property(nonatomic,assign)NSTimeInterval pingBTStateSeconds;
 
+ (HLBluetoothTool*)sharedInstance;

- (void)beginScan;

- (void)stopScan;
 
- (void)writeData:(NSData*__nonnull)data btDevice:(HLBTDevice*__nonnull)device characteristicUUIDStr:(NSString*__nonnull)uuid;
 
- (void)cancelConnection:(HLBTDevice *__nonnull)peripheral;
 
- (void)cancelAllConnection;


@end

NS_ASSUME_NONNULL_END
