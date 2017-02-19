//
//  LJBlurTool.m
//  miniFilter
//
//  Created by qianfeng on 15/10/5.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "LJBlurTool.h"
#import "UIView+Frame.h"
#import "UIImage+Utility.h"
#import "UIDevice+SystemVersion.h"
#import "UIView+Twinkle.h"

typedef NS_ENUM(NSUInteger, CLBlurType)
{
    kCLBlurTypeNormal = 0,
    kCLBlurTypeCircle,
    kCLBlurTypeBand,
};
@interface CLBlurCircle : UIView
@property (nonatomic, strong) UIColor *color;
@end

@interface CLBlurBand : UIView
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat offset;
@end

@interface LJBlurTool()<UIGestureRecognizerDelegate>
{
    
    CLBlurCircle *_circleView;
    CLBlurBand *_bandView;
    CGRect _bandImageRect;
    
    CLBlurType _blurType;
}


@property (nonatomic, strong) UIView *selectedMenu;

@end

@implementation LJBlurTool

#pragma mark-

+ (NSString*)title
{
    return @"Blur & Focus";
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

- (void)setup
{
    _blurType = kCLBlurTypeNormal;

    _thumnailImage = _originalImage;
    _blurSlider = [self sliderWithValue:0.2 minimumValue:0 maximumValue:1];
   
    CGFloat reat;
    if (self.showImgV.image.size.width >  self.showImgV.image.size.height) {
        reat = self.showImgV.frame.size.width/(float)self.showImgV.image.size.width;
    }else{
        reat = self.showImgV.frame.size.height/(float)self.showImgV.image.size.height;
        if (self.showImgV.image.size.width *reat >= self.showImgV.frame.size.width) {
            reat = self.showImgV.frame.size.width/(float)self.showImgV.image.size.width;
        }
    }
    CGSize size = CGSizeMake( self.showImgV.image.size.width *reat, self.showImgV.image.size.height * reat);
    CGPoint center = self.showImgV.center;
    CGRect frame =  CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    
    _handlerView = [[UIView alloc] initWithFrame:frame];
    [self.bView addSubview:_handlerView];
    [self setHandlerView];
    

    _menuScroll.showsHorizontalScrollIndicator = NO;

    [self setBlurMenu];
 
    [self setDefaultParams];
    [self sliderDidChange:nil];
}



#pragma mark-

- (void)setBlurMenu
{
    CGFloat W = 70;
    CGFloat x = 0;
    
    NSArray *_menu = @[
                       @{@"title":@"全局", @"icon":@"icon_normal.png"},
                       @{@"title":@"径向", @"icon":@"icon_circle.png"},
                       @{@"title":@"直线", @"icon":@"icon_band.png"},
                       ];
    
    NSInteger tag = 0;
    for(NSDictionary *obj in _menu){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, 0, W, _menuScroll.height)];
        view.backgroundColor = [UIColor clearColor];
        view.tag = tag++;
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
        iconView.clipsToBounds = YES;
        iconView.layer.cornerRadius = 2;
        iconView.image = [UIImage imageNamed:obj[@"icon"]];
        [view addSubview:iconView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, W-15, W, 15)];
        label.backgroundColor = [UIColor clearColor];
        label.text = obj[@"title"];
        label.textColor = [UIColor cyanColor];
        label.font = [UIFont systemFontOfSize:10];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedBlurMenu:)];
        [view addGestureRecognizer:gesture];
        
        if(self.selectedMenu==nil){
            self.selectedMenu = view;
        }
        
        [_menuScroll addSubview:view];
        x += W;
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)setSelectedMenu:(UIView *)selectedMenu
{
    if(selectedMenu != _selectedMenu){
        _selectedMenu.backgroundColor = [UIColor clearColor];
        _selectedMenu = selectedMenu;
        _selectedMenu.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
    }
}

