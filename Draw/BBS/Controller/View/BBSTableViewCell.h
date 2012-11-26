//
//  BBSTableViewCell.h
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "PPTableViewCell.h"

@class PPTableViewController;

@interface BBSTableViewCell : PPTableViewCell
{
    UIImageView *_avatar;
    UILabel *_nickName;
    UILabel *_content;
    UILabel *_timestamp;
    UIImageView *_image;
    UIButton *_imageMask;
    UIButton *_avatarMask;
}
@property (retain, nonatomic) IBOutlet UIImageView *avatar;
@property (retain, nonatomic) IBOutlet UILabel *nickName;
@property (retain, nonatomic) IBOutlet UILabel *content;
@property (retain, nonatomic) IBOutlet UILabel *timestamp;
@property (retain, nonatomic) IBOutlet UIImageView *image;
@property (retain, nonatomic) IBOutlet UIButton *imageMask;
@property (retain, nonatomic) IBOutlet UIButton *avatarMask;
@property (retain, nonatomic) PPTableViewController *superController;

+ (id )createCellWithIdentifier:(NSString *)identifier
                                      delegate:(id)delegate;

@end
