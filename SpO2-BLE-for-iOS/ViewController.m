//
//  ViewController.m
//  SpO2-BLE-for-iOS
//
//  Created by doe on 15/10/29.
//  Copyright © 2015年 doe. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BMWaveform.h"
#import "Constants.h"
#import "BMOximeterAnalyzer.h"
#import "BMOximeterParams.h"

@interface ViewController ()<CBCentralManagerDelegate, CBPeripheralDelegate, OximeterAnalyzerDelegate>

@property (weak, nonatomic) IBOutlet UILabel                 *labelMessage;
@property (weak, nonatomic) IBOutlet UITextField             *tfBluetoothName;
@property (weak, nonatomic) IBOutlet UIButton                *btnScan;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanIndicator;
@property (weak, nonatomic) IBOutlet UILabel                 *labelSpO2;
@property (weak, nonatomic) IBOutlet UILabel                 *labelPulseRate;
@property (weak, nonatomic) IBOutlet UIButton                *btnDisconnect;



@property (nonatomic,weak) IBOutlet BMWaveform               *waveForm;
@property (nonatomic,strong) CBCentralManager                *centralManager;
@property (nonatomic,strong) CBPeripheral                    *targetPeripheral;

@property (nonatomic,strong)BMOximeterAnalyzer               *analyzer;

- (IBAction)btnScanClick;
- (IBAction)btnSourceClik;
- (IBAction)btnDisconnectClick;

@end

@implementation ViewController

-(BMOximeterAnalyzer *)analyzer
{
    if(!_analyzer)
    {
        _analyzer = [BMOximeterAnalyzer sharedAnalyzer];
        _analyzer.delegate = self;
    }
    
    return _analyzer;
}

-(CBCentralManager *)centerManager
{
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                                                             options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    }

    return _centralManager;
}
                           
- (void)viewDidLoad {
    [super viewDidLoad];
    [self centerManager];
}



#pragma mark ---demo functions------
- (IBAction)btnScanClick {
    [_centralManager scanForPeripheralsWithServices:nil options:nil];
    
    self.labelMessage.text = @"Start Scan...";
    
    [self stopScan:5];
}

- (IBAction)btnSourceClik {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SOURCE_CODE_SITE]];
}

- (IBAction)btnDisconnectClick {
    [self.centralManager cancelPeripheralConnection:self.targetPeripheral];
}

   
-(void)stopScan:(NSUInteger)secFromNow
{
    _btnScan.enabled = NO;
    _scanIndicator.hidden = NO;

    //cancel the scan opreation
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(secFromNow * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_centralManager stopScan];
        _btnScan.enabled = YES;
        _scanIndicator.hidden = YES;
        
        NSLog(@"stop scan....");
    });
}


#pragma mark ---CBCentralManagerDelegate Functions---
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _btnScan.enabled = (central.state == CBCentralManagerStatePoweredOn);
    });
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{

    if([peripheral.name isEqualToString:_tfBluetoothName.text])
    {
        [self.labelMessage performSelectorOnMainThread:@selector(setText:) withObject:@"Discovered target Oximeter..." waitUntilDone:NO];
        
        _targetPeripheral = peripheral;
        [self stopScan:0];
        _targetPeripheral.delegate = self;
        [central connectPeripheral:_targetPeripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES}];
        
        [self.labelMessage performSelectorOnMainThread:@selector(setText:) withObject:@"Connectting to target Oximeter..." waitUntilDone:NO];

    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:@[[CBUUID UUIDWithString:UUID_SERVICE_DATA]]];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.labelMessage.text = @"Connectted to target Oximeter...";
        [self.btnDisconnect setHidden:NO];
    });
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
 
        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelMessage.text = @"Disconnect...";
            [self.btnDisconnect setHidden:YES];
        });
}


#pragma mark ---CBPeripheralDelegate Functions---
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error
{
    
    if (!error) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:UUID_CHARACTER_RECEIVE]] forService:[peripheral.services lastObject]];
    }else {
        NSLog(@"%s: %@",__func__ ,error);
    }

}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error) {
        [peripheral setNotifyValue:YES forCharacteristic:[service.characteristics lastObject]];

    } else {
        NSLog(@"%s: %@",__func__ ,error);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    [self.analyzer addData:characteristic.value];
}


#pragma mark ---OximeterAnalyzerDelegate Functions---
-(void)OximeterAnalyzer:(BMOximeterAnalyzer *)analyzer didRefreshOximeterWaveAmplitude:(BMOximeterParams *)params
{

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.waveForm addAmplitude:params.waveAmplitude];
    });
}

-(void)OximeterAnalyzer:(BMOximeterAnalyzer *)analyzer didRefreshOximeterParams:(BMOximeterParams *)params
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (params.SpO2Value == [BMOximeterParams SpO2InvalidValue]) {
            self.labelSpO2.text = @"---";
        }else{
            self.labelSpO2.text = [NSString stringWithFormat:@"%lu",params.SpO2Value];
        }
        
        if (params.pulseRateValue == [BMOximeterParams pulseRateInvalidValue]) {
            self.labelPulseRate.text = @"---";
        }else{
            self.labelPulseRate.text = [NSString stringWithFormat:@"%lu",params.pulseRateValue];
        }
    });
}

@end
