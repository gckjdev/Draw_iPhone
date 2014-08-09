//
//  CRBubble.h
//  ProductTour
//
//  Created by Clément Raussin on 12/02/2014.
//  Copyright (c) 2014 Clément Raussin. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CR_ARROW_SPACE 5
#define CR_ARROW_SIZE 5

@interface CRBubble : UIView
{
    NSArray *stringArray;
    int maxWidth;
    CGPoint isMoving;
    int swipeXPosition;
    int swipeYPosition;
    
    UILabel *descLabel;
}


typedef enum {
    //箭头指向：上下左右位置
    CRArrowPositionTop,
    CRArrowPositionBottom,
    CRArrowPositionRight,
    CRArrowPositionLeft,
    
    //箭头指向：对于角落处的view，使用左上，右上，左下，右下
    CRArrowPositionTopLeft,
    CRArrowPositionTopRight,
    CRArrowPositionBottomLeft,
    CRArrowPositionBottomRight
} CRArrowPosition;

@property (nonatomic, strong) UIView *attachedView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) CRArrowPosition arrowPosition;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic) BOOL isVisible;
@property (nonatomic) NSInteger fontSize;

-(id)initWithAttachedView:(UIView*)view
              description:(NSString*)description
            arrowPosition:(CRArrowPosition)arrowPosition
                 fontSize:(NSInteger)fontSize
                 andColor:(UIColor*)color;
-(CGSize)size;
-(CGRect)frame;
-(void) setVisible:(BOOL)visible;
@end
