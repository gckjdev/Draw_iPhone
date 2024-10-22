// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

#import "GameConstants.pb.h"
#import "GameBasic.pb.h"
#import "BBS.pb.h"
// @@protoc_insertion_point(imports)

@class PBApp;
@class PBAppBuilder;
@class PBBBSAction;
@class PBBBSActionBuilder;
@class PBBBSActionSource;
@class PBBBSActionSourceBuilder;
@class PBBBSBoard;
@class PBBBSBoardBuilder;
@class PBBBSContent;
@class PBBBSContentBuilder;
@class PBBBSDraw;
@class PBBBSDrawBuilder;
@class PBBBSPost;
@class PBBBSPostBuilder;
@class PBBBSPrivilege;
@class PBBBSPrivilegeBuilder;
@class PBBBSReward;
@class PBBBSRewardBuilder;
@class PBBBSUser;
@class PBBBSUserBuilder;
@class PBClass;
@class PBClassBuilder;
@class PBContest;
@class PBContestBuilder;
@class PBContestList;
@class PBContestListBuilder;
@class PBDrawAction;
@class PBDrawActionBuilder;
@class PBDrawBg;
@class PBDrawBgBuilder;
@class PBGameItem;
@class PBGameItemBuilder;
@class PBGameItemList;
@class PBGameItemListBuilder;
@class PBGameSession;
@class PBGameSessionBuilder;
@class PBGameSessionChanged;
@class PBGameSessionChangedBuilder;
@class PBGameUser;
@class PBGameUserBuilder;
@class PBGradient;
@class PBGradientBuilder;
@class PBGroup;
@class PBGroupBuilder;
@class PBGroupNotice;
@class PBGroupNoticeBuilder;
@class PBGroupTitle;
@class PBGroupTitleBuilder;
@class PBGroupUser;
@class PBGroupUserBuilder;
@class PBGroupUserRole;
@class PBGroupUserRoleBuilder;
@class PBGroupUsersByTitle;
@class PBGroupUsersByTitleBuilder;
@class PBIAPProduct;
@class PBIAPProductBuilder;
@class PBIAPProductList;
@class PBIAPProductListBuilder;
@class PBIAPProductPrice;
@class PBIAPProductPriceBuilder;
@class PBIntKeyIntValue;
@class PBIntKeyIntValueBuilder;
@class PBIntKeyValue;
@class PBIntKeyValueBuilder;
@class PBItemPriceInfo;
@class PBItemPriceInfoBuilder;
@class PBKeyValue;
@class PBKeyValueBuilder;
@class PBLayer;
@class PBLayerBuilder;
@class PBLocalizeString;
@class PBLocalizeStringBuilder;
@class PBMessage;
@class PBMessageBuilder;
@class PBMessageStat;
@class PBMessageStatBuilder;
@class PBOpusRank;
@class PBOpusRankBuilder;
@class PBPromotionInfo;
@class PBPromotionInfoBuilder;
@class PBSNSUser;
@class PBSNSUserBuilder;
@class PBSNSUserCredential;
@class PBSNSUserCredentialBuilder;
@class PBSimpleGroup;
@class PBSimpleGroupBuilder;
@class PBSize;
@class PBSizeBuilder;
@class PBTask;
@class PBTaskBuilder;
@class PBUserAward;
@class PBUserAwardBuilder;
@class PBUserBasicInfo;
@class PBUserBasicInfoBuilder;
@class PBUserItem;
@class PBUserItemBuilder;
@class PBUserItemList;
@class PBUserItemListBuilder;
@class PBUserLevel;
@class PBUserLevelBuilder;
@class PBUserResult;
@class PBUserResultBuilder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef NS_ENUM(SInt32, PBGroupUserType) {
  PBGroupUserTypeGroupUserAdmin = 1,
  PBGroupUserTypeGroupUserMember = 2,
  PBGroupUserTypeGroupUserGuest = 3,
  PBGroupUserTypeGroupUserCreator = 4,
  PBGroupUserTypeGroupUserRequester = 5,
  PBGroupUserTypeGroupUserInvitee = 6,
  PBGroupUserTypeGroupGuestInvitee = 7,
};

BOOL PBGroupUserTypeIsValidValue(PBGroupUserType value);
NSString *NSStringFromPBGroupUserType(PBGroupUserType value);


@interface GroupRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface PBGroupUser : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasPermission_:1;
  BOOL hasCustomeTitle_:1;
  BOOL hasUser_:1;
  BOOL hasType_:1;
  SInt32 permission;
  NSString* customeTitle;
  PBGameUser* user;
  PBGroupUserType type;
}
- (BOOL) hasUser;
- (BOOL) hasCustomeTitle;
- (BOOL) hasPermission;
- (BOOL) hasType;
@property (readonly, strong) PBGameUser* user;
@property (readonly, strong) NSString* customeTitle;
@property (readonly) SInt32 permission;
@property (readonly) PBGroupUserType type;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBGroupUserBuilder*) builder;
+ (PBGroupUserBuilder*) builder;
+ (PBGroupUserBuilder*) builderWithPrototype:(PBGroupUser*) prototype;
- (PBGroupUserBuilder*) toBuilder;

