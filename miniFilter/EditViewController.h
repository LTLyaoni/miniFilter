//
//  EditViewController.h
//  miniFilter
//
//  Created by qianfeng01 on 15/9/25.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUMSlider.h"

@interface EditViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *bScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *editImgV;
@property (strong) UIImage * editImage;
@property (weak, nonatomic) IBOutlet HUMSlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet HUMSlider *contrastSlider;
@property (weak, nonatomic) IBOutlet HUMSlider *colourSlider;
@property (weak, nonatomic) IBOutlet UIView *regulateView;
@property (weak, nonatomic) IBOutlet UIScrollView *shearScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *rotateScrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *regulateToolBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shearToolBarItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rotateToolBarItem;
@property (weak, nonatomic) IBOutlet UIButton *contrastBtn;

@property (weak, nonatomic) IBOutlet UIButton *sureBtnClicked;




@end
