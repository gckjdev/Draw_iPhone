//
//  TutorialProtoModel.m
//  Draw
//
//  Created by ChaoSo on 14-9-11.
//
//

#import "TutorialProtoModel.h"

@implementation TutorialProtoModel

+ (id) objectWithDictionary:(NSDictionary*)dictionary
{
    id obj = [[[TutorialProtoModel alloc] initWithDictionary:dictionary] autorelease];
    return obj;
}

- (id) initWithDictionary:(NSDictionary*)dictionary
{
    self=[super init];
    if(self)
    {
        PPDebug(@"init billboard = %@", dictionary);
        self.dataDict = dictionary;
    }
    return self;
}
- (NSString*)tutorialName
{
    return [_dataDict objectForKey:@"tutorialName"];
}
- (int)tutorialCategory
{
    return [[_dataDict objectForKey:@"tutorialCategory"] intValue];
}
- (int)tutorialType
{
    return [[_dataDict objectForKey:@"tutorialType"] intValue];
}
- (NSString*)tutorialDesc
{
    return [_dataDict objectForKey:@"tutorialDesc"];
}
- (NSString*)tutorialImageUrl
{
    return [_dataDict objectForKey:@"tutorialImageUrl"];
}
- (NSArray*)stageList
{
    return [_dataDict objectForKey:@"stageList"];
}


-(void)dealloc{
    PPRelease(_dataDict);
    [super dealloc];
}
@end
