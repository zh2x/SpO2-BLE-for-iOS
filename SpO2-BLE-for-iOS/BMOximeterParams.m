//
//  BMOximeterParams.m
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/11/3.
//  Copyright © 2015年 doe. All rights reserved.
//

#import "BMOximeterParams.h"

@implementation BMOximeterParams

@synthesize SpO2Value;
@synthesize pulseRateValue;
@synthesize waveAmplitude;

+(NSUInteger)SpO2InvalidValue
{
    return 127;
}
+(NSUInteger)pulseRateInvalidValue
{
    return 255;
}

@end

