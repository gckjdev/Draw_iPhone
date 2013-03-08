//
//  GiftDetailView.m
//  Draw
//
//  Created by 王 小涛 on 13-3-8.
//
//

#import "GiftDetailView.h"
#import "AutoCreateViewByXib.h"
#import "PBGameItemUtils.h"


@implementation GiftDetailView

AUTO_CREATE_VIEW_BY_XIB(GiftDetailView);

+ (id)createWithItem:(PBGameItem *)item
            myFriend:(MyFriend *)myFriend
               count:(int)count
{
    return nil;
}

@end
