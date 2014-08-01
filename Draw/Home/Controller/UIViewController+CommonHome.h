//
//  UIViewController+CommonHome.h
//  Draw
//
//  Created by qqn_pipi on 14-7-9.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (CommonHome)

- (void)enterFriend;
- (void)enterTopOpus;
- (void)enterTask;
- (void)enterOpusClass;
- (void)enterGroup;
- (void)enterBBS;
- (void)enterContest;
- (void)enterOfflineDraw;
- (void)enterTimeline;
- (void)enterDraftBox;
- (void)enterChat;
- (void)enterMore;
- (void)enterUserDetail;
- (void)showBulletinView;
- (void)goToGuidePage;
- (void)enterMetroHome;
- (void)enterUserSetting;
- (void)enterPainter;
- (void)enterUserTimeline;
- (void)enterShop;
- (void)enterLearnDraw;

- (void)startAudioManager;

- (void)enterBBSWithPostId:(NSString*)postId;
- (void)enterContestWithContestId:(NSString*)contestId;


@end
