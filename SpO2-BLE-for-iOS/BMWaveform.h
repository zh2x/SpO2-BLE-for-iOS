//
//  BMWaveform.h
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/10/29.
//  Copyright © 2015年 doe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMWaveform : UIView

//the distance between two adjacent points on the X axis.
//default : 5.0
@property (nonatomic, assign) CGFloat xStep;


//the width of the line, default : 3.0
@property (nonatomic, assign) CGFloat lineWidth;

//the color of the line, default : white
@property (nonatomic, copy)   UIColor* lineColor;



//the pleth point get from Oximeter.
-(void)addAmplitude:(NSUInteger)amp;


//convenient init BMWaveform
+(instancetype)waveformWithFrame:(CGRect)frame;

@end