+ (PBGroupUser*) parseFromData:(NSData*) data;
+ (PBGroupUser*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupUser*) parseFromInputStream:(NSInputStream*) input;
+ (PBGroupUser*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupUser*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBGroupUser*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBGroupUserBuilder : PBGeneratedMessageBuilder {
@private
  PBGroupUser* resultPbgroupUser;
}

- (PBGroupUser*) defaultInstance;

- (PBGroupUserBuilder*) clear;
- (PBGroupUserBuilder*) clone;

- (PBGroupUser*) build;
- (PBGroupUser*) buildPartial;

- (PBGroupUserBuilder*) mergeFrom:(PBGroupUser*) other;
- (PBGroupUserBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBGroupUserBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUser;
- (PBGameUser*) user;
- (PBGroupUserBuilder*) setUser:(PBGameUser*) value;
- (PBGroupUserBuilder*) setUserBuilder:(PBGameUserBuilder*) builderForValue;
- (PBGroupUserBuilder*) mergeUser:(PBGameUser*) value;
- (PBGroupUserBuilder*) clearUser;

- (BOOL) hasCustomeTitle;
- (NSString*) customeTitle;
- (PBGroupUserBuilder*) setCustomeTitle:(NSString*) value;
- (PBGroupUserBuilder*) clearCustomeTitle;

- (BOOL) hasPermission;
- (SInt32) permission;
- (PBGroupUserBuilder*) setPermission:(SInt32) value;
- (PBGroupUserBuilder*) clearPermission;

- (BOOL) hasType;
- (PBGroupUserType) type;
- (PBGroupUserBuilder*) setType:(PBGroupUserType) value;
- (PBGroupUserBuilder*) clearType;
@end

@interface PBGroupTitle : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasTitleId_:1;
  BOOL hasTitle_:1;
  SInt32 titleId;
  NSString* title;
}
- (BOOL) hasTitleId;
- (BOOL) hasTitle;
@property (readonly) SInt32 titleId;
@property (readonly, strong) NSString* title;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBGroupTitleBuilder*) builder;
+ (PBGroupTitleBuilder*) builder;
+ (PBGroupTitleBuilder*) builderWithPrototype:(PBGroupTitle*) prototype;
- (PBGroupTitleBuilder*) toBuilder;

+ (PBGroupTitle*) parseFromData:(NSData*) data;
+ (PBGroupTitle*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupTitle*) parseFromInputStream:(NSInputStream*) input;
+ (PBGroupTitle*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupTitle*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBGroupTitle*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBGroupTitleBuilder : PBGeneratedMessageBuilder {
@private
  PBGroupTitle* resultPbgroupTitle;
}

- (PBGroupTitle*) defaultInstance;

- (PBGroupTitleBuilder*) clear;
- (PBGroupTitleBuilder*) clone;

- (PBGroupTitle*) build;
- (PBGroupTitle*) buildPartial;

- (PBGroupTitleBuilder*) mergeFrom:(PBGroupTitle*) other;
- (PBGroupTitleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBGroupTitleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTitleId;
- (SInt32) titleId;
- (PBGroupTitleBuilder*) setTitleId:(SInt32) value;
- (PBGroupTitleBuilder*) clearTitleId;

- (BOOL) hasTitle;
- (NSString*) title;
- (PBGroupTitleBuilder*) setTitle:(NSString*) value;
- (PBGroupTitleBuilder*) clearTitle;
@end

@interface PBGroupUsersByTitle : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasTitle_:1;
  PBGroupTitle* title;
  NSMutableArray * usersArray;
}
- (BOOL) hasTitle;
@property (readonly, strong) PBGroupTitle* title;
@property (readonly, strong) NSArray * users;
- (PBGameUser*)usersAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBGroupUsersByTitleBuilder*) builder;
+ (PBGroupUsersByTitleBuilder*) builder;
+ (PBGroupUsersByTitleBuilder*) builderWithPrototype:(PBGroupUsersByTitle*) prototype;
- (PBGroupUsersByTitleBuilder*) toBuilder;

