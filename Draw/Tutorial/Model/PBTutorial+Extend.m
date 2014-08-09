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
#import "UserTutorialManager.h"

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

- (PBStage*)nextStage:(NSUInteger)index
{
    int nextIndex = index+1;
    return [self getStageByIndex:nextIndex];
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

- (NSArray*)tipsImageList:(NSUInteger)chapterIndex
{
    if ([self.chapterList count] == 0){
        return nil;
    }
    
    if (chapterIndex >= [self.chapterList count]){
        return nil;
    }
    
    PBChapter* chapter = [self.chapterList objectAtIndex:chapterIndex];
    if ([chapter.tipsList count] == 0){
        return nil;
    }
    
    NSMutableArray* retList = [NSMutableArray array];
    for (PBTip* tip in chapter.tipsList){
        if (tip.imageName){
            [retList addObject:tip.imageName];
        }
    }
    
    return retList;
}

- (BOOL)hasMoreThanOneChapter
{
    if ([self.chapterList count] > 1){
        return YES;
    }
    else{
        return NO;
    }
}


@end

@implementation PBUserTutorial (Extend3)

- (BOOL)isStageLock:(int)stageIndex
{
    return (stageIndex > self.currentStageIndex);
}

- (int)progress
{
    int currentTryStageCount = [self.userStagesList count];
    int passCount = currentTryStageCount-1;
    if (self.currentStageIndex == (currentTryStageCount-1)){
        // already try current stage index, check if passed
        PBUserStage* userStage = [self.userStagesList objectAtIndex:self.currentStageIndex];
        if ([[UserTutorialManager defaultManager] isPass:userStage.bestScore] ||
            [[UserTutorialManager defaultManager] isPass:userStage.lastScore]){
            
            // current stage is passed
            passCount++;
        }
    }
    
    if (passCount < 0){
        passCount = 0;
    }
    
    PBTutorial* pbTutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorial.tutorialId];
    int totalStageCount = [pbTutorial.stagesList count];
    
    if (totalStageCount > 0){
        return (((passCount)*1.0f) / (totalStageCount*1.0f))*100;
    }
    else{
        return 0;
    }
}

-(BOOL)isFinishedTutorial:(int)stageIndex{
    int currentTryStageCount = [self.userStagesList count];
    if (self.currentStageIndex == (currentTryStageCount-1)){
        PBUserStage* userStage = [self.userStagesList objectAtIndex:self.currentStageIndex];
        if([[UserTutorialManager defaultManager] isPass:userStage.bestScore]){
            return YES;
        }
    }
    return NO;
}

@end

@implementation PBUserStage (Extend4)

- (NSString*)getCurrentChapterOpusId
{
//#ifdef DEBUG
//    return @"53c4dc42e4b089b4ff460ed3";
//#endif
    
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

- (int)defeatPercent
{
    if (self.totalCount > 0){
        return (((self.defeatCount+1)*1.0f) / (self.totalCount*1.0f))*100;
    }
    else{
        return 0;
    }
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

