//
//  GroupBuyNetworkConstants.h
//  groupbuy
//
//  Created by qqn_pipi on 11-7-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//


#define SERVER_URL                  (GlobalGetServerURL())
#define TRAFFIC_SERVER_URL                  (GlobalGetTrafficServerURL())
#define BOARD_SERVER_URL                  (GlobalGetBoardServerURL())
//#define APP_ID                      @"Game"

#define STRING_SEPERATOR @"$"

//#define SHARE_KEY @"NetworkRequestShareKey"

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

#define METHOD_SENDMESSAGE @"sm"
#define METHOD_GETMYMESSAGE @"gmm"
#define METHOD_DELETEMESSAGE @"dmm"
#define METHOD_GETMEPOST @"gmep"
#define METHOD_UPDATEUSER @"uu"
#define METHOD_USERFEEDBACK @"ufb"
#define METHOD_USER_READ_MSG @"urm"
#define METHOD_GETMESSAGESTATLIST @"gmsl"
#define METHOD_GETMESSAGELIST @"gml"


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

//find draw
#define METHOD_FINDDRAW @"fd"

//for levelService
#define METHOD_SYND_LEVEL_EXP   @"sle"

//for Draw offline
#define METHOD_CREATE_OPUS @"cop"
#define METHOD_CREATE_OPUS_IMAGE @"coi"
#define METHOD_UPDATE_OPUS @"uop"
#define METHOD_MATCH_OPUS  @"mop"
#define METHOD_GET_OPUS_BY_ID @"goi"
#define METHOD_GET_FEED_LIST  @"gfl"
#define METHOD_ACTION_ON_OPUS  @"aoo"
#define METHOD_GET_FEED_COMMENT_LIST @"gfc"
#define METHOD_GET_OUPS_TIMES @"got"

//contest
#define METHOD_GET_CONTEST_OPUS_LIST @"gcol"

#define PARA_COMMENT_TIMES @"cmt"
#define PARA_GUESS_TIMES @"gt"
#define PARA_CORRECT_TIMES @"crt"
#define PARA_FLOWER_TIMES @"ft"
#define PARA_TOMATO_TIMES @"tt"
#define PARA_SAVE_TIMES @"st"




#define ACTION_TYPE_GUESS    2
#define ACTION_TYPE_COMMENT  3
#define ACTION_TYPE_SAVE     100


// for traffic server
#define PARA_SERVER_ADDRESS @"sa"
#define PARA_SERVER_PORT @"sp"
#define PARA_SERVER_LANGUAGE @"sl"
#define PARA_SERVER_USER_COUNT @"su"
#define PARA_SERVER_USAGE @"us"
#define PARA_SERVER_CAPACITY @"sc"

#define METHOD_GET_TRAFFIC_SERVER_LIST @"gt"
#define METHOD_CHARGE_ACCOUNT @"ca"
#define METHOD_DEDUCT_ACCOUNT @"da"
#define METHOD_UPDATE_ITEM_AMOUNT @"uia"
#define METHOD_UPDATE_ACCOUNT_BALANCE @"uab"
#define METHOD_SYNC_USER_ACCOUNT_ITEM @"sai"
#define METHOD_FEEDBACK @"fb"
#define METHOD_COMMIT_WORDS @"cw"

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
#define PARA_SAVE_PERCENT @"sp"
#define PARA_RESCUE_DATA_TAG @"rdt"

#define PARA_AMOUNT @"pa"
#define PARA_SOURCE @"sr"
#define PARA_TRANSACTION_ID @"tid"
#define PARA_TRANSACTION_RECEIPT @"tre"
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

#define PARA_MOBILE @"mb"
#define PARA_EMAIL @"em"
#define PARA_NEW_APPID  @"napp"

#define PARA_TO_USERID @"tuid"
#define PARA_MESSAGE_ID @"mid"
#define PARA_TARGET_MESSAGE_ID @"tmd"

#define PARA_COUNTRYCODE @"cc"

#define PARA_MATCHITEMCOUNT @"mic"

#define PARA_LANGUAGE @"lang"
#define PARA_APPID @"app"
#define PARA_GAME_ID @"gid"
#define PARA_DRAW_DATA @"dd"
#define PARA_DRAW_IMAGE @"photo"
#define PARA_FEED_ID @"fid"

#define PARA_COMMENT_CONTENT @"comc"

#define PARA_COMMENT_TYPE @"cmt"
#define PARA_COMMENT_ID @"cmid"
#define PARA_COMMENT_SUMMARY @"cmsm"
#define PARA_COMMENT_USERID @"cmuid"
#define PARA_COMMENT_NICKNAME @"cmnn"

