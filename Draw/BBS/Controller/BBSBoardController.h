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
#import "AdService.h"

@interface BBSBoardController : PPTableViewController<BBSServiceDelegate, BBSBoardSectionDelegate>
{

}

@property (nonatomic, retain) UIView* adView;

@end
