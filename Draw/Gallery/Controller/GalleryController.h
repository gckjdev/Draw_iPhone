//
//  GalleryController.h
//  Draw
//
//  Created by Kira on 13-6-7.
//
//

#import "CommonTabController.h"
#import "MWPhotoBrowser.h"
#import "PhotoEditView.h"
#import "UserPhotoView.h"

@interface GalleryController : CommonTabController <UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, UserPhotoViewDelegate>
- (IBAction)clickFilterUserPhoto:(id)sender;
@end
