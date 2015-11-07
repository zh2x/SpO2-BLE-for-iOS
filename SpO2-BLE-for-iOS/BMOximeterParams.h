//
//  BMOximeterParams.h
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/11/3.
//  Copyright © 2015年 doe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMOximeterParams : NSObject

//range[0 100]    127 is invalid value
//value refresh frequency: 1HZ
@property(nonatomic,assign) NSUInteger SpO2Value;

//range[0 250]    255 is invalid value
//value refresh frequency: 1HZ
@property(nonatomic,assign) NSUInteger pulseRateValue;

//range[0 100]
//value refresh frequency: 100HZ
@property(nonatomic,assign) NSUInteger waveAmplitude;


+(NSUInteger)SpO2InvalidValue;
+(NSUInteger)pulseRateInvalidValue;
@end
