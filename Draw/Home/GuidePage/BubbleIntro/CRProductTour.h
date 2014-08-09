//
//  CRProductTour.h
//  ProductTour
//
//  Created by Clément Raussin on 12/02/2014.
//  Copyright (c) 2014 Clément Raussin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRBubble.h"

@interface CRProductTour : UIView

@property (nonatomic, strong)  NSMutableArray *bubblesArray;
@property (nonatomic, strong) UIButton *closeButton;

-(void)setBubbles:(NSMutableArray*)arrayOfBubbles;
-(void)refreshBubbleArray;
-(UIButton*)buildCloseButtonX:(NSInteger)x
                            Y:(NSInteger)y
                          Tag:(NSInteger)tag;

@end
