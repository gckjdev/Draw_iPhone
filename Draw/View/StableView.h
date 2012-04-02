//
//  StableView.h
//  Draw
//
//  Created by  on 12-4-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HJManagedImageV;

@interface ToolView : UIButton
{
    NSInteger _number;
    UIButton *numberButton;
}
- (id)initWithNumber:(NSInteger)number;
- (void)setNumber:(NSInteger)number;
- (NSInteger)number;
- (void)addTarget:(id)target action:(SEL)action;
- (void)decreaseNumber;
@end



typedef enum {
    Drawer = 1,
    Guesser = 2
}AvatarType;
@interface AvatarView : UIView
{
    NSInteger _score;
    UIButton *markButton;
    AvatarType type;
    HJManagedImageV *imageView;
}

- (void)setUrlString:(NSString *)urlString;
- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType;
@property(nonatomic, assign) NSInteger score;
//- (void)addTarget:(id)target action:(SEL)action;
@end

