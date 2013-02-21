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
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ShareCell" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <ShareCell> but cannot find cell object from Nib");
        return nil;
    }
    ShareCell* cell =  (ShareCell*)[topLevelObjects objectAtIndex:0];
    return cell;
}

+ (ShareCell*)creatShareCellWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ShareCellDelegate>)aDelegate
{
    ShareCell* cell = [self creatShareCell];
    cell.indexPath = indexPath;
    cell.delegate = aDelegate;
    float imageButtonHeight;
    float imageButtonWidth;
    float seperator;
    
    if ([DeviceDetection isIPAD]) {
        imageButtonHeight = 189.4;
        imageButtonWidth = 150;
        seperator = 33.6;
    } else {
        imageButtonHeight = 94.7;
        imageButtonWidth = 75;
        seperator = 4;
    }
    
    for (int i = BASE_BUTTON_INDEX; i < BASE_BUTTON_INDEX + IMAGES_PER_LINE; ++i) {
        MyPaintButton* button = [MyPaintButton creatMyPaintButton];
        [button setFrame:CGRectMake((i-BASE_BUTTON_INDEX)*(imageButtonWidth + seperator)+seperator, 2, imageButtonWidth, imageButtonHeight)];
        button.tag = i;
        [cell addSubview:button];
        [button addTarget:cell action:@selector(clickPaintButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

+ (float)getCellHeight
{
    return [DeviceDetection isIPAD]?193.4:98.7;
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
    
    
    int count = [paints count];
    
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
    int j = button.tag - BASE_BUTTON_INDEX;
    if (j >=0 && j < [_paints count]) {
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
