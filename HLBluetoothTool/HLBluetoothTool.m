//
//  HLBluetoothTool.m
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import "HLBluetoothTool.h"
#import "HLBTCentralMgr.h"
#import "HLBTFilter.h"
static NSTimeInterval defaultScanTime = 1;
static NSTimeInterval defaultPingTime = 5;

@interface HLBluetoothTool ()<HLBTCentralMgrDelegate,HLBTDeviceDelegate>
@property(nonatomic,strong)HLBTCentralMgr * centerManager;
@property(nonatomic,strong)dispatch_source_t pingTimer;
@property(nonatomic,strong,readwrite)NSMutableArray<HLBTDevice*> * __nullable discoverPeripherals;
@property(nonatomic,strong,readwrite)NSMutableArray<HLBTDevice*> * __nullable connectPeripherals;

@end

@implementation HLBluetoothTool
static HLBluetoothTool * blueTooth = nil;
+(HLBluetoothTool*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blueTooth = [[HLBluetoothTool alloc]init];
        [blueTooth Initialize];
    });
    return  blueTooth;
}
-(void)Initialize{
    _centerManager = [[HLBTCentralMgr alloc]init];
    _centerManager.delegate = self;
    _scanSeconds = defaultScanTime;
    _pingBTStateSeconds = defaultPingTime;
    _discoverPeripherals = [NSMutableArray arrayWithCapacity:1];
    _connectPeripherals = [NSMutableArray arrayWithCapacity:1];
}

#pragma - mark public

-(void)beginScan{
    _centerManager.searchSec = self.scanSeconds;
    _centerManager.filterRulesDelegate = self.filterDelegate;
    if (_pingTimer!=nil) {
        return;
    }
    
    if (_centerManager.cbCentralManager.state!=CBManagerStatePoweredOn&&!self.pingBTStateSeconds) {
        if ([self.delegate respondsToSelector:@selector(btToolScanEndResbonsWithDevice:why:)]) {
            [self.delegate btToolScanEndResbonsWithDevice:nil why:HLBTScanEndReasonOff];
        }
        return;
    }
    
    __weak typeof(self)weakSelf = self;
    
    [self pingBTStateOnResbons:^{
        __strong typeof(weakSelf) strongWeak = weakSelf;
        NSLog(@"%@",[NSThread currentThread]);
       
        [strongWeak.centerManager startScan];
    } everySecond:self.pingBTStateSeconds];
}
-(void)stopScan{
    
    [_centerManager cancelScan];
    if (self.pingTimer) {
        dispatch_source_cancel(self.pingTimer);
    }
}
 
- (void)writeData:(NSData*__nonnull)data btDevice:(HLBTDevice*__nonnull)device characteristicUUIDStr:(NSString*__nonnull)uuid;{
    [device writeData:data writeCharacteristicWithUUIDStr:uuid];
}

- (void)cancelConnection:(HLBTDevice *)peripheral{
    [_centerManager cancelConnection:peripheral.cbPeripheral];
}
 
- (void)cancelAllConnection{
    [_centerManager cancelAllConnection];
}

#pragma - mark private

-(void)pingBTStateOnResbons:(void(^)(void))BTStateOnResbons everySecond:(NSTimeInterval)second{
    if (_centerManager.cbCentralManager.state==CBManagerStatePoweredOn) {
        if (BTStateOnResbons) {
            BTStateOnResbons();
        }
        return;
    }
    __block NSTimeInterval runtimeIndex = 0;
    _pingTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(_pingTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.0);
    dispatch_source_set_event_handler(_pingTimer, ^{
        if (self->_centerManager.cbCentralManager.state==CBManagerStatePoweredOn) {
            dispatch_source_cancel(self->_pingTimer);
            self->_pingTimer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (BTStateOnResbons) {
                    BTStateOnResbons();
                }
            });
            return;
        }
        if (runtimeIndex == second) {
            dispatch_source_cancel(self->_pingTimer);
            self->_pingTimer = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(btToolScanEndResbonsWithDevice:why:)]) {
                    [self.delegate btToolScanEndResbonsWithDevice:nil why:HLBTScanEndReasonWaitingOpenTimeOut];
                }
             });
         }
        runtimeIndex++;
        NSLog(@"timer date 1== %@",[NSDate date]);
        
        if ([self.delegate respondsToSelector:@selector(btToolPingBTStatusTimeCountdown:)]) {
            [self.delegate btToolPingBTStatusTimeCountdown:second - runtimeIndex];
        }
        
    });
    dispatch_resume(_pingTimer);
}

