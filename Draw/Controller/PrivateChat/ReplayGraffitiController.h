//
//  ReplayGraffitiController.h
//  Draw
//
//  Created by haodong on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"

@class ShowDrawView;
@interface ReplayGraffitiController : PPViewController
{
    ShowDrawView *_showDrawView;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) ShowDrawView *showDrawView;
- (id)initWithDrawActionList:(NSArray *)drawActionList;

@end
