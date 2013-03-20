//
//  GiftDetailView.h
//  Draw
//
//  Created by 王 小涛 on 13-3-8.
//
//

#import <UIKit/UIKit.h>
#import "GameBasic.pb.h"
#import "MyFriend.h"

@interface GiftDetailView : UIView
@property (retain, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *countLable;
@property (retain, nonatomic) IBOutlet UILabel *priceLabel;
@property (retain, nonatomic) IBOutlet UIImageView *currencyImageView;
@property (retain, nonatomic) IBOutlet UIImageView *itemImageView;
@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;

+ (id)createWithItem:(int)itemId
            myFriend:(MyFriend *)myFriend
               count:(int)count;


@end
