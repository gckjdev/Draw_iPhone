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


@implementation ToolView
- (id)initWithNumber:(NSInteger)number
{
    self = [super initWithFrame:CGRectMake(0, 0, 39, 52)];
    if(self){
        self.userInteractionEnabled = NO;
        ShareImageManager *imageManager = [ShareImageManager defaultManager];
        [self setBackgroundImage:[imageManager toolImage] forState:UIControlStateNormal];
        numberButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [numberButton setFrame:CGRectMake(27, 10, 24, 24)];
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
        numberString = @"99+";
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
    self = [super initWithFrame:CGRectMake(0, 0, 32, 32)];
    if (self) {
        type = aType;
        imageView = [[HJManagedImageV alloc] initWithFrame:self.bounds];
        [imageView clear];
        if ([urlString length] > 0){
            [imageView setUrl:[NSURL URLWithString:urlString]];
        }
        else{
            if (gender) {
                [imageView setImage:[[ShareImageManager defaultManager] 
                                     maleDefaultAvatarImage]];
            }else{
                [imageView setImage:[[ShareImageManager defaultManager] 
                                     maleDefaultAvatarImage]];                
            }
        }
        [GlobalGetImageCache() manage:imageView];
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
            [markButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
            UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 2, 0);
            [markButton setTitleEdgeInsets:insets];
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

@end
