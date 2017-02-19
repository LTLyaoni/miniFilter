//
//  SpecialViewController.m
//  miniFilter
//
//  Created by qianfeng01 on 15/9/28.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "SpecialViewController.h"
#import "UIView+Twinkle.h"
#import "FixPhotoViewController.h"
#import "LJFilterTool.h"
#import "CLEffectTool.h"
#import "LJBlurTool.h"

@interface SpecialViewController ()
<UIPopoverPresentationControllerDelegate>
{
    NSMutableArray * _filterBtnArray;
    NSMutableArray * _effectBtnArray;
    NSMutableArray * _virtualBtnArray;
    LJFilterTool *_filterTool;
    CLEffectTool *_effectTool;
    LJBlurTool *_blurTool;
    int _typeTag;
}
@end

@implementation SpecialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _typeTag = 0;

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide]; 

    _filterBtnArray = [[NSMutableArray alloc] init];
    _effectBtnArray = [[NSMutableArray alloc] init];
    _virtualBtnArray = [[NSMutableArray alloc] init];
    
    self.specialImgV.userInteractionEnabled = YES;
    self.specialImage =[self fixOrientation:self.specialImage];
    self.specialImgV.image = self.specialImage;
    
    [self initSlider];
    [self initWithScrollView];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needSavePic:) name:@"savePic" object:nil];
}

#pragma mark - 初始化控件

-(void)initSlider
{
    self.sureBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    self.contrastBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    
    self.filterToolBarItem.enabled = NO;
    
    self.effectSlider.alpha = 0;
    self.effectSlider2.alpha = 0;
    
    [self.effectSlider setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];
    [self.effectSlider2 setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];
    
    self.effectSlider2.transform =  CGAffineTransformRotate(self.effectSlider2.transform,-90*M_PI/180);
}

//初始化scrollView
-(void)initWithScrollView
{
    self.effectScrollView.alpha = 0;
    self.virtualScrollView.alpha = 0;
    self.virtualSlider.alpha = 0;
    [self.virtualSlider setThumbImage:[UIImage imageNamed:@"thum"] forState:UIControlStateNormal];
    //滤镜

    _filterTool = [[LJFilterTool alloc]init];
    _filterTool.showImg = self.specialImgV;
    _filterTool.originalImage = self.specialImage ;
    //NSLog(@"----%p",self.filterScrollView);
    _filterTool.filterScroll = self.filterScrollView;
    _filterTool.nowImage =self.specialImage ;
    [_filterTool setup];
    
    
    //效果
    _effectTool = [[CLEffectTool alloc]init];
    _effectTool.showImgV = self.specialImgV;
    _effectTool.originalImage = self.specialImage ;
     _effectTool.nowImg = self.specialImage ;
    _effectTool.menuScroll = self.effectScrollView;
    _effectTool.bVieW = self.bView;
    [_effectTool setup];
    //虚化
    _blurTool = [[LJBlurTool alloc]init];
    _blurTool.showImgV = self.specialImgV;
    _blurTool.originalImage = self.specialImage ;
     _blurTool.nowImage =self.specialImage ;
    _blurTool.menuScroll = self.virtualScrollView;
    _blurTool.bView = self.bView;
    
    _blurTool.blurSlider = self.virtualSlider;
}

#pragma mark - top按钮触发事件
- (IBAction)cancelBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

//保存当前图片，并传回首页
- (IBAction)doneBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"savePic" object:self.specialImgV.image];
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

-(void)needSavePic:(NSNotification *)notification
{
    UIImage * image = notification.object;
}

#pragma mark - 工具按钮触发事件
//对比
//按下时触发
- (IBAction)contrastBtnClicked:(UIButton *)sender {
    self.specialImgV.image = self.specialImage;
}
//松开时触发
- (IBAction)contrastBtnUp:(UIButton *)sender {
    if (!_typeTag) {
        self.specialImgV.image = _filterTool.nowImage;
    }
    if (_typeTag == 1) {
        self.specialImgV.image = _effectTool.nowImg;
    }
    if (_typeTag == 2) {
         self.specialImgV.image = _blurTool.nowImage;
    }
    
}

- (IBAction)sureBtnClicked:(id)sender {
    
        self.specialImage = self.specialImgV.image;
    
        _filterTool.originalImage = self.specialImage;
        _filterTool.thumnailImage = self.specialImage;
    
        _effectTool.originalImage = self.specialImage;
        _effectTool.thumnailImage = self.specialImage;
    
        _blurTool.originalImage = self.specialImage;
        _blurTool.thumnailImage = self.specialImage;
    
}


#pragma mark - toolBar按钮触发事件
//滤镜按钮触发事件
- (IBAction)filterBtnClicked:(id)sender {
    
    self.filterToolBarItem.enabled = NO;
    self.effectToolBarItem.enabled = YES;
    self.virtualToolBarItem.enabled = YES;
    if ([_effectTool.selectedEffect respondsToSelector:@selector(cleanup)]) {
        [_effectTool.selectedEffect cleanup];
    }
    
    _typeTag = 0;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.effectSlider.alpha = 0;
        self.effectSlider2.alpha = 0;
        self.effectScrollView.alpha = 0;
        self.virtualScrollView.alpha = 0;
        self.virtualSlider.alpha = 0;
        self.filterScrollView.alpha = 1;
    }];
}

//效果按钮触发事件
- (IBAction)effectBtnClicked:(id)sender {

    
    self.filterToolBarItem.enabled = YES;
    self.effectToolBarItem.enabled = NO;
    self.virtualToolBarItem.enabled = YES;
    _typeTag = 1;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.filterScrollView.alpha = 0;
        self.virtualScrollView.alpha = 0;
        self.virtualSlider.alpha = 0;
        self.effectScrollView.alpha = 1;
    }];
}

//虚化按钮触发事件
- (IBAction)virtualBtnClicked:(id)sender {

    
    self.filterToolBarItem.enabled = YES;
    self.effectToolBarItem.enabled = YES;
    self.virtualToolBarItem.enabled = NO;
    if ([_effectTool.selectedEffect respondsToSelector:@selector(cleanup)]) {
        [_effectTool.selectedEffect cleanup];
    }
    _typeTag = 2;
    [_blurTool setup];
    [UIView animateWithDuration:1.0 animations:^{
        self.effectSlider.alpha = 0;
        self.effectSlider2.alpha = 0;
        self.effectScrollView.alpha = 0;
        self.filterScrollView.alpha = 0;
        self.virtualScrollView.alpha = 1;
        self.virtualSlider.alpha = 1;
    }];
}


#pragma mark - 按钮绑定事件

//虚化实现事件
-(void)virtualBtn:(UIButton *)virtualBtn
{
    
    [_virtualBtnArray addObject:virtualBtn];
    for (UIButton * btn in _virtualBtnArray) {
        btn.selected = NO;
        btn.alpha = 1;
    }
    UIButton * btn = _virtualBtnArray.lastObject;
    btn.selected = YES;
    if (btn.selected) {
        btn.alpha = 0.8;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
//#pragma mark - Navigation
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UIImage * img = self.specialImgV.image;
//    if ([segue.identifier isEqualToString:@"goToFilter"]) {
//        FilterViewController * filterVC = segue.destinationViewController;
//        filterVC.filterImage = img;
//    }
//}


@end
