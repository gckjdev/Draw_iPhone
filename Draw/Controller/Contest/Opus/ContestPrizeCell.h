//
//  ContestPrizeCell.h
//  Draw
//
//  Created by gamy on 13-8-26.
//
//

#import "PPTableViewCell.h"
#import "ContestFeed.h"
#import "StableView.h"

typedef enum{
    ContestPrizeFirst = 1,
    ContestPrizeSecond,
    ContestPrizeThird,
    ContestPrizeSpecial,
}ContestPrize;

@interface ContestPrizeCell : PPTableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *opusImage;
@property (retain, nonatomic) IBOutlet UIImageView *prizeIcon;
@property (retain, nonatomic) IBOutlet AvatarView *avatar;
@property (retain, nonatomic) IBOutlet UIButton *nickButton;
@property (retain, nonatomic) IBOutlet UILabel *prizeLabel;

- (IBAction)clickNickButton:(id)sender;

- (void)setPrize:(ContestPrize)prize
           title:(NSString *)title
            opus:(ContestFeed *)opus;


@end
