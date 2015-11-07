//
//  BMOximeterAnalyzer.h
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/11/2.
//  Copyright © 2015年 doe. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BMOximeterAnalyzer;
@class BMOximeterParams;


@protocol OximeterAnalyzerDelegate <NSObject>

@optional

-(void)OximeterAnalyzer:(BMOximeterAnalyzer *)analyzer didRefreshOximeterParams:(BMOximeterParams*)params;

-(void)OximeterAnalyzer:(BMOximeterAnalyzer *)analyzer didRefreshOximeterWaveAmplitude:(BMOximeterParams*)params;

@end




@interface BMOximeterAnalyzer : NSObject

+(instancetype)sharedAnalyzer;

@property(nonatomic,strong) id<OximeterAnalyzerDelegate> delegate;

-(void)addData:(NSData *)data;

@end
