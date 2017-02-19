//
//  CLEffectTool.m
//
//  Created by sho yakushiji on 2013/10/23.
//  Copyright (c) 2013年 CALACULU. All rights reserved.
//

#import "CLEffectTool.h"
#import <AVFoundation/AVFoundation.h>
#import "CLEffectBase.h"
#import "UIImage+Utility.h"
#import "UIView+Frame.h"
#import "CLClassList.h"
#import "UIView+Twinkle.h"
@interface CLEffectTool()<AVAudioPlayerDelegate>
{
    NSOperationQueue *_queue;
    AVAudioPlayer *_player;
}
@end


@implementation CLEffectTool


+ (NSArray*)effectList
{
    static NSArray *list = nil;
    if(list==nil){
        NSMutableArray *tmp = [@[[CLEffectBase class]] mutableCopy];
        [tmp addObjectsFromArray:[CLClassList subclassesOfClass:[CLEffectBase class]]];
        
        list = [tmp sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CGFloat dockedNum1 = [obj1 dockedNumber];
            CGFloat dockedNum2 = [obj2 dockedNumber];
            
            if(dockedNum1 < dockedNum2){ return NSOrderedAscending; }
            else if(dockedNum1 > dockedNum2){ return NSOrderedDescending; }
            return NSOrderedSame;
        }];
    }
    return list;
}


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
    _player.delegate = self;
    _player.volume = 0.1;
    [_player prepareToPlay];
    
    
    _queue = [[NSOperationQueue alloc]init];
    [_queue setMaxConcurrentOperationCount:1];
    _thumnailImage = _originalImage ;
    _menuScroll.showsHorizontalScrollIndicator = NO;
    _effectClasses = [[self class] effectList];
    [self setEffectMenu];
    
}
- (void)cleanup
{
    [self.selectedEffect cleanup];
    [_indicatorView removeFromSuperview];
    
 }

#pragma mark- 

- (void)setEffectMenu
{
    CGFloat W = 70;
    CGFloat x = 0;
    
    for(NSInteger i=0; i<_effectClasses.count; ++i){
        Class effect = _effectClasses[i];
        
        if([effect isSubclassOfClass:[CLEffectBase class]] && [effect isAvailable]){
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, 0, W, _menuScroll.height)];
            view.tag = i;
            
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
            iconView.clipsToBounds = YES;
            iconView.layer.cornerRadius = 5;
            iconView.contentMode = UIViewContentModeScaleAspectFill;
            iconView.image = [effect iconImage];
            [view addSubview:iconView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, W-15, W, 15)];
            label.backgroundColor = [UIColor clearColor];
            label.text = [effect title];
            label.textColor = [UIColor cyanColor];
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            [view addSubview:label];
            
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMenu:)];
            [view addGestureRecognizer:gesture];
            
            [_menuScroll addSubview:view];
            x += W;
            
            if(self.selectedMenu==nil){
                self.selectedMenu = view;
            }
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedMenu:(UITapGestureRecognizer*)sender
{
    UIView *view = sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1;
    }];
    
    self.selectedMenu = view;
}

- (void)setSelectedMenu:(UIView *)selectedMenu
{
    if(selectedMenu != _selectedMenu){
        _selectedMenu.backgroundColor = [UIColor clearColor];
        _selectedMenu = selectedMenu;
        _selectedMenu.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        
        Class effectClass = _effectClasses[_selectedMenu.tag];
        self.selectedEffect = [[effectClass alloc] initWithSuperView:_bVieW imageViewFrame:_showImgV.frame];
    }
}

- (void)setSelectedEffect:(CLEffectBase *)selectedEffect
{
    if(selectedEffect != _selectedEffect){
        [_selectedEffect cleanup];
        _selectedEffect = selectedEffect;
        _selectedEffect.delegate = self;
        
        
        
        
        [_queue cancelAllOperations];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(buildThumnailImage) object:nil];
        
        [_queue addOperation:operation];

    }
}

- (void)buildThumnailImage
{
    UIImage *image;
    if(self.selectedEffect.needsThumnailPreview){
        image = [self.selectedEffect applyEffect:_thumnailImage];
    }
    else{
        image = [self.selectedEffect applyEffect:_originalImage];
    }
    self.nowImg = image;
    [_showImgV performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
    [self.showImgV performSelectorOnMainThread:@selector(twinkle) withObject:nil waitUntilDone:NO];
    [_player performSelectorOnMainThread:@selector(play) withObject:nil waitUntilDone:NO];
    
    
}


#pragma mark- CLEffect delegate

- (void)effectParameterDidChange:(CLEffectBase *)effect
{
    if(effect == self.selectedEffect){
        static BOOL inProgress = NO;
        
        if(inProgress){ return; }
        inProgress = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self buildThumnailImage];
            inProgress = NO;
        });
    }
}

@end
