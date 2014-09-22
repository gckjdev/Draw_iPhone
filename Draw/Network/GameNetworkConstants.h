//
//  GroupBuyNetworkConstants.h
//  groupbuy
//
//  Created by qqn_pipi on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PPNetworkRequest.h"

#define SERVER_URL                          (GlobalGetServerURL())
#define API_SERVER_URL                      SERVER_URL
#define TRAFFIC_SERVER_URL                  (GlobalGetTrafficServerURL())
#define BOARD_SERVER_URL                    (GlobalGetBoardServerURL())
//#define APP_ID                      @"Game"

#define STRING_SEPERATOR @"$"

//#define SHARE_KEY @"NetworkRequestShareKey"

//for opus
#define METHOD_SUBMIT_OPUS @"submitOpus"
#define METHOD_RANDOM_GET_SONGS @"randomGetSongs"
#define METHOD_SEARCH_SONG @"searchSong"

#define PARA_SUB_CATEGORY @"subCategory"
#define METHOD_RECOVERY_OPUS @"constructIndex"
#define METHOD_FIX_EMPTY_USER @"fixEmptyUser"
#define METHOD_GET_OPUS @"getOpus"
#define METHOD_RANK_OPUS @"rankOpus"
#define METHOD_SET_OPUS_HOT_SCORE @"setOpusHotScore"
#define METHOD_EXPORT_USER_OPUS @"exportOpus"

// for guess
#define METHOD_GET_USER_GUESS_OPUSES @"getUserGuessOpus"
#define PARA_MODE @"mode"
#define PARA_IS_START_NEW @"isStartNew"

#define METHOD_GUESS_OPUS @"guessOpus"
#define METHOD_GET_USER_GUESS_RANK @"getUserGuessRank"
#define METHOD_GET_GUESS_RANK_LIST @"getGuessRankList"
#define METHOD_GET_GUESS_CONTEST_LIST @"getGuessContestList"
#define METHOD_GET_RECENT_GUESS_CONTEST_LIST @"getRecentGuessContestList"


// method name

#define METHOD @"m1"                    // set by Benson, use m1 for security
#define METHOD_TEST @"test"
#define METHOD_ONLINESTATUS @"srpt"
#define METHOD_REGISTRATION @"reg"
#define METHOD_CREATEPOST @"cp"
#define METHOD_CREATEPLACE @"cpl"
#define METHOD_GETUSERPLACES @"gup"
#define METHOD_GETPLACEPOST @"gpp"
#define METHOD_GETNEARBYPLACE @"gnp"
#define METHOD_USERFOLLOWPLACE @"ufp"
#define METHOD_USERUNFOLLOWPLACE @"unfp"
#define METHOD_GETUSERFOLLOWPOSTS @"guf"
#define METHOD_GETNEARBYPOSTS @"gne"
#define METHOD_GETUSERFOLLOWPLACES @"gufp"
#define METHOD_DEVICELOGIN @"dl"
#define METHOD_GETPOSTRELATEDPOST @"gpr"
#define METHOD_BINDUSER @"bu"
#define METHOD_UPDATE_USER_DEVICE @"updateUserDevice"
#define METHOD_REMOVE_USER_DEVICE @"removeUserDevice"

#define METHOD_SENDMESSAGE @"sm"
#define METHOD_GETMYMESSAGE @"gmm"
#define METHOD_DELETEMESSAGE @"dmm"
#define METHOD_GETMEPOST @"gmep"
#define METHOD_UPDATEUSER @"uu"
#define METHOD_USERFEEDBACK @"ufb"
#define METHOD_USER_READ_MSG @"urm"
#define METHOD_GETMESSAGESTATLIST @"gmsl"
#define METHOD_GETMESSAGELIST @"gml"
#define METHOD_NEW_GETMESSAGELIST @"getMessageList"


#define METHOD_REGISTERUSER @"ru"
#define METHOD_BINDUSER @"bu"

#define METHOD_UPDATEPLACE @"up"
#define METHOD_GETPLACE @"gtp"
#define METHOD_GETPUBLICTIMELINE @"gpt"
#define METHOD_ACTIONONPOST @"aop"	

#define METHOD_GETAPPUPDATE @"gau"
#define METHOD_UPDATEKEYWORD @"uk"
#define METHOD_ACTIONONPRODUCT @"ap"
#define METHOD_WRITEPRODUCTCOMMENT @"wpc"
#define METHOD_GETPRODUCTCOMMENTS @"gpc"

#define METHOD_REGISTERDEVICE @"rd"
#define METHOD_FINDPRODUCTWITHPRICE @"fpp"
#define METHOD_FINDPRODUCTWITHREBATE @"fpd"
#define METHOD_FINDPRODUCTWITHBOUGHT @"fpb"
#define METHOD_FINDPRODUCTWITHLOCATION @"fpl"
#define METHOD_FINDPRODUCTSGROUPBYCATEGORY @"fgc"
#define METHOD_FINDPRODUCTS @"fp"
#define METHOD_FINDPRODUCTSBYKEYWORD @"fpk"
#define METHOD_FINDPRODUCTSBYSCORE @"fps"

#define METHOD_ADDSHOPPINGITEM @"asi"
#define METHOD_UPDATESHOPPINGITEM @"usi"
#define METHOD_DELETESHOPPINGITEM @"dsi"
#define METHOD_GETSHOPPINGITEM @"gsi"
#define METHOD_GETITEMMATCHCOUNT @"csip"
#define METHOD_FINDPRODUCTSBYSHOPPINGITEMID @"fpsi"
#define METHOD_GETALLCATEGORY @"gac"

