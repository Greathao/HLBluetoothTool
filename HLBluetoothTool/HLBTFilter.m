//
//  HLBTFilter.m
//  HLBLEDome
//
//  Created by liuhao on 2021/5/9.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import "HLBTFilter.h"

@implementation HLBTFilter

#pragma - mark public

- (NSArray<CBUUID*>*_Nullable)parseFilterServersUUIDParameter{
    if ([self.filterRulesDelegate respondsToSelector:@selector(centerManagerSetScanServersUUIDs)]) {
        NSArray<NSString*>* filterServiceUUIDs = [self.filterRulesDelegate centerManagerSetScanServersUUIDs];
        if (filterServiceUUIDs.count) {
            NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:1];
            for ( NSString * serversUUid in filterServiceUUIDs) {
                [tempArr addObject: [CBUUID UUIDWithString:serversUUid]];
            }
            return tempArr;
        }
    }
    return nil;
}
- (NSDictionary<HLBTScanAfterFilterConfigKey,id>*) getAfterFilterConfig{
    if ([self.filterRulesDelegate respondsToSelector:@selector(centerManagerSetScanAfterRules)]) {
        return [self.filterRulesDelegate centerManagerSetScanAfterRules];
    }
    return nil;
}
- (NSMutableArray<CBUUID*>*) getFilterCharacteristicUUIDs{
    NSMutableArray<CBUUID*>*uuids = [NSMutableArray arrayWithCapacity:1];
    if ([self.filterRulesDelegate respondsToSelector:@selector(peripheralCharacteristicProtocol)]) {
        NSArray *  arr  =  [self.filterRulesDelegate peripheralCharacteristicProtocol];
        for (NSString * uuid in arr) {
            [uuids addObject:[CBUUID UUIDWithString:uuid]];
        }
        return uuids;
    }
    return nil;
}
//- (NSDictionary<HLBTCharacteristicUUIDKey,NSArray <NSString*>*>*) getPeripheralC{
//    if ([self.filterRulesDelegate respondsToSelector:@selector(peripheralCharacteristicProtocol)]) {
//        NSDictionary<HLBTCharacteristicUUIDKey,NSArray <NSString*>*>* dic =  [self.filterRulesDelegate peripheralCharacteristicProtocol];
//}




///如过滤了需要跳出
-(BOOL)isfilterRules:(NSDictionary<HLBTScanAfterFilterConfigKey,id>*) scanAfterFilterDic didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (!scanAfterFilterDic||!scanAfterFilterDic.count) {
        return YES;
    }
    
    
    id name =  scanAfterFilterDic[HLBTScanAfterFilterPeripheralName];
    NSString * rssi = scanAfterFilterDic[HLBTScanAfterFilterNumberRSSINotLess];
    NSString * mac = scanAfterFilterDic[HLBTScanAfterFilterkCBAdvDataManufacturerDataKey];
    
    if ([self name:name RSSI:rssi AndMac:mac filterRulesDidDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI]) {
        return YES;
    }
    if ([self name:name RSSI:rssi filterRulesDidDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI]) {
        return YES;
    }
    
    if ([self RSSI:rssi mac:mac filterRulesDidDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI] ) {
        return YES;
    }
    
    if ([self name:name MAC:mac filterRulesDidDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI]) {
        return YES;
    }
    
    if ([self containsObject:name withPeripheralName:peripheral.name]) {
        return YES;
    }
    
    if ([self MAC:mac filterRulesDidDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI]) {
        return YES;
    }
    if ((RSSI.intValue > rssi.intValue)) {
        return YES;
    }
    
    return NO;
}


#pragma  - mark private 过滤具体策略

-(BOOL)containsObject:(id)name withPeripheralName:(NSString*)pname{
    if ([name isKindOfClass:[NSArray class]]) {
        NSArray * names = name;
        if ([names containsObject:pname]){
            return YES;
        };
    }
    if ([name isKindOfClass:[NSString class]]) {
        if ([name isEqualToString:pname]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)name:(NSString*)name RSSI:(NSString*)rssi AndMac:(NSString*)mac filterRulesDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (!name || !rssi || !mac) return NO;
    
    if ([self containsObject:name withPeripheralName:peripheral.name]
        &&(RSSI.intValue > rssi.intValue )
        && [[self.class convertDataToHexStr:advertisementData[HLBTScanAfterFilterkCBAdvDataManufacturerDataKey]] isEqualToString:mac]) {
        return YES;
    }
    return NO;
}

-(BOOL)name:(NSString*)name RSSI:(NSString*)rssi filterRulesDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if (!name || !rssi) return NO;
    if ([self containsObject:name withPeripheralName:peripheral.name]
        &&(RSSI.intValue > rssi.intValue))
    {
        return YES;
    }
    return NO;
}

-(BOOL)RSSI:(NSString*)rssi mac:(NSString*)mac filterRulesDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (!rssi || !mac)return NO;
    if((RSSI.intValue > rssi.intValue )
       && [[self.class convertDataToHexStr:advertisementData[HLBTScanAfterFilterkCBAdvDataManufacturerDataKey]] isEqualToString:mac])
    {
        return YES;
    }
    return NO;
}

-(BOOL)name:(NSString*)name MAC:(NSString*)mac filterRulesDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if (!name || !mac) return NO ;
    if ([[self.class convertDataToHexStr: advertisementData[HLBTScanAfterFilterkCBAdvDataManufacturerDataKey]] isEqualToString:mac]
        &&[self containsObject:name withPeripheralName:peripheral.name]) {
        return YES;
    }
    return NO;
}

-(BOOL) MAC:(NSString*) mac filterRulesDidDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (!mac || !advertisementData[HLBTScanAfterFilterkCBAdvDataManufacturerDataKey]) return NO;
    NSData * data = advertisementData[HLBTScanAfterFilterkCBAdvDataManufacturerDataKey];
    NSString * hexStr = [self.class convertDataToHexStr:data];
    if ([hexStr isEqualToString:mac]) {
        return YES;
    }
    return NO;
}

// 将NSData转换成十六进制的字符串
+ (NSString *)convertDataToHexStr:(NSData *)data;
 {
    
    if (!data || [data length] == 0) {
        return nil;
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}



@end
