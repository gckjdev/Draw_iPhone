//
//  UserPhotoView.h
//  Draw
//
//  Created by Kira on 13-6-7.
//
//

#import <UIKit/UIKit.h>
@class PBUserPhoto;

@protocol UserPhotoViewDelegate <NSObject>

- (void)didClickPhoto:(PBUserPhoto*)photo;

@end


@interface UserPhotoView : UIView
@property (retain, nonatomic) IBOutlet UILabel *createDateLabel;

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (assign, nonatomic) id<UserPhotoViewDelegate>delegate;
- (IBAction)clickPhoto:(id)sender;
+ (UserPhotoView*)createViewWithPhoto:(PBUserPhoto*)photo
                             delegate:(id<UserPhotoViewDelegate>)delegate;
- (void)updateWithUserPhoto:(PBUserPhoto*)photo;
@end
