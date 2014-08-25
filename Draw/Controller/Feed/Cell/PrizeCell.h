//
//  PrizeCell.h
//  Draw
//
//  Created by ChaoSo on 14-8-21.
//
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "StableView.h"
#import "CommentFeed.h"
typedef enum{
    PizeCellPrizeFirst = 1,
    PizeCellPrizeSecond,
    PizeCellPrizeThird,
    PizeCellPrizeCustom,
    PizeCellPrizeMine = INT_MAX,
}PizeCellPrize;
@interface PrizeCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIView *rankNumber;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet UILabel *rankDesc;
@property (retain, nonatomic) IBOutlet UIView *userNameView;
@property (retain, nonatomic) IBOutlet UIButton *opusView;

- (IBAction)clickImageView:(id)sender;
+ (id)createCell:(id)delegate;
+ (NSString *)getCellIdentifier;
+ (CGFloat)getCellHeightWithFeed;
- (void)setCellInfo:(DrawFeed *)feed row:(NSInteger)row;
@end
