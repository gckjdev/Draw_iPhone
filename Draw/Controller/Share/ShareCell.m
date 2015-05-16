//
//  ShareCell.m
//  Draw
//
//  Created by Orange on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareCell.h"
#import "MyPaint.h"
#import "UIImageUtil.h"
#import "DrawUtils.h"
#include "CoreDataUtil.h"
#import "MyPaintManager.h"
#import "PPDebug.h"
#import "MyPaintButton.h"

@interface ShareCell() {
        NSArray *_paints;
}

- (IBAction)clickPaintButton:(id)sender;
+ (ShareCell*)creatShareCell;
@end


@implementation ShareCell
@synthesize indexPath = _indexPath;
@synthesize delegate = _delegate;

#define BASE_BUTTON_INDEX 10
+ (ShareCell*)creatShareCell
{
    ShareCell* cell = [self createViewWithXibIdentifier:@"ShareCell"];
    return cell;
}

+ (ShareCell*)creatShareCellWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ShareCellDelegate>)aDelegate
{
    ShareCell* cell = [self creatShareCell];
    cell.indexPath = indexPath;
    cell.delegate = aDelegate;
    
    CGFloat width = [MyPaintButton buttonSize].width;
    CGFloat space = CGRectGetWidth([[UIScreen mainScreen] bounds])/IMAGES_PER_LINE - width;
    for (int i = 0; i < IMAGES_PER_LINE; ++i) {
        MyPaintButton* button = [MyPaintButton creatMyPaintButton];

        [button updateOriginX:space/2+(width+space)*i];
        [button updateOriginY:[MyPaintButton buttonSize].height*0.025];
        
        button.tag = i+BASE_BUTTON_INDEX;
        [cell addSubview:button];
//        cell.contentView.userInteractionEnabled = NO;
//        cell.userInteractionEnabled = NO;
        [button addTarget:cell action:@selector(clickPaintButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

+ (CGFloat)getCellHeight
{
    return [MyPaintButton buttonSize].height*1.05;
}

+ (NSString*)getIdentifier
{
    return @"ShareCell";
}

- (void)setPaints:(NSArray *)paints
{
    
    if (paints != _paints) {
        [_paints release];
        _paints = [paints retain];
    }
    
    
    NSUInteger count = [paints count];
    
    for (int i = 0; i < IMAGES_PER_LINE; ++i) {
        MyPaintButton *button = (MyPaintButton *)[self viewWithTag:BASE_BUTTON_INDEX + i];
        if (button && i < count) {
            MyPaint *paint = [paints objectAtIndex:i];   
            [button setInfo:paint];
        }else {
            button.hidden = YES;
        }
    }

}



- (IBAction)clickPaintButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSUInteger j = button.tag - BASE_BUTTON_INDEX;
    if (j < [_paints count]) {
        MyPaint *paint = [_paints objectAtIndex:j];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPaint:)]) {
            [self.delegate didSelectPaint:paint];
        }
    }
}


- (void)dealloc {
    [_paints release];
    [_indexPath release];
    [super dealloc];
}
@end