+ (PBGroupUsersByTitle*) parseFromData:(NSData*) data;
+ (PBGroupUsersByTitle*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupUsersByTitle*) parseFromInputStream:(NSInputStream*) input;
+ (PBGroupUsersByTitle*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupUsersByTitle*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBGroupUsersByTitle*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBGroupUsersByTitleBuilder : PBGeneratedMessageBuilder {
@private
  PBGroupUsersByTitle* resultPbgroupUsersByTitle;
}

- (PBGroupUsersByTitle*) defaultInstance;

- (PBGroupUsersByTitleBuilder*) clear;
- (PBGroupUsersByTitleBuilder*) clone;

- (PBGroupUsersByTitle*) build;
- (PBGroupUsersByTitle*) buildPartial;

- (PBGroupUsersByTitleBuilder*) mergeFrom:(PBGroupUsersByTitle*) other;
- (PBGroupUsersByTitleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBGroupUsersByTitleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTitle;
- (PBGroupTitle*) title;
- (PBGroupUsersByTitleBuilder*) setTitle:(PBGroupTitle*) value;
- (PBGroupUsersByTitleBuilder*) setTitleBuilder:(PBGroupTitleBuilder*) builderForValue;
- (PBGroupUsersByTitleBuilder*) mergeTitle:(PBGroupTitle*) value;
- (PBGroupUsersByTitleBuilder*) clearTitle;

- (NSMutableArray *)users;
- (PBGameUser*)usersAtIndex:(NSUInteger)index;
- (PBGroupUsersByTitleBuilder *)addUsers:(PBGameUser*)value;
- (PBGroupUsersByTitleBuilder *)setUsersArray:(NSArray *)array;
- (PBGroupUsersByTitleBuilder *)clearUsers;
@end

@interface PBGroup : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasBalance_:1;
  BOOL hasLevel_:1;
  BOOL hasFame_:1;
  BOOL hasCreateDate_:1;
  BOOL hasMemberFee_:1;
  BOOL hasCapacity_:1;
  BOOL hasSize_:1;
  BOOL hasGuestSize_:1;
  BOOL hasGuestCapacity_:1;
  BOOL hasTopicCount_:1;
  BOOL hasFanCount_:1;
  BOOL hasTitleCapacity_:1;
  BOOL hasStatus_:1;
  BOOL hasGroupId_:1;
  BOOL hasName_:1;
  BOOL hasDesc_:1;
  BOOL hasSignature_:1;
  BOOL hasStatusDesc_:1;
  BOOL hasBgImage_:1;
  BOOL hasMedalImage_:1;
  BOOL hasCreator_:1;
  BOOL hasTopic_:1;
  SInt64 balance;
  SInt32 level;
  SInt32 fame;
  SInt32 createDate;
  SInt32 memberFee;
  SInt32 capacity;
  SInt32 size;
  SInt32 guestSize;
  SInt32 guestCapacity;
  SInt32 topicCount;
  SInt32 fanCount;
  SInt32 titleCapacity;
  SInt32 status;
  NSString* groupId;
  NSString* name;
  NSString* desc;
  NSString* signature;
  NSString* statusDesc;
  NSString* bgImage;
  NSString* medalImage;
  PBGameUser* creator;
  PBBBSPost* topic;
  NSMutableArray * titlesArray;
  NSMutableArray * adminsArray;
  NSMutableArray * usersArray;
  NSMutableArray * guestsArray;
}
- (BOOL) hasGroupId;
- (BOOL) hasName;
- (BOOL) hasLevel;
- (BOOL) hasFame;
- (BOOL) hasBalance;
- (BOOL) hasCreateDate;
- (BOOL) hasMemberFee;
- (BOOL) hasCapacity;
- (BOOL) hasSize;
- (BOOL) hasGuestSize;
- (BOOL) hasGuestCapacity;
- (BOOL) hasTopicCount;
- (BOOL) hasFanCount;
- (BOOL) hasTitleCapacity;
- (BOOL) hasDesc;
- (BOOL) hasSignature;
- (BOOL) hasStatus;
- (BOOL) hasStatusDesc;
- (BOOL) hasBgImage;
- (BOOL) hasMedalImage;
- (BOOL) hasCreator;
- (BOOL) hasTopic;
@property (readonly, strong) NSString* groupId;
@property (readonly, strong) NSString* name;
@property (readonly) SInt32 level;
@property (readonly) SInt32 fame;
@property (readonly) SInt64 balance;
@property (readonly) SInt32 createDate;
@property (readonly) SInt32 memberFee;
@property (readonly) SInt32 capacity;
@property (readonly) SInt32 size;
@property (readonly) SInt32 guestSize;
@property (readonly) SInt32 guestCapacity;
@property (readonly) SInt32 topicCount;
@property (readonly) SInt32 fanCount;
@property (readonly) SInt32 titleCapacity;
@property (readonly, strong) NSString* desc;
@property (readonly, strong) NSString* signature;
@property (readonly) SInt32 status;
@property (readonly, strong) NSString* statusDesc;
@property (readonly, strong) NSString* bgImage;
@property (readonly, strong) NSString* medalImage;
@property (readonly, strong) NSArray * titles;
@property (readonly, strong) PBGameUser* creator;
@property (readonly, strong) NSArray * admins;
@property (readonly, strong) NSArray * users;
@property (readonly, strong) NSArray * guests;
@property (readonly, strong) PBBBSPost* topic;
- (PBGroupTitle*)titlesAtIndex:(NSUInteger)index;
- (PBGameUser*)adminsAtIndex:(NSUInteger)index;
- (PBGroupUsersByTitle*)usersAtIndex:(NSUInteger)index;
- (PBGameUser*)guestsAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBGroupBuilder*) builder;
+ (PBGroupBuilder*) builder;
+ (PBGroupBuilder*) builderWithPrototype:(PBGroup*) prototype;
- (PBGroupBuilder*) toBuilder;

