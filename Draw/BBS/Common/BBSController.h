//
//  BBSController.h
//  Draw
//
//  Created by gamy on 13-3-20.
//
//

#import "CommonTabController.h"
#import "BBSService.h"
#import "MWPhotoBrowser.h"
#import "BBSPostActionCell.h"

@interface BBSController : CommonTabController<BBSServiceDelegate,MWPhotoBrowserDelegate,BBSPostActionCellDelegate>

@end
