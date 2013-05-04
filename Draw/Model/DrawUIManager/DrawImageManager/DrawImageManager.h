//
//  DrawImageManager.h
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import <Foundation/Foundation.h>

@interface DrawImageManager : NSObject
+ (id)defaultManager;

- (UIImage *)drawHomeBbs;
- (UIImage *)drawHomeContest;
- (UIImage *)drawHomeDraw;
- (UIImage *)drawHomeGuess;
- (UIImage *)drawHomeOnlineGuess;
- (UIImage *)drawHomeShop;
- (UIImage *)drawHomeTimeline;
- (UIImage *)drawHomeTop;
- (UIImage *)drawAppsRecommand;
- (UIImage *)drawFreeCoins;
- (UIImage *)drawPlayWithFriend;

- (UIImage *)drawHomeHome;
- (UIImage *)drawHomeMessage;
- (UIImage *)drawHomeOpus;
- (UIImage *)drawHomeSetting;

- (UIImage *)drawHomeMore;
- (UIImage *)drawHomeMe;
- (UIImage *)drawHomeFriend;

//
- (UIImage *)drawHomeBG;
- (UIImage *)drawHomeSplitline;
- (UIImage *)drawHomeSplitline1;
- (UIImage *)drawHomeDisplayBG;

//ZJH Image
- (UIImage *)zjhHomeHelp;
- (UIImage *)zjhHomeNormalSite;
- (UIImage *)zjhHomeRichSite;
- (UIImage *)zjhHomeStart;
- (UIImage *)zjhHomeVSSite;
- (UIImage *)zjhHomeCharge;
- (UIImage *)zjhHomeMore;

- (UIImage *)zjhHomeFreeCoinBG;

- (UIImage *)diceHomeShop;
- (UIImage *)diceHomeMore;

//learn draw
- (UIImage *)learnDrawBg;
- (UIImage *)learnDrawBottomBar;
- (UIImage *)learnDrawBottomSplit;
- (UIImage *)learnDrawBought;
- (UIImage *)learnDrawDraft;
- (UIImage *)learnDrawDraw;
//- (UIImage *)learnDrawHome;
- (UIImage *)learnDrawMark;
- (UIImage *)learnDrawMore;
- (UIImage *)learnDrawShop;

//dream avatar
- (UIImage *)dreamAvatarDraw;
- (UIImage *)dreamAvatarDraft;
- (UIImage *)dreamAvatarShop;
- (UIImage *)dreamAvatarFreeIngot;
- (UIImage *)dreamAvatarMore;

@end
