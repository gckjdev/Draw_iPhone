//
//  BBSBoardController.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "PPTableViewController.h"
#import "BBSService.h"

@interface BBSBoardController : PPTableViewController<BBSServiceDelegate>
{

}
- (IBAction)clickBackButton:(id)sender;

@end
