//
//  GalleryController.h
//  Draw
//
//  Created by Kira on 13-6-7.
//
//

#import "CommonTabController.h"
#import "MWPhotoBrowser.h"
#import "GalleryPictureInfoEditView.h"


@interface GalleryController : CommonTabController <UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate, GalleryPictureInfoEditViewDelegate>

@end
