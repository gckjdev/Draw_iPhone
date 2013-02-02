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
#import "Item.h"
#import "UIImageView+WebCache.h"

#define TOOL_VIEW_FRAM (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 61 * 2, 61 * 2) : CGRectMake(0, 0, 61, 61))

#define NUMBER_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(27 * 2, 10 * 2, 24 * 2, 24 * 2) : CGRectMake(27, 10, 24, 24)) 

#define AVATAR_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 33 * 2, 34 * 2) : CGRectMake(0, 0, 31, 32))

#define MARK_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(16 * 2,18 * 2,16 * 2,17 * 2) : CGRectMake(16,18,16,17))


#define MARK_FONT_SIZE (([DeviceDetection isIPAD]) ? 12 * 2 : 12)
#define TOOL_NUMBER_SIZE (([DeviceDetection isIPAD]) ? 13 * 2 : 13)

#define MARK_INSET (([DeviceDetection isIPAD]) ? UIEdgeInsetsMake(0, 0, 2 * 2, 0) : UIEdgeInsetsMake(0, 0, 2 * 2, 0))

@implementation ToolView
@synthesize itemType = _itemType;
@synthesize alreadyHas = _alreadyHas;

+ (ToolView *)tipsViewWithNumber:(NSInteger)number
{
    return [[[ToolView alloc] initWithItemType:ItemTypeTips number:number] autorelease];
}

+ (ToolView *)flowerViewWithNumber:(NSInteger)number
{
    return [[[ToolView alloc] initWithItemType:ItemTypeFlower number:number] autorelease];
}
+ (ToolView *)tomatoViewWithNumber:(NSInteger)number
{
    return [[[ToolView alloc] initWithItemType:ItemTypeTomato number:number] autorelease];
}


- (id)initWithItemType:(ItemType)type number:(NSInteger)number
{
    
    self = [super initWithFrame:TOOL_VIEW_FRAM];
    if(self){
        
        self.itemType = type;
        self.userInteractionEnabled = NO;
        

        if ([Item isItemCountable:type]) {
            numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [numberButton setFrame:NUMBER_VIEW_FRAME];
            
            ShareImageManager *imageManager = [ShareImageManager defaultManager];
            [numberButton setBackgroundImage:[imageManager toolNumberImage] forState:UIButtonTypeCustom];
            [numberButton setUserInteractionEnabled:NO];
            float width = self.frame.size.width;
            float height = self.frame.size.height;
            [numberButton setFrame:CGRectMake(width*0.6, height*0.6, width*0.3, height*0.3)];
            
            [self addSubview:numberButton];
            [numberButton.titleLabel setFont:[UIFont systemFontOfSize:TOOL_NUMBER_SIZE]];
            numberButton.titleLabel.minimumFontSize = 10;
            [self setNumber:number];
            [numberButton retain];            
        }else{
            ShareImageManager *imageManager = [ShareImageManager defaultManager];
            alreadyHasFlag = [[[UIImageView alloc] initWithImage:imageManager.buyedImage] autorelease];
 
            float width = self.frame.size.width;
            float height = self.frame.size.height;
            [alreadyHasFlag setFrame:CGRectMake(width*0.5, height*0.5, width*0.3, height*0.5)];
            
            [self addSubview:alreadyHasFlag];
            if (number <= 0) {
                self.alreadyHas = NO;
            } else {
                self.alreadyHas = YES;
            }
            [alreadyHasFlag retain];
        }
        numberButton.hidden = YES;// no more use the tool number --kira
        
    }
    return self;
}

- (void)setItemType:(ItemType)itemType
{
    _itemType = itemType;
    UIImage *image = [Item imageForItemType:itemType];
    [self setImage:image forState:UIControlStateNormal];
}

- (id)initWithNumber:(NSInteger)number
{
    return [self initWithItemType:ItemTypeTips number:number];
}

- (void)dealloc
{
    [numberButton release], numberButton = nil;
    [alreadyHasFlag release], alreadyHasFlag = nil;
    [super dealloc];
}
- (void)setNumber:(NSInteger)number
{
    _number = number;
    NSString *numberString = nil;
    if (number >= 0) {
        numberString = @"N";
        if (number < 100) {
            numberString = [NSString stringWithFormat:@"%d",number];                
        }
    } else {
        numberString = @"0";
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

- (void)setAlreadyHas:(BOOL)alreadyHas
{
    _alreadyHas = alreadyHas;
    if (_alreadyHas) {
        alreadyHasFlag.hidden = NO;
    } else {
        alreadyHasFlag.hidden = YES;
    }
}

+ (CGFloat)width
{
    return TOOL_VIEW_FRAM.size.width;
}
+ (CGFloat)height
{
    return TOOL_VIEW_FRAM.size.height;
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
    CGFloat wEdge = -3.1;//width / EDGE_WIDTH_TIMES;
    CGFloat hEdge = -3.1;//height / EDGE_HEIGHT_TIMES;
    return CGRectMake(wEdge, hEdge, width - 2 * wEdge, height - 3 * hEdge);
}

- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType gender:(BOOL)gender level:(int)level;
{
    
    self = [super initWithFrame:AVATAR_VIEW_FRAME];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        type = aType;
        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
        [self addSubview:bgView];
//        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
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
        [self setAvatarSelected:NO level:level];
    }
    
    return self;
}


- (id)initWithUrlString:(NSString *)urlString frame:(CGRect)frame gender:(BOOL)gender level:(int)level;
{
    self = [super initWithFrame:frame];    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
        [self addSubview:bgView];
        [self setAvatarSelected:NO];
//        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        [self setAvatarUrl:urlString gender:gender];
        [self addTapGuesture];
        [self setAvatarSelected:NO level:level];
    }
    
    return self;
}


- (void)setUrlString:(NSString *)urlString
{
//    [imageView clear];
//    [imageView setUrl:[NSURL URLWithString:urlString]];
//    [GlobalGetImageCache() manage:imageView];
    
    [imageView setImageWithURL:[NSURL URLWithString:urlString]];
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
//    [imageView clear];
    [imageView setImage:image];
//    [GlobalGetImageCache() manage:imageView];
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
//    [imageView clear];
    if (gender) {
        [imageView setImage:[[ShareImageManager defaultManager] 
                             maleDefaultAvatarImage]];
    }else{
        [imageView setImage:[[ShareImageManager defaultManager] 
                             femaleDefaultAvatarImage]];                
    }
    if ([url length] > 0){
//        [imageView setUrl:[NSURL URLWithString:url]];
//        [GlobalGetImageCache() manage:imageView];
        [imageView setImageWithURL:[NSURL URLWithString:url]];
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

- (UIImage*)backgroundForLevel:(int)level
{
    if (level >=40 && level <= 50) {
        return [[ShareImageManager defaultManager] purpleAvatarImage];
    }
    if (level >= 25 && level < 40) {
        return [[ShareImageManager defaultManager] goldenAvatarImage];
    }
    if (level >= 10 && level < 25) {
        return [[ShareImageManager defaultManager] greenAvatarImage];
    }
    return [[ShareImageManager defaultManager] avatarUnSelectImage];
    
}

- (void)setAvatarSelected:(BOOL)selected level:(int)level
{
    if (selected) {
        [bgView setImage:[[ShareImageManager defaultManager] avatarSelectImage]];
    }else{
        [bgView setImage:[self backgroundForLevel:level]];
    }
}
@end
