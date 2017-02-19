//
//  LJClippingTool.m
//  miniFilter
//
//  Created by qianfeng on 15/10/7.
//  Copyright (c) 2015年 miniFilter. All rights reserved.
//

#import "LJClippingTool.h"

#import <QuartzCore/QuartzCore.h>
#import "UIImage+Utility.h"
#import "UIView+Frame.h"
#import "UIDevice+SystemVersion.h"

@interface CLRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
- (id)initWithValue1:(NSInteger)value1 value2:(NSInteger)value2;
- (NSString*)description;
@end


@interface CLRatioMenuItem : UIView
@property (nonatomic, strong) CLRatio *ratio;
- (id)initWithFrame:(CGRect)frame iconImage:(UIImage*)iconImage;
- (void)changeOrientation;
@end


@interface CLClippingPanel : UIView
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) CLRatio *clippingRatio;
- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame;
- (void)setBgColor:(UIColor*)bgColor;
- (void)setGridColor:(UIColor*)gridColor;
- (void)clippingRatioDidChange;
@end



#pragma mark- LJClippingTool

@interface LJClippingTool()
{
    CGFloat _reat;
}

@property (nonatomic, strong) CLRatioMenuItem *selectedMenu;
@end



@implementation LJClippingTool

{
    CLClippingPanel *_gridView;
    UIView *_menuContainer;
    UIScrollView *_menuScroll;
    BOOL IS_SET;
}

+ (BOOL)isAvailable
{
    return YES;
}

- (void)setup
{
    if (IS_SET)return;
    IS_SET = YES;
    
    _menuContainer = [[UIView alloc] initWithFrame:self.mScrollview.frame];
    _menuContainer.backgroundColor = self.mScrollview.backgroundColor;
    [self.bView addSubview:_menuContainer];
    
   
    
    _menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _menuContainer.width - 70, _menuContainer.height)];
    _menuScroll.backgroundColor = [UIColor clearColor];
    _menuScroll.showsHorizontalScrollIndicator = NO;
    _menuScroll.clipsToBounds = NO;
    [_menuContainer addSubview:_menuScroll];
    
    UIView *btnPanel = [[UIView alloc] initWithFrame:CGRectMake(_menuScroll.right, 0, 70, _menuContainer.height)];
    btnPanel.backgroundColor = [_menuContainer.backgroundColor colorWithAlphaComponent:0.9];
    [_menuContainer addSubview:btnPanel];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    btn.center = CGPointMake(btnPanel.width/2, btnPanel.height/2 - 10);
    [btn addTarget:self action:@selector(pushedRotateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"rotate_btn.png"] forState:UIControlStateNormal];
    btn.adjustsImageWhenHighlighted = YES;
    [btnPanel addSubview:btn];
    
    [self setCropMenu];
    
    //蒙版
    //NSLog(@"%@",NSStringFromCGSize(self.showImgV.image.size));
    CGSize imgSize = self.showImgV.image.size;
    CGSize frameSize = self.showImgV.frame.size;
    if (imgSize.width >=  imgSize.height) {
        _reat = frameSize.width/(double)imgSize.width;
    }else{
        _reat = frameSize.height/(double)imgSize.height;
        if (imgSize.width *_reat >= frameSize.width ) {
            _reat = frameSize.width/(double)imgSize.width;
        }
    }
    CGSize size = CGSizeMake( imgSize.width *_reat, imgSize.height * _reat);
    
    CGPoint center = self.showImgV.center;
    CGRect frame =  CGRectMake(center.x - size.width/2, center.y - size.height/2, size.width, size.height);
    
    
    _gridView = [[CLClippingPanel alloc] initWithSuperview:self.bScrollview frame:frame];
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.bgColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    _gridView.gridColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    _gridView.clipsToBounds = NO;
    
    _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.bView.height-_menuScroll.top);
    [UIView animateWithDuration:0.3
                     animations:^{
                         _menuContainer.transform = CGAffineTransformIdentity;
                     }];
}

- (void)cleanup
{
    if (!IS_SET)return;
    IS_SET = NO;
   
    [_gridView removeFromSuperview];
    [UIView animateWithDuration:0.3
                     animations:^{
                         _menuContainer.transform = CGAffineTransformMakeTranslation(0, self.bView.height-_menuScroll.top);
                     }
                     completion:^(BOOL finished) {
                         [_menuContainer removeFromSuperview];
                     }];
}
- (void)execute{
    
    CGRect rct = _gridView.clippingRect;
    rct.size.width  /= _reat;
    rct.size.height /= _reat;
    rct.origin.x    /= _reat;
    rct.origin.y    /= _reat;
    
    UIImage *result = [self.showImgV.image crop:rct];
//    completionBlock(result, nil, nil);
    self.showImgV.image = result;
}


#pragma mark-


