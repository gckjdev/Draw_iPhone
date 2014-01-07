//
//  SongSearchController.h
//  Draw
//
//  Created by 王 小涛 on 13-10-23.
//
//

#import "PPTableViewController.h"
#import "SingOpus.h"
#import "SearchController.h"

#define KEY_NOTIFICATION_SELECT_SONG @"KEY_NOTIFICATION_SELECT_SONG"

@interface SongSearchController : SearchController


- (id)initWithSingOpus:(SingOpus *)opus;

@end
