//
//  BBSTableViewCell.h
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "PPTableViewCell.h"
#import "Bbs.pb.h"

//#define ISIPAD [DeviceDetection isIPAD]
#define IMAGE_HEIGHT (ISIPAD ? 80 * 2.33 : 80)

@protocol BBSTableViewCellDelegate <NSObject>

@optional
- (void)didClickUserAvatar:(PBBBSUser *)user;
- (void)didClickImageWithURL:(NSURL *)url;
- (void)didClickDrawImageWithPost:(PBBBSPost *)post;
- (void)didClickDrawImageWithAction:(PBBBSAction *)action;

@end

@class PPTableViewController;
@class BBSColorManager;
@class BBSImageManager;
@class BBSFontManager;

@interface BBSTableViewCell : PPTableViewCell
{
    UIImageView *_avatar;
    UILabel *_nickName;
    UILabel *_content;
    UILabel *_timestamp;
    UIImageView *_image;
    UIButton *_imageMask;
    UIButton *_avatarMask;
    
    BBSImageManager *_bbsImageManager;
    BBSColorManager *_bbsColorManager;
    BBSFontManager *_bbsFontManager;

}
@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *content;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) IBOutlet UITextView *contentTextView;
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) UIButton *imageMask;
@property (retain, nonatomic) UIButton *avatarMask;
@property (retain, nonatomic) PPTableViewController *superController;

@property (assign, nonatomic) BOOL useContentLabel; //set once when init;

+ (id )createCellWithIdentifier:(NSString *)identifier
                                      delegate:(id)delegate;

- (void)clickAvatarButton:(id)sender;
- (void)clickImageButton:(id)sender;
- (void)updateImageViewFrameWithImage:(UIImage *)image;
@end
