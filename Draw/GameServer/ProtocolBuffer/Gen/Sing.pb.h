// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "GameBasic.pb.h"
#import "GameConstants.pb.h"

@class PBApp;
@class PBApp_Builder;
@class PBDrawAction;
@class PBDrawAction_Builder;
@class PBDrawBg;
@class PBDrawBg_Builder;
@class PBGameItem;
@class PBGameItemList;
@class PBGameItemList_Builder;
@class PBGameItem_Builder;
@class PBGameSession;
@class PBGameSessionChanged;
@class PBGameSessionChanged_Builder;
@class PBGameSession_Builder;
@class PBGameUser;
@class PBGameUser_Builder;
@class PBIAPProduct;
@class PBIAPProductList;
@class PBIAPProductList_Builder;
@class PBIAPProductPrice;
@class PBIAPProductPrice_Builder;
@class PBIAPProduct_Builder;
@class PBItemPriceInfo;
@class PBItemPriceInfo_Builder;
@class PBKeyValue;
@class PBKeyValue_Builder;
@class PBLocalizeString;
@class PBLocalizeString_Builder;
@class PBMessage;
@class PBMessageStat;
@class PBMessageStat_Builder;
@class PBMessage_Builder;
@class PBPromotionInfo;
@class PBPromotionInfo_Builder;
@class PBSNSUser;
@class PBSNSUser_Builder;
@class PBSing;
@class PBSing_Builder;
@class PBSize;
@class PBSize_Builder;
@class PBSong;
@class PBSong_Builder;
@class PBUserBasicInfo;
@class PBUserBasicInfo_Builder;
@class PBUserItem;
@class PBUserItemList;
@class PBUserItemList_Builder;
@class PBUserItem_Builder;
@class PBUserLevel;
@class PBUserLevel_Builder;
@class PBUserResult;
@class PBUserResult_Builder;

@interface SingRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PBSong : PBGeneratedMessage {
@private
  BOOL hasSongId_:1;
  BOOL hasName_:1;
  BOOL hasAuthor_:1;
  BOOL hasLyric_:1;
  NSString* songId;
  NSString* name;
  NSString* author;
  NSString* lyric;
  NSMutableArray* mutableTagList;
}
- (BOOL) hasSongId;
- (BOOL) hasName;
- (BOOL) hasAuthor;
- (BOOL) hasLyric;
@property (readonly, retain) NSString* songId;
@property (readonly, retain) NSString* name;
@property (readonly, retain) NSString* author;
@property (readonly, retain) NSString* lyric;
- (NSArray*) tagList;
- (int32_t) tagAtIndex:(int32_t) index;

+ (PBSong*) defaultInstance;
- (PBSong*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBSong_Builder*) builder;
+ (PBSong_Builder*) builder;
+ (PBSong_Builder*) builderWithPrototype:(PBSong*) prototype;

+ (PBSong*) parseFromData:(NSData*) data;
+ (PBSong*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBSong*) parseFromInputStream:(NSInputStream*) input;
+ (PBSong*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBSong*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBSong*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBSong_Builder : PBGeneratedMessage_Builder {
@private
  PBSong* result;
}

- (PBSong*) defaultInstance;

- (PBSong_Builder*) clear;
- (PBSong_Builder*) clone;

- (PBSong*) build;
- (PBSong*) buildPartial;

- (PBSong_Builder*) mergeFrom:(PBSong*) other;
- (PBSong_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBSong_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSongId;
- (NSString*) songId;
- (PBSong_Builder*) setSongId:(NSString*) value;
- (PBSong_Builder*) clearSongId;

- (BOOL) hasName;
- (NSString*) name;
- (PBSong_Builder*) setName:(NSString*) value;
- (PBSong_Builder*) clearName;

- (BOOL) hasAuthor;
- (NSString*) author;
- (PBSong_Builder*) setAuthor:(NSString*) value;
- (PBSong_Builder*) clearAuthor;

- (BOOL) hasLyric;
- (NSString*) lyric;
- (PBSong_Builder*) setLyric:(NSString*) value;
- (PBSong_Builder*) clearLyric;

- (NSArray*) tagList;
- (int32_t) tagAtIndex:(int32_t) index;
- (PBSong_Builder*) replaceTagAtIndex:(int32_t) index with:(int32_t) value;
- (PBSong_Builder*) addTag:(int32_t) value;
- (PBSong_Builder*) addAllTag:(NSArray*) values;
- (PBSong_Builder*) clearTagList;
@end

@interface PBSing : PBGeneratedMessage {
@private
  BOOL hasDuration_:1;
  BOOL hasPitch_:1;
  BOOL hasVoiceType_:1;
  BOOL hasSong_:1;
  Float32 duration;
  Float32 pitch;
  int32_t voiceType;
  PBSong* song;
}
- (BOOL) hasSong;
- (BOOL) hasVoiceType;
- (BOOL) hasDuration;
- (BOOL) hasPitch;
@property (readonly, retain) PBSong* song;
@property (readonly) int32_t voiceType;
@property (readonly) Float32 duration;
@property (readonly) Float32 pitch;

+ (PBSing*) defaultInstance;
- (PBSing*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBSing_Builder*) builder;
+ (PBSing_Builder*) builder;
+ (PBSing_Builder*) builderWithPrototype:(PBSing*) prototype;

+ (PBSing*) parseFromData:(NSData*) data;
+ (PBSing*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBSing*) parseFromInputStream:(NSInputStream*) input;
+ (PBSing*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBSing*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBSing*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBSing_Builder : PBGeneratedMessage_Builder {
@private
  PBSing* result;
}

- (PBSing*) defaultInstance;

- (PBSing_Builder*) clear;
- (PBSing_Builder*) clone;

- (PBSing*) build;
- (PBSing*) buildPartial;

- (PBSing_Builder*) mergeFrom:(PBSing*) other;
- (PBSing_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBSing_Builder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSong;
- (PBSong*) song;
- (PBSing_Builder*) setSong:(PBSong*) value;
- (PBSing_Builder*) setSongBuilder:(PBSong_Builder*) builderForValue;
- (PBSing_Builder*) mergeSong:(PBSong*) value;
- (PBSing_Builder*) clearSong;

- (BOOL) hasVoiceType;
- (int32_t) voiceType;
- (PBSing_Builder*) setVoiceType:(int32_t) value;
- (PBSing_Builder*) clearVoiceType;

- (BOOL) hasDuration;
- (Float32) duration;
- (PBSing_Builder*) setDuration:(Float32) value;
- (PBSing_Builder*) clearDuration;

- (BOOL) hasPitch;
- (Float32) pitch;
- (PBSing_Builder*) setPitch:(Float32) value;
- (PBSing_Builder*) clearPitch;
@end
