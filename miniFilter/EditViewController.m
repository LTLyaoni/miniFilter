//
//  EditViewController.m
//  miniFilter
//
//  Created by qianfeng01 on 15/9/25.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "EditViewController.h"
#import "LJAdjustmentTool.h"
#import "LJRotateTool.h"
#import "LJClippingTool.h"


@interface EditViewController ()
{
    LJAdjustmentTool *_adjustmentTool;
    LJClippingTool *_clippingTool;
    BOOL IS_CLIP;
    
}
@end



@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    IS_CLIP = NO;
    
    self.editImage = [self fixOrientation:self.editImage];
    self.editImgV.image = self.editImage;
    
    [self initSlider];
    [self initView];
    
    _adjustmentTool = [[LJAdjustmentTool alloc]init];
    _adjustmentTool.saturationSlider = self.colourSlider;
    _adjustmentTool.brightnessSlider = self.brightnessSlider;
    _adjustmentTool.contrastSlider = self.contrastSlider;
    _adjustmentTool.originalImage = self.editImage;
    _adjustmentTool.nowImg = self.editImage;
    _adjustmentTool.showImgV = self.editImgV;
    [_adjustmentTool setup];
    
    _clippingTool = [[LJClippingTool alloc]init];
    _clippingTool.bScrollview = self.bScrollView;
    _clippingTool.showImgV = self.editImgV;
    _clippingTool.mScrollview = self.shearScrollView;
    _clippingTool.bView = self.view;
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needSavePic:) name:@"savePic" object:nil];
}

#pragma mark - 初始化界面
//初始化View
-(void)initView
{
    self.sureBtnClicked.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    self.contrastBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    self.sureBtnClicked.alpha = 0;
    
    self.shearScrollView.alpha = 0;
    self.rotateScrollView.alpha = 0;
    self.shearScrollView.backgroundColor = [UIColor darkGrayColor];
    
   // self.rotateScrollView.backgroundColor = [UIColor grayColor];
    NSArray * imgArray = @[@"leftRotate.png",@"rightRotate.png",@"horRotate.png",@"verRotate.png"];
    NSArray * rotateArray = @[@"左转",@"右转",@"水平翻转",@"垂直翻转"];
    for (int i = 0; i < 4; i++) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(75 * i, 0, 70, 90)];
        view.tag = i + 1;
        [self.rotateScrollView addSubview:view];
        
        UIImageView * imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        imgView.image = [UIImage imageNamed:imgArray[i]];
        [view addSubview:imgView];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 50, 20)];
        label.text = rotateArray[i];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor cyanColor];
        [view addSubview:label];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotateSubViewTap:)];
        [view addGestureRecognizer:tap];
        
        
    }
}

//初始化slider
-(void)initSlider
{
    self.regulateToolBarItem.enabled = NO;
    
    [self.brightnessSlider setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];
    [self.contrastSlider setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];
    [self.colourSlider setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];
}




#pragma mark - 旋转

//旋转按钮实现
-(void)rotateSubViewTap:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.2 animations:^{
        tap.view.alpha = 0.5;
    }completion:^(BOOL finished) {
        tap.view.alpha = 1;
    }];
    switch (tap.view.tag) {
        case 1:
            self.editImgV.image = [LJRotateTool rotate90CounterClockwise:self.editImgV.image];
            break;
        case 2:
            self.editImgV.image = [LJRotateTool rotate90Clockwise:self.editImgV.image];
            break;
        case 3:
            self.editImgV.image = [LJRotateTool flipHorizontal:self.editImgV.image];
            break;
        case 4:
            self.editImgV.image = [LJRotateTool flipVertical:self.editImgV.image];
            break;
            
        default:
            break;
    }
}




#pragma mark - top按钮触发事件
- (IBAction)cancelBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)doneBtnClicked:(id)sender {
        
    if(IS_CLIP ) [_clippingTool execute] ;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"savePic" object:self.editImgV.image];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}


#pragma mark - 按钮触发事件

- (IBAction)sureBtnClicked:(id)sender {
}

//对比按钮按下时触发
- (IBAction)contrastBtnClicked:(id)sender {
    self.editImgV.image = self.editImage;
}

//对比按钮松开时触发
- (IBAction)contrastBtnUp:(id)sender {
    self.editImgV.image = _adjustmentTool.nowImg;
}

#pragma mark - 通知
//通知方法
-(void)needSavePic:(NSNotification *)notification
{
    UIImage * image = notification.object;
}

#pragma mark - toolBar触发方法
//调节
- (IBAction)regulateItemClicked:(id)sender {
    IS_CLIP = NO;
    
    [_clippingTool cleanup];
    self.contrastBtn.alpha = 1;
    self.sureBtnClicked.alpha = 0;
    self.regulateToolBarItem.enabled = NO;
    self.shearToolBarItem.enabled = YES;
    self.rotateToolBarItem.enabled = YES;
    [UIView animateWithDuration:1.0 animations:^{
        self.regulateView.alpha = 1;
        self.shearScrollView.alpha = 0;
        self.rotateScrollView.alpha = 0;
    }];
    
    
}

//剪切
- (IBAction)shearItemClicked:(id)sender {
    IS_CLIP = YES;
    [_clippingTool setup];
    self.contrastBtn.alpha = 0;
    self.sureBtnClicked.alpha = 0;
    self.regulateToolBarItem.enabled = YES;
    self.shearToolBarItem.enabled = NO;
    self.rotateToolBarItem.enabled = YES;
    [UIView animateWithDuration:1.0 animations:^{
        self.regulateView.alpha = 0;
        self.shearScrollView.alpha = 1;
        self.rotateScrollView.alpha = 0;
    }];
}

//旋转
- (IBAction)rotateItemCliked:(id)sender {
    IS_CLIP = NO;
    [_clippingTool cleanup];
    self.contrastBtn.alpha = 0;
    self.sureBtnClicked.alpha = 1;
    self.regulateToolBarItem.enabled = YES;
    self.shearToolBarItem.enabled = YES;
    self.rotateToolBarItem.enabled = NO;
    [UIView animateWithDuration:1.0 animations:^{
        self.regulateView.alpha = 0;
        self.shearScrollView.alpha = 0;
        self.rotateScrollView.alpha = 1;
    }];
}


#pragma mark - 图像方向修正 -
- (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    
    
    return img;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
