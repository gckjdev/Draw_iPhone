//
//  AskPsManager.m
//  Draw
//
//  Created by haodong on 13-6-14.
//
//

#import "AskPsManager.h"

#import "Opus.pb.h"
#import "StringUtil.h"


@implementation AskPsManager

+ (PBOpus *)createTestAskPs
{
    PBOpusBuilder *builer  = [[[PBOpusBuilder alloc] init] autorelease];
    [builer setOpusId:[NSString GetUUID]];
    [builer setDesc:@"this is desc"];
    [builer setImage:@"http://ts3.mm.bing.net/th?id=H.4871614937760894&pid=1.7"];
    PBAskPsBuilder *pbAskPsBuilder = [[[PBAskPsBuilder alloc] init] autorelease];
    [pbAskPsBuilder addAllRequirement:[NSArray arrayWithObjects:@"求恶搞",@"霸气一点", nil]];
    [pbAskPsBuilder setAwardCoinsMaxTotal:50];
    [pbAskPsBuilder setAwardCoinsPerUser:500];
    [pbAskPsBuilder setAwardIngotBestUser:3];
    PBAskPs *pbAskP = [pbAskPsBuilder build];
    [builer setAskPs:pbAskP];
    return [builer build];
}

+ (NSArray *)createAskPsList
{
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (int i = 0 ; i < 10; i ++) {
        [mutableArray addObject:[self createTestAskPs]];
    }
    return mutableArray;
}

@end
