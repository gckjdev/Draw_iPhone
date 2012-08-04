//
//  DiceAvatarView.m
//  Draw
//
//  Created by Orange on 12-7-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceAvatarView.h"
#import "DACircularProgressView.h"
#import "HJManagedImageV.h"
#import "DiceImageManager.h"
#import "PPApplication.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "ShareImageManager.h"

#define PROGRESS_UPDATE_TIME    0.01

@implementation DiceAvatarView
@synthesize score = _score;
@synthesize userId = _userId;
@synthesize delegate = _delegate;
@synthesize hasPen = _hasPen;

- (void)dealloc
{
    [imageView release];
//    [markButton release];
    [_userId release];
    [progressView release];
    [bgView release];
    [_timer release];
    [super dealloc];
}

- (void)addTapGuesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnAvatar)];    
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

#define EDGE_WIDTH_TIMES 13
#define EDGE_HEIGHT_TIMES 13
- (CGRect)calAvatarFrame
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat wEdge = -progressView.progressBarWidth;//width / EDGE_WIDTH_TIMES;
    CGFloat hEdge = -progressView.progressBarWidth;//height / EDGE_HEIGHT_TIMES;
    return CGRectMake(wEdge, hEdge, width - 2 * wEdge, height - 2 * hEdge);
}

- (CGRect)calSqureAvatarFrame
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat wEdge = -3.1;//width / EDGE_WIDTH_TIMES;
    CGFloat hEdge = -3.1;//height / EDGE_HEIGHT_TIMES;
    return CGRectMake(wEdge, hEdge, width - 2 * wEdge, height - 3 * hEdge);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgView = [[UIImageView alloc] initWithFrame:[self calSqureAvatarFrame]];
        [self addSubview:bgView];
        
        float width = MIN(self.bounds.size.width, self.bounds.size.height);
        imageView = [[HJManagedImageV alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        [imageView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        imageView.layer.cornerRadius = self.frame.size.width/2;
        imageView.layer.masksToBounds = YES;
        [imageView setImage:[[DiceImageManager defaultManager] 
                             greenSafaImage]];
        [self addSubview:imageView];
        
        progressView = [[DACircularProgressView alloc] init];
        progressView.progressBarWidth = width*0.05;
        [progressView setFrame:[self calAvatarFrame]];
        progressView.trackTintColor = [UIColor clearColor];
        progressView.progressTintColor = [UIColor greenColor];
        progressView.hidden = YES;
        [self addSubview:progressView];
        
        [self addTapGuesture];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

    }
    return self;
}

- (void)setProgress:(CGFloat)progress{
    progressView.hidden = NO;
    progressView.progress = progress;
}

- (void)setProgressHidden:(BOOL)hidden
{
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1];
    if (hidden) {
        progressView.hidden = YES;
    } else {
        progressView.hidden = NO;
    }
    [UIView commitAnimations];
}

