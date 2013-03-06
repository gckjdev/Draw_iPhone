//
//  StoreCell.h
//  Draw
//
//  Created by 王 小涛 on 13-3-4.
//
//

#import "PPTableViewCell.h"
#import "GameBasic.pb.h"

@interface StoreCell : PPTableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *itemImageView;
@property (retain, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *itemDescLabel;
@property (retain, nonatomic) IBOutlet UIImageView *promotionImageView;

- (void)setCellInfo:(PBGameItem *)item;


@end
