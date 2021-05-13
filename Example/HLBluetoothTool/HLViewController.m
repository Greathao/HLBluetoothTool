//
//  HLViewController.m
//  HLBluetoothTool
//
//  Created by Greathao on 05/12/2021.
//  Copyright (c) 2021 Greathao. All rights reserved.
//

#import "HLViewController.h"
#import <HLBluetoothTool/HLBluetoothTool.h>
@interface HLViewController ()<HLBTToolDelegate,HLBTFilterRulesProtocol,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView * tabView;
@property(nonatomic,strong)NSMutableArray * dataSource;
@end

@implementation HLViewController
static NSString *const tabViewCellID = @"tabViewcellID";
 
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    [HLBluetoothTool sharedInstance].filterDelegate = self;
    [HLBluetoothTool sharedInstance].delegate = self;
}

-(void)setupUI{
    [self addSearchitem];
    [self addTabView];
}

-(void)searchBLE{
    [[HLBluetoothTool sharedInstance] beginScan];
}

# pragma  - mark HLBTFilterRulesProtocol 添加过滤规则
//设置发现外设前的过滤条件 服务UUIDs:[CBUUID UUIDWithString:xxxx]
//- (NSArray<NSString*>*)centerManagerSetScanServersUUIDs{
//    return <#expression#>;
//}

/////设置发现外设后的筛选条件
//- (NSDictionary<HLBTScanAfterFilterConfigKey,id>*)centerManagerSetScanAfterRules{
//    return @{HLBTScanAfterFilterkCBAdvDataManufacturerDataKey:@"3412186000db513bca4a"};
//}

///过滤外设特征uuid
//- (NSArray <NSString*>*)peripheralCharacteristicProtocol{
//
//}

# pragma  - mark HLBTToolDelegate 回调响应
/// 时时响应扫描过程中的结果
/// @param devices 扫描到的设备
- (void)btToolScanResbonsWithDevice:(NSArray<HLBTDevice *> *__nullable)devices{
    self.dataSource = [NSMutableArray arrayWithArray:devices];
    [self.tabView reloadData];
}

/// 扫描结束后的响应
/// @param devices 扫描到的设备
/// @param reason 停止扫描的原因
- (void)btToolScanEndResbonsWithDevice:(NSArray<HLBTDevice *> *__nullable)devices why:(HLBTScanEndReason)reason{
  
}

/// 设备连接状态响应 成功/失败
/// @param isConnected 成功/失败
/// @param device 连接的设备实体
- (void)btToolIsConnected:(BOOL)isConnected withDevice:(HLBTDevice *)device{
    
}

/// 设备扫描服务的响应
/// @param device 设备
/// @param error 错误
- (void)btToolDiscoverServicesWithDevice:(HLBTDevice*)device error:(NSError *)error{
    
}

/// 扫描完设备特征之后的响应
/// @param device 设备
/// @param error 错误
- (void)btToolDiscoverCharacteristicsEndWithDevice:(HLBTDevice*)device error:(NSError *)error{
    
}

/// 订阅消息的响应
/// @param device 设备
/// @param uuidStr 特征标识
/// @param error  错误
- (void)btToolNotificationStatefromDevice:(HLBTDevice*)device characteristicUUIDsString:(NSString*)uuidStr error:(NSError *)error{
    
}

/// 当写入为它的时候可用此检测是否写入成功
/// CBCharacteristicWriteWithResponse:
/// @param device 设备
/// @param uuidStr 特征标识
/// @param error 错误
- (void)btToolDidWriteValuefromDevice:(HLBTDevice*)device characteristicUUIDsString:(NSString*)uuidStr error:(NSError *)error{
    
}


/// 设备连接后 断开的响应
/// @param device 断开的设备实体
/// @param error 错误信息
- (void)btToolDisconnected:(HLBTDevice *)device error:(nullable NSError *)error{
    
}

/// 收到外设来的消息
/// @param device 设备
/// @param uuidStr 特征标识
/// @param data 内容
/// @param error 错误
- (void)btToolDidUpdateFrom:(HLBTDevice*)device characteristicUUIDsString:(NSString*)uuidStr value:(NSData*)data error:(NSError *)error{
    
}


/// ping 倒计时 次数
/// @param sec miao
- (void)btToolPingBTStatusTimeCountdown:(NSTimeInterval)sec{
    
}
/// 监听手机硬件信息
/// @param isOn 好的/坏的
/// @param des 原因
- (void)BTState:(BOOL)isOn describe:(NSString*)des{
    
}


 


#pragma  - mark UITableViewDelegate/UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tabViewCellID];;
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tabViewCellID];
     }
    
    HLBTDevice * device = self.dataSource [indexPath.row];
    
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"kCBAdvDataManufacturerData:%@\nidentifierUUIDString:\n%@\n", device.macAddess,device.identifierUUIDString]  ;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n 信号:%@",device.name,device.RSSI];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  120;
}


#pragma  - mark subViews
-(void)addTabView{
    _tabView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _tabView.delegate = self;
    _tabView.dataSource = self;
    [self.view addSubview:_tabView];
 }

-(void)addSearchitem{
    UIBarButtonItem * item = [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(searchBLE)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma -mark getter
-(NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc]initWithCapacity:1];
    }
    return _dataSource;
}

@end