+ (PBGroup*) parseFromData:(NSData*) data;
+ (PBGroup*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroup*) parseFromInputStream:(NSInputStream*) input;
+ (PBGroup*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroup*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBGroup*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBGroupBuilder : PBGeneratedMessageBuilder {
@private
  PBGroup* resultPbgroup;
}

- (PBGroup*) defaultInstance;

- (PBGroupBuilder*) clear;
- (PBGroupBuilder*) clone;

- (PBGroup*) build;
- (PBGroup*) buildPartial;

- (PBGroupBuilder*) mergeFrom:(PBGroup*) other;
- (PBGroupBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBGroupBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasGroupId;
- (NSString*) groupId;
- (PBGroupBuilder*) setGroupId:(NSString*) value;
- (PBGroupBuilder*) clearGroupId;

- (BOOL) hasName;
- (NSString*) name;
- (PBGroupBuilder*) setName:(NSString*) value;
- (PBGroupBuilder*) clearName;

- (BOOL) hasLevel;
- (SInt32) level;
- (PBGroupBuilder*) setLevel:(SInt32) value;
- (PBGroupBuilder*) clearLevel;

- (BOOL) hasFame;
- (SInt32) fame;
- (PBGroupBuilder*) setFame:(SInt32) value;
- (PBGroupBuilder*) clearFame;

- (BOOL) hasBalance;
- (SInt64) balance;
- (PBGroupBuilder*) setBalance:(SInt64) value;
- (PBGroupBuilder*) clearBalance;

- (BOOL) hasCreateDate;
- (SInt32) createDate;
- (PBGroupBuilder*) setCreateDate:(SInt32) value;
- (PBGroupBuilder*) clearCreateDate;

- (BOOL) hasMemberFee;
- (SInt32) memberFee;
- (PBGroupBuilder*) setMemberFee:(SInt32) value;
- (PBGroupBuilder*) clearMemberFee;

- (BOOL) hasCapacity;
- (SInt32) capacity;
- (PBGroupBuilder*) setCapacity:(SInt32) value;
- (PBGroupBuilder*) clearCapacity;

- (BOOL) hasSize;
- (SInt32) size;
- (PBGroupBuilder*) setSize:(SInt32) value;
- (PBGroupBuilder*) clearSize;

- (BOOL) hasGuestSize;
- (SInt32) guestSize;
- (PBGroupBuilder*) setGuestSize:(SInt32) value;
- (PBGroupBuilder*) clearGuestSize;

- (BOOL) hasGuestCapacity;
- (SInt32) guestCapacity;
- (PBGroupBuilder*) setGuestCapacity:(SInt32) value;
- (PBGroupBuilder*) clearGuestCapacity;

- (BOOL) hasTopicCount;
- (SInt32) topicCount;
- (PBGroupBuilder*) setTopicCount:(SInt32) value;
- (PBGroupBuilder*) clearTopicCount;

- (BOOL) hasFanCount;
- (SInt32) fanCount;
- (PBGroupBuilder*) setFanCount:(SInt32) value;
- (PBGroupBuilder*) clearFanCount;

- (BOOL) hasTitleCapacity;
- (SInt32) titleCapacity;
- (PBGroupBuilder*) setTitleCapacity:(SInt32) value;
- (PBGroupBuilder*) clearTitleCapacity;

- (BOOL) hasDesc;
- (NSString*) desc;
- (PBGroupBuilder*) setDesc:(NSString*) value;
- (PBGroupBuilder*) clearDesc;

- (BOOL) hasSignature;
- (NSString*) signature;
- (PBGroupBuilder*) setSignature:(NSString*) value;
- (PBGroupBuilder*) clearSignature;

- (BOOL) hasStatus;
- (SInt32) status;
- (PBGroupBuilder*) setStatus:(SInt32) value;
- (PBGroupBuilder*) clearStatus;

- (BOOL) hasStatusDesc;
- (NSString*) statusDesc;
- (PBGroupBuilder*) setStatusDesc:(NSString*) value;
- (PBGroupBuilder*) clearStatusDesc;

- (BOOL) hasBgImage;
- (NSString*) bgImage;
- (PBGroupBuilder*) setBgImage:(NSString*) value;
- (PBGroupBuilder*) clearBgImage;

- (BOOL) hasMedalImage;
- (NSString*) medalImage;
- (PBGroupBuilder*) setMedalImage:(NSString*) value;
- (PBGroupBuilder*) clearMedalImage;

- (NSMutableArray *)titles;
- (PBGroupTitle*)titlesAtIndex:(NSUInteger)index;
- (PBGroupBuilder *)addTitles:(PBGroupTitle*)value;
- (PBGroupBuilder *)setTitlesArray:(NSArray *)array;
- (PBGroupBuilder *)clearTitles;

- (BOOL) hasCreator;
- (PBGameUser*) creator;
- (PBGroupBuilder*) setCreator:(PBGameUser*) value;
- (PBGroupBuilder*) setCreatorBuilder:(PBGameUserBuilder*) builderForValue;
- (PBGroupBuilder*) mergeCreator:(PBGameUser*) value;
- (PBGroupBuilder*) clearCreator;

- (NSMutableArray *)admins;
- (PBGameUser*)adminsAtIndex:(NSUInteger)index;
- (PBGroupBuilder *)addAdmins:(PBGameUser*)value;
- (PBGroupBuilder *)setAdminsArray:(NSArray *)array;
- (PBGroupBuilder *)clearAdmins;

- (NSMutableArray *)users;
- (PBGroupUsersByTitle*)usersAtIndex:(NSUInteger)index;
- (PBGroupBuilder *)addUsers:(PBGroupUsersByTitle*)value;
- (PBGroupBuilder *)setUsersArray:(NSArray *)array;
- (PBGroupBuilder *)clearUsers;

- (NSMutableArray *)guests;
- (PBGameUser*)guestsAtIndex:(NSUInteger)index;
- (PBGroupBuilder *)addGuests:(PBGameUser*)value;
- (PBGroupBuilder *)setGuestsArray:(NSArray *)array;
- (PBGroupBuilder *)clearGuests;

- (BOOL) hasTopic;
- (PBBBSPost*) topic;
- (PBGroupBuilder*) setTopic:(PBBBSPost*) value;
- (PBGroupBuilder*) setTopicBuilder:(PBBBSPostBuilder*) builderForValue;
- (PBGroupBuilder*) mergeTopic:(PBBBSPost*) value;
- (PBGroupBuilder*) clearTopic;
@end

@interface PBGroupUserRole : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasRole_:1;
  BOOL hasPermission_:1;
  BOOL hasGroupId_:1;
  BOOL hasGroupName_:1;
  SInt32 role;
  SInt32 permission;
  NSString* groupId;
  NSString* groupName;
}
- (BOOL) hasGroupId;
- (BOOL) hasRole;
- (BOOL) hasPermission;
- (BOOL) hasGroupName;
@property (readonly, strong) NSString* groupId;
@property (readonly) SInt32 role;
@property (readonly) SInt32 permission;
@property (readonly, strong) NSString* groupName;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBGroupUserRoleBuilder*) builder;
+ (PBGroupUserRoleBuilder*) builder;
+ (PBGroupUserRoleBuilder*) builderWithPrototype:(PBGroupUserRole*) prototype;
- (PBGroupUserRoleBuilder*) toBuilder;

