//
//  price1LabelView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-6.
//
//

#import <UIKit/UIKit.h>
#import "GameBasic.pb.h"

@interface GameItemDetailView : UIView
@property (retain, nonatomic) IBOutlet UIImageView *itemImageView;
@property (retain, nonatomic) IBOutlet UILabel *discountLabel;
@property (retain, nonatomic) IBOutlet UILabel *discountNoteLabel;
@property (retain, nonatomic) IBOutlet UILabel *priceNoteLabel;
@property (retain, nonatomic) IBOutlet UILabel *descNoteLabel;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;



+ (id)createWithItem:(PBGameItem *)item;
- (void)showInView:(UIView *)view;

@end