- (void)setCropMenu
{
    CGFloat W = 70;
    CGFloat x = 0;
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[[CLRatio alloc] initWithValue1:0 value2:0]];
    [array addObject:[[CLRatio alloc] initWithValue1:1 value2:1]];
    [array addObject:[[CLRatio alloc] initWithValue1:4 value2:3]];
    [array addObject:[[CLRatio alloc] initWithValue1:3 value2:2]];
    [array addObject:[[CLRatio alloc] initWithValue1:16 value2:9]];
    
    CGSize  imgSize = self.showImgV.image.size;
    CGFloat maxW = MIN(imgSize.width, imgSize.height);
    UIImage *iconImage = [self.showImgV.image resize:CGSizeMake(70 * imgSize.width/maxW, 70 * imgSize.height/maxW)];
    
    for(CLRatio *ratio in array){
        ratio.isLandscape = (self.showImgV.image.size.width > self.showImgV.image.size.height);
        
        CLRatioMenuItem *view = [[CLRatioMenuItem alloc] initWithFrame:CGRectMake(x, 0, W, _menuScroll.height) iconImage:iconImage];
        view.ratio = ratio;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedMenu:)];
        [view addGestureRecognizer:gesture];
        
        [_menuScroll addSubview:view];
        x += W;
        
        if(self.selectedMenu==nil){
            self.selectedMenu = view;
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedMenu:(UITapGestureRecognizer*)sender
{
    CLRatioMenuItem *view = (CLRatioMenuItem*)sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.alpha = 1;
                     }
     ];
    
    self.selectedMenu = view;
    
    if(view.ratio.ratio==0){
        _gridView.clippingRatio = nil;
    }
    else{
        _gridView.clippingRatio = view.ratio;
    }
}

- (void)setSelectedMenu:(CLRatioMenuItem *)selectedMenu
{
    if(selectedMenu != _selectedMenu){
        _selectedMenu.backgroundColor = [UIColor clearColor];
        _selectedMenu = selectedMenu;
        _selectedMenu.backgroundColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
    }
}

- (void)pushedRotateBtn:(UIButton*)sender
{
    for(CLRatioMenuItem *item in _menuScroll.subviews){
        if([item isKindOfClass:[CLRatioMenuItem class]]){
            [item changeOrientation];
        }
    }
    
    if(_gridView.clippingRatio.ratio!=0 && _gridView.clippingRatio.ratio!=1){
        [_gridView clippingRatioDidChange];
    }
}

@end


#pragma mark- UI components

@interface CLClippingCircle : UIView

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation CLClippingCircle

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = rct.size.width/2-rct.size.width/6;
    rct.origin.y = rct.size.height/2-rct.size.height/6;
    rct.size.width /= 3;
    rct.size.height /= 3;
    
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillEllipseInRect(context, rct);
}

@end

@interface CLGridLayar : CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;
@end

@implementation CLGridLayar

+ (BOOL)needsDisplayForKey:(NSString*)key
{
    if ([key isEqualToString:@"clippingRect"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if(self && [layer isKindOfClass:[CLGridLayar class]]){
        self.bgColor   = ((CLGridLayar*)layer).bgColor;
        self.gridColor = ((CLGridLayar*)layer).gridColor;
        self.clippingRect = ((CLGridLayar*)layer).clippingRect;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    CGContextClearRect(context, _clippingRect);
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 1);
    
    rct = self.clippingRect;
    
    CGContextBeginPath(context);
    CGFloat dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
        CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
        dW += _clippingRect.size.width/3;
    }
    
    dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
        CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
        dW += rct.size.height/3;
    }
    CGContextStrokePath(context);
}

@end

@implementation CLClippingPanel
{
    CLGridLayar *_gridLayer;
    CLClippingCircle *_ltView;
    CLClippingCircle *_lbView;
    CLClippingCircle *_rtView;
    CLClippingCircle *_rbView;
}

- (CLClippingCircle*)clippingCircleWithTag:(NSInteger)tag
{
    CLClippingCircle *view = [[CLClippingCircle alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    view.backgroundColor = [UIColor clearColor];
    view.bgColor = [UIColor blackColor];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    
    [self.superview addSubview:view];
    
    return view;
}

- (id)initWithSuperview:(UIView*)superview frame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self){
        [superview addSubview:self];
        
        _gridLayer = [[CLGridLayar alloc] init];
        _gridLayer.frame = self.bounds;
        _gridLayer.bgColor   = [UIColor colorWithWhite:1 alpha:0.6];
        _gridLayer.gridColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self.layer addSublayer:_gridLayer];
        
        _ltView = [self clippingCircleWithTag:0];
        _lbView = [self clippingCircleWithTag:1];
        _rtView = [self clippingCircleWithTag:2];
        _rbView = [self clippingCircleWithTag:3];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
        [self addGestureRecognizer:panGesture];
        
        self.clippingRect = self.bounds;
    }
    return self;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    [_ltView removeFromSuperview];
    [_lbView removeFromSuperview];
    [_rtView removeFromSuperview];
    [_rbView removeFromSuperview];
}

- (void)setBgColor:(UIColor *)bgColor
{
    _gridLayer.bgColor = bgColor;
}