+ (PBGroupUserRole*) parseFromData:(NSData*) data;
+ (PBGroupUserRole*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupUserRole*) parseFromInputStream:(NSInputStream*) input;
+ (PBGroupUserRole*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupUserRole*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBGroupUserRole*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBGroupUserRoleBuilder : PBGeneratedMessageBuilder {
@private
  PBGroupUserRole* resultPbgroupUserRole;
}

- (PBGroupUserRole*) defaultInstance;

- (PBGroupUserRoleBuilder*) clear;
- (PBGroupUserRoleBuilder*) clone;

- (PBGroupUserRole*) build;
- (PBGroupUserRole*) buildPartial;

- (PBGroupUserRoleBuilder*) mergeFrom:(PBGroupUserRole*) other;
- (PBGroupUserRoleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBGroupUserRoleBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasGroupId;
- (NSString*) groupId;
- (PBGroupUserRoleBuilder*) setGroupId:(NSString*) value;
- (PBGroupUserRoleBuilder*) clearGroupId;

- (BOOL) hasRole;
- (SInt32) role;
- (PBGroupUserRoleBuilder*) setRole:(SInt32) value;
- (PBGroupUserRoleBuilder*) clearRole;

- (BOOL) hasPermission;
- (SInt32) permission;
- (PBGroupUserRoleBuilder*) setPermission:(SInt32) value;
- (PBGroupUserRoleBuilder*) clearPermission;

- (BOOL) hasGroupName;
- (NSString*) groupName;
- (PBGroupUserRoleBuilder*) setGroupName:(NSString*) value;
- (PBGroupUserRoleBuilder*) clearGroupName;
@end

@interface PBGroupNotice : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasType_:1;
  BOOL hasStatus_:1;
  BOOL hasCreateDate_:1;
  BOOL hasAmount_:1;
  BOOL hasNoticeId_:1;
  BOOL hasGroupId_:1;
  BOOL hasGroupName_:1;
  BOOL hasMessage_:1;
  BOOL hasPublisher_:1;
  BOOL hasTarget_:1;
  SInt32 type;
  SInt32 status;
  SInt32 createDate;
  SInt32 amount;
  NSString* noticeId;
  NSString* groupId;
  NSString* groupName;
  NSString* message;
  PBGameUser* publisher;
  PBGameUser* target;
}
- (BOOL) hasNoticeId;
- (BOOL) hasType;
- (BOOL) hasStatus;
- (BOOL) hasGroupId;
- (BOOL) hasGroupName;
- (BOOL) hasMessage;
- (BOOL) hasCreateDate;
- (BOOL) hasAmount;
- (BOOL) hasPublisher;
- (BOOL) hasTarget;
@property (readonly, strong) NSString* noticeId;
@property (readonly) SInt32 type;
@property (readonly) SInt32 status;
@property (readonly, strong) NSString* groupId;
@property (readonly, strong) NSString* groupName;
@property (readonly, strong) NSString* message;
@property (readonly) SInt32 createDate;
@property (readonly) SInt32 amount;
@property (readonly, strong) PBGameUser* publisher;
@property (readonly, strong) PBGameUser* target;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBGroupNoticeBuilder*) builder;
+ (PBGroupNoticeBuilder*) builder;
+ (PBGroupNoticeBuilder*) builderWithPrototype:(PBGroupNotice*) prototype;
- (PBGroupNoticeBuilder*) toBuilder;