#define METHOD_LOGIN @"lg"

#define METHOD_SEGMENTTEXT @"st"
#define METHOD_COMPAREPRODUCT @"comp"

//friends method
#define METHOD_FINDFRIENDS @"ff"
#define METHOD_GET_FRIEND_LIST @"gfrl"
#define METHOD_SEARCHUSER @"su"
#define METHOD_FOLLOWUSER @"fu"
#define METHOD_UNFOLLOWUSER @"ufu"
#define METHOD_GET_RELATION_COUNT @"grc"

//game method
#define METHOD_FETCH_SHOPPING_LIST @"gpri"
#define METHOD_GET_ACCOUNT_BALANCE @"gab"

#define METHOD_FIND_ROOM_BY_USER @"fru"
#define METHOD_INVITE_USER @"ivu"    
#define METHOD_SEARCH_ROOM @"scr"
#define METHOD_UPDATE_ROOM @"udr"
#define METHOD_CREATE_ROOM @"cr"
#define METHOD_JOIN_ROOM @"jr"
#define METHOD_REOMOVE_ROOM @"rr"
#define METHOD_NEW_JOIN_ROOM @"njr"

#define METHOD_GET_STATISTICS @"gss"
#define METHOD_REPORT_STATUS  @"rs" 

#define METHOD_DELETE_SINGLE_MESSAGE @"deleteMessage"

//find draw
#define METHOD_FINDDRAW @"fd"

//for levelService
#define METHOD_SYND_LEVEL_EXP           @"sle"
#define METHOD_INCREASE_EXPERIENCE      @"increaseExp"

//for Draw offline
#define METHOD_CREATE_OPUS @"cop"
#define METHOD_CREATE_OPUS_IMAGE @"coi"
#define METHOD_UPDATE_OPUS @"uop"
#define METHOD_MATCH_OPUS  @"mop"
#define METHOD_GET_OPUS_BY_ID @"goi"
#define METHOD_GET_FEED_LIST  @"gfl"
#define METHOD_GET_OPUST_COUNT @"goc"
#define METHOD_ACTION_ON_OPUS  @"aoo"
#define METHOD_GET_FEED_COMMENT_LIST @"gfc"
#define METHOD_GET_OUPS_TIMES @"got"

#define METHOD_GET_NEW_NUMBER           @"getNewNumber"
#define METHOD_REGISTER_NEW_USER_NUMBER @"registerNewUserNumber"
#define METHOD_GET_NUMBERS_FOR_USER     @"getNumbersForUser"
#define METHOD_LOGIN_NUMBER             @"loginNumber"
#define METHOD_LOGOUT_NUMBER            @"logoutNumber"
#define METHOD_SEND_PASSWORD            @"sendPassword"
#define METHOD_SET_USER_NUMBER          @"setUserNumber"
#define METHOD_SET_FRIEND_MEMO          @"setFriendMemo"
#define METHOD_VERIFY_ACCOUNT           @"verifyAccount"
#define METHOD_SEND_VERFICATION         @"sendVerification"
#define METHOD_PURCHASE_VIP             @"purchaseVip"
#define METHOD_GET_BUY_VIP_COUNT        @"buyVipCount"
#define METHOD_AWARD_APP                @"awardApp"
#define METHOD_SET_USER_OFF_GROUP       @"setUserOffGroup"

#define METHOD_GET_VIP_PURCHASE_INFO    @"getVipPurchaseInfo"
#define PARA_VIP_NEXT_OPEN_DATE         @"vipNextOpenDate"
#define PARA_CAN_BUY_VIP                @"canBuyVip"
#define PARA_VIP_MONTH_LEFT             @"vipMonthLeft"
#define PARA_VIP_YEAR_LEFT              @"vipYearLeft"

#define PARA_REMOVE_OLD_NUMBER          @"removeOldNumber"
#define PARA_SET_USER_NUMBER            @"setUserNumber"
#define PARA_XIAOJI_NUMBER              @"xn"
#define PARA_TEST                       @"test"


//contest
#define METHOD_GET_CONTEST_OPUS_LIST @"gcol"

#define METHOD_BLACK_USER   @"blu"
#define METHOD_BLACK_FRIEND @"blf"

#define METHOD_NEW_UPDATE_USER      @"updateUser"
#define METHOD_UPLOAD_USER_IMAGE    @"uploadUserImage"

#define PARA_COMMENT_TIMES @"cmt"
#define PARA_GUESS_TIMES @"gt"
#define PARA_CORRECT_TIMES @"crt"
#define PARA_FLOWER_TIMES @"ft"
#define PARA_TOMATO_TIMES @"tt"
#define PARA_SAVE_TIMES @"st"
#define PARA_PLAY_TIMES @"pt"

//for gallery
#define METHOD_ADD_USER_PHOTO    @"addUserPhoto"
#define METHOD_UPDATE_USER_PHOTO   @"uup"
#define METHOD_GET_USER_PHOTO_LIST     @"getUserPhoto"
#define METHOD_DELETE_USER_PHOTO   @"deleteUserPhoto"

#define PARA_USER_PHOTO_TAGS             @"tag"
#define PARA_USER_PHOTO_ID               @"userPhotoId"
#define PARA_USAGE                       @"usage"

#define ACTION_TYPE_GUESS                   2
#define ACTION_TYPE_COMMENT                 3
#define ACTION_TYPE_SAVE                    100
#define ACTION_TYPE_ADD_FAVORITE            (ACTION_TYPE_SAVE)
#define ACTION_TYPE_REMOVE_FAVORITE         101
#define ACTION_TYPE_RECOMMEND_OPUS          102
#define ACTION_TYPE_UNRECOMMEND_OPUS        103
#define ACTION_TYPE_REJECT_DRAW_TO_ME_OPUS  104
#define ACTION_TYPE_CONTEST_COMMENT         105
#define ACTION_TYPE_PLAY_OPUS               106

