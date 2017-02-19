//
//  FixPhotoViewController.m
//  miniFilter
//
//  Created by qianfeng01 on 15/9/28.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "FixPhotoViewController.h"
#import "ViewController.h"
#import "MMProgressHUD.h"
#import "SpecialViewController.h"
#import "EditViewController.h"
#import "HYYShareView.h"

@interface FixPhotoViewController ()

@end

@implementation FixPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide]; 
    [MMProgressHUD setPresentationStyle:MMProgressHUDPresentationStyleExpand];
    [MMProgressHUD showWithTitle:nil status:@"Loading……"];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.3];
}

-(void)savePic:(NSNotification *)notification
{
    self.fixImgV.image = notification.object;
}

-(void)dismiss
{
    [MMProgressHUD dismissWithSuccess:@"Success"];
   
}


#pragma mark - 按钮触发事件
- (IBAction)cancelBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAndShareItemClicked:(id)sender{
    UIImageWriteToSavedPhotosAlbum(self.fixImgV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}



#pragma mark - 保存

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存失败" ;
    }else{
        msg = @"保存成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:@"( ^_^ )不错嘛，赶快分享一下吧~" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"分享", nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        
        
        HYYShareView * shareView =[[HYYShareView alloc]initWithFrame:self.view.bounds andType:TYPE_SHARE];
        
        shareView.shareUrl=@"http://f0.topit.me/0/97/2f/11882920689162f970o.jpg";
        shareView.shareImageUrl=@"http://f0.topit.me/0/97/2f/11882920689162f970o.jpg";
        shareView.shareTitle=@"proFilter真是太好用了";
        shareView.shareText=@"分享";
        shareView.shareImageName=@"icon.jpg";
        shareView.shareImage=self.fixImgV.image;
        [self.view addSubview:shareView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIImage *)sender {
    if ([segue.identifier isEqualToString:@"goToSpecial"]) {
        SpecialViewController * specialVC  = segue.destinationViewController;
        specialVC.specialImage = self.fixImgV.image;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(savePic:) name:@"savePic" object:nil];
    }else if ([segue.identifier isEqualToString:@"goToEdit"]){
        EditViewController * editVC = segue.destinationViewController;
        editVC.editImage = self.fixImgV.image;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(savePic:) name:@"savePic" object:nil];
    }
}


@end
