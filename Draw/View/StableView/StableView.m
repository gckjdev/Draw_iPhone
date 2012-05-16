//
//  StableView.m
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StableView.h"
#import "ShareImageManager.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "PPDebug.h"
#import "DeviceDetection.h"

#define TOOL_VIEW_FRAM (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 39 * 2, 52 * 2) : CGRectMake(0, 0, 39, 52))

#define NUMBER_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(27 * 2, 10 * 2, 24 * 2, 24 * 2) : CGRectMake(27, 10, 24, 24)) 

#define AVATAR_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 33 * 2, 34 * 2) : CGRectMake(0, 0, 31, 32))

#define MARK_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(16 * 2,18 * 2,16 * 2,17 * 2) : CGRectMake(16,18,16,17))


#define MARK_FONT_SIZE (([DeviceDetection isIPAD]) ? 12 * 2 : 12)
#define TOOL_NUMBER_SIZE (([DeviceDetection isIPAD]) ? 16 * 2 : 16)

#define MARK_INSET (([DeviceDetection isIPAD]) ? UIEdgeInsetsMake(0, 0, 2 * 2, 0) : UIEdgeInsetsMake(0, 0, 2 * 2, 0))

@implementation ToolView
- (id)initWithNumber:(NSInteger)number
{

    self = [super initWithFrame:TOOL_VIEW_FRAM];
    if(self){
        self.userInteractionEnabled = NO;
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [self setBackgroundImage:[imageManager toolImage] forState:UIControlStateNormal];
        numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [numberButton setFrame:NUMBER_VIEW_FRAME];
        [numberButton setBackgroundImage:[imageManager toolNumberImage] forState:UIButtonTypeCustom];
        [numberButton setUserInteractionEnabled:NO];
        [self addSubview:numberButton];
        [numberButton.titleLabel setFont:[UIFont systemFontOfSize:TOOL_NUMBER_SIZE]];
        numberButton.titleLabel.minimumFontSize = 10;
        [self setNumber:number];
        [numberButton retain];
    }
    return self;
}

- (void)dealloc
{
    [numberButton release], numberButton = nil;
    [super dealloc];
}
- (void)setNumber:(NSInteger)number
{
    _number = number;
    NSString *numberString = nil;
    numberButton.hidden = YES;
    if (number >= 0) {
        numberString = @"N";
        if (number < 100) {
            numberString = [NSString stringWithFormat:@"%d",number];                
        }
        numberButton.hidden = NO;
    }
    [numberButton setTitle:numberString forState:UIControlStateNormal];
}
- (NSInteger)number
{
    return _number;
}

- (void)decreaseNumber
{
    [self setNumber:--_number];
}

- (void)addTarget:(id)target action:(SEL)action
{
    self.userInteractionEnabled = YES;
    [super addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    [numberButton setEnabled:enabled];
}

@end


@implementation AvatarView
@synthesize score = _score;
@synthesize userId = _userId;
@synthesize delegate = _delegate;
@synthesize hasPen = _hasPen;

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
    CGFloat wEdge = -width/16;//width / EDGE_WIDTH_TIMES;
    CGFloat hEdge = -height/15.5;//height / EDGE_HEIGHT_TIMES;
    return CGRectMake(wEdge, hEdge, width - 2 * wEdge, height - 3 * hEdge);
}

- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType gender:(BOOL)gender;
{
    
    PPDebug(@"<alloc Avatar View>: url = %@, gender = %d", urlString, gender);

    self = [super initWithFrame:AVATAR_VIEW_FRAME];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        type = aType;
        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
        [self addSubview:bgView];
        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        [self setAvatarUrl:urlString gender:gender];
        [self addTapGuesture];

        markButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [markButton retain];
        markButton.frame = MARK_VIEW_FRAME;
        [self addSubview:markButton];
        markButton.userInteractionEnabled = NO;
        ShareImageManager *manager = [ShareImageManager defaultManager];
        if (type == Drawer) {
            [self setAvatarSelected:YES];
            [markButton setBackgroundImage:[manager drawingMarkSmallImage] forState:UIControlStateNormal];
        }else if(type == Guesser){
            [self setAvatarSelected:NO];
            [markButton setBackgroundImage:[manager scoreBackgroundImage] forState:UIControlStateNormal];            
            [markButton.titleLabel setFont:[UIFont boldSystemFontOfSize:MARK_FONT_SIZE]];
            [markButton setTitleEdgeInsets:MARK_INSET];
            [self setScore:0];
        }
    }
    
    return self;
}


- (id)initWithUrlString:(NSString *)urlString frame:(CGRect)frame gender:(BOOL)gender;
{
    self = [super initWithFrame:frame];    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
        [self addSubview:bgView];
        [self setAvatarSelected:NO];
        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        [self setAvatarUrl:urlString gender:gender];
        [self addTapGuesture];
    }
    
    return self;
}


- (void)setUrlString:(NSString *)urlString
{
    [imageView clear];
    [imageView setUrl:[NSURL URLWithString:urlString]];
    [GlobalGetImageCache() manage:imageView];
}
- (void)dealloc
{
    [imageView release];
    [markButton release];
    [_userId release];
    [bgView release];
    [super dealloc];
}

- (void)setScore:(NSInteger)score
{
    _score = score;
    if (type == Drawer) {
        return;
    }
    if (score > 0) {
        markButton.hidden = NO;
        [markButton setTitle:[NSString stringWithFormat:@"%d",score] forState:UIControlStateNormal];
    }else{
         markButton.hidden = YES;   
        [markButton setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)setImage:(UIImage *)image
{
    [imageView clear];
    [imageView setImage:image];
    [GlobalGetImageCache() manage:imageView];
}

- (void)clickOnAvatar
{
//    PPDebug(@"clickOnAvatar");
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:_userId];
    }
}
- (void)setAvatarFrame:(CGRect)frame
{
    self.frame = frame;
    bgView.frame = [self calAvatarFrame];
    imageView.frame = self.bounds;
//    imageView.frame = frame;//CGRectMake(0, 0, frame.size.width, frame.size.height);
}
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
- (void)setAvatarSelected:(BOOL)selected
{
    if (selected) {
        [bgView setImage:[[ShareImageManager defaultManager] avatarSelectImage]];
    }else{
        [bgView setImage:[[ShareImageManager defaultManager] avatarUnSelectImage]];
    }
}
- (void)setHasPen:(BOOL)hasPen
{
    if (markButton == nil) {
        markButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [markButton retain];
        markButton.frame = CGRectMake(self.frame.size.width*0.6, self.frame.size.height*0.6, self.frame.size.width*0.4, self.frame.size.height*0.4);
        [self addSubview:markButton];
        markButton.userInteractionEnabled = NO;
        ShareImageManager *manager = [ShareImageManager defaultManager];
        [markButton setBackgroundImage:[manager drawingMarkLargeImage] forState:UIControlStateNormal];
    }
    markButton.hidden = !hasPen;
}
@end
