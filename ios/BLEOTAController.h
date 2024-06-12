//
//  OTAController.h
//  iBridge
//
//  Created by 邱文庆 on 2018/3/13.
//  Copyright © 2018年 IVT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BLEOTADelegate <NSObject>

enum {
    OTA_STATE_IDLE = 0, 
    OTA_STATE_STARTING, //start command sent
    OTA_STATE_STARTED,  //ack of start received, parameter is total length of firmware
    OTA_STATE_DATAING,  //parameter is sent data length of firmware
    OTA_STATE_COMPLETED //parameter is OTA_SUCCESS for success
};

enum {
    OTA_SUCCESS = 0,
    OTA_ERR_CHECK_SUM_FAIL,
    OTA_ERR_OTHER
};

- (void)ota_send_data:(NSData *)pkt;
- (void)ota_state:(unsigned char)state parameter:(long long)param;

@end

@interface BLEOTAController :NSObject

- (void)start:(long)total_length;
- (void)data:(NSData *)data index:(long)index;
- (void)end:(unsigned char)error;
- (void)pkt_received:(NSData *)pkt;

- (void)download_firmware_from_url:(NSString *)url_string;

@property(weak,nonatomic) id<BLEOTADelegate> delegate;

@end
