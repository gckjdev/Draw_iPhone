//
//  ShareController.h
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ShareCell.h"
#import "ShowDrawView.h"

#import "ANGifEncoder.h"
#import "ANCutColorTable.h"
#import "ANGifNetscapeAppExtension.h"
#import "ANImageBitmapRep.h"
#import "UIImagePixelSource.h"

@interface ShareController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ShareCellDelegate, ShowDrawViewDelegate> {
    NSMutableArray *_paints;
    int _currentSelectedPaint;
}
@property (retain, nonatomic) IBOutlet UISegmentedControl *paintsFilter;
@property (retain, nonatomic) IBOutlet UITableView *gallery;
@property (retain, nonatomic) NSMutableArray* paints;

@end
