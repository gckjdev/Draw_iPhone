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

@class PBUserPhoto;
@class GalleryController;

@protocol GalleryControllerDelegate <NSObject>

- (void)didGalleryController:(GalleryController*)galleryController SelectedUserPhoto:(PBUserPhoto*)userPhoto;

@end

@interface GalleryController : CommonTabController <UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, UserPhotoViewDelegate>
- (IBAction)clickFilterUserPhoto:(id)sender;

- (id)initWithDelegate:(id<GalleryControllerDelegate>)delegate;
@end
