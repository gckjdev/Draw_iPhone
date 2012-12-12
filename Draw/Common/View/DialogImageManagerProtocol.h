//
//  DialogImageManagerProtocol.h
//  Draw
//
//  Created by Kira on 12-12-12.
//
//

#import <Foundation/Foundation.h>
@class UIImage;

@protocol DialogImageManagerProtocol <NSObject>

- (UIImage*)commonDialogBgImage;
- (UIImage*)commonDialogLeftBtnImage;
- (UIImage*)commonDialogRightBtnImage;

- (UIImage*)inputDialogBgImage;
- (UIImage*)inputDialogInputBgImage;
- (UIImage*)inputDialogLeftBtnImage;
- (UIImage*)inputDialogRightBtnImage;




@end
