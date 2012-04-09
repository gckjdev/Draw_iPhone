//
//  ShareController.h
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "ShareCell.h"
#import "ShowDrawView.h"
#import "CommonDialog.h"
#import "ShareAction.h"

@interface ShareController : PPViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, ShareCellDelegate, ShowDrawViewDelegate, CommonDialogDelegate> {
    NSArray*_paints;
    int _currentSelectedPaint;
    NSMutableArray *_gifImages;
    
    int SHARE_AS_PHOTO;
    int SHARE_AS_GIF;
    int REPLAY;
    int DELETE;
    int CANCEL;    
}
@property (retain, nonatomic) IBOutlet UISegmentedControl *paintsFilter;
@property (retain, nonatomic) IBOutlet UITableView *gallery;
@property (retain, nonatomic) NSArray* paints;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) ShareAction *shareAction;

- (IBAction)changeGalleryFielter:(id)sender;

@end
