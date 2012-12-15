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

#define CELL_HEIGHT_IPHONE 93.0
#define CELL_HEIGHT_IPAD ((CELL_HEIGHT_IPHONE)*2.0)

#define CELL_HEIGHT ([DeviceDetection isIPAD] ? (CELL_HEIGHT_IPAD) : (CELL_HEIGHT_IPHONE))

@implementation ColorShopCell
@synthesize coinImageView;
@synthesize priceLabel;
@synthesize colorShopCellDelegate = _colorShopCellDelegate;
+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
//    PPDebug(@"<ColorShopCell>cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        PPDebug(@"<ColorShopCell>create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"ColorShopCell";
}

+ (CGFloat)getCellHeight
{
    return CELL_HEIGHT;
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
