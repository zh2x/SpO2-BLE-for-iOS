//
//  BMWaveform.m
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/10/29.
//  Copyright © 2015年 doe. All rights reserved.
//

#import "BMWaveform.h"

//the edge marge of the view
#define kEDGE_MARGE                10
#define kDEFAULT_LINE_WIDTH        1.2
#define kDEFAULT_XSTEP             1.5
#define kDEFAULT_LINE_COLOR        [UIColor whiteColor]
#define kDEFAULT_BACKGROUND_COLOR  [UIColor colorWithRed:46/255.0 green:148/255.0 blue:216/255.0 alpha:1.0]


@interface BMWaveform ()

@property(strong,nonatomic) UIBezierPath   *path;
@property(assign,nonatomic) CGPoint         prePoint;

@end

@implementation BMWaveform

//init a BMWaveform
-(instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineWidth       = kDEFAULT_LINE_WIDTH;
        self.xStep           = kDEFAULT_XSTEP;
        self.lineColor       = kDEFAULT_LINE_COLOR;
        self.backgroundColor = kDEFAULT_BACKGROUND_COLOR;
        
    }
    return self;
}

+(instancetype)waveformWithFrame:(CGRect)frame
{
    return [[self alloc]initWithFrame:frame];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    self.lineWidth       = kDEFAULT_LINE_WIDTH;
    self.xStep           = kDEFAULT_XSTEP;
    self.lineColor       = kDEFAULT_LINE_COLOR;
    self.backgroundColor = kDEFAULT_BACKGROUND_COLOR;
}

//override the drawRect func
- (void)drawRect:(CGRect)rect {
    if(_path != nil)
    {
        [self.lineColor set];
        [_path stroke];
    }
}

//draw the waveform
//this just a small demo for pleth, maybe you can make a better one.
//the Amplitude range is [0,100]
-(void)addAmplitude:(NSUInteger)amp
{
    //compute current point
    amp = (self.frame.size.height - 2*kEDGE_MARGE)*amp*0.01 + kEDGE_MARGE;
    amp = self.frame.size.height - amp;
    CGPoint curPoint = CGPointMake(_prePoint.x + self.xStep, amp);
    
    if(curPoint.x > self.frame.size.width)
    {
        curPoint.x = 0;
        _prePoint = curPoint;
    }
    
    //draw the line
    CGRect refreshRect = CGRectMake(_prePoint.x, 0, self.xStep, self.frame.size.height);
    _path = [UIBezierPath bezierPath];
    [_path setLineWidth:self.lineWidth];
    [_path setLineCapStyle:kCGLineCapSquare];
    [_path moveToPoint:_prePoint];
    [_path addLineToPoint:curPoint];
    
    [self setNeedsDisplayInRect:refreshRect];
    [self.layer displayIfNeeded];
    _prePoint = curPoint;
}


@end
