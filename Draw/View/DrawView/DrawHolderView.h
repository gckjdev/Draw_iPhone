//
//  DrawHolderView.h
//  Draw
//
//  Created by gamy on 13-3-15.
//
//

#import <Foundation/Foundation.h>
#import "SuperDrawView.h"

@class DrawView;
@class ShowDrawView;

@interface DrawHolderView : UIView
{
    SuperDrawView *_contentView;
}

- (DrawView *)drawView;

- (ShowDrawView *)showView;

- (void)setContentView:(SuperDrawView *)contentView;

+ (id)drawHolderViewWithFrame:(CGRect)frame
                    contentView:(SuperDrawView *)contentView;



@end
