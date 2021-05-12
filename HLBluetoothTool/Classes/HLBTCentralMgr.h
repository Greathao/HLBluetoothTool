//
//  HLBTCentralMgr.h
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLBTDefine.h"
#import "HLBTFilterRulesProtocol.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HLBTFilter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HLBTCentralMgrDelegate <NSObject>

@required
///时时监听手机蓝牙硬件状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;

@optional
///扫描到的外设
- (void)centralManager:(HLBTCentralMgr *)central didDiscoverDeviceInfo:(NSDictionary<HLBTDeviceInfoKey,id>*)deviceInfo;
///连接成功
- (void)centralManager:(HLBTCentralMgr *)central didConnectPeripheral:(CBPeripheral *)peripheral;
///连接失败
- (void)centralManager:(HLBTCentralMgr *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
///连接断开
- (void)centralManager:(HLBTCentralMgr *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
///扫描结束超时未找到
- (void)centralManagerSearchEndResbons:(HLBTScanEndReason) resobs discoverPeripherals:(NSArray<CBPeripheral*> *)discoverPeripherals;
 
@end
 
@interface HLBTCentralMgr : NSObject<CBCentralManagerDelegate>

@property (nonatomic,strong,readonly) CBCentralManager * cbCentralManager;
@property(nonatomic,strong,readonly)  HLBTFilter * btfilter;
///发现的设备数量
@property (nonatomic,strong,readonly) NSMutableArray<CBPeripheral*> * __nullable discoverPeripherals;
@property (nonatomic,weak) id<HLBTCentralMgrDelegate> delegate;
@property (nonatomic,weak) id<HLBTFilterRulesProtocol> filterRulesDelegate;
///扫描时长 默认：最大
@property(nonatomic,assign)NSTimeInterval searchSec;

- (void)startScan;
- (void)cancelScan;
- (void)connectPeripheral:(CBPeripheral * __nonnull)peripheral;
- (void)cancelConnection:(CBPeripheral * __nonnull)peripheral;
- (void)cancelAllConnection;

- (NSArray<CBPeripheral*>* __nullable)getConnectedPeripherals;
- (CBPeripheral* __nullable )getConnectedPeripheral:(NSString*)peripheralName;
 
@end

NS_ASSUME_NONNULL_END
