//
//  LJAdjustmentTool.m
//  miniFilter
//
//  Created by qianfeng on 15/10/6.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "LJAdjustmentTool.h"
#import "UIImage+Utility.h"
#import "UIView+Frame.h"
#import "UIDevice+SystemVersion.h"

@implementation LJAdjustmentTool
{
    
    UIActivityIndicatorView *_indicatorView;
}

+ (NSString*)title
{
    return @"Adjustment";
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

- (void)setup
{
    _thumnailImage = _originalImage;
    
    [self setupSlider];
}

#pragma mark-


- (void)setupSlider
{
    [_saturationSlider  addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    _saturationSlider.maximumValue = 2;
    _saturationSlider.minimumValue = 0;
    _saturationSlider.value = 1;
    
    
    [_brightnessSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    
    _brightnessSlider.maximumValue = 1;
    _brightnessSlider.minimumValue = -1;
    _brightnessSlider.value = 0;
    
    [_contrastSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
   
    _contrastSlider.maximumValue = 1.5;
    _contrastSlider.minimumValue = 0.5;
    _contrastSlider.value = 1;

 }

- (void)sliderDidChange:(UISlider*)sender
{
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    inProgress = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.nowImg = [self filteredImage:_thumnailImage];
        [self.showImgV performSelectorOnMainThread:@selector(setImage:) withObject:_nowImg waitUntilDone:NO];
        inProgress = NO;
    });
}

- (UIImage*)filteredImage:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    //色相
    CIFilter *filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    [filter setDefaults];
    [filter setValue:[NSNumber numberWithFloat:_saturationSlider.value]
              forKey:@"inputSaturation"];
    NSLog(@"%f",_saturationSlider.value);
    //曝光亮度
    filter = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat brightness = 2*_brightnessSlider.value;
    [filter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputEV"];
    //对比度
    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, [filter outputImage], nil];
    [filter setDefaults];
    CGFloat contrast   = _contrastSlider.value*_contrastSlider.value;
    [filter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputPower"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

@end