- (void)addDiscoverPeripherals:(HLBTDevice *)device{
    if (![self.discoverPeripherals containsObject:device]) {
        for (HLBTDevice * devic in self.discoverPeripherals) {
            if ([devic.identifierUUIDString isEqualToString:device.identifierUUIDString]) {
                return;
            }
        }
        [self.discoverPeripherals addObject:device];
    }
}

- (void)addConnectPeripherals:(HLBTDevice *)device{
    if (![self.connectPeripherals containsObject:device]) {
        for (HLBTDevice * devic in self.connectPeripherals) {
            if ([devic.identifierUUIDString isEqualToString:device.identifierUUIDString]) {
                return;
            }
        }
        [self.connectPeripherals addObject:device];
    }
}
- (void)removeConnectPeripheral:(HLBTDevice*)device{
    if ([self.connectPeripherals containsObject:device]) {
        for (HLBTDevice * devic in self.connectPeripherals) {
            if ([devic.identifierUUIDString isEqualToString:device.identifierUUIDString]) {
                [self.connectPeripherals removeObject:device];
                return;
            }
        }
        [self.connectPeripherals removeObject:device];
    }
}
- (HLBTDevice*)getDeviceWithPeripheral:(CBPeripheral*)peripheral{
    for (HLBTDevice * device in self.discoverPeripherals) {
        if ([peripheral isEqual:device.cbPeripheral]) {
            return device;
        }
    }
    for (HLBTDevice * device in self.connectPeripherals) {
        if ([peripheral isEqual:device.cbPeripheral]) {
            return device;
        }
    }
    return nil;
}

#pragma - mark HLBTCentralMgrDelegate

///扫描到的外设
- (void)centralManager:(HLBTCentralMgr *)central didDiscoverDeviceInfo:(NSDictionary<HLBTDeviceInfoKey,id>*)deviceInfo{
    HLBTDevice * device = [[HLBTDevice alloc]initWithPeriphral:deviceInfo[HLBTDeviceInfoCBPeripheral]];
    device.delegate = self;
    NSDictionary<NSString *, id> * advertisementData = deviceInfo[HLBTDeviceInfoNSDictAdvertisementData];
    device.macAddess = [HLBTFilter convertDataToHexStr:advertisementData[@"kCBAdvDataManufacturerData"]];
    device.RSSI = [deviceInfo[HLBTDeviceInfoNSNumberRSSI] stringValue];
    [self addDiscoverPeripherals:device];
    if ([self.delegate respondsToSelector:@selector(btToolScanResbonsWithDevice:)]) {
        [self.delegate btToolScanResbonsWithDevice:self.discoverPeripherals];
    }
}

