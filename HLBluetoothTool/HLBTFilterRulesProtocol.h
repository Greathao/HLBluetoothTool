//
//  HLBTFilterRulesProtocol.h
//  HLBLEDome
//
//  Created by liuhao on 2021/5/7.
//  Copyright © 2021 Beijing Mr Hi Network Technology Company Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLBTDefine.h"
NS_ASSUME_NONNULL_BEGIN

@protocol HLBTFilterRulesProtocol <NSObject>

@optional
 
///设置发现外设前的过滤条件 服务UUIDs:[CBUUID UUIDWithString:xxxx]
- (NSArray<NSString*>*)centerManagerSetScanServersUUIDs;

///设置发现外设后的筛选条件
- (NSDictionary<HLBTScanAfterFilterConfigKey,id>*)centerManagerSetScanAfterRules;
 
///过滤外设特征uuid
- (NSArray <NSString*>*)peripheralCharacteristicProtocol;

 

@end

NS_ASSUME_NONNULL_END