// for item
#define METHOD_BUY_ITEM @"buyItem"
#define METHOD_CONSUME_ITEM @"consumeItem"

// for traffic server
#define PARA_SERVER_ADDRESS @"sa"
#define PARA_SERVER_PORT @"sp"
#define PARA_SERVER_LANGUAGE @"sl"
#define PARA_SERVER_USER_COUNT @"su"
#define PARA_SERVER_USAGE @"us"
#define PARA_SERVER_CAPACITY @"sc"

#define METHOD_GET_TRAFFIC_SERVER_LIST @"gt"
#define METHOD_CHARGE_ACCOUNT @"ca"
#define METHOD_CHARGE_INGOT @"cia"

#define METHOD_DEDUCT_ACCOUNT @"da"
#define METHOD_UPDATE_ITEM_AMOUNT @"uia"
#define METHOD_UPDATE_ACCOUNT_BALANCE @"uab"
#define METHOD_SYNC_USER_ACCOUNT_ITEM @"sai"
#define METHOD_SYNC_ACCOUNT @"syncAccount"

#define METHOD_FEEDBACK @"fb"
#define METHOD_COMMIT_WORDS @"cw"

#define METHOD_GET_TARGET_USER_LIST_INFO    @"gtuli"
#define METHOD_GET_TARGET_USER_INFO    @"gtui"
#define METHOD_DELETE_FEED @"delf"
#define METHOD_GET_RECOMMEND_APP    @"gra"

#define METHOD_GET_TOP_PLAYERS @"gtpl"

//game parameters

#define PARA_SHOPPING_TYPE @"pt"
#define PARA_SHOPPING_AMOUNT @"pa"
#define PARA_SHOPPING_VALUE @"val"
#define PARA_APPLE_IAP_PRODUCT_ID @"ipi"

#define PARA_ACCOUNT_BALANCE @"ab"
#define PARA_ACCOUNT_INGOT_BALANCE @"aib"

#define PARA_SAVE_PERCENT @"sp"
#define PARA_RESCUE_DATA_TAG @"rdt"

#define PARA_AMOUNT @"pa"
#define PARA_AWARD_APPID @"awardAppId"
#define PARA_FORCE_BY_ADMIN @"forceByAdmin"
#define PARA_SOURCE @"sr"
#define PARA_TRANSACTION_ID @"tid"
#define PARA_TRANSACTION_RECEIPT @"tre"
#define  PARA_ADMIN_USER_ID  @"auid"
#define PARA_ITEM_TYPE @"it"
#define PARA_ITEM_AMOUNT @"ia"
#define PARA_ITEMS @"is"
#define PARA_DEVIATION @"dv"
#define PARA_GUESS_BALANCE @"gb"
#define PARA_AWARD_EXP @"ae"

#define PARA_ROOM_ID @"frid"
#define PARA_ROOM_NAME @"rn"
#define PARA_USERID_LIST @"uids"
#define PARA_LAST_PLAY_DATE @"lpd"
#define PARA_PLAY_TIMES @"pt"
#define PAPA_ROOM_USERS @"rus"
#define PARA_OFFSET @"os"
#define PARA_COUNT @"ct"
#define PARA_FORWARD @"fw"
#define PARA_RET_COUNT @"cnt"


// alix pay order parameters
#define PARA_ALIPAY_ORDER  @"alixorder"

// request parameters
#define METHOD_GET_MYCOMMENT_LIST @"gmcl"
#define PARA_USERS @"users"
#define PARA_USERID @"uid"
#define PARA_CREATOR_USERID @"cuid"
#define PARA_LOGINID @"lid"
#define PARA_LOGINIDTYPE @"lty"
#define PARA_USERTYPE @"uty"
#define PARA_PASSWORD @"pwd"
#define PARA_NEW_PASSWORD @"npwd"

#define PARA_USER @"user"

#define PARA_SINA_ID @"siid"
#define PARA_QQ_ID @"qid"

#define PARA_USER_COINS @"ucn"


#define PARA_FACEBOOKID @"fid"
#define PARA_RENRENID @"rid"
#define PARA_TWITTERID @"tid"

#define PARA_DEVICEID @"did"
#define PARA_DEVICETYPE @"dty"
#define PARA_DEVICEMODEL @"dm"
#define PARA_DEVICEOS @"dos"
#define PARA_DEVICETOKEN @"dto"
#define PARA_NICKNAME @"nn"
#define PARA_SIGNATURE @"sig"
#define PARA_AUTO_REG @"are"
#define PARA_RETURN_XIAOJI @"retxj"

#define PARA_STROKES @"stro"
#define PARA_DRAFT_CREATE_DATE @"dcrd"
#define PARA_COMPLETE_DATE @"coda"
#define PARA_SPEND_TIME @"spti"

#define PARA_MOBILE @"mb"
#define PARA_EMAIL @"em"
#define PARA_NEW_APPID  @"napp"
#define PARA_VERIFYCODE @"code"

#define PARA_IS_DATA_ZIP            @"idz"
#define PARA_IS_DATA_COMPRESSED     @"idc"
#define PARA_RETURN_DATA_METHOD     @"rdm"
#define PARA_RETURN_COMPRESSED_DATA @"rcd"

#define PARA_TO_USERID @"tuid"
#define PARA_MESSAGE_ID @"mid"
#define PARA_TARGET_MESSAGE_ID @"tmd"