- (void)setHandlerView
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandlerView:)];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandlerView:)];
    UIPinchGestureRecognizer *pinch    = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandlerView:)];
    UIRotationGestureRecognizer *rot   = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateHandlerView:)];
    
    panGesture.maximumNumberOfTouches = 1;
    
    tapGesture.delegate = self;
    //panGesture.delegate = self;
    pinch.delegate = self;
    rot.delegate = self;
    
    [_handlerView addGestureRecognizer:tapGesture];
    [_handlerView addGestureRecognizer:panGesture];
    [_handlerView addGestureRecognizer:pinch];
    [_handlerView addGestureRecognizer:rot];
}

- (void)setDefaultParams
{
    CGFloat W = 1.5*MIN(_handlerView.width, _handlerView.height);
    
    _circleView = [[CLBlurCircle alloc] initWithFrame:CGRectMake(_handlerView.width/2-W/2, _handlerView.height/2-W/2, W, W)];
    _circleView.backgroundColor = [UIColor clearColor];
    _circleView.color = [UIColor whiteColor];
    
    CGFloat H = _handlerView.height;
    CGFloat R = sqrt((_handlerView.width*_handlerView.width) + (_handlerView.height*_handlerView.height));
    
    _bandView = [[CLBlurBand alloc] initWithFrame:CGRectMake(0, 0, R, H)];
    _bandView.center = CGPointMake(_handlerView.width/2, _handlerView.height/2);
    _bandView.backgroundColor = [UIColor clearColor];
    _bandView.color = [UIColor whiteColor];
    
    CGFloat ratio = _originalImage.size.width / self.showImgV.width;
    _bandImageRect = _bandView.frame;
    _bandImageRect.size.width  *= ratio;
    _bandImageRect.size.height *= ratio;
    _bandImageRect.origin.x *= ratio;
    _bandImageRect.origin.y *= ratio;
    
}

- (HUMSlider*)sliderWithValue:(CGFloat)value minimumValue:(CGFloat)min maximumValue:(CGFloat)max
{
    _blurSlider.continuous = NO;
    [_blurSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    
    _blurSlider.maximumValue = max;
    _blurSlider.minimumValue = min;
    _blurSlider.value = value;
    
    
    return _blurSlider;
}

- (void)sliderDidChange:(UISlider*)slider
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _blurImage = [_thumnailImage gaussBlur:_blurSlider.value];
        [self buildThumnailImage];
    });
}

- (void)buildThumnailImage
{
    static BOOL inProgress = NO;
    
    if(inProgress){ return; }
    
    inProgress = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.nowImage = [self buildResultImage:_thumnailImage withBlurImage:_blurImage];
        
        [self.showImgV performSelectorOnMainThread:@selector(setImage:) withObject:_nowImage waitUntilDone:NO];
        inProgress = NO;
    });
}

- (UIImage*)buildResultImage:(UIImage*)image withBlurImage:(UIImage*)blurImage
{
    UIImage *result = blurImage;
    
    switch (_blurType) {
        case kCLBlurTypeCircle:
            result = [self circleBlurImage:image withBlurImage:blurImage];
            break;
        case kCLBlurTypeBand:
            result = [self bandBlurImage:image withBlurImage:blurImage];
            break;
        default:
            break;
    }
    return result;
}

- (UIImage*)blurImage:(UIImage*)image withBlurImage:(UIImage*)blurImage andMask:(UIImage*)maskImage
{
    UIImage *tmp = [image maskedImage:maskImage];
    
    UIGraphicsBeginImageContext(image.size);
    {
        [blurImage drawAtPoint:CGPointZero];
        [tmp drawAtPoint:CGPointZero];
        tmp = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return tmp;
}

- (UIImage*)circleBlurImage:(UIImage*)image withBlurImage:(UIImage*)blurImage
{
    CGFloat ratio = image.size.width / self.showImgV.width;
    //NSLog(@"222%@",NSStringFromCGRect(_circleView.frame));
    CGRect frame  = _circleView.frame;
    frame.size.width  *= ratio;
    frame.size.height *= ratio;
    frame.origin.x *= ratio;
    frame.origin.y *= ratio;

    
    
   UIImage *mask = [UIImage imageNamed:@"circle.png"];
    UIGraphicsBeginImageContext(image.size);
    {
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext() , [[UIColor whiteColor] CGColor]);
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height));
        [mask drawInRect:frame];
        mask = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [self blurImage:image withBlurImage:blurImage andMask:mask];
}

