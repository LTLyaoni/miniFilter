//
//  SpecialViewController.h
//  miniFilter
//
//  Created by qianfeng01 on 15/9/28.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUMSlider.h"

@interface SpecialViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *bView;
@property (weak, nonatomic) IBOutlet UIImageView *specialImgV;
@property (weak, nonatomic) IBOutlet UIScrollView *filterScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *effectScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *virtualScrollView;
@property (weak, nonatomic) IBOutlet HUMSlider *virtualSlider;
@property (weak, nonatomic) IBOutlet HUMSlider *effectSlider;
@property (weak, nonatomic) IBOutlet HUMSlider *effectSlider2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterToolBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *effectToolBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *virtualToolBarItem;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIButton *contrastBtn;

@property (retain,nonatomic) UIImage * specialImage;

@end