+ (PBGroupNotice*) parseFromData:(NSData*) data;
+ (PBGroupNotice*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupNotice*) parseFromInputStream:(NSInputStream*) input;
+ (PBGroupNotice*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBGroupNotice*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBGroupNotice*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBGroupNoticeBuilder : PBGeneratedMessageBuilder {
@private
  PBGroupNotice* resultPbgroupNotice;
}

- (PBGroupNotice*) defaultInstance;

- (PBGroupNoticeBuilder*) clear;
- (PBGroupNoticeBuilder*) clone;

- (PBGroupNotice*) build;
- (PBGroupNotice*) buildPartial;

- (PBGroupNoticeBuilder*) mergeFrom:(PBGroupNotice*) other;
- (PBGroupNoticeBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBGroupNoticeBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasNoticeId;
- (NSString*) noticeId;
- (PBGroupNoticeBuilder*) setNoticeId:(NSString*) value;
- (PBGroupNoticeBuilder*) clearNoticeId;

- (BOOL) hasType;
- (SInt32) type;
- (PBGroupNoticeBuilder*) setType:(SInt32) value;
- (PBGroupNoticeBuilder*) clearType;

- (BOOL) hasStatus;
- (SInt32) status;
- (PBGroupNoticeBuilder*) setStatus:(SInt32) value;
- (PBGroupNoticeBuilder*) clearStatus;

- (BOOL) hasGroupId;
- (NSString*) groupId;
- (PBGroupNoticeBuilder*) setGroupId:(NSString*) value;
- (PBGroupNoticeBuilder*) clearGroupId;

- (BOOL) hasGroupName;
- (NSString*) groupName;
- (PBGroupNoticeBuilder*) setGroupName:(NSString*) value;
- (PBGroupNoticeBuilder*) clearGroupName;

- (BOOL) hasMessage;
- (NSString*) message;
- (PBGroupNoticeBuilder*) setMessage:(NSString*) value;
- (PBGroupNoticeBuilder*) clearMessage;

- (BOOL) hasCreateDate;
- (SInt32) createDate;
- (PBGroupNoticeBuilder*) setCreateDate:(SInt32) value;
- (PBGroupNoticeBuilder*) clearCreateDate;

- (BOOL) hasAmount;
- (SInt32) amount;
- (PBGroupNoticeBuilder*) setAmount:(SInt32) value;
- (PBGroupNoticeBuilder*) clearAmount;

- (BOOL) hasPublisher;
- (PBGameUser*) publisher;
- (PBGroupNoticeBuilder*) setPublisher:(PBGameUser*) value;
- (PBGroupNoticeBuilder*) setPublisherBuilder:(PBGameUserBuilder*) builderForValue;
- (PBGroupNoticeBuilder*) mergePublisher:(PBGameUser*) value;
- (PBGroupNoticeBuilder*) clearPublisher;

- (BOOL) hasTarget;
- (PBGameUser*) target;
- (PBGroupNoticeBuilder*) setTarget:(PBGameUser*) value;
- (PBGroupNoticeBuilder*) setTargetBuilder:(PBGameUserBuilder*) builderForValue;
- (PBGroupNoticeBuilder*) mergeTarget:(PBGameUser*) value;
- (PBGroupNoticeBuilder*) clearTarget;
@end

@interface PBContest : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  BOOL hasContestantsOnly_:1;
  BOOL hasCanVote_:1;
  BOOL hasIsAnounymous_:1;
  BOOL hasCanSubmit_:1;
  BOOL hasMaxFlowerPerContest_:1;
  BOOL hasStartDate_:1;
  BOOL hasEndDate_:1;
  BOOL hasType_:1;
  BOOL hasStatus_:1;
  BOOL hasParticipantCount_:1;
  BOOL hasOpusCount_:1;
  BOOL hasJoinersType_:1;
  BOOL hasVoteStartDate_:1;
  BOOL hasVoteEndDate_:1;
  BOOL hasCanSubmitCount_:1;
  BOOL hasJudgeRankWeight_:1;
  BOOL hasMaxFlowerPerOpus_:1;
  BOOL hasContestId_:1;
  BOOL hasStatementUrl_:1;
  BOOL hasContestUrl_:1;
  BOOL hasTitle_:1;
  BOOL hasDesc_:1;
  BOOL hasGroup_:1;
  BOOL hasCategory_:1;
  BOOL contestantsOnly_:1;
  BOOL canVote_:1;
  BOOL isAnounymous_:1;
  BOOL canSubmit_:1;
  SInt32 maxFlowerPerContest;
  SInt32 startDate;
  SInt32 endDate;
  SInt32 type;
  SInt32 status;
  SInt32 participantCount;
  SInt32 opusCount;
  SInt32 joinersType;
  SInt32 voteStartDate;
  SInt32 voteEndDate;
  SInt32 canSubmitCount;
  SInt32 judgeRankWeight;
  SInt32 maxFlowerPerOpus;
  NSString* contestId;
  NSString* statementUrl;
  NSString* contestUrl;
  NSString* title;
  NSString* desc;
  PBGroup* group;
  PBOpusCategoryType category;
  PBAppendableArray * awardRulesArray;
  NSMutableArray * contestantsArray;
  NSMutableArray * judgesArray;
  NSMutableArray * reportersArray;
  NSMutableArray * winnerUsersArray;
  NSMutableArray * awardUsersArray;
  NSMutableArray * rankTypesArray;
}
- (BOOL) hasContestId;
- (BOOL) hasStartDate;
- (BOOL) hasEndDate;
- (BOOL) hasType;
- (BOOL) hasStatus;
- (BOOL) hasParticipantCount;
- (BOOL) hasOpusCount;
- (BOOL) hasTitle;
- (BOOL) hasContestUrl;
- (BOOL) hasStatementUrl;
- (BOOL) hasVoteStartDate;
- (BOOL) hasVoteEndDate;
- (BOOL) hasIsAnounymous;
- (BOOL) hasCategory;
- (BOOL) hasCanSubmitCount;
- (BOOL) hasMaxFlowerPerContest;
- (BOOL) hasMaxFlowerPerOpus;
- (BOOL) hasJudgeRankWeight;
- (BOOL) hasCanSubmit;
- (BOOL) hasCanVote;
- (BOOL) hasContestantsOnly;
- (BOOL) hasGroup;
- (BOOL) hasJoinersType;
- (BOOL) hasDesc;
@property (readonly, strong) NSString* contestId;
@property (readonly) SInt32 startDate;
@property (readonly) SInt32 endDate;
@property (readonly) SInt32 type;
@property (readonly) SInt32 status;
@property (readonly) SInt32 participantCount;
@property (readonly) SInt32 opusCount;
@property (readonly, strong) NSString* title;
@property (readonly, strong) NSString* contestUrl;
@property (readonly, strong) NSString* statementUrl;
@property (readonly) SInt32 voteStartDate;
@property (readonly) SInt32 voteEndDate;
- (BOOL) isAnounymous;
@property (readonly) PBOpusCategoryType category;
@property (readonly) SInt32 canSubmitCount;
@property (readonly) SInt32 maxFlowerPerContest;
@property (readonly) SInt32 maxFlowerPerOpus;
@property (readonly) SInt32 judgeRankWeight;
- (BOOL) canSubmit;
- (BOOL) canVote;
- (BOOL) contestantsOnly;
@property (readonly, strong) NSArray * contestants;
@property (readonly, strong) NSArray * judges;
@property (readonly, strong) NSArray * reporters;
@property (readonly, strong) NSArray * winnerUsers;
@property (readonly, strong) NSArray * awardUsers;
@property (readonly, strong) NSArray * rankTypes;
@property (readonly, strong) PBGroup* group;
@property (readonly) SInt32 joinersType;
@property (readonly, strong) NSString* desc;
@property (readonly, strong) PBArray * awardRules;
- (PBGameUser*)contestantsAtIndex:(NSUInteger)index;
- (PBGameUser*)judgesAtIndex:(NSUInteger)index;
- (PBGameUser*)reportersAtIndex:(NSUInteger)index;
- (PBUserAward*)winnerUsersAtIndex:(NSUInteger)index;
- (PBUserAward*)awardUsersAtIndex:(NSUInteger)index;
- (PBIntKeyValue*)rankTypesAtIndex:(NSUInteger)index;
- (SInt32)awardRulesAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBContestBuilder*) builder;
+ (PBContestBuilder*) builder;
+ (PBContestBuilder*) builderWithPrototype:(PBContest*) prototype;
- (PBContestBuilder*) toBuilder;