- (UIImage*)bandBlurImage:(UIImage*)image withBlurImage:(UIImage*)blurImage
{
    UIImage *mask = [UIImage imageNamed:@"band.png"];
    
    UIGraphicsBeginImageContext(image.size);
    {
        CGContextRef context =  UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
        
        CGContextSaveGState(context);
        CGFloat ratio = image.size.width / _originalImage.size.width;
        CGFloat Tx = (_bandImageRect.size.width/2  + _bandImageRect.origin.x)*ratio;
        CGFloat Ty = (_bandImageRect.size.height/2 + _bandImageRect.origin.y)*ratio ;
        CGContextTranslateCTM(context, Tx, Ty);
        CGContextRotateCTM(context, _bandView.rotation);
        CGContextTranslateCTM(context, 0, _bandView.offset*image.size.width/_handlerView.width);
        CGContextScaleCTM(context, 1, _bandView.scale);
        CGContextTranslateCTM(context, -Tx, -Ty);
        
        CGRect rct = _bandImageRect;
        rct.size.width  *= ratio;
        rct.size.height *= ratio;
        rct.origin.x    *= ratio;
        rct.origin.y    *= ratio ;
        [mask drawInRect:rct];
        
        CGContextRestoreGState(context);
        
        mask = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return [self blurImage:image withBlurImage:blurImage andMask:mask];
}

#pragma mark- Gesture handler

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)tappedBlurMenu:(UITapGestureRecognizer*)sender
{
    UIView *view = sender.view;
    
    self.selectedMenu = view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1;
    }];
    
    if(view.tag != _blurType){
        _blurType = view.tag;
        
        [_circleView removeFromSuperview];
        [_bandView removeFromSuperview];
        
        switch (_blurType) {
            case kCLBlurTypeNormal:
                break;
            case kCLBlurTypeCircle:
                [_handlerView addSubview:_circleView];
                [_circleView setNeedsDisplay];
                break;
            case kCLBlurTypeBand:
                [_handlerView addSubview:_bandView];
                [_bandView setNeedsDisplay];
                break;
            default:
                break;
        }
        [self buildThumnailImage];
    }
}

- (void)tapHandlerView:(UITapGestureRecognizer*)sender
{
    switch (_blurType) {
        case kCLBlurTypeCircle:
        {
            CGPoint point = [sender locationInView:_handlerView];
            _circleView.center = point;
            //NSLog(@"%@",NSStringFromCGRect(_circleView.frame));
            [self buildThumnailImage];
            
            break;
        }
        case kCLBlurTypeBand:
        {
            CGPoint point = [sender locationInView:_handlerView];
            point = CGPointMake(point.x-_handlerView.width/2, point.y-_handlerView.height/2);
            point = CGPointMake(point.x*cos(-_bandView.rotation)-point.y*sin(-_bandView.rotation), point.x*sin(-_bandView.rotation)+point.y*cos(-_bandView.rotation));
            _bandView.offset = point.y;
            [self buildThumnailImage];
            break;
        }
        default:
            break;
    }
}

