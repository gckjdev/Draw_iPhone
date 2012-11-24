//
//  BBSBoardController.h
//  Draw
//
//  Created by gamy on 12-11-14.
//
//

#import "PPTableViewController.h"
#import "BBSService.h"
#import "BBSBoardSection.h"

@interface BBSBoardController : PPTableViewController<BBSServiceDelegate, BBSBoardSectionDelegate>
{

}
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickMyPostList:(id)sender;
- (IBAction)clickMyAction:(id)sender;

@end
