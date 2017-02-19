//
//  CLPixellateEffect.m
//
//  Created by sho yakushiji on 2013/10/23.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLPixellateEffect.h"

#import "UIView+Frame.h"

@implementation CLPixellateEffect
{
    UIView *_containerView;
    UISlider *_radiusSlider;
}

#pragma mark-

+ (NSString*)title
{
    return @"马赛克";
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 6.0);
}

- (id)initWithSuperView:(UIView*)superview imageViewFrame:(CGRect)frame;
{
    self = [super init];
    if(self){
        _containerView = [[UIView alloc] initWithFrame:superview.bounds];
        [superview addSubview:_containerView];
        
        [self setUserInterface];
    }
    return self;
}

- (void)cleanup
{
    [_containerView removeFromSuperview];
}

- (UIImage*)applyEffect:(UIImage*)image
{
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CIFilter *filter = [CIFilter filterWithName:@"CIPixellate" keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //NSLog(@"%@", [filter attributes]);
    
    [filter setDefaults];
    
    CGFloat R = MIN(image.size.width, image.size.height) * 0.1 * _radiusSlider.value;
    CIVector *vct = [[CIVector alloc] initWithX:image.size.width/2 Y:image.size.height/2];
    [filter setValue:vct forKey:@"inputCenter"];
    [filter setValue:[NSNumber numberWithFloat:R] forKey:@"inputScale"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    
    return result;
}

#pragma mark-

- (UISlider*)sliderWithValue:(CGFloat)value minimumValue:(CGFloat)min maximumValue:(CGFloat)max
{
    HUMSlider *slider = [[HUMSlider alloc] initWithFrame:CGRectMake(10, 0, 200, 20)];
    [slider setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];

    
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, slider.height)];
    container.backgroundColor = [UIColor clearColor] ;
    container.layer.cornerRadius = slider.height/2;
    
    slider.continuous = NO;
    [slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    
    slider.maximumValue = max;
    slider.minimumValue = min;
    slider.value = value;
    
    [container addSubview:slider];
    [_containerView addSubview:container];
    
    return slider;
}

- (void)setUserInterface
{
    _radiusSlider = [self sliderWithValue:0.5 minimumValue:0 maximumValue:1.0];
    _radiusSlider.superview.center = CGPointMake(_containerView.width/2, _containerView.height-30);
}

- (void)sliderDidChange:(UISlider*)sender
{
    [self.delegate effectParameterDidChange:self];
}

@end
