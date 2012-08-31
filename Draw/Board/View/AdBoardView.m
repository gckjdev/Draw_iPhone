//
//  AdBoardView.m
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdBoardView.h"
#import "AdService.h"
@implementation AdBoardView


- (id)initWithBoard:(Board *)board
{
    self = [super initWithBoard:board];
    if (self) {
        
    }
    return self;
}

#define AD_Y_SPACE 100
- (void)loadView
{
//    [super loadView];
//            
//    AdBoard *adBoard = (AdBoard *)self.board;
//
//    NSInteger count = [adBoard.adList count];
//    if(count == 0)
//        return;
//    
//    CGFloat adHeight = 50;
//    CGFloat space = (self.frame.size.height - adHeight * count) / (count+1) ;
//    CGFloat y = space;
//    
//    [self clearAllAdView];
//    
//    for (AdObject *adObject in adBoard.adList) {
//        UIView* adView = [[AdService defaultService] createAdInView:self 
//                                    adPlatformType:adObject.platform 
//                                     adPublisherId:adObject.publishId
//                                             frame:CGRectMake(0, y, 320, 50) 
//                                         iPadFrame:CGRectMake((768-320)/2, y, 320, 50)];
//        [_adViewList addObject:adView];
//        y += space + adHeight;
//    }

}

@end
