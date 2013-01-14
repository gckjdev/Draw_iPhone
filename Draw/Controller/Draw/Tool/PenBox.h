//
//  PenBox.h
//  Draw
//
//  Created by gamy on 12-12-28.
//
//

#import <UIKit/UIKit.h>
#import "ItemType.h"

@class PenBox;

@protocol PenBoxDelegate <NSObject>

@optional
- (void)penBox:(PenBox *)penBox didSelectPen:(ItemType)penType penImage:(UIImage *)image;

@end

@interface PenBox : UIView
+ (id)createViewWithdelegate:(id)delegate;

@property (nonatomic, assign)id<PenBoxDelegate> delegate;

@end