+ (PBContest*) parseFromData:(NSData*) data;
+ (PBContest*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBContest*) parseFromInputStream:(NSInputStream*) input;
+ (PBContest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBContest*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBContest*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBContestBuilder : PBGeneratedMessageBuilder {
@private
  PBContest* resultPbcontest;
}

- (PBContest*) defaultInstance;

- (PBContestBuilder*) clear;
- (PBContestBuilder*) clone;

- (PBContest*) build;
- (PBContest*) buildPartial;

- (PBContestBuilder*) mergeFrom:(PBContest*) other;
- (PBContestBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBContestBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasContestId;
- (NSString*) contestId;
- (PBContestBuilder*) setContestId:(NSString*) value;
- (PBContestBuilder*) clearContestId;

- (BOOL) hasStartDate;
- (SInt32) startDate;
- (PBContestBuilder*) setStartDate:(SInt32) value;
- (PBContestBuilder*) clearStartDate;

- (BOOL) hasEndDate;
- (SInt32) endDate;
- (PBContestBuilder*) setEndDate:(SInt32) value;
- (PBContestBuilder*) clearEndDate;

- (BOOL) hasType;
- (SInt32) type;
- (PBContestBuilder*) setType:(SInt32) value;
- (PBContestBuilder*) clearType;

- (BOOL) hasStatus;
- (SInt32) status;
- (PBContestBuilder*) setStatus:(SInt32) value;
- (PBContestBuilder*) clearStatus;

- (BOOL) hasParticipantCount;
- (SInt32) participantCount;
- (PBContestBuilder*) setParticipantCount:(SInt32) value;
- (PBContestBuilder*) clearParticipantCount;

- (BOOL) hasOpusCount;
- (SInt32) opusCount;
- (PBContestBuilder*) setOpusCount:(SInt32) value;
- (PBContestBuilder*) clearOpusCount;

- (BOOL) hasTitle;
- (NSString*) title;
- (PBContestBuilder*) setTitle:(NSString*) value;
- (PBContestBuilder*) clearTitle;

- (BOOL) hasContestUrl;
- (NSString*) contestUrl;
- (PBContestBuilder*) setContestUrl:(NSString*) value;
- (PBContestBuilder*) clearContestUrl;

- (BOOL) hasStatementUrl;
- (NSString*) statementUrl;
- (PBContestBuilder*) setStatementUrl:(NSString*) value;
- (PBContestBuilder*) clearStatementUrl;

- (BOOL) hasVoteStartDate;
- (SInt32) voteStartDate;
- (PBContestBuilder*) setVoteStartDate:(SInt32) value;
- (PBContestBuilder*) clearVoteStartDate;

- (BOOL) hasVoteEndDate;
- (SInt32) voteEndDate;
- (PBContestBuilder*) setVoteEndDate:(SInt32) value;
- (PBContestBuilder*) clearVoteEndDate;

- (BOOL) hasIsAnounymous;
- (BOOL) isAnounymous;
- (PBContestBuilder*) setIsAnounymous:(BOOL) value;
- (PBContestBuilder*) clearIsAnounymous;

- (BOOL) hasCategory;
- (PBOpusCategoryType) category;
- (PBContestBuilder*) setCategory:(PBOpusCategoryType) value;
- (PBContestBuilder*) clearCategory;

- (BOOL) hasCanSubmitCount;
- (SInt32) canSubmitCount;
- (PBContestBuilder*) setCanSubmitCount:(SInt32) value;
- (PBContestBuilder*) clearCanSubmitCount;

- (BOOL) hasMaxFlowerPerContest;
- (SInt32) maxFlowerPerContest;
- (PBContestBuilder*) setMaxFlowerPerContest:(SInt32) value;
- (PBContestBuilder*) clearMaxFlowerPerContest;

- (BOOL) hasMaxFlowerPerOpus;
- (SInt32) maxFlowerPerOpus;
- (PBContestBuilder*) setMaxFlowerPerOpus:(SInt32) value;
- (PBContestBuilder*) clearMaxFlowerPerOpus;

- (BOOL) hasJudgeRankWeight;
- (SInt32) judgeRankWeight;
- (PBContestBuilder*) setJudgeRankWeight:(SInt32) value;
- (PBContestBuilder*) clearJudgeRankWeight;

- (BOOL) hasCanSubmit;
- (BOOL) canSubmit;
- (PBContestBuilder*) setCanSubmit:(BOOL) value;
- (PBContestBuilder*) clearCanSubmit;

- (BOOL) hasCanVote;
- (BOOL) canVote;
- (PBContestBuilder*) setCanVote:(BOOL) value;
- (PBContestBuilder*) clearCanVote;

- (BOOL) hasContestantsOnly;
- (BOOL) contestantsOnly;
- (PBContestBuilder*) setContestantsOnly:(BOOL) value;
- (PBContestBuilder*) clearContestantsOnly;

- (NSMutableArray *)contestants;
- (PBGameUser*)contestantsAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addContestants:(PBGameUser*)value;
- (PBContestBuilder *)setContestantsArray:(NSArray *)array;
- (PBContestBuilder *)clearContestants;

- (NSMutableArray *)judges;
- (PBGameUser*)judgesAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addJudges:(PBGameUser*)value;
- (PBContestBuilder *)setJudgesArray:(NSArray *)array;
- (PBContestBuilder *)clearJudges;

- (NSMutableArray *)reporters;
- (PBGameUser*)reportersAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addReporters:(PBGameUser*)value;
- (PBContestBuilder *)setReportersArray:(NSArray *)array;
- (PBContestBuilder *)clearReporters;

- (NSMutableArray *)winnerUsers;
- (PBUserAward*)winnerUsersAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addWinnerUsers:(PBUserAward*)value;
- (PBContestBuilder *)setWinnerUsersArray:(NSArray *)array;
- (PBContestBuilder *)clearWinnerUsers;

- (NSMutableArray *)awardUsers;
- (PBUserAward*)awardUsersAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addAwardUsers:(PBUserAward*)value;
- (PBContestBuilder *)setAwardUsersArray:(NSArray *)array;
- (PBContestBuilder *)clearAwardUsers;

- (NSMutableArray *)rankTypes;
- (PBIntKeyValue*)rankTypesAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addRankTypes:(PBIntKeyValue*)value;
- (PBContestBuilder *)setRankTypesArray:(NSArray *)array;
- (PBContestBuilder *)clearRankTypes;

- (BOOL) hasGroup;
- (PBGroup*) group;
- (PBContestBuilder*) setGroup:(PBGroup*) value;
- (PBContestBuilder*) setGroupBuilder:(PBGroupBuilder*) builderForValue;
- (PBContestBuilder*) mergeGroup:(PBGroup*) value;
- (PBContestBuilder*) clearGroup;

- (BOOL) hasJoinersType;
- (SInt32) joinersType;
- (PBContestBuilder*) setJoinersType:(SInt32) value;
- (PBContestBuilder*) clearJoinersType;

- (BOOL) hasDesc;
- (NSString*) desc;
- (PBContestBuilder*) setDesc:(NSString*) value;
- (PBContestBuilder*) clearDesc;

- (PBAppendableArray *)awardRules;
- (SInt32)awardRulesAtIndex:(NSUInteger)index;
- (PBContestBuilder *)addAwardRules:(SInt32)value;
- (PBContestBuilder *)setAwardRulesArray:(NSArray *)array;
- (PBContestBuilder *)setAwardRulesValues:(const SInt32 *)values count:(NSUInteger)count;
- (PBContestBuilder *)clearAwardRules;
@end

@interface PBContestList : PBGeneratedMessage<GeneratedMessageProtocol> {
@private
  NSMutableArray * contestsArray;
}
@property (readonly, strong) NSArray * contests;
- (PBContest*)contestsAtIndex:(NSUInteger)index;

+ (instancetype) defaultInstance;
- (instancetype) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PBContestListBuilder*) builder;
+ (PBContestListBuilder*) builder;
+ (PBContestListBuilder*) builderWithPrototype:(PBContestList*) prototype;
- (PBContestListBuilder*) toBuilder;

+ (PBContestList*) parseFromData:(NSData*) data;
+ (PBContestList*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBContestList*) parseFromInputStream:(NSInputStream*) input;
+ (PBContestList*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PBContestList*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PBContestList*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PBContestListBuilder : PBGeneratedMessageBuilder {
@private
  PBContestList* resultPbcontestList;
}

- (PBContestList*) defaultInstance;

- (PBContestListBuilder*) clear;
- (PBContestListBuilder*) clone;

- (PBContestList*) build;
- (PBContestList*) buildPartial;

- (PBContestListBuilder*) mergeFrom:(PBContestList*) other;
- (PBContestListBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PBContestListBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (NSMutableArray *)contests;
- (PBContest*)contestsAtIndex:(NSUInteger)index;
- (PBContestListBuilder *)addContests:(PBContest*)value;
- (PBContestListBuilder *)setContestsArray:(NSArray *)array;
- (PBContestListBuilder *)clearContests;
@end


// @@protoc_insertion_point(global_scope)
