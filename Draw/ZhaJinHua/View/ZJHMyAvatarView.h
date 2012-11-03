//
//  ZJHMyAvatarView.h
//  Draw
//
//  Created by Kira on 12-11-3.
//
//

#import "ZJHAvatarView.h"

@interface ZJHMyAvatarView : ZJHAvatarView
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UILabel *coinsLabel;

+ (ZJHMyAvatarView*)createZJHMyAvatarView;

@end
