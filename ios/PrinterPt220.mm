#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(PrinterPt220, NSObject)

RCT_EXTERN_METHOD(ptConnect:(NSString *)address
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(ptSetPrinter:(NSString *)command
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(ptPrintText:(NSString *)text
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
