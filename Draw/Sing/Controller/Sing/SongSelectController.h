//
//  SongSelectController.h
//  Draw
//
//  Created by 王 小涛 on 13-5-29.
//
//

#import <Foundation/Foundation.h>
#import "PPTableViewController.h"
#import "SongService.h"

@interface SongSelectController : PPTableViewController<SongServiceDelegate>

@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@end
