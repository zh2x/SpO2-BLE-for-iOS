//
//  BMOximeterAnalyzer.m
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/11/2.
//  Copyright © 2015年 doe. All rights reserved.
//

#import "BMOximeterAnalyzer.h"
#import "BMOximeterParams.h"

@interface BMOximeterAnalyzer()

@property(nonatomic,copy)     NSMutableArray   *dataArray;
@property(nonatomic,strong)   BMOximeterParams *oximeterParams;

@end

@implementation BMOximeterAnalyzer

-(NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(BMOximeterParams *)oximeterParams
{
    if (!_oximeterParams) {
        _oximeterParams = [[BMOximeterParams alloc]init];
    }
    return _oximeterParams;
}

+(instancetype)sharedAnalyzer
{
    static BMOximeterAnalyzer *sharedAnalyzer = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAnalyzer = [[self alloc]init];
    });
    return sharedAnalyzer;
}


//add data to buf
-(void)addData:(NSData *)data
{
    BOOL isPackageHeaderFound = NO;
    Byte package[5]           = {0};
    int  packageIndex         = 0;
    
    int  parserIndex = 0;
    int  i = 0;

    
    Byte *bytes = (Byte *)[data bytes];
    for(int i= 0; i < data.length; i++)
    {
        [self.dataArray addObject: [NSNumber numberWithInt:(int)(bytes[i]&0xff) ]];
    }
    
    if(self.dataArray.count < 10)
    {
        return;
    }
    
    
    while (i < self.dataArray.count)
    {
        //scan for package header
        if([self.dataArray[i] integerValue] & 0x80)
        {
            isPackageHeaderFound     = YES;
            package[packageIndex ++] = [self.dataArray[i] integerValue];
            i++;
            continue;
        }
        
        if(isPackageHeaderFound)
        {
            package[packageIndex ++] = [self.dataArray[i] integerValue];
            if(packageIndex == 5)
            {
                BMOximeterParams *params = [[BMOximeterParams alloc] init];
                
                params.waveAmplitude  = package[1];
                params.pulseRateValue = package[3] | ((package[2] & 0x40) << 1);
                params.SpO2Value      = package[4];
                
                //refresh parameters
                if (params.SpO2Value != self.oximeterParams.SpO2Value || params.pulseRateValue != self.oximeterParams.pulseRateValue)
                {
                    
                    if([self.delegate respondsToSelector:@selector(OximeterAnalyzer:didRefreshOximeterParams:)])
                    {
                        [self.delegate performSelector:@selector(OximeterAnalyzer:didRefreshOximeterParams:) withObject:params];
                    }
                }
                
                //refresh pulse wave
                if([self.delegate respondsToSelector:@selector(OximeterAnalyzer:didRefreshOximeterWaveAmplitude:)])
                {
                    [self.delegate performSelector:@selector(OximeterAnalyzer:didRefreshOximeterWaveAmplitude:) withObject:params];
                }
                
                self.oximeterParams = params;
                
                
                packageIndex         = 0;
                isPackageHeaderFound = NO;
                parserIndex          = i;
                memset(package, 0, sizeof(package));
            }
        }
        
        i++;
        
    }
    [self.dataArray removeObjectsInRange:NSMakeRange(0, parserIndex+1)];
}

@end
