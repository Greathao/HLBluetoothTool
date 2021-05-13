//
//  HLBTCentralMgr.m
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import "HLBTCentralMgr.h"

@interface HLBTCentralMgr ()

@property(nonatomic,strong,readwrite)CBCentralManager * cbCentralManager;
@property(nonatomic,strong,readwrite)HLBTFilter * btfilter;
///发现的设备数
@property(nonatomic,strong,readwrite)NSMutableArray<CBPeripheral*> * __nullable discoverPeripherals;

///连接的设备数量
@property(nonatomic,strong)NSMutableArray * connectedPeripherals;

@property(nonatomic,strong)NSDictionary<HLBTScanAfterFilterConfigKey,id>* afterFilterDic;

@end

@implementation HLBTCentralMgr

- (instancetype)init
{
    self = [super init];
    if (self) {
//                NSDictionary * options = @{
                    
//                    CBCentralManagerOptionShowPowerAlertKey:@YES,
//
//                    CBCentralManagerOptionRestoreIdentifierKey:@"HLBluetoothRestore",
//                   /*如果建立了一个成功的连接，此时 APP 进入 suspended 状态时，如果你想要系统为给定 Peripheral 显示一个弹框，你可以在 options 选项中包含这个键。*/
//                    CBConnectPeripheralOptionNotifyOnNotificationKey:@YES,
//                    /*如果发生了 disconnection 事件，此时 APP 进入 suspended 状态时，如果你想要系统为给定 Peripheral 显示一个弹框，你可以在 options 选项中包含这个键。*/
//                    CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES
//                };
//                dispatch_queue_t queue = dispatch_queue_create("com.HLBTCentralMgr.cn", DISPATCH_QUEUE_CONCURRENT);
        
        self.cbCentralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
        self.btfilter = [[HLBTFilter alloc]init];
        
        self.discoverPeripherals = [NSMutableArray arrayWithCapacity:1];
        self.connectedPeripherals = [NSMutableArray arrayWithCapacity:1];
        self.searchSec = MAXFLOAT;
    }
    return self;
}
#pragma -mark public
- (void)startScan
{
    if (self.cbCentralManager.state!=CBCentralManagerStatePoweredOn){ NSLog(@"设备不支持蓝牙或未开启"); return;}
    if (self.cbCentralManager.isScanning){NSLog(@"当前正在扫描中"); return;}

    self.btfilter.filterRulesDelegate = self.filterRulesDelegate;
    
    self.afterFilterDic = [_btfilter getAfterFilterConfig];
   
    [self beginScaning:[self parseFilterParameter]];
    
}
- (void)cancelScan
{
    [self.cbCentralManager stopScan];
    if ([self.delegate respondsToSelector:@selector(centralManagerSearchEndResbons:discoverPeripherals:)]){
        [self.delegate centralManagerSearchEndResbons:HLBTScanEndReasonInitiative discoverPeripherals:self.discoverPeripherals];
    }
}

- (void)connectPeripheral:(CBPeripheral * __nonnull)peripheral
{
    
    [self stopScanAndDeallocScanThreadAndNotifDelegateWhy:HLBTScanEndReasonConnect];
    [self.cbCentralManager connectPeripheral:peripheral options:nil];
}
- (void)cancelConnection:(CBPeripheral * __nonnull)peripheral
{
    [self.cbCentralManager cancelPeripheralConnection:peripheral];
}

- (void)cancelAllConnection
{
    for (int i=0;i<self.connectedPeripherals.count;i++) {
        [self.cbCentralManager cancelPeripheralConnection:self.connectedPeripherals[i]];
    }
}

- ( NSArray<CBPeripheral*>* __nullable )getConnectedPeripherals{
    return self.connectedPeripherals.copy;
}
- ( CBPeripheral* __nullable )getConnectedPeripheral:(NSString*)peripheralName{
    for (CBPeripheral * peripheral in self.connectedPeripherals) {
        if ([peripheral.name isEqualToString:peripheralName]) {
            return peripheral;
        }
    }
    return nil;
}

#pragma -mark private

- (NSArray<CBUUID*>*_Nullable)parseFilterParameter{
    return [self.btfilter parseFilterServersUUIDParameter];
}