- (void)setAvatarStyle:(AvatarViewStyle)style
{
    if (style == Square) {
        progressView.hidden = YES;
        imageView.layer.cornerRadius = 0;
        _currentStyle = Square;
        [bgView setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
    } else {
        progressView.hidden = NO;
        imageView.layer.cornerRadius = imageView.frame.size.width/2;
        _currentStyle = Round;
        [bgView setImage:nil];
    }
    imageView.layer.masksToBounds = YES;
}

- (void)startReciprocol:(CFTimeInterval)reciprocolTime
{
    _currentProgress = 1.0f;
    _reciprocolTime = reciprocolTime;
    if (_timer != nil){
        if ([_timer isValid]){
            [_timer invalidate];
        }
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:(reciprocolTime*PROGRESS_UPDATE_TIME) target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)stopReciprocol
{
    [_timer invalidate];
    _timer = nil;
    [self setProgressHidden:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(reciprocalEnd:)]) {
        [_delegate reciprocalEnd:self];
    }
}

//
//
//- (id)initWithUrlString:(NSString *)urlString frame:(CGRect)frame gender:(BOOL)gender level:(int)level;
//{
//    self = [super initWithFrame:frame];    
//    if (self) {
//        self.backgroundColor = [UIColor clearColor];
//        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
//        [self addSubview:bgView];
//        [self setAvatarSelected:NO];
//        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
//        [self addSubview:imageView];
//        [self setAvatarUrl:urlString gender:gender];
//        [self addTapGuesture];
//        [self setAvatarSelected:NO level:level];
//    }
//    
//    return self;
//}


//- (void)setUrlString:(NSString *)urlString
//{
//    [imageView clear];
//    [imageView setUrl:[NSURL URLWithString:urlString]];
//    [GlobalGetImageCache() manage:imageView];
//}

//
//- (void)setScore:(NSInteger)score
//{
//    _score = score;
//    if (type == Drawer) {
//        return;
//    }
//    if (score > 0) {
//        markButton.hidden = NO;
//        [markButton setTitle:[NSString stringWithFormat:@"%d",score] forState:UIControlStateNormal];
//    }else{
//        markButton.hidden = YES;   
//        [markButton setTitle:nil forState:UIControlStateNormal];
//    }
//}

- (void)setImage:(UIImage *)image
{
    [imageView clear];
    [imageView setImage:image];
    [GlobalGetImageCache() manage:imageView];
}

- (void)updateTimer:(id)sender
{
    _currentProgress -= PROGRESS_UPDATE_TIME;
    if (_currentProgress <= 0) {
        [self stopReciprocol];
        return;
    }
    [self setProgress:_currentProgress];
    
}

- (void)clickOnAvatar
{
    //    PPDebug(@"clickOnAvatar");
    [self startReciprocol:10];
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:self];
    }
    
    
}
//- (void)setAvatarFrame:(CGRect)frame
//{
//    self.frame = frame;
//    bgView.frame = [self calAvatarFrame];
//    imageView.frame = self.bounds;
//    //    imageView.frame = frame;//CGRectMake(0, 0, frame.size.width, frame.size.height);
//}
- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender
{
    [imageView clear];
    if (gender) {
        [imageView setImage:[[ShareImageManager defaultManager] 
                             maleDefaultAvatarImage]];
    }else{
        [imageView setImage:[[ShareImageManager defaultManager] 
                             femaleDefaultAvatarImage]];                
    }
    if ([url length] > 0){
        [imageView setUrl:[NSURL URLWithString:url]];
        [GlobalGetImageCache() manage:imageView];
    }
}

- (void)setUrlString:(NSString *)urlString 
              userId:(NSString*)userId
              gender:(BOOL)gender 
               level:(int)level 
          drunkPoint:(int)drunkPint 
              wealth:(int)wealth
{
    [self setAvatarUrl:urlString gender:gender];
    [self setUserId:userId];
}

//- (void)setAvatarSelected:(BOOL)selected
//{
//    if (selected) {
//        [bgView setImage:[[ShareImageManager defaultManager] avatarSelectImage]];
//    }else{
//        [bgView setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
//    }
//}
//- (void)setHasPen:(BOOL)hasPen
//{
//    if (markButton == nil) {
//        markButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [markButton retain];
//        markButton.frame = CGRectMake(self.frame.size.width*0.6, self.frame.size.height*0.6, self.frame.size.width*0.4, self.frame.size.height*0.4);
//        [self addSubview:markButton];
//        markButton.userInteractionEnabled = NO;
//        ShareImageManager *manager = [ShareImageManager defaultManager];
//        [markButton setBackgroundImage:[manager drawingMarkLargeImage] forState:UIControlStateNormal];
//    }
//    markButton.hidden = !hasPen;
//}

//- (UIImage*)backgroundForLevel:(int)level
//{
//    if (level >=40 && level <= 50) {
//        return [[ShareImageManager defaultManager] purpleAvatarImage];
//    }
//    if (level >= 25 && level < 40) {
//        return [[ShareImageManager defaultManager] goldenAvatarImage];
//    }
//    if (level >= 10 && level < 25) {
//        return [[ShareImageManager defaultManager] greenAvatarImage];
//    }
//    return [[ShareImageManager defaultManager] avatarUnSelectImage];
//    
//}
//
//- (void)setAvatarSelected:(BOOL)selected level:(int)level
//{
//    if (selected) {
//        [bgView setImage:[[ShareImageManager defaultManager] avatarSelectImage]];
//    }else{
//        [bgView setImage:[self backgroundForLevel:level]];
//    }
//}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
