//
//  CLEffectTool.h
//
//  Created by sho yakushiji on 2013/10/23.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//



#import "CLEffectBase.h"


@interface CLEffectTool :NSObject  <CLEffectDelegate>
{
    NSArray *_effectClasses;
    

    UIActivityIndicatorView *_indicatorView;
}


@property (strong ,nonatomic)NSArray *effectClasses;

@property (weak ,nonatomic)UIImage *originalImage;
@property (weak ,nonatomic)UIImage *thumnailImage;
@property (strong ,nonatomic)UIImage *nowImg;

@property (weak,nonatomic)UIImageView *showImgV;
@property (weak,nonatomic)UIView *bVieW;

@property (weak ,nonatomic)UIScrollView *menuScroll;
@property (strong ,nonatomic)UIActivityIndicatorView *indicatorView;

@property (nonatomic, weak) UIView *selectedMenu;
@property (nonatomic, strong) CLEffectBase *selectedEffect;

- (void)setup;

@end
