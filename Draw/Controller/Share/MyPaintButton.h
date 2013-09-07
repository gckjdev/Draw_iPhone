//
//  MyPaintButton.h
//  Draw
//
//  Created by Orange on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyPaintButton;
@class MyPaint;

@interface MyPaintButton : UIButton
{
    MyPaint *_paint;
}
@property (retain, nonatomic) IBOutlet UILabel *drawWord;
@property (retain, nonatomic) IBOutlet UIImageView *myPrintTag;
@property (retain, nonatomic) IBOutlet UIImageView *drawImage;
@property (retain, nonatomic) IBOutlet MyPaint *paint;

@property (retain, nonatomic) IBOutlet UIView *holderView;

+ (CGSize)buttonSize;
+ (MyPaintButton*)creatMyPaintButton;
- (void)setInfo:(MyPaint *)paint;

@end
