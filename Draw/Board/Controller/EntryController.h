//
//  EntryController.h
//  Draw
//
//  Created by  on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "BoardService.h"
#import "BoardView.h"

@interface EntryController : PPViewController<BoardServiceDelegate, BoardViewDelegate>
- (IBAction)clickBackButton:(id)sender;

@end
