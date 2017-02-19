//
//  ViewController.m
//  miniFilter
//
//  Created by qianfeng01 on 15/9/22.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "ViewController.h"
#import "FixPhotoViewController.h"

@interface ViewController ()

<UIScrollViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

{
    //创建图片数组
    NSMutableArray * _picArray;
    //创建计时器
//    NSTimer * _timer;
    CADisplayLink * _timer;
    NSInteger _ftp;
    NSInteger _currentPage;
    BOOL _IS_UP;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _picArray = [[NSMutableArray alloc] init];
    [self initProImageView];
    [self performSelector:@selector(getPic) withObject:nil afterDelay:0.1];
    _currentPage = 0;
    _ftp = 0;
    _IS_UP = YES;
    //启动模仿计时器
    if (_timer == nil) {
        _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(ftpUpdate)];
        _timer.frameInterval = 5;
        [_timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    self.scrollView.delegate = self;
    self.pageControl.defersCurrentPageDisplay = YES;
}


#pragma mark - 自定义图片

-(void)initProImageView
{
//    CALayer * aLayer = self.proImgV.layer;
    self.proImgV.layer.shadowPath = ([UIBezierPath bezierPathWithRect:CGRectMake(-60, 0, self.proImgV.frame.size.width + 200, self.proImgV.frame.size.height)]).CGPath;
    self.proImgV.layer.shadowColor = [UIColor blackColor].CGColor;
    self.proImgV.layer.shadowOffset = CGSizeMake(0, -55);
    self.proImgV.layer.shadowOpacity = 1;
    self.proImgV.layer.shadowRadius = 30;
}

#pragma mark - 获取一组图片资源

//随机获取图片
-(void)getPic
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 4, self.scrollView.frame.size.height);
    for (int i = 0; i < 19; i++) {
        UIImage * img = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i + 1]];
        [_picArray addObject:img];
    }
    for (int i = 0; i < 4; i++) {
        int index = arc4random() % (19 - i);
        UIImageView * imgV = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i,0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        imgV.image = _picArray[index];
        imgV.alpha = 0.95;
        [self.scrollView addSubview:imgV];
        [_picArray removeObjectAtIndex:index];
    }
}


#pragma mark - 计时器相关方法 -

//计时器帧率刷新
-(void)ftpUpdate
{
    _ftp++;
    if (_ftp > 36) {
        [self pageControll];
        _ftp = 0;
    }
}

//pageControl随着图片移动而移动；
-(void)pageControll
{
    //判断当前页面增/减
    if (_IS_UP) {
        _currentPage++;
        if (_currentPage > 2) _IS_UP = NO;
    }else{
        _currentPage--;
        if (_currentPage < 1) _IS_UP = YES;
    }
    //移动动画
    [UIView animateWithDuration:0.5 animations:^{
        self.pageControl.currentPage = _currentPage;
        self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width * _currentPage, 0);
    }];
    
}

#pragma mark - UIScrollViewDelegate代理方法 -
//当视图开始拖动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _ftp = 0;
}

//当视图停止减速
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _ftp = 0;
    _currentPage = scrollView.contentOffset.x / self.scrollView.frame.size.width;
    self.pageControl.currentPage = _currentPage;
    if (_currentPage > 2)_IS_UP = NO;
    if (_currentPage < 1)_IS_UP = YES;
}

#pragma mark - 按钮触发事件

- (IBAction)choosePhoto:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (IBAction)camera:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker=[[UIImagePickerController alloc]init];
        picker.delegate=self;
        picker.allowsEditing=YES;
        picker.sourceType=UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:NO completion:^{
            
        }];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"此设备没有摄像头" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - UIImagePickerController代理方法

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   
    FixPhotoViewController * fixVC = [storyboard instantiateViewControllerWithIdentifier:@"fixPhoto"];
    [picker presentViewController:fixVC animated:YES completion:^{
        fixVC.fixImgV.image = info[@"UIImagePickerControllerOriginalImage"];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
