//
//  StableView.m
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StableView.h"
#import "ShareImageManager.h"
#import "PPApplication.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "UIImageView+WebCache.h"
#import "GameItemManager.h"
#import "UIButtonExt.h"
#import "UIImageView+Extend.h"

#define TOOL_VIEW_FRAM (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 61 * 1.5, 61 * 1.5) : CGRectMake(0, 0, 61, 61))

#define NUMBER_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(27 * 2, 10 * 2, 24 * 2, 24 * 2) : CGRectMake(27, 10, 24, 24)) 

#define AVATAR_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 34 * 2, 34 * 2) : CGRectMake(0, 0, 32, 32))

#define MARK_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(16 * 2,18 * 2,16 * 2,18 * 2) : CGRectMake(16,18,16,18))


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
        
        PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:type];
        if (item.consumeType == PBGameItemConsumeTypeAmountConsumable) {
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
    PBGameItem *item = [[GameItemManager defaultManager] itemWithItemId:itemType];
    [self setBackgroundImageWithURL:[NSURL URLWithString:item.image]];
    
    if (itemType == ItemTypeTomato) {
        [self setBackgroundImage:[[ShareImageManager defaultManager] tomato] forState:UIControlStateNormal];
    }
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

#define BORDER_WIDTH    (ISIPAD ? 4 : 2)

- (void)setAsRound{
    SET_VIEW_ROUND(self);
    SET_VIEW_ROUND(bgView);
    SET_VIEW_ROUND(imageView);
    
    [bgView setImage:nil];
}

- (void)setBackgroundImage:(UIImage *)image
{
    [bgView setImage:image];
    [bgView setFrame:self.bounds];
    [self sendSubviewToBack:bgView];
}

- (void)setContentInset:(CGSize)contentInset
{
    _contentInset = contentInset;
    [imageView setFrame:CGRectInset(self.bounds, contentInset.width, contentInset.height)];
    bgView.frame = self.bounds;
}

- (void)setAsSquare{
    self.layer.cornerRadius = 0;
    self.layer.masksToBounds = NO;
    bgView.layer.cornerRadius = 0;
    bgView.layer.masksToBounds = NO;
    imageView.layer.cornerRadius = 0;
    imageView.layer.masksToBounds = NO;
}

#define BADGE_VIEW_TAG 32445
- (void)setBadge:(NSInteger)number
{
    BadgeView *badge = [self badgeView];
    if (badge == nil) {
        badge = [BadgeView badgeViewWithNumber:number];
        badge.tag = BADGE_VIEW_TAG;
        [self addSubview:badge];
        [badge updateOriginX:(CGRectGetWidth(self.bounds)-CGRectGetWidth(badge.bounds))];
        [badge updateOriginY:(CGRectGetHeight(badge.bounds))];
    }
}

- (BadgeView *)badgeView
{
    BadgeView *badge = (id)[self viewWithTag:BADGE_VIEW_TAG];
    return badge;
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
    return self.bounds;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
        [bgView setImage:[UIImage imageNamed:@"draw_home_avatar_bg"]];
        [self addSubview:bgView];
        [self setAvatarSelected:NO];
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        
        [self addTapGuesture];
        
        [self setAsRound];
        
        self.layer.borderWidth = BORDER_WIDTH;
        self.layer.borderColor = [COLOR_GRAY_AVATAR CGColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    bgView.frame=self.bounds;
    [self setContentInset:self.contentInset];
}

- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType gender:(BOOL)gender level:(int)level;
{
    
    self = [super initWithFrame:AVATAR_VIEW_FRAME];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        type = aType;
        bgView = [[UIImageView alloc] initWithFrame:[self calAvatarFrame]];
        [bgView setImage:[UIImage imageNamed:@"user_picbg.png"]];
        [self addSubview:bgView];
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
        
        [self setAsRound];
        self.layer.borderWidth = BORDER_WIDTH;
        self.layer.borderColor = [COLOR_GRAY_AVATAR CGColor];
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
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:imageView];
        [self setAvatarUrl:urlString gender:gender];
        [self addTapGuesture];
        [self setAvatarSelected:NO level:level];
        
        [self setAsRound];
        self.layer.borderWidth = BORDER_WIDTH;
        self.layer.borderColor = [COLOR_GRAY_AVATAR CGColor];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame user:(PBGameUser *)user
{
    AvatarView *av = [self initWithUrlString:user.avatar frame:frame gender:user.gender level:user.level];
    av.user = user;
//    PPDebug(@"<AvatarView> initWithFrame, addr = %@", av);
    return av;
}

- (void)setUser:(PBGameUser *)user
{
    [self setUserId:user.userId];
    [self setUrlString:user.avatar];
    [self setGender:user.gender];
    _user = user;
}

- (void)clear
{
    
}


- (void)dealloc
{
//    PPDebug(@"%@ dealloc", self);
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
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatarView:)]) {
        [_delegate didClickOnAvatarView:self];
    }
}
- (void)setAvatarFrame:(CGRect)frame
{
    self.frame = frame;
    bgView.frame = [self calAvatarFrame];
    imageView.frame = self.bounds;
//    imageView.frame = frame;//CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setUrlString:(NSString *)urlString
{
    
    UIImage *defaultImage = [[ShareImageManager defaultManager] avatarImageByGender:self.gender];
    [imageView setImageWithUrl:[NSURL URLWithString:urlString] placeholderImage:defaultImage showLoading:YES animated:YES];
}

- (void)setAvatarUrl:(NSString *)urlString gender:(BOOL)gender
{
    UIImage *placeHolderImage = [[ShareImageManager defaultManager] avatarImageByGender:gender];
    [imageView setImageWithUrl:[NSURL URLWithString:urlString] placeholderImage:placeHolderImage showLoading:YES animated:YES];
}

- (void)setAvatarUrl:(NSString *)urlString gender:(BOOL)gender useDefaultLogo:(BOOL)useDefaultLogo
{
    UIImage *placeHolderImage = nil;
    if (useDefaultLogo){
        placeHolderImage = [[ShareImageManager defaultManager] homeDefaultAvatar];
    }
    else{
        [[ShareImageManager defaultManager] avatarImageByGender:gender];
    }
    [imageView setImageWithUrl:[NSURL URLWithString:urlString] placeholderImage:placeHolderImage showLoading:YES animated:YES];
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


@implementation BadgeView


#define BadgeSize (ISIPAD ?  40: 25)
#define BADGE_FONT (ISIPAD ? [UIFont systemFontOfSize:18] : [UIFont systemFontOfSize:10])
#define DEFAULT_MAX_NUMBER 99


- (void)baseInit
{
    self.userInteractionEnabled = NO;
    
    [self.titleLabel setFont:BADGE_FONT];
    
    [self setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    
    [self setBGImage:[[ShareImageManager defaultManager] badgeImage]];
    [self setMaxNumber:DEFAULT_MAX_NUMBER];
//    [self updateWidth:BadgeSize];
//    [self updateHeight:BadgeSize];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

+ (id)badgeViewWithNumber:(NSInteger)number
{
    BadgeView *badge = [[[BadgeView alloc] initWithFrame:CGRectMake(0, 0, BadgeSize, BadgeSize)] autorelease];
    [badge baseInit];
    [badge setNumber:number];    
    return badge;
}

- (void)setNumber:(NSInteger)number
{
    _number = number;
    [self setHidden:NO];
    if (_number > self.maxNumber) {
        [self setTitle:@"N" forState:UIControlStateNormal];
    }else if(_number <= 0){
        //hide it
        [self setTitle:nil forState:UIControlStateNormal];
        [self setHidden:YES];
    }else{
        [self setTitle:[@(number) stringValue] forState:UIControlStateNormal];
    }
    
}

- (void)setMaxNumber:(NSInteger)maxNumber
{
    _maxNumber = maxNumber;
    [self setNumber:self.number];
}

- (void)setBGImage:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateNormal];
}


@end