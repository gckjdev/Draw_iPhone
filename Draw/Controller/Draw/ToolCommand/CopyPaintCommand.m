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
#import "MKBlockActionSheet.h"
#import "ChangeAvatar.h"

@interface CopyPaintCommand ()
@property (retain, nonatomic) ChangeAvatar* imagePicker;
@end

@implementation CopyPaintCommand

- (void)dealloc
{
    [_imagePicker release];
    [super dealloc];
}

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
    
    
    MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kSelectFromUserPhoto"), nil] autorelease];

    [actionSheet setActionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return ;
        }
        switch (buttonIndex) {
            case 0: {
                self.imagePicker = [[[ChangeAvatar alloc] init] autorelease];
                [self.imagePicker setAutoRoundRect:NO];
                [self.imagePicker showSelectionView:(PPViewController*)[self.toolPanel theViewController]];
            } break;
            case 1: {
                GalleryController *fc = [[GalleryController alloc] initWithDelegate:self title:NSLS(@"kSelectPhoto")];
                [[[self.toolPanel theViewController] navigationController] pushViewController:fc animated:YES];
                [fc release];
            } break;
            default:
                break;
        }
    }];
    [actionSheet showInView:[self.toolPanel theViewController].view];
    
    return YES;
}


@end