- (void)panHandlerView:(UIPanGestureRecognizer*)sender
{
    switch (_blurType) {
        case kCLBlurTypeCircle:
        {
            CGPoint point = [sender locationInView:_handlerView];
            _circleView.center = point;
            [self buildThumnailImage];
            break;
        }
        case kCLBlurTypeBand:
        {
            CGPoint point = [sender locationInView:_handlerView];
            point = CGPointMake(point.x-_handlerView.width/2, point.y-_handlerView.height/2);
            point = CGPointMake(point.x*cos(-_bandView.rotation)-point.y*sin(-_bandView.rotation), point.x*sin(-_bandView.rotation)+point.y*cos(-_bandView.rotation));
            _bandView.offset = point.y;
            [self buildThumnailImage];
            break;
        }
        default:
            break;
    }
}

- (void)pinchHandlerView:(UIPinchGestureRecognizer*)sender
{
    switch (_blurType) {
        case kCLBlurTypeCircle:
        {
            static CGRect initialFrame;
            if (sender.state == UIGestureRecognizerStateBegan) {
                initialFrame = _circleView.frame;
            }
            
            CGFloat scale = sender.scale;
            CGRect rct;
            rct.size.width  = MAX(MIN(initialFrame.size.width*scale, 3*MAX(_handlerView.width, _handlerView.height)), 0.3*MIN(_handlerView.width, _handlerView.height));
            rct.size.height = rct.size.width;
            rct.origin.x = initialFrame.origin.x + (initialFrame.size.width-rct.size.width)/2;
            rct.origin.y = initialFrame.origin.y + (initialFrame.size.height-rct.size.height)/2;
            
            _circleView.frame = rct;
            [self buildThumnailImage];
            break;
        }
        case kCLBlurTypeBand:
        {
            static CGFloat initialScale;
            if (sender.state == UIGestureRecognizerStateBegan) {
                initialScale = _bandView.scale;
            }
            
            _bandView.scale = MIN(2, MAX(0.2, initialScale * sender.scale));
            [self buildThumnailImage];
            break;
        }
        default:
            break;
    }
}

- (void)rotateHandlerView:(UIRotationGestureRecognizer*)sender
{
    switch (_blurType) {
        case kCLBlurTypeBand:
        {
            static CGFloat initialRotation;
            if (sender.state == UIGestureRecognizerStateBegan) {
                initialRotation = _bandView.rotation;
            }
            
            _bandView.rotation = MIN(M_PI/2, MAX(-M_PI/2, initialRotation + sender.rotation));
            [self buildThumnailImage];
            break;
        }
        default:
            break;
    }
    
}

@end


#pragma mark- UI components

@implementation CLBlurCircle

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = 0.35*rct.size.width;
    rct.origin.y = 0.35*rct.size.height;
    rct.size.width *= 0.3;
    rct.size.height *= 0.3;
    
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextStrokeEllipseInRect(context, rct);
    
    self.alpha = 1;
    [UIView animateWithDuration:0.2 delay:1 options : UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
    }];
}

@end




@implementation CLBlurBand

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        _scale    = 1;
        _rotation = 0;
        _offset   = 0;
    }
    return self;
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self calcTransform];
}

- (void)setRotation:(CGFloat)rotation
{
    _rotation = rotation;
    [self calcTransform];
}

- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    [self calcTransform];
}

- (void)calcTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, -self.offset*sin(self.rotation), self.offset*cos(self.rotation));
    transform = CGAffineTransformRotate(transform, self.rotation);
    transform = CGAffineTransformScale(transform, 1, self.scale);
    self.transform = transform;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setCenter:(CGPoint)center
{
    [super setCenter:center];
    [self setNeedsDisplay];
}

- (void)setTransform:(CGAffineTransform)transform
{
    [super setTransform:transform];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.y = 0.3*rct.size.height;
    rct.size.height *= 0.4;
    
    CGContextSetLineWidth(context, 1/self.scale);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextStrokeRect(context, rct);
    
    self.alpha = 1;
    [UIView animateWithDuration:0.2 delay:1 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 0;
    }completion:^(BOOL finished) {
    }];
}
@end


















