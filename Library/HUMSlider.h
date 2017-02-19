//
//  HUMSlider.h
//  HUMSliderSample
//
//  Created by Ellen Shapiro on 12/26/14.
//  Copyright (c) 2014 Just Hum, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A slider which pops up ticks and saturates/desaturates images when the user adjusts
 * a slider for better feedback to the user about their adjustment.
 *
 * NOTE: This is not using IBDesignable in order to maintain compatibility with
 *       iOS 7. *sad trombone*
 */
@interface HUMSlider : UISlider

#pragma mark - Ticks

///The color of the ticks you wish to pop up. Defaults to dark gray.
@property (nonatomic) UIColor *tickColor;

///How many sections of ticks should be created. NOTE: Needs to be an odd number or math falls apart. Defaults to 9. 
@property (nonatomic) NSUInteger sectionCount;

///How many points the tick popping should be adjusted for a custom thumbnail image to account for any space at the top (for example, to balance out a custom shadow).
@property (nonatomic) CGFloat pointAdjustmentForCustomThumb;

#pragma mark - Images

///The color to use as the fully-saturated color. Defaults to red.
@property (nonatomic) UIColor *saturatedColor;

///The color to use as the desaturated color. Defaults to light gray.
@property (nonatomic) UIColor *desaturatedColor;

#pragma mark - Configurable Animation Durations

///How long it should take to adjust tick alpha. Defaults to .2 seconds.
@property (nonatomic) NSTimeInterval tickAlphaAnimationDuration;

///How long it takes most ticks to pop up from hidden. Defaults to .5 seconds.
@property (nonatomic) NSTimeInterval tickMovementAnimationDuration;

///How long it takes the tick on either side of the middle tick pop up from hidden. Defaults to .35 seconds.
@property (nonatomic) NSTimeInterval secondTickMovementAndimationDuration;

///How long to wait between animating secondary ticks. Defaults to 0.025 seconds. 
@property (nonatomic) NSTimeInterval nextTickAnimationDelay;

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
