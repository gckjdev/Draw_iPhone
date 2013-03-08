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

+ (id)createWithItem:(PBGameItem *)item
            myFriend:(MyFriend *)myFriend
               count:(int)count;


@end
