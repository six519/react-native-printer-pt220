#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PrinterPt220, NSObject)

RCT_EXTERN_METHOD(ptConnect:(NSString *)name
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(ptSetPrinter:(NSString *)cmd
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(ptPrintText:(NSString *)text
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(ptInit)

RCT_EXTERN_METHOD(ptGetDevices:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
