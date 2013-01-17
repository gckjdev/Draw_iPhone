//
//  AnalyticsManager.h
//  Draw
//
//  Created by qqn_pipi on 12-12-29.
//
//

#import <Foundation/Foundation.h>

#define HOME_CLICK                          @"HOME_CLICK"

#define HOME_ACTION_DRAW                    @"HOME_ACTION_DRAW"
#define HOME_ACTION_GUESS                   @"HOME_ACTION_GUESS"
#define HOME_ACTION_ONLINE                  @"HOME_ACTION_ONLINE"
#define HOME_ACTION_TIMELINE                @"HOME_ACTION_TIMELINE"
#define HOME_ACTION_TOP                     @"HOME_ACTION_TOP"
#define HOME_ACTION_CONTEST                 @"HOME_ACTION_CONTEST"
#define HOME_ACTION_BBS                     @"HOME_ACTION_BBS"
#define HOME_ACTION_SHOP                    @"HOME_ACTION_SHOP"
#define HOME_ACTION_APPS                    @"HOME_ACTION_APPS"
#define HOME_ACTION_FREE_COINS              @"HOME_ACTION_FREE_COINS"
#define HOME_ACTION_PLAY_WITH_FRIEDN        @"HOME_ACTION_PLAY_WITH_FRIEDN"

#define HOME_BOTTOM_USER                    @"HOME_BOTTOM_USER"
#define HOME_BOTTOM_OPUS                    @"HOME_BOTTOM_OPUS"
#define HOME_BOTTOM_FRIEND                  @"HOME_BOTTOM_FRIEND"
#define HOME_BOTTOM_CHAT                    @"HOME_BOTTOM_CHAT"
#define HOME_BOTTOM_MORE                    @"HOME_BOTTOM_MORE"

#define HOME_TOP_AVATAR                     @"HOME_TOP_AVATAR"
#define HOME_TOP_COINS                      @"HOME_TOP_COINS"
#define HOME_TOP_BULLETIN                   @"HOME_TOP_BULLETIN"
#define HOME_TOP_FREE_COINS                 @"HOME_TOP_FREE_COINS"

#define HOME_HOT_DRAW                       @"HOME_HOT_DRAW"


#define REGISTRATION_CLICK                  @"REGISTRATION_CLICK"
#define REGISTRATION_RESULT                 @"REGISTRATION_RESULT"

#define REGISTRATION_EMAIL                  @"EMAIL"

#define TOP_TAB_CLICK                       @"TOP_TAB_CLICK"
#define TOP_TAB_OPUS_CLICK                  @"TOP_TAB_OPUS_CLICK"

#define TOP_TAB_USERS                       @"TOP_TAB_USERS"
#define TOP_TAB_YEARLY                      @"TOP_TAB_YEARLY"
#define TOP_TAB_WEEKLY                      @"TOP_TAB_WEEKLY"
#define TOP_TAB_LATEST                      @"TOP_TAB_LATEST"

#define SHARE_ACTION_CLICK                  @"SHARE_ACTION_CLICK"

#define SHARE_ACTION_SINA                   @"SHARE_ACTION_SINA"
#define SHARE_ACTION_QQ                     @"SHARE_ACTION_QQ"
#define SHARE_ACTION_FACEBOOK               @"SHARE_ACTION_FACEBOOK"
#define SHARE_ACTION_WEIXIN_FRIEND          @"SHARE_ACTION_WEIXIN_FRIEND"
#define SHARE_ACTION_WEIXIN_TIMELINE        @"SHARE_ACTION_WEIXIN_TIMELINE"
#define SHARE_ACTION_ALBUM                  @"SHARE_ACTION_ALBUM"
#define SHARE_ACTION_EMAIL                  @"SHARE_ACTION_EMAIL"
#define SHARE_ACTION_SAVE                   @"SHARE_ACTION_SAVE"

#define CONTEST_HOME_CLICK                  @"CONTEST_HOME_CLICK"

#define CONTEST_HOME_RULE                   @"CONTEST_HOME_RULE"
#define CONTEST_HOME_OPUS                   @"CONTEST_HOME_OPUS"
#define CONTEST_HOME_JOIN                   @"CONTEST_HOME_JOIN"

#define FREE_COIN_CLICK                     @"FREE_COIN_CLICK"
#define FREE_COIN_TYPE_JIFENQIANG           @"JI_FEN_QIANG"
#define FREE_COIN_TYPE_VIDEO                @"VIDEO"
#define FREE_COIN_TYPE_MONEYTREE            @"MONEY_TREE"

#define SELECT_WORD_CLICK                           @"SELECT_WORD_CLICK_"
#define SELECT_WORD_CLICK_TYPE_HOT                  @"HOT_WORD"
#define SELECT_WORD_CLICK_TYPE_CUSTOM               @"CUSTOM_WORD"
#define SELECT_WORD_CLICK_TYPE_SYSTEM               @"SYSTEM_WORD"
#define SELECT_WORD_CLICK_TYPE_DRAFT                @"DRAFT"
#define SELECT_WORD_CLICK_TYPE_LOAD_DRAFTS          @"LOAD_DRAFTS"
#define SELECT_WORD_CLICK_TYPE_ADD_CUSTOM_WORD      @"ADD_CUSTOM_WORD"
#define SELECT_WORD_CLICK_TYPE_MORE_CUSTOM_WORDS    @"MORE_CUSTOM_WORDS"


#define DRAW_CLICK                                  @"DRAW_CLICK"
#define DRAW_CLICK_PEN                              @"DRAW_CLICK_PEN"
#define DRAW_CLICK_COLOR_BOX                        @"DRAW_CLICK_COLOR_BOX"
#define DRAW_CLICK_PALETTE                          @"DRAW_CLICK_PALETTE"
#define DRAW_CLICK_ERASER                           @"DRAW_CLICK_ERASER"
#define DRAW_CLICK_PAINT_BUCKET                     @"DRAW_CLICK_PAINT_BUCKET"
#define DRAW_CLICK_WIDTH                            @"DRAW_CLICK_WIDTH"
#define DRAW_CLICK_ALPHA                            @"DRAW_CLICK_ALPHA"
#define DRAW_CLICK_REDO                             @"DRAW_CLICK_REDO"
#define DRAW_CLICK_UNDO                             @"DRAW_CLICK_UNDO"
#define DRAW_CLICK_CHAT                             @"DRAW_CLICK_CHAT"

@interface AnalyticsManager : NSObject

+ (AnalyticsManager*)sharedAnalyticsManager;

- (void)reportClickHomeMenu:(NSString*)menuName;
- (void)reportClickHomeElements:(NSString*)elementName;

- (void)reportRegistration:(NSString*)snsName;
- (void)reportRegistrationResult:(int)errorCode;

- (void)reportTopTabClicks:(NSString*)tabName;
- (void)reportTopDrawClicks:(NSString*)tabName;

- (void)reportDrawDetailsActionClicks:(NSString*)actionName;
- (void)reportShareActionClicks:(NSString*)actionName;

- (void)reportContestHomeClicks:(NSString*)name;

- (void)reportFreeCoins:(NSString*)freeCoinName;
- (void)reportSelectWord:(NSString*)wordType;

- (void)reportDrawClick:(NSString*)name;

@end
