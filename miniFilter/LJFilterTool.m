//
//  LJFilterTool.m
//  miniFilter
//
//  Created by qianfeng on 15/10/3.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "LJFilterTool.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utility.h"
#import "UIView+Frame.h"
#import "UIDevice+SystemVersion.h"
#import "UIView+Twinkle.h"
#import <AVFoundation/AVFoundation.h>


@interface LJFilterPanel : UIView
{
    
}
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) NSString *title;

@end

@implementation LJFilterPanel

@end

@interface LJFilterTool ()
{
    LJFilterPanel *  _lastView;
     AVAudioPlayer *_player;
    NSOperationQueue *_queue;
}
@end

@implementation LJFilterTool

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

- (void)setup
{
    NSString  *soundPath = [[NSBundle mainBundle]pathForResource:@"audio" ofType:@"m4a"];
    NSData *soundData = [NSData dataWithContentsOfFile:soundPath];
    NSError *error = [[NSError alloc]init];
    _player = [[AVAudioPlayer alloc]initWithData:soundData error:&error];
    _player.numberOfLoops=0;
    _player.volume = 0.1;
    [_player prepareToPlay];
    
    _queue = [[NSOperationQueue alloc]init];
    [_queue setMaxConcurrentOperationCount:1];
    [self setFilters];
    _lastView = [[LJFilterPanel alloc]init];
    _thumnailImage = [_originalImage aspectFill:CGSizeMake(50, 50)];
    _filterScroll.showsHorizontalScrollIndicator = NO;
    [self setFilterMenu];
   
}




#pragma mark - 创建 -
- (void)setFilters
{
    _filters = @[
                 @{@"name":@"Original",                 @"title":@"原图",        @"version":@(0.0)},
                 @{@"name":@"CISRGBToneCurveToLinear",  @"title":@"暮光",     @"version":@(7.0)},
                 @{@"name":@"CIVignetteEffect",         @"title":@"LOMO",   @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectInstant",     @"title":@"流年",    @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectProcess",     @"title":@"雪青",    @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectTransfer",    @"title":@"优格",   @"version":@(7.0)},
                 @{@"name":@"CISepiaTone",              @"title":@"晚秋",      @"version":@(5.0)},
                 @{@"name":@"CIPhotoEffectChrome",      @"title":@"淡雅",     @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectFade",        @"title":@"拿铁",       @"version":@(7.0)},
                 @{@"name":@"CILinearToSRGBToneCurve",  @"title":@"丽日",      @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectTonal",       @"title":@"灰度",      @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectNoir",        @"title":@"暗调",       @"version":@(7.0)},
                 @{@"name":@"CIPhotoEffectMono",        @"title":@"黑白",       @"version":@(7.0)},
                 @{@"name":@"CIColorInvert",            @"title":@"负片",     @"version":@(6.0)},
                 ];
}
- (void)setFilterMenu
{
    
    CGFloat W = 70;
    CGFloat x = 0;
    
    for(NSDictionary *filter in _filters){
        if([UIDevice iosVersion] >= [filter[@"version"] floatValue]){
            LJFilterPanel *view = [[LJFilterPanel alloc] initWithFrame:CGRectMake(x, 0, W, W)];
            view.filterName = filter[@"name"];
            view.title      = filter[@"title"];
           // NSLog(@"***%@",view.title);
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
            iconView.clipsToBounds = YES;
            iconView.layer.cornerRadius = 5;
            iconView.contentMode = UIViewContentModeScaleAspectFill;
            [view addSubview:iconView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, W-15, W, 15)];
            label.backgroundColor = [UIColor clearColor];
            label.text = view.title;
            label.textColor = [UIColor cyanColor];
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedFilterPanel:)];
            [view addGestureRecognizer:gesture];
           // NSLog(@"----%p",_filterScroll);
            [_filterScroll addSubview:view];
            x += W;
            
           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *iconImage = [self filteredImage:_thumnailImage withFilterName:filter[@"name"]];
              [iconView performSelectorOnMainThread:@selector(setImage:) withObject:iconImage waitUntilDone:NO];
            });
        }
    }
    _filterScroll.contentSize = CGSizeMake(MAX(x, _filterScroll.frame.size.width+1), 0);
}

- (UIImage*)filteredImage:(UIImage*)image withFilterName:(NSString*)filterName
{
    if([filterName isEqualToString:@"Original"]){
        return _originalImage;
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    
   // NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    if([filterName isEqualToString:@"CIVignetteEffect"]){
        // parameters for CIVignetteEffect
        CGFloat R = MIN(image.size.width, image.size.height)/2;//半径
        CIVector *vct = [[CIVector alloc] initWithX:image.size.width/2 Y:image.size.height/2];//圆心
        [filter setValue:vct forKey:@"inputCenter"];
        [filter setValue:[NSNumber numberWithFloat:0.9] forKey:@"inputIntensity"];
        [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputRadius"];
    }
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

- (void)tappedFilterPanel:(UITapGestureRecognizer*)sender
{
    _lastView.backgroundColor = [UIColor clearColor];
    
    _lastView = (LJFilterPanel*)sender.view;
    _lastView.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
    
    [_queue cancelAllOperations];
    
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(filtImage) object:nil];
    [_queue addOperation:operation];
    
}

-(void)filtImage{
    self.nowImage = [self filteredImage:_originalImage withFilterName:_lastView.filterName];
    
    [self.showImg performSelectorOnMainThread:@selector(setImage:) withObject:_nowImage waitUntilDone:NO];
    [self.showImg performSelectorOnMainThread:@selector(twinkle) withObject:nil waitUntilDone:NO];
    [_player performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
    
}
@end