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

#define AVATAR_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(0, 0, 32 * 2, 32 * 2) : CGRectMake(0, 0, 32, 32))
#define MARK_VIEW_FRAME (([DeviceDetection isIPAD]) ? CGRectMake(17 * 2,20 * 2,16 * 2,17 * 2) : CGRectMake(17,20,16,17))

#define MARK_FONT_SIZE (([DeviceDetection isIPAD]) ? 12 * 2 : 12)

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

- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType gender:(BOOL)gender;
{
    
    PPDebug(@"<alloc Avatar View>: url = %@, gender = %d", urlString, gender);
    self = [super initWithFrame:AVATAR_VIEW_FRAME];
    if (self) {
        type = aType;
        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
//        [imageView clear];
        if ([urlString length] > 0){
            [imageView setUrl:[NSURL URLWithString:urlString]];
            [GlobalGetImageCache() manage:imageView];
        }
        else{
            if (gender) {
                [imageView setImage:[[ShareImageManager defaultManager] 
                                     maleDefaultAvatarImage]];
            }else{
                [imageView setImage:[[ShareImageManager defaultManager] 
                                     femaleDefaultAvatarImage]];                
            }

        }
        [self addSubview:imageView];
        markButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [markButton retain];
        markButton.frame = CGRectMake(17,20,16,17);
        [self addSubview:markButton];
        markButton.userInteractionEnabled = NO;
        ShareImageManager *manager = [ShareImageManager defaultManager];
        if (type == Drawer) {
            [markButton setImage:[manager drawingMarkSmallImage] forState:UIControlStateNormal];
        }else{
            [markButton setBackgroundImage:[manager scoreBackgroundImage] forState:UIControlStateNormal];            
            [markButton.titleLabel setFont:[UIFont boldSystemFontOfSize:MARK_FONT_SIZE]];
            [markButton setTitleEdgeInsets:MARK_INSET];
            [self setScore:0];
        }
        self.backgroundColor = [UIColor grayColor];
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

@end
