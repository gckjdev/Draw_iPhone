//
//  ColorShopCell.m
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorShopCell.h"
#import "ColorGroup.h"
#import "ColorView.h"
#import "PPDebug.h"
#import "DeviceDetection.h"
#import "ShareImageManager.h"


@implementation ColorShopCell
@synthesize coinImageView;
@synthesize priceLabel;
@synthesize colorShopCellDelegate = _colorShopCellDelegate;
+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    ColorShopCell *cell = [self createViewWithXibIdentifier:cellId];
    cell.delegate = delegate;
    [cell.priceLabel setTextColor:COLOR_COFFEE];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"ColorShopCell";
}

+ (CGFloat)getCellHeight
{
    return ISIPAD?140:70;
}

- (void)updatePrice:(NSInteger)price
{
    NSString *priceString = [NSString stringWithFormat:@"%d",price];
    [self.priceLabel setText:priceString];
}

- (void)clickColorView:(id)sender
{
    PPDebug(@"<ColorShopCell>click color view");
    if (_colorShopCellDelegate && [_colorShopCellDelegate respondsToSelector:@selector(didPickedColorView:)]) {
        [_colorShopCellDelegate didPickedColorView:sender];
    }
}

#define BASE_COLOR_VIEW_TAG 10
#define COLOR_NUMBER_PER_ROW 5
- (void)setCellInfo:(ColorGroup *)colorGroup hasBought:(BOOL)hasBought
{
    priceLabel.hidden = YES;
    [coinImageView setImage:(hasBought?[ShareImageManager defaultManager].colorBuyedImage:nil)];
    
    if (colorGroup) {
        [self updatePrice:colorGroup.price];
        for (int i = BASE_COLOR_VIEW_TAG; i < BASE_COLOR_VIEW_TAG + COLOR_NUMBER_PER_ROW; ++ i) {
            ColorView *colorView = (ColorView *)[self viewWithTag:i];
            if (colorView) {
                int j = i - BASE_COLOR_VIEW_TAG;
                if(j < [colorGroup.colorViewList count]){
//                    if (colorView.scale != ColorViewScaleLarge) {
                        [colorView setScale:ColorViewScaleLarge];
//                    }
                    ColorView *view = [colorGroup.colorViewList objectAtIndex:j];
                    [colorView setDrawColor:view.drawColor];
                    [colorView setHidden:NO];
                }else{
                    [colorView setHidden:YES];
                }
                colorView.userInteractionEnabled = hasBought;
                [colorView addTarget:self action:@selector(clickColorView:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }    
}

- (void)dealloc {
    [coinImageView release];
    [priceLabel release];
    [super dealloc];
}
@end