///连接成功
- (void)centralManager:(HLBTCentralMgr *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    HLBTDevice * device = [self getDeviceWithPeripheral:peripheral];
    device.filterRulesDelegate = self.filterDelegate;
    [self addConnectPeripherals:device];
    peripheral.delegate = device;
    if ([self.delegate respondsToSelector:@selector(btToolIsConnected:withDevice:)]) {
        [self.delegate btToolIsConnected:YES withDevice:device];
    }
    [peripheral discoverServices:[central.btfilter parseFilterServersUUIDParameter]];
    
}
///连接失败
- (void)centralManager:(HLBTCentralMgr *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    HLBTDevice * device = [self getDeviceWithPeripheral:peripheral];
    
    if ([self.delegate respondsToSelector:@selector(btToolIsConnected:withDevice:)]) {
        [self.delegate btToolIsConnected:NO withDevice:device];
    }
}
///连接断开
- (void)centralManager:(HLBTCentralMgr *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;{
    HLBTDevice * device = [self getDeviceWithPeripheral:peripheral];
    [self removeConnectPeripheral:device];
    if ([self.delegate respondsToSelector:@selector(btToolDisconnected:error:)]) {
        [self.delegate btToolDisconnected:device error:error];
    }
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    NSString * stateStr = @"未知";
    switch (central.state) {
        case CBManagerStateUnknown:
            stateStr = @"未知";
            //未知状态
            break;
        case CBManagerStateResetting:
            stateStr = @"蓝牙重置中";
            //蓝牙重置中
            break;
        case CBManagerStateUnsupported:
            stateStr = @"不支持蓝牙";
            //蓝牙不支持
            break;
        case CBManagerStateUnauthorized:
            stateStr = @"没有权限";
            //没有权限
            break;
        case CBManagerStatePoweredOff:
            stateStr = @"蓝牙未开启";
            
            
            //蓝牙未开启
            break;
        case CBManagerStatePoweredOn:
            stateStr = @"蓝牙已启用";
            //蓝牙已开启
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(BTState:describe:)]) {
        [self.delegate BTState:central.state == CBManagerStatePoweredOn describe:stateStr];
    }
}

///扫描结束
- (void)centralManagerSearchEndResbons:(HLBTScanEndReason) resobs discoverPeripherals:(NSArray<CBPeripheral*> *)discoverPeripherals;{
    if ([self.delegate respondsToSelector:@selector(btToolScanEndResbonsWithDevice:why:)]) {
        [self.delegate btToolScanEndResbonsWithDevice: self.discoverPeripherals why:resobs];
    }
}
 

#pragma - mark HLBTDeviceDelegate

///给设备提供中央
-(HLBTCentralMgr*)BTDeviceGetBTCentralManager{
    return  self.centerManager;
}

-(void)btDevice:(HLBTDevice*)device didDiscoverCharacteristics:(NSArray<CBCharacteristic*>* )characteristic error:(nullable NSError *)error{
    if ([self.delegate respondsToSelector:@selector(btToolDiscoverCharacteristicsEndWithDevice:error:)]) {
        [self.delegate btToolDiscoverCharacteristicsEndWithDevice:device error:error];
    }
}

-(void)btDevice:(HLBTDevice*)device didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(btToolDidWriteValuefromDevice:characteristicUUIDsString:error: )]) {
        [self.delegate btToolDidWriteValuefromDevice:device characteristicUUIDsString:characteristic.UUID.UUIDString error:error];
    }
}
-(void)btDevice:(HLBTDevice*)device didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(btToolDidUpdateFrom:characteristicUUIDsString:value:error:)]) {
        [self.delegate btToolDidUpdateFrom:device characteristicUUIDsString:characteristic.UUID.UUIDString value:characteristic.value error:error];
    }
}

///订阅响应
-(void)btDevice:(HLBTDevice*)device didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"订阅失败\nUUID:%@",characteristic.UUID.UUIDString);

        NSLog(@"%@",error);
    }
    if (characteristic.isNotifying) {
        NSLog(@"订阅成功\nUUID:%@",characteristic.UUID.UUIDString);
    } else {
        NSLog(@"取消订阅\nUUID:%@",characteristic.UUID.UUIDString);
    }
    if ([self.delegate respondsToSelector:@selector(btToolNotificationStatefromDevice:characteristicUUIDsString:error:)]) {
        [self.delegate btToolNotificationStatefromDevice:device characteristicUUIDsString:characteristic.UUID.UUIDString error:error];
    }
}
-(void)btDevice:(HLBTDevice*)device didDiscoverServices:(NSError *)error;
{
    if ([self.delegate respondsToSelector:@selector(btToolDiscoverServicesWithDevice:error:)]) {
        [self.delegate btToolDiscoverServicesWithDevice:device error:error];
    }
    
}

@end