#define PARA_ITEMIDARRAY @"iia"
#define PARA_REQUIRE_MATCH @"rm"
#define PARA_TYPE @"tp"

#define PARA_NEED_RETURN_USER           @"r"
#define PARA_AVATAR                     @"av"
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
#define PARA_WORD_LIST @"wl"
#define PARA_SCORE @"sco"
#define PARA_OPUS_CREATOR_UID @"opc"
#define PARA_RETURN_ITEM @"ri"

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

#define PARA_VERSION @"v"

#define PARA_KEYWORD @"kw"
#define PARA_EXPIRE_DATE @"e_date"

#define PARA_WORD @"word"

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

//response parameters
#define PARA_LOC @"loc"
#define PARA_IMAGE @"img"
#define PARA_TITLE @"tt"
#define PARA_START_DATE @"sd"
#define PARA_END_DATE @"ed"
#define PARA_CAN_SUBMIT_COUNT @"csc"
#define PARA_PRICE @"pr"
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

#define PARA_FAN_COUNT @"fac"
#define PARA_MESSAGE_COUNT @"mc"
#define PARA_ROOM_COUNT @"rc"

//friends operation
#define PARA_TARGETUSERID   @"tid"
#define PARA_FRIENDSTYPE    @"ft"
#define PARA_SEARCHSTRING   @"ss"
#define PARA_START_INDEX    @"si"
#define PARA_END_INDEX      @"ei"
#define PARA_LASTMODIFIEDDATE @"lsmd"
#define PARA_RELATION @"rl"
#define FRIENDS_TYPE_FOLLOW 0
#define FRIENDS_TYPE_FAN    1

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


//for draw contest
#define METHOD_GET_CONTEST_LIST @"gcl"
#define PARA_CONTESTID @"cid"
#define PARA_CONTEST_URL @"cu"
#define PARA_STATEMENT_URL @"su"

#define PARA_CONTEST_IPAD_URL @"cpu"
#define PARA_STATEMENT_IPAD_URL @"spu"

#define PARA_OPUS_COUNT @"oc"
#define PARA_PARTICIPANT_COUNT @"pc"
#define PARA_LIMIT @"lm"


#define FINDDRAW_FORMAT_PROTOCOLBUFFER @"pb"



#pragma mark BBS Constant
#define METHOD_GET_BBSBOARD_LIST @"gbbl"
#define METHOD_GET_BBSPOST_LIST @"gbpl"
#define METHOD_GET_BBSACTION_LIST @"gbal"
#define METHOD_CREATE_POST @"cp"

#define METHOD_DELETE_BBSPOST @"dbp"
#define METHOD_DELETE_BBSACTION @"dba"
#define METHOD_GET_BBSPOST @"gbp"
#define METHOD_GET_BBS_DRAWDATA @"gbd"
#define METHOD_PAY_BBS_REWARD @"pbr"

#define PARA_BOARDID @"bid"
#define PARA_BONUS @"bn"
#define PARA_RANGETYPE @"rt"

#define METHOD_GET_CONTEST_TOP_OPUS @"gcto"
#define PARA_ACTIONID @"aid"
#define PARA_THUMB_IMAGE @"timg"
#define PARA_DRAW_THUMB @"dti"
#define PARA_ACTION_UID @"auid"
#define PARA_ACTION_NICKNAME @"ann"
#define PARA_POST_UID @"puid"
#define PARA_BRIEF_TEXT @"btxt"
#define PARA_SOURCE_ACTION_TYPE @"sat"
#define METHOD_CREATE_BBS_ACTION @"cba"


#define REGISTER_TYPE_EMAIL     1
#define REGISTER_TYPE_SINA      2
#define REGISTER_TYPE_QQ        3
#define REGISTER_TYPE_RENREN    4
#define REGISTER_TYPE_FACEBOOK  5
#define REGISTER_TYPE_TWITTER   6


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

#define ERROR_BBS_TEXT_TOO_SHORT        30001
#define ERROR_BBS_TEXT_TOO_LONG         30002
#define ERROR_BBS_TEXT_TOO_FREQUENT     30003
#define ERROR_BBS_POST_SUPPORT_TIMES_LIMIT 30004

#define REJECT_ASK_LOCATION             1
#define ACCEPT_ASK_LOCATION             0

extern NSString* GlobalGetServerURL();
extern NSString* GlobalGetTrafficServerURL();
extern NSString* GlobalGetBoardServerURL();
