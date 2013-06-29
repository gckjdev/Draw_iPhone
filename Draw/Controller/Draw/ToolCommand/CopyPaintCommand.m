//
//  DrawToCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "CopyPaintCommand.h"
#import "MyFriend.h"
#import "UIImageUtil.h"
#import "DrawToolUpPanel.h"

@implementation CopyPaintCommand

-(void)sendAnalyticsReport{
//    AnalyticsReport(DRAW_CLICK_CHANGE_DRAWTOUSER);
}


//- (void)changeTargetFriend:(MyFriend *)aFriend
//{
//    if (aFriend) {
//        [self.toolHandler changeDrawToFriend:aFriend];
//        [self.toolPanel updateDrawToUser:aFriend];
//    }
//}

- (void)changeCopyPaint:(PBUserPhoto*)photo
{
    if (photo) {
        [self.toolHandler changeCopyPaint:photo];
        if ([self.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
            [(DrawToolUpPanel*)self.toolPanel updateCopyPaint:photo];
        }
    }
}

//- (void)friendController:(FriendController *)controller
//         didSelectFriend:(MyFriend *)aFriend
//{
//    [self changeTargetFriend:aFriend];
//    [controller.navigationController popViewControllerAnimated:YES];
//}

- (void)didGalleryController:(GalleryController *)galleryController SelectedUserPhoto:(PBUserPhoto *)userPhoto
{
    [self changeCopyPaint:userPhoto];
    [galleryController.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)execute
{
    //TODO enter MyFriendController and select the friend
    GalleryController *fc = [[GalleryController alloc] initWithDelegate:self title:NSLS(@"kSelectPhoto")];
    [[[self.toolPanel theViewController] navigationController] pushViewController:fc animated:YES];
    [fc release];
    
    return YES;
}


@end