#define PARA_COUNTRYCODE @"cc"

#define PARA_MATCHITEMCOUNT @"mic"

#define PARA_LANGUAGE @"lang"
#define PARA_CONTEST @"contest"

#define PARA_APPID @"app"
#define PARA_GAME_ID @"gid"
#define PARA_DRAW_DATA @"dd"
#define PARA_OPUS_META_DATA @"meta_data"
#define PARA_OPUS_IMAGE_DATA @"image"
#define PARA_OPUS_DATA @"data"
#define PARA_UPLOAD_DATA_TYPE @"dataType"
#define PARA_MAX_FLOWER_TIMES @"maxFlowerTimes"

#define PARA_DRAW_IMAGE         @"photo"
#define PARA_DRAW_BG_IMAGE      @"bg_image"
#define PARA_FEED_ID @"fid"

#define PARA_WALL_DATA @"wall_data"
#define PARA_WALL_BG_IMAGE @"wall_bg_image"

#define PARA_COMMENT_CONTENT @"comc"

#define PARA_COMMENT_TYPE @"cmt"
#define PARA_COMMENT_ID @"cmid"
#define PARA_COMMENT_SUMMARY @"cmsm"
#define PARA_COMMENT_USERID @"cmuid"
#define PARA_COMMENT_NICKNAME @"cmnn"

#define PARA_ITEMIDARRAY @"iia"
#define PARA_REQUIRE_MATCH @"rm"
#define PARA_TYPE @"tp"
#define PARA_NOTICEID @"nid"
#define PARA_CREDENTIAL @"credential"
#define PARA_SELL_CONTENT_TYPE @"sct"
#define PARA_OPUS_ID_LIST @"opusIdList"

#define PARA_NEED_RETURN_USER           @"r"
#define PARA_AVATAR                     @"av"
#define PARA_BACKGROUND                 @"bg"
#define PARA_URL                        @"url"
#define PARA_ACCESS_TOKEN               @"at"
#define PARA_ACCESS_TOKEN_SECRET        @"ats"
#define PARA_PROVINCE                   @"pro"
#define PARA_CITY                       @"ci"
#define PARA_LOCATION                   @"lo"
#define PARA_GENDER                     @"ge"
#define PARA_BIRTHDAY                   @"bi"
#define PARA_SINA_NICKNAME              @"sn"
#define PARA_SINA_DOMAIN                @"sd"
#define PARA_QQ_NICKNAME                @"qn"
#define PARA_QQ_DOMAIN                  @"qd"
#define PARA_GPS                        @"gps"
#define PARA_FACEBOOK_NICKNAME          @"fn"
#define PARA_FACEBOOK_ACCESS_TOKEN      @"fat"
#define PARA_FACEBOOK_EXPIRE_DATE       @"fed"

#define PARA_SINA_REFRESH_TOKEN         @"srt"
#define PARA_SINA_EXPIRE_DATE           @"sed"

#define PARA_QQ_REFRESH_TOKEN           @"qrt"
#define PARA_QQ_EXPIRE_DATE             @"qed"
#define PARA_QQ_OPEN_ID                 @"qqoid"
#define PARA_REFRESH_TOKEN              @"rto"

#define PARA_DOMAIN                     @"d"
#define PARA_SNS_ID                     @"sid"


#define PARA_OPUS_ID @"opid"
#define PARA_CORRECT @"cre"
#define PARA_ACTION_TYPE @"act"
#define PARA_DAY @"day"
#define PARA_WORD_LIST @"wl"
#define PARA_OPUS_CREATOR_UID @"opc"
#define PARA_RETURN_ITEM @"ri"
#define PARA_DATA_LEN @"dataLen"

#define PARA_RADIUS @"ra"
#define PARA_POSTTYPE @"pt"
#define PARA_NAME @"na"
#define PARA_DESC @"de"
#define PARA_AFTER_TIMESTAMP @"at"
#define PARA_BEFORE_TIMESTAMP @"bt"
#define PARA_MAX_COUNT @"mc"

#define PARA_TOTAL_VIEW     @"tv"
#define PARA_TOTAL_FORWARD  @"tf"
#define PARA_TOTAL_QUOTE    @"tq"
#define PARA_TOTAL_REPLY    @"tr"
#define PARA_TOTAL_RELATED  @"trl"
#define PARA_CREATE_DATE    @"cd"

#define PARA_SEQ            @"sq"

#define PARA_POSTID         @"pi"
#define PARA_IMAGE_URL      @"iu"
#define PARA_CONTENT_TYPE   @"ct"
#define PARA_TEXT_CONTENT   @"t"
#define PARA_USER_LATITUDE  @"ula"
#define PARA_USER_LONGITUDE @"ulo"
#define PARA_SYNC_SNS @"ss"
#define PARA_PLACEID @"pid"
#define PARA_SRC_POSTID @"spi"
#define PARA_EXCLUDE_POSTID @"epi"
#define PARA_REPLY_POSTID @"rpi"
#define PARA_POST_ACTION_TYPE @"pat"

#define PARA_ISPRIVATE @"isPrivate"

#define PARA_CREATE_USERID @"cuid"

#define PARA_STATUS @"s"

#define PARA_TIMESTAMP @"ts"
#define PARA_MAC @"mac"

#define PARA_DATA @"dat"

#define PARA_LONGTITUDE @"lo"
#define PARA_LATITUDE @"lat"
#define PARA_MESSAGETEXT @"t"

#define PARA_REQUEST_MESSAGE_ID @"rmid"
#define PARA_REPLY_RESULT @"rre"
#define PARA_IS_GROUP @"isg"

