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
- (void)setEnabled:(BOOL)enabled;

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
    NSString *_userId;
}

- (void)setUrlString:(NSString *)urlString;
- (id)initWithUrlString:(NSString *)urlString type:(AvatarType)aType gender:(BOOL)gender;
@property(nonatomic, assign) NSInteger score;
@property(nonatomic, retain) NSString *userId;
//- (void)addTarget:(id)target action:(SEL)action;
@end

