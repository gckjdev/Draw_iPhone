//
//  ShareCell.h
//  Draw
//
//  Created by Orange on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyPaintButton.h"
#import "PPTableViewCell.h"
#define IMAGES_PER_LINE 4

@class MyPaint;

@protocol ShareCellDelegate <NSObject>

@optional
- (void)didSelectPaint:(MyPaint *)paint;
@end

@interface ShareCell : PPTableViewCell
{

}
@property (retain, nonatomic) NSIndexPath* indexPath;
@property (assign, nonatomic) id<ShareCellDelegate> delegate;

+ (ShareCell*)creatShareCellWithIndexPath:(NSIndexPath *)indexPath delegate:(id<ShareCellDelegate>)aDelegate;
+ (NSString*)getIdentifier;
- (void)setPaints:(NSArray *)paints;

@end