#define PARA_VERSION @"v"

#define PARA_KEYWORD @"kw"
#define PARA_EXPIRE_DATE @"e_date"

#define PARA_WORD_ID    @"wordId"
#define PARA_WORD       @"word"
#define PARA_WORD_TYPE  @"wordType"
#define PARA_WORD_SCORE @"wordScore"

#define PARA_FEED_TIMESTAMP @"fts"

// response parameters

#define RET_MESSAGE @"msg"
#define RET_CODE @"ret"
#define RET_DATA @"dat"

#define PARA_SINA_ACCESS_TOKEN          @"sat"
#define PARA_SINA_ACCESS_TOKEN_SECRET   @"sats"
#define PARA_QQ_ACCESS_TOKEN            @"qat"
#define PARA_QQ_ACCESS_TOKEN_SECRET     @"qats"

// app related info

#define PARA_APPURL @"au"
#define PARA_ICON @"ai"
#define PARA_SINA_APPKEY @"sak"
#define PARA_SINA_APPSECRET @"sas"
#define PARA_QQ_APPKEY @"qak"
#define PARA_QQ_APPSECRET @"qas"
#define PARA_RENREN_APPKEY @"rak"
#define PARA_RENREN_APPSECRET @"ras"
#define PARA_MESSAGE_TYPE @"mt"

#define PRAR_START_OFFSET @"so"

#define OPUS_ID_SEPERATOR @"$"
#define ID_SEPERATOR @"$"

//response parameters
#define PARA_LOC @"loc"
#define PARA_IMAGE @"img"
#define PARA_CLASS @"class"
#define PARA_TITLE @"tt"
#define PARA_ROLE @"role"
#define PARA_START_DATE @"sd"
#define PARA_END_DATE @"ed"
#define PARA_CAN_SUBMIT_COUNT @"csc"
#define PARA_PRICE @"pr"
#define PARA_CURRENCY @"crr"
#define PARA_FORCE_BUY @"fby"

#define PARA_VALUE @"val"
#define PARA_REBATE @"rb"
#define PARA_BOUGHT @"bo"
#define PARA_SITE_ID @"si"
#define PARA_SITE_NAME @"sn"
#define PARA_SITE_URL @"su"
#define PARA_ID @"_id"
#define PARA_ADDRESS @"add"
#define PARA_DETAIL @"dt"
#define PARA_WAP_URL @"wu"
#define PARA_TEL @"te"
#define PARA_SHOP @"sh"

#define PARA_UP @"up"
#define PARA_DOWN @"down"

#define PARA_PRODUCT @"p"
#define PARA_CATEGORY_NAME @"na"
#define PARA_CATEGORY_ID @"ci"
#define PARA_CATEGORIES @"ctg"
#define PARA_START_OFFSET @"so"
#define PARA_MAX_DISTANCE @"md"
#define PARA_TODAY_ONLY @"to"
#define PARA_SORT_BY @"sb"
#define PARA_PRODUCT_TYPE @"pt"

#define PARA_START_PRICE @"sp"
#define PARA_END_PRICE @"ep"

#define PARA_ACTION_NAME @"an"
#define PARA_ACTION_VALUE @"av"

#define PARA_ITEMID @"ii"
#define PARA_CATEGORY_NAME @"na"
#define PARA_SUB_CATEGORY_NAME @"scn"
#define PARA_CATEGORY_ID @"ci"
#define PARA_CATEGORY_PRODUCTS_NUM @"cpn"

#define PARA_REGISTER_TYPE  @"rt"

#define PARA_FEEDBACK @"fb"
#define PARA_CONTACT @"ca"

#define PARA_FEED_COUNT @"fec"
#define PARA_COMMENT_COUNT @"comc"
#define PARA_DRAWTOME_COUNT @"dtc"
#define PARA_BBS_ACTION_COUNT @"bac"
#define PARA_FAN_COUNT @"fac"
#define PARA_MESSAGE_COUNT @"mc"
#define PARA_ROOM_COUNT @"rc"
#define PARA_TIME_LINE_GUESS_COUNT @"tlgc"
#define PARA_TIME_LINE_OPUS_COUNT @"tloc"
#define PARA_GROUP_NOTICE_COUNT @"gnc"
#define PARA_TIME_LINE_CONQUER_COUNT @"tlco"

//friends operation
#define PARA_TARGETUSERID   @"tid"
#define PARA_TARGETUSER_NICKNAME @"tnn"
#define PARA_FRIENDSTYPE    @"ft"
#define PARA_SEARCHSTRING   @"ss"
#define PARA_START_INDEX    @"si"
#define PARA_END_INDEX      @"ei"
#define PARA_LASTMODIFIEDDATE @"lsmd"
#define PARA_RELATION_FAN_COUNT @"rfac"
#define PARA_RELATION_FOLLOW_COUNT @"rflc"
#define PARA_RELATION_BLACK_COUNT @"rfbc"
#define PARA_FEATURE_OPUS   @"featureOpus"
#define PARA_MEMO           @"memo"

#define PARA_RELATION @"rl"
#define FRIENDS_TYPE_FOLLOW 0
#define FRIENDS_TYPE_FAN    1

// Tutorial
#define PARA_TUTORIAL_ID                @"tuid"
#define PARA_TUTORIAL_TYPE              @"tutp"

#define PARA_REMOTE_USER_TUTORIAL_ID    @"ruti"
#define PARA_LOCAL_USER_TUTORIAL_ID     @"luti"
#define PARA_TUTORIAL_NAME              @"tutorialName"