- (void)beginScaning:(NSArray<CBUUID*>*__nullable)arr{
    NSLog(@"扫描中----");
    [self.cbCentralManager scanForPeripheralsWithServices:arr options:nil];
    ///扫描时长
    [self performSelector:@selector(searchTimeOut) withObject:nil afterDelay:self.searchSec];
    
    if (![[NSThread currentThread]isMainThread]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:self.searchSec]];
        
    }
}
///停止扫描 并停止取消监听扫描的常驻线程  并告知外界原因
-(void)stopScanAndDeallocScanThreadAndNotifDelegateWhy:(HLBTScanEndReason)why {
    
    if (self.cbCentralManager.isScanning) {
        [self.cbCentralManager  stopScan];
        if ([self.delegate respondsToSelector:@selector(centralManagerSearchEndResbons:discoverPeripherals:)]){
            [self.delegate centralManagerSearchEndResbons:why discoverPeripherals:self.discoverPeripherals];
        }
        NSLog(@"扫描结束\n当前central状态：%d \n 原因：%ld \n 找到了的设备数%@",self.cbCentralManager.isScanning,(long)why,self.discoverPeripherals);
     }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchTimeOut) object:nil];
 }

- (void)searchTimeOut{
    //没发现此设备
    [self stopScanAndDeallocScanThreadAndNotifDelegateWhy:HLBTScanEndReasonTimeOut];
    //    NSLog(@"在线程:%@\n搜索了%f后结束 \n找到了的设备数：%@",[NSThread currentThread],self.searchSec,self.discoverPeripherals) ;
}
- (void)addDiscoverPeripherals:(CBPeripheral *)peripheral{
    if (![self.discoverPeripherals containsObject:peripheral]) {
        for (CBPeripheral * periph in self.discoverPeripherals) {
            if ([periph.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                return;
            }
        }
         [self.discoverPeripherals addObject:peripheral];
    }
}
- (void)addConnectedPeripheral:(CBPeripheral *)peripheral {
    if (![self.connectedPeripherals containsObject:peripheral]) {
        for (CBPeripheral * periph in self.discoverPeripherals) {
            if ([periph.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                return;
            }
        }
         [self.connectedPeripherals addObject:peripheral];
    }
}
- (void)deleteConnectedPeripheral:(CBPeripheral *)peripheral{
    if ([self.connectedPeripherals containsObject:peripheral]) {
        for (CBPeripheral * periph in self.discoverPeripherals) {
            if ([periph.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                [self.connectedPeripherals removeObject:peripheral];
                 return;
            }
        }
        [self.connectedPeripherals removeObject:peripheral];
        
    }
}


#pragma -mark CBCentralManagerDelegate
///扫描到的设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"：%@%@%@",peripheral.name , RSSI,advertisementData);
    if (![_btfilter isfilterRules:self.afterFilterDic didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI]) {
        return;
    }
    [self addDiscoverPeripherals:peripheral];
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didDiscoverDeviceInfo:)]){
        [self.delegate centralManager:self didDiscoverDeviceInfo:@{
            HLBTDeviceInfoCBPeripheral:peripheral,
            HLBTDeviceInfoNSDictAdvertisementData:advertisementData,
            HLBTDeviceInfoNSNumberRSSI:RSSI
        }];
    }
}
///连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功%@",peripheral.name);
    [self addConnectedPeripheral:peripheral];
    if ([self.delegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
        [self.delegate centralManager:self didConnectPeripheral:peripheral];
    }
}
///连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"连接失败%@",error.localizedDescription);
    if ([self.delegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        [self.delegate centralManager:self didFailToConnectPeripheral:peripheral error:error];
    }
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if (error) {
        NSLog(@"连接断开原因：%@",[error localizedDescription]);
    }
    [self deleteConnectedPeripheral:peripheral];
    
    if ([self.delegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
        [self.delegate centralManager:self didDisconnectPeripheral:peripheral error:error];
    }
    
}


//- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict;{
//    NSLog(@"%@",dict);
//}


///监听手机蓝牙硬件状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
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
    NSLog(@"%@",stateStr);
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(centralManagerDidUpdateState:)]) {
        [self.delegate centralManagerDidUpdateState:central];
    }
    
}



@end
