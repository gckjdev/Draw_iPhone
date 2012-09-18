//
//  ContestController.h
//  Draw
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewController.h"
#import "ContestService.h"

@interface ContestController : PPTableViewController<ContestServiceDelegate>
{
    ContestService *_contestService;
}

- (IBAction)clickBackButton:(id)sender;

@end