#define METHOD_USER_TUTORIAL_ACTION     @"userTutorialAction"
#define PARA_USER_TUTORIAL_DEVICE_OS    @"userTutorialDeviceOs"
#define PARA_USER_TUTORIAL_DEVICE_MODEL @"userTutorialDeviceModel"
#define PARA_USER_TUTORIAL_DEVICE_TYPE  @"userTutorialDeviceType"

#define PARA_STAGE_ID                   @"stageId"
#define PARA_STAGE_INDEX                @"stageIndex"
#define PARA_CHAPTER_INDEX              @"chapterIndex"
#define PARA_CHAPTER_OPUS_ID            @"chapterOpusId"
#define PARA_STAGE_SCORE                @"stageScore"
#define PARA_STAGE_NAME                 @"stageName"

#define PARA_TOTAL_COUNT                @"total_count"
#define PARA_TOTAL_DEFEAT               @"total_defeat"

#define PARA_BEST_SCORE                    @"best_score"
#define PARA_BEST_OPUS_ID                  @"best_opus_id"
#define PARA_BEST_CREATE_DATE              @"best_c_date"

#define PARA_LATEST_SCORE                  @"l_score"
#define PARA_LATEST_OPUS_ID                @"l_opus_id"
#define PARA_LATEST_CREATE_DATE            @"l_c_date"

//new words
#define PARA_NEW_WORDS  @"nw"
//find draw 
#define PARA_FORMAT @"format"

//for level exp
#define PARA_EXP    @"exp"
#define PARA_LEVEL  @"lvl"
#define PARA_LEVEL_INFO @"lif"
#define PARA_SYNC_TYPE  @"st"

//for recommend app
#define PARA_RECOMMEND_APPS @"recommend_apps"
#define PARA_APP_NAME   @"name"
#define PARA_APP_DESCRIPTION    @"description"
#define PARA_APP_ICON_URL   @"icon_url"
#define PARA_APP_ULR        @"url"

// create contest
#define METHOD_CREATE_CONTEST @"createContest"
#define METHOD_UPDATE_CONTEST @"updateContest"
#define PARA_META_DATA @"meta_data"

// for group contest
#define METHOD_GET_GROUP_CONTEST_LIST @"ggcl"

#define METHOD_GET_WONDERFUL_CONTEST_LIST @"gwcl"
#define METHOD_SET_OPUS_TARGET_USER @"setOpusTargetUser"
#define METHOD_SET_OPUS_CLASS @"setOpusClass"

#define PARA_DEFAULT_SEPERATOR @"$"

//for draw contest
#define METHOD_GET_CONTEST_LIST @"gcl"
#define PARA_CONTESTID @"cid"
#define PARA_SONGID @"sid"
#define PARA_CONTEST_URL @"cu"
#define PARA_STATEMENT_URL @"su"
#define PARA_CATEGORY @"cate"

#define PARA_CONTEST_IPAD_URL @"cpu"
#define PARA_STATEMENT_IPAD_URL @"spu"

#define PARA_OPUS_COUNT @"oc"
#define PARA_PARTICIPANT_COUNT @"pc"
#define PARA_LIMIT @"lm"


#define FINDDRAW_FORMAT_PROTOCOLBUFFER @"pb"
#define FORMAT_PROTOCOLBUFFER @"pb"


#pragma mark- BBS Constant

#define METHOD_GET_BBSBOARD_LIST @"gbbl"
#define METHOD_GET_BBSPOST_LIST @"gbpl"
#define METHOD_SEARCH_BBSPOST_LIST @"sbp"
#define METHOD_GET_BBSACTION_LIST @"gbal"
#define METHOD_CREATE_POST @"cp"

#define METHOD_MARK_POST @"mp"
#define METHOD_UNMARK_POST @"ump"
#define METHOD_GET_MARKED_POSTS @"gmp"


#define METHOD_DELETE_BBSPOST @"dbp"
#define METHOD_DELETE_BBSACTION @"dba"
#define METHOD_GET_BBSPOST @"gbp"
#define METHOD_GET_BBS_DRAWDATA @"gbd"
#define METHOD_PAY_BBS_REWARD @"pbr"
#define METHOD_EDIT_BBS_POST @"edp"
#define METHOD_EDIT_BBS_POST_TEXT @"edpt"
#define METHOD_CHANGE_BBS_ROLE @"cbr"
#define METHOD_GET_BBS_PRIVILEGELIST @"gbpr"

#define METHOD_CREATE_BOARD @"createBoard"
#define METHOD_UPDATE_BOARD @"updateBoard"
#define METHOD_DELETE_BOARD @"deleteBoard"
#define METHOD_SET_USER_BOARD_TYPE @"cbr"
#define METHOD_FORBID_USER_BOARD @"forbidUserBoard"

#define METHOD_CREATE_USER_WALL @"createWall"
#define METHOD_UPDATE_USER_WALL @"updateWall"
#define METHOD_GET_USER_WALL_LIST @"getWallList"
#define METHOD_GET_USER_WALL @"getWall"

#define METHOD_GET_CONTEST_TOP_OPUS @"gcto"
#define METHOD_CREATE_BBS_ACTION @"cba"

#define PARA_WALL_TYPE @"wallType"
#define PARA_WALL_ID @"wall_id"

#define PARA_BOARDID @"bid"
#define PARA_BONUS @"bn"
#define PARA_RANGETYPE @"rt"

#define PARA_RANKTYPES @"rts"
#define PARA_RANVALUES @"rvs"


