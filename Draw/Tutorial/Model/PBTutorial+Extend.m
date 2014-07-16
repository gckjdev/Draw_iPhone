//
//  PBTutorial+Extend.m
//  Draw
//
//  Created by qqn_pipi on 14-6-28.
//
//

#import "PBTutorial+Extend.h"
#import "LocaleUtils.h"
#import "TutorialCoreManager.h"

@implementation PBTutorial (Extend)

- (NSString*)name
{
    if ([LocaleUtils isChina]){
        return self.cnName;
    }
    
    if ([LocaleUtils isChinese]){
        if ([self.tcnName length] == 0){
            return self.cnName;
        }
        else{
            return self.tcnName;
        }
    }
    
    if ([self.enName length] == 0){
        return self.cnName;
    }
    else{
        return self.enName;
    }
}

- (NSString*)desc
{
    if([LocaleUtils isChina]){
        return self.cnDesc;
    }
    if([LocaleUtils isChinese]){
        if([self.tcnDesc length] == 0){
            return self.cnDesc;
        }
        else{
            return self.tcnDesc;
        }
    }
    if ([self.enName length] == 0){
        return self.cnDesc;
    }
    else{
        return self.enDesc;
    }

    
}

- (NSString*)singleCategoryName:(int)value
{
    switch (value) {
            
        case 0:
            return NSLS(@"kTutorialCategoryNewer");
        case 1:
            return NSLS(@"kTutorialCategoryHigherLevel");
        case 2:
            return NSLS(@"kTutorialCategoryTopLevel");
        default:
            return @"";
    }
}

- (NSString*)categoryName
{
    NSString* retName = @"";
    for (NSNumber* category in self.categoriesList){
        int value = category.intValue;
        NSString* name = [self singleCategoryName:value];
        if ([name length] > 0){
            retName = [retName stringByAppendingString:name];
            if ([self.categoriesList lastObject] != category){
                retName = [retName stringByAppendingString:@", "];
            }
        }
    }
    
    return retName;
}

- (PBStage*)getStageByIndex:(NSUInteger)index
{
    if (index >= [self.stagesList count]){
        return nil;
    }
    
    return [self.stagesList objectAtIndex:index];
}

@end


//pbStage extend
@implementation PBStage (Extend2)

-(NSString *) name {
    if ([LocaleUtils isChina]){
        return self.cnName;
    }
    
    if ([LocaleUtils isChinese]){
        if ([self.tcnName length] == 0){
            return self.cnName;
        }
        else{
            return self.tcnName;
        }
    }
    
    if ([self.enName length] == 0){
        return self.cnName;
    }
    else{
        return self.enName;
    }

    
}

- (NSString*)desc
{
    if([LocaleUtils isChina]){
        return self.cnDesc;
    }
    if([LocaleUtils isChinese]){
        if([self.tcnDesc length] == 0){
            return self.cnDesc;
        }
        else{
            return self.tcnName;
        }
    }
    if ([self.enName length] == 0){
        return self.cnDesc;
    }
    else{
        return self.enDesc;
    }
    
    
}




@end

@implementation PBUserTutorial (Extend3)

- (BOOL)isStageLock:(int)stageIndex
{
    return (stageIndex > self.currentStageIndex);
}

@end

@implementation PBUserStage (Extend4)

- (NSString*)getCurrentChapterOpusId
{
#ifdef DEBUG
    return @"53c4dc42e4b089b4ff460ed3";
#endif
    
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorialId];
    if (self.stageIndex >= [tutorial.stagesList count]){
        return nil;
    }
    
    PBStage* stage = [tutorial.stagesList objectAtIndex:self.stageIndex];
    if (stage == nil){
        return nil;
    }
    
    if (self.currentChapterIndex >= [stage.chapterList count]){
        return nil;
    }
    
    PBChapter* chapter = [stage.chapterList objectAtIndex:self.currentChapterIndex];
    return chapter.opusId;
}

@end

@implementation PBUserStage_Builder (Extend5)

- (NSString*)getCurrentChapterOpusId
{
#ifdef DEBUG
    return @"53c4dc42e4b089b4ff460ed3";
#endif
    
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorialId];
    if (self.stageIndex >= [tutorial.stagesList count]){
        return nil;
    }
    
    PBStage* stage = [tutorial.stagesList objectAtIndex:self.stageIndex];
    if (stage == nil){
        return nil;
    }
    
    if (self.currentChapterIndex >= [stage.chapterList count]){
        return nil;
    }
    
    PBChapter* chapter = [stage.chapterList objectAtIndex:self.currentChapterIndex];
    return chapter.opusId;
}

@end

