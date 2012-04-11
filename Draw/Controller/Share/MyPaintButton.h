//
//  MyPaintButton.h
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyPaintButton;

@protocol MyPaintButtonDelegate <NSObject>
- (void)clickImage:(MyPaintButton*)myPaintButton;
@end

@interface MyPaintButton : UIView
@property (retain, nonatomic) IBOutlet UIImageView *wordsBackground;

@property (retain, nonatomic) IBOutlet UIButton *clickButton;
@property (retain, nonatomic) IBOutlet UILabel *drawWord;
@property (nonatomic, retain) IBOutlet UIImageView* background;
@property (retain, nonatomic) IBOutlet UIImageView *myPrintTag;
@property (retain, nonatomic) id<MyPaintButtonDelegate>delegate;

+ (MyPaintButton*)creatMyPaintButton;
+ (MyPaintButton*)createMypaintButtonWith:(UIImage*)buttonImage 
                                 drawWord:(NSString*)drawWord 
                              isDrawnByMe:(BOOL)isDrawnByMe 
                                 delegate:(id<MyPaintButtonDelegate>)delegate;
@end