#define PARA_ACTIONID @"aid"
#define PARA_THUMB_IMAGE @"timg"
#define PARA_DRAW_THUMB @"dti"
#define PARA_ACTION_UID @"auid"
#define PARA_ACTION_NICKNAME @"ann"
#define PARA_POST_UID @"puid"
#define PARA_BRIEF_TEXT @"btxt"
#define PARA_SOURCE_ACTION_TYPE @"sat"

#define PARA_TOPIC_MODE @"mode"
#define CONST_GROUP_MODE 1
#define CONST_BBS_MODE 0



//group

#define PARA_GROUPID @"groupId"
#define PARA_TITLE_ID @"titleId"
#define PARA_SOURCE_TITLEID @"soruceTitleId"
#define PARA_FEE @"fee"

#define PARA_GROUP_NAME @"groupName"
#define PARA_GROUP_MEDAL @"groupMedal"
#define PARA_VIP @"vip"

// learn draw
#define METHOD_GET_LEARNDRAW_LIST @"gldl"
#define METHOD_GET_USER_LEARNDRAW_LIST @"guldl"
#define METHOD_GET_USER_LEARDRAWID_LIST @"guldil"
#define METHOD_BUY_LEARN_DRAW @"bld"
#define METHOD_ADD_LEARN_DRAW @"ald"
#define METHOD_REMOVE_LEARN_DRAW @"rld"

#define METHOD_MANAGE_USER_INFO @"manageUserInfo"
#define METHOD_SET_USER_PASSWORD @"setUserPassword"


//group

#define METHOD_CREATE_GROUP @"createGroup"
#define METHOD_GET_GROUP @"getGroup"
#define METHOD_GET_SIMPLE_GROUP @"getSimpleGroup"
#define METHOD_JOIN_GROUP @"joinGroup"

#define METHOD_HANDLE_JOIN_REQUEST @"handelJoinGroupRequest"
#define METHOD_EDIT_GROUP @"editGroup"
#define METHOD_DISMISS_GROUP @"dismissGroup"
#define METHOD_INVITE_GROUPMEMBERS @"inviteGroupUser"
#define METHOD_GET_GROUP_MEMBERS @"getGroupMembers"
#define METHOD_EXPEL_GROUPUSER @"expelGroupUser"
#define METHOD_QUIT_GROUP @"quitGroup"
#define METHOD_UPDATE_GROUPUSER_ROLE @"updateUserRole"
#define METHOD_INVITE_GROUPGUESTS @"inviteGroupGuest"

#define METHOD_SET_USER_AS_ADMIN @"setUserAsAdmin"
#define METHOD_REMOVE_USER_FROM_ADMIN @"removeUserFromAdmin"

#define METHOD_FOLLOW_GROUP @"followGroup"
#define METHOD_UNFOLLOW_GROUP @"unfollowGroup"
#define METHOD_GET_GROUP_FANS @"getGroupFans"
#define METHOD_GET_GROUPS @"getGroups"
#define METHOD_UPGRADE_GROUP @"upgradeGroup"
#define METHOD_GET_GROUP_NOTICES @"getGroupNotices"

#define METHOD_SYNC_FOLLOWED_GROUPIDS @"syncFollowedGroupIds"
#define METHOD_SYNC_FOLLOWED_TOPICIDS @"syncFollowedTopicIds"

#define METHOD_IGNORE_NOTICE @"ignoreNotice"
#define METHOD_IGNORE_ALL_REQUEST_NOTICE @"ignoreAllRequestNotices"
#define METHOD_GET_GROUP_CHARGE_HISTORIES @"getGroupChargeHistories"

#define METHOD_FOLLOW_TOPIC @"followTopic"
#define METHOD_UNFOLLOW_TOPIC @"unfollowTopic"
#define METHOD_GET_TOPIC_TIMELINE @"getTopicTimeline"
#define METHOD_GET_FOLLOWED_TOPIC @"getFollowTopics"
#define METHOD_GET_TOPICS @"getTopics"

//#define METHOD_GET_GROUPRELATION @"getRelationWithGroup"
#define METHOD_SEARCH_GROUP @"searchGroup"
#define METHOD_GET_GROUP_BADGES @"getGroupBadge"
#define METHOD_GET_POST_ACTION_BY_USER @"getPostActionByUser"
#define METHOD_CHARGE_GROUP @"chargeGroup"


#define METHOD_CHANGE_USER_TITLE @"changeUserTitle"
#define METHOD_DELETE_GROUP_TITLE @"deleteGroupTitle"
#define METHOD_GET_USERS_BYTITLE @"getUsersByTitle"
#define METHOD_CREATE_GROUP_TITLE @"createGroupTitle"
#define METHOD_ACCEPT_INVITATION @"acceptInvitation"
#define METHOD_REJECT_INVITATION @"rejectInvitation"

#define METHOD_UPDATE_GROUP_ICON @"updateGroupIcon"
#define METHOD_UPDATE_GROUP_BG @"updateGroupBG"
#define METHOD_SYNC_GROUP_ROLES @"syncGroupRoles"
#define METHOD_UPDATE_GROUP_TITLE @"updateTitleName"

#define METHOD_UPDATE_USER_CREDENTIAL @"updateUserCredential"

// tutorial
#define METHOD_SYNC_USER_TUTORIAL @"METHOD_SYNC_USER_TUTORIAL"

//bbs postId by tutorialId and stageId
#define METHOD_GET_STAGE_POST_ID @"getStagePostId"

#define REGISTER_TYPE_EMAIL     1
#define REGISTER_TYPE_SINA      2
#define REGISTER_TYPE_QQ        3
#define REGISTER_TYPE_RENREN    4
#define REGISTER_TYPE_FACEBOOK  5
#define REGISTER_TYPE_TWITTER   6

