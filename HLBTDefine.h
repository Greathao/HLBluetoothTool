//
//  HLBluetoothDefine.h
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

typedef NSString *  HLBTScanAfterFilterConfigKey;

///外设name value :@[stringName1,stringName2]||@"stringName"
extern HLBTScanAfterFilterConfigKey const HLBTScanAfterFilterPeripheralName;
///信号强度  理想状态为0  但在实际中基本不会存在这个理想状态  因为在理想状态，所发射的功率全部被接收时RSSI的值为0，那么在同等环境下，我们可以认为接收到-20dbm信号值的强度大于接收到-50dbm信号值的强度 具体值自行判断
// value: 只支持sting 例如： @"-60"  小于 -60 的设备就会被过滤掉
extern HLBTScanAfterFilterConfigKey const HLBTScanAfterFilterNumberRSSINotLess;
 
///由于硬件厂商可能将mac地址存在此 kCBAdvDataManufacturerData 作为广播
// value: 只支持sting 例如： @"xxxxxxxxxxxx" 具体看硬件厂商规则
extern HLBTScanAfterFilterConfigKey const HLBTScanAfterFilterkCBAdvDataManufacturerDataKey;
 
typedef NSString *  HLBTCharacteristicUUIDKey;
  
typedef NSString *  HLBTDeviceInfoKey;

extern HLBTDeviceInfoKey const HLBTDeviceInfoCBPeripheral;
extern HLBTDeviceInfoKey const HLBTDeviceInfoNSDictAdvertisementData;
extern HLBTDeviceInfoKey const HLBTDeviceInfoNSNumberRSSI;

@class HLBTCentralMgr;

typedef enum : NSInteger {
   /// 扫描时发现设备并未开启蓝牙 或不支持
    HLBTScanEndReasonOff = 101,
    ///扫描时等待用户去开启蓝牙 时间超时 还是未开启
    HLBTScanEndReasonWaitingOpenTimeOut,
    
    ///连接设备时触发的中断
    HLBTScanEndReasonConnect,
    ///设备到了规定的扫描时间
    HLBTScanEndReasonTimeOut,
    ///主动触发的中断 ：外界调用了cancelScan
    HLBTScanEndReasonInitiative
    
    
} HLBTScanEndReason;

