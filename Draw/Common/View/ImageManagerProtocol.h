//
//  DialogImageManagerProtocol.h
//  Draw
//
//  Created by Kira on 12-12-12.
//
//

#import <Foundation/Foundation.h>
@class UIImage;

@protocol ImageManagerProtocol <NSObject>
@required

- (UIImage*)commonDialogBgImage;
- (UIImage*)commonDialogLeftBtnImage;
- (UIImage*)commonDialogRightBtnImage;

- (UIImage*)inputDialogBgImage;
- (UIImage*)inputDialogInputBgImage;
- (UIImage*)inputDialogLeftBtnImage;
- (UIImage*)inputDialogRightBtnImage;

- (UIImage *)audioOff;
- (UIImage *)audioOn;
- (UIImage *)musicOn;
- (UIImage *)musicOff;
- (UIImage *)settingsBgImage;
- (UIImage *)settingsLeftSelected;
- (UIImage *)settingsLeftUnselected;
- (UIImage *)settingsRightSelected;
- (UIImage *)settingsRightUnselected;

- (UIImage *)roomListBgImage;
- (UIImage *)roomListLeftBtnSelectedImage;
- (UIImage *)roomListLeftBtnUnselectedImage;
- (UIImage *)roomListRightBtnSelectedImage;
- (UIImage *)roomListRightBtnUnselectedImage;
- (UIImage *)roomListBackBtnImage;
- (UIImage *)roomListCellBgImage;
- (UIImage *)roomListCreateRoomBtnBgImage;
- (UIImage *)roomListFastEntryBtnBgImage;


@end