#define LOGIN_USER_BY_EMAIL     100


#define SORT_BY_START_DATE 0
#define SORT_BY_PRICE 1
#define SORT_BY_REBATE 2
#define SORT_BY_BOUGHT 3
#define SORT_BY_END_DATE 4

#define CATEGORY_TAOBAO_MIAOSHA         100
#define CATEGORY_TAOBAO_ZHEKOU          150
#define CATEGORY_AD                     200

#define DATA_UNDEFINE                   (-1)


#define ERROR_DEVICE_NOT_BIND           20003

// User Errors
#define ERROR_LOGINID_EXIST             20001
#define ERROR_DEVICEID_BIND            	20002
#define ERROR_DEVICE_NOT_BIND 			20003
#define ERROR_LOGINID_DEVICE_BOTH_EXIST 20004 
#define ERROR_USERID_NOT_FOUND          20005
#define ERROR_CREATE_USER				20006
#define ERROR_USER_GET_NICKNAME 		20007
#define ERROR_EMAIL_EXIST				20008
#define ERROR_EMAIL_VERIFIED			20009
#define ERROR_PASSWORD_NOT_MATCH        20010
#define ERROR_EMAIL_NOT_VALID        	20011
#define ERROR_DEVICE_TOKEN_NULL         20012
#define ERROR_USER_EMAIL_NOT_FOUND      20013

#define ERROR_FOLLOW_USER_NOT_FOUND     20017

#define ERROR_PARAMETER_PASSWORD_EMPTY 	10020
#define ERROR_PARAMETER_PASSWORD_NULL 	10021
#define ERROR_PARAMETER_EMAIL_NULL      10064
#define ERROR_PARAMETER_EMAIL_EMPTY     10065
#define ERROR_PARAMETER_VERIFYCODE_NULL  10066
#define ERROR_PARAMETER_VERIFYCODE_EMPTY 10067

#define ERROR_BBS_TEXT_TOO_SHORT        30001
#define ERROR_BBS_TEXT_TOO_LONG         30002
#define ERROR_BBS_TEXT_TOO_FREQUENT     30003
#define ERROR_BBS_POST_SUPPORT_TIMES_LIMIT 30004
#define ERROR_BBS_TEXT_REPEAT           30005
#define ERROR_BBS_BOARD_FORIDDEN        120021

//contest
#define ERROR_CONTEST_END               110004

#define ERROR_CONTEST_REACH_MAX_FLOWER          110006
#define ERROR_CONTEST_EXCEED_THROW_FLOWER_DATE  110007
#define ERROR_CONTEST_CANNOT_UPDATE_AFTER_START 110011


#define ERROR_BALANCE_NOT_ENOUGH        70005 //change from 200002 to 70005, by Gamy, 2014.1.2. the code is just used at the client.

#define ERROR_BAD_PARAMETER             200003
#define ERROR_ITEM_NOT_ENOUGH           200004

#define ERROR_ALIPAY_NOT_INSTALLED      320001
#define ERROR_SINATURE                  320002
#define ERROR_PAY_ERROR                 320003

#define ERROR_XIAOJI_NUMBER_NULL        320004
#define ERROR_USER_DATA_NULL            320005
#define ERROR_OPUS_ID_NULL              320006

#define ERROR_USER_COMMENT_OWN_OPUS_CONTEST    110009


//group Error Code
#define ERROR_GROUP  200000                                                     
#define ERROR_GROUP_DUPLICATE_NAME  200001
#define ERROR_PARAMETER_GROUPID_EMPTY  200002
#define ERROR_PARAMETER_GROUPID_NULL  200003
#define ERROR_GROUP_MULTIJOINED  200006

#define ERROR_GROUP_MULTIREQUESTED  200007
#define ERROR_GROUP_PERMISSION  200008
#define ERROR_GROUP_FULL  200009
#define ERROR_GROUP_REJECTED  200010
#define ERROR_GROUP_USER_NOT_REQUESTSTATUS  200011
#define ERROR_GROUP_INVALIDATE_ROLE  200012
#define ERROR_GROUP_MEMBER_UNFOLLOW  200013
#define ERROR_GROUP_REPEAT_FOLLOW  200014
#define ERROR_GROUP_NOTEXIST  200015
#define ERROR_GROUP_LEVEL_SMALL  200016



#define ERROR_PARAMETER_NOTICEID_EMPTY  200017  
#define ERROR_PARAMETER_NOTICEID_NULL  200018  
#define ERROR_GROUP_REQUEST_HANDLE_TYPE_INVALID  200019  
#define ERROR_GROUP_NOTICE_NOTFOUND  200020  
#define ERROR_GROUP_TITLEID_EXISTED     200021  
#define ERROR_GROUP_NOT_MEMBER  200022  
#define ERROR_GROUP_NOT_ADMIN  200023  
#define ERROR_GROUP_NOT_INVITEE  200024  
#define ERROR_GROUP_TITLEID_NOTEXISTED     200025
#define ERROR_GROUP_INVITATION     200026

#define ERROR_GROUP_NAME_EMPTY  200050
#define ERROR_GROUP_NAME_TOO_LONG  200051


#define ERROR_GROUP_BALANCE_NOT_ENOUGH 200052

#define ERROR_GROUP_CREATION 200060

/////


/////



#define REJECT_ASK_LOCATION             1
#define ACCEPT_ASK_LOCATION             0

#define DEVICE_TYPE_IOS                 1
#define STRING_DEVICE_TYPE_IOS          @"1"

extern NSString* GlobalGetServerURL();
extern NSString* GlobalGetTrafficServerURL();
extern NSString* GlobalGetBoardServerURL();

