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


- (UIImage *)drawHomeHome;
- (UIImage *)drawHomeMessage;
- (UIImage *)drawHomeOpus;
- (UIImage *)drawHomeSetting;

- (UIImage *)drawHomeMore;
- (UIImage *)drawHomeMe;
- (UIImage *)drawHomeFriend;

//
- (UIImage *)drawHomeSplitline;
- (UIImage *)drawHomeDisplayBG;

//ZJH Image
- (UIImage *)zjhHomeHelp;
- (UIImage *)zjhHomeNormalSite;
- (UIImage *)zjhHomeRichSite;
- (UIImage *)zjhHomeStart;
- (UIImage *)zjhHomeVSSite;
@end