- (void)setGridColor:(UIColor *)gridColor
{
    _gridLayer.gridColor = gridColor;
    _ltView.bgColor = _lbView.bgColor = _rtView.bgColor = _rbView.bgColor = [gridColor colorWithAlphaComponent:1];
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    
    _ltView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:self];
    _lbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    _rtView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:self];
    _rbView.center = [self.superview convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:self];
    
    _gridLayer.clippingRect = clippingRect;
    [self setNeedsDisplay];
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated
{
    if(animated){
        [UIView animateWithDuration:0.3
                         animations:^{
                             _ltView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:self];
                             _lbView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:self];
                             _rtView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:self];
                             _rbView.center = [self.superview convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:self];
                         }
         ];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = 0.3;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        [_gridLayer addAnimation:animation forKey:nil];
        
        _gridLayer.clippingRect = clippingRect;
        _clippingRect = clippingRect;
        [self setNeedsDisplay];
    }
    else{
        self.clippingRect = clippingRect;
    }
}

- (void)clippingRatioDidChange
{
    CGRect rect = self.bounds;
    if(self.clippingRatio){
        CGFloat H = rect.size.width * self.clippingRatio.ratio;
        if(H<=rect.size.height){
            rect.size.height = H;
        }
        else{
            rect.size.width *= rect.size.height / H;
        }
        
        rect.origin.x = (self.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = (self.bounds.size.height - rect.size.height) / 2;
    }
    [self setClippingRect:rect animated:YES];
}

- (void)setClippingRatio:(CLRatio *)clippingRatio
{
    if(clippingRatio != _clippingRatio){
        _clippingRatio = clippingRatio;
        [self clippingRatioDidChange];
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [_gridLayer setNeedsDisplay];
}

- (void)panCircleView:(UIPanGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:self];
    CGPoint dp = [sender translationInView:self];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = self.frame.size.width;
    const CGFloat H = self.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.clippingRatio.ratio : self.clippingRatio.ratio;
    
    switch (sender.view.tag) {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if(ratio!=0){
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            }
            else{
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    self.clippingRect = rct;
}

- (void)panGridView:(UIPanGestureRecognizer*)sender
{
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if(sender.state==UIGestureRecognizerStateBegan){
        CGPoint point = [sender locationInView:self];
        dragging = CGRectContainsPoint(_clippingRect, point);
        initialRect = self.clippingRect;
    }
    else if(dragging){
        CGPoint point = [sender translationInView:self];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), self.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), self.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
    }
}
@end




@implementation CLRatio
{
    NSInteger _longSide;
    NSInteger _shortSide;
}

- (id)initWithValue1:(NSInteger)value1 value2:(NSInteger)value2
{
    self = [super init];
    if(self){
        _longSide  = MAX(labs(value1), labs(value2));
        _shortSide = MIN(labs(value1), labs(value2));
    }
    return self;
}

- (NSString*)description
{
    if(_longSide==0 || _shortSide==0){
        return @"Custom";
    }
    
    if(self.isLandscape){
        return [NSString stringWithFormat:@"%ld : %ld", (long)_longSide, (long)_shortSide];
    }
    return [NSString stringWithFormat:@"%ld : %ld", (long)_shortSide, (long)_longSide];
}

- (CGFloat)ratio
{
    if(_longSide==0 || _shortSide==0){
        return 0;
    }
    
    if(self.isLandscape){
        return _shortSide / (CGFloat)_longSide;
    }
    return _longSide / (CGFloat)_shortSide;
}

@end


@implementation CLRatioMenuItem
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}

- (id)initWithFrame:(CGRect)frame iconImage:(UIImage *)iconImage
{
    self = [super initWithFrame:frame];
    if(self){
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 50, 50)];
        _iconView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
        _iconView.image = iconImage;
        _iconView.clipsToBounds = YES;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.layer.cornerRadius = 3;
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, 15)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor cyanColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setRatio:(CLRatio *)ratio
{
    if(ratio != _ratio){
        _ratio = ratio;
        [self refreshViews];
    }
}

- (void)refreshViews
{
    _titleLabel.text = [_ratio description];
    
    CGPoint center = _iconView.center;
    CGFloat W, H;
    if(_ratio.ratio!=0){
        if(_ratio.isLandscape){
            W = 50;
            H = 50*_ratio.ratio;
        }
        else{
            W = 50/_ratio.ratio;
            H = 50;
        }
    }
    else{
        CGFloat maxW  = MAX(_iconView.image.size.width, _iconView.image.size.height);
        CGFloat a = _iconView.image.size.width;
        CGFloat b = _iconView.image.size.height;
        //NSLog(@"%f,%f",a,b);
        W = 50 * _iconView.image.size.width / maxW;
        H = 50 * _iconView.image.size.height / maxW;
    }
    _iconView.frame = CGRectMake(center.x-W/2, center.y-H/2, W, H);
}

- (void)changeOrientation
{
    self.ratio.isLandscape = !self.ratio.isLandscape;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self refreshViews];
                     }
     ];
}


@end






























