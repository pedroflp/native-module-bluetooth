//
//  BluetoothModule.m
//  bluetooth
//
//  Created by Pedro Felipe on 09/01/24.
//

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(Bluetooth,NSObject)

RCT_EXTERN_METHOD(startScan)
RCT_EXTERN_METHOD(stopScan)
RCT_EXTERN_METHOD(connectPeripheral:(NSString)peripheralIdentifier)

@end

