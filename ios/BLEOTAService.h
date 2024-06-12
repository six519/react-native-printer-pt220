//
//  BLEOTAService.h
//  iBridgeLib
//
//  Created by qiuwenqing on 15/11/17.
//  Copyright © 2015年 BRT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEService.h"

@class CBPeripheral;
@class CBCharacteristic;
@class BLEOTAService;

@protocol BLEOTAServiceDelegate <NSObject>

#pragma mark - BLEOTAServiceDelegate

#pragma mark 启动服务的结果,调用start之后会产生此事件
- (void)bleOtaService:(nonnull BLEOTAService *)bleOtaService didStart:(BOOL)result;

#pragma mark 接收数据
- (void)bleOtaService:(nonnull BLEOTAService *)bleOtaService didPktReceived:(nonnull NSData *)pkt;

@end

@interface BLEOTAService : BLEService

#pragma mark - 公用方法

#pragma mark 启动服务
#pragma mark 在连接成功之后(didDisconnectPeripheral)才能调用
#pragma mark 会触发didStart
- (BOOL)start:(nonnull CBPeripheral *)peripheral;

#pragma mark 停止服务
- (void)stop;

#pragma mark 写OTA数据
- (void)writePkt:(nonnull NSData *)pkt;

#pragma mark 

#pragma mark - 公用属性
@property(weak,nonatomic) id<BLEOTAServiceDelegate> delegate;

@end
