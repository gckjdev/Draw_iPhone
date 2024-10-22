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
    
//    for (NSNumber* category in self.categories){
    for (int i=0; i<self.categories.count; i++){
        int value = [self.categories int32AtIndex:i];
        NSString* name = [self singleCategoryName:value];
        if ([name length] > 0){
            retName = [retName stringByAppendingString:name];
//            if ([self.categories lastObject] != category){
            if (i != self.categories.count-1){
                retName = [retName stringByAppendingString:@", "];
            }
        }
    }
    
    return retName;
}

- (PBStage*)getStageByIndex:(NSUInteger)index
{
    if (index >= [self.stages count]){
        return nil;
    }
    
    return [self.stages objectAtIndex:index];
}

- (PBStage*)nextStage:(NSUInteger)index
{
    int nextIndex = index+1;
    return [self getStageByIndex:nextIndex];
}

- (BOOL)isForStudy
{
    return (self.type == PBTutorialTypeTutorialTypeLearn);
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
    if ([self.chapter count] == 0){
        return nil;
    }
    
    if (chapterIndex >= [self.chapter count]){
        return nil;
    }
    
    PBChapter* chapter = [self.chapter objectAtIndex:chapterIndex];
    if ([chapter.tips count] == 0){
        return nil;
    }
    
    NSMutableArray* retList = [NSMutableArray array];
    for (PBTip* tip in chapter.tips){
        if (tip.imageName){
            [retList addObject:tip.imageName];
        }
    }
    
    return retList;
}

- (BOOL)hasMoreThanOneChapter
{
    if ([self.chapter count] > 1){
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

    if (self.tutorial && self.tutorial.unlockAllStage){
        return NO;
    }

    PBTutorial* pbTutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorial.tutorialId];
    if (pbTutorial && pbTutorial.unlockAllStage){
        return NO;
    }
    return (stageIndex > self.currentStageIndex);
}

- (int)progress
{
    int currentTryStageCount = [self.userStages count];
    int passCount = currentTryStageCount-1;
    if (self.currentStageIndex == (currentTryStageCount-1)){
        // already try current stage index, check if passed
        PBUserStage* userStage = [self.userStages objectAtIndex:self.currentStageIndex];
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
    int totalStageCount = [pbTutorial.stages count];
    
    if (totalStageCount > 0){
        return (((passCount)*1.0f) / (totalStageCount*1.0f))*100;
    }
    else{
        return 0;
    }
}

-(BOOL)isFinishedTutorial:(int)stageIndex{
    
    return (self.progress >= 100);
//    int currentTryStageCount = [self.userStagesList count];
//    if (self.currentStageIndex == (currentTryStageCount-1)){
//        // already try current stage index, check if passed
//        PBUserStage* userStage = [self.userStagesList objectAtIndex:self.currentStageIndex];
//        if([[UserTutorialManager defaultManager] isPass:userStage.bestScore]){
//            return YES;
//        }
//    }
//    return NO;
}

- (BOOL)isForStudy
{
    PBTutorial* pbTutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorial.tutorialId];
    
    return [pbTutorial isForStudy];
}

- (BOOL)hasFinishPractice:(int)stageIndex
{
    if (stageIndex < 0 || stageIndex >= [self.userStages count]){
        return NO;
    }
    
    PBUserStage* userStage = [self.userStages objectAtIndex:stageIndex];
    return [userStage hasFinishPractice];
}

@end

@implementation PBUserStage (Extend4)

- (NSString*)getCurrentChapterOpusId
{
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorialId];
    if (self.stageIndex >= [tutorial.stages count]){
        return nil;
    }
    
    PBStage* stage = [tutorial.stages objectAtIndex:self.stageIndex];
    if (stage == nil){
        return nil;
    }
    
    if (self.currentChapterIndex >= [stage.chapter count]){
        return nil;
    }
    
    PBChapter* chapter = [stage.chapter objectAtIndex:self.currentChapterIndex];
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

- (BOOL)hasFinishPractice
{
    // if user has conquer local opus draft, then means user already complete the practice
    return ([self.conquerLocalOpusId length] > 0);
}

@end

@implementation PBUserStageBuilder (Extend5)

- (NSString*)getCurrentChapterOpusId
{
    
    PBTutorial* tutorial = [[TutorialCoreManager defaultManager] findTutorialByTutorialId:self.tutorialId];
    if (self.stageIndex >= [tutorial.stages count]){
        return nil;
    }
    
    PBStage* stage = [tutorial.stages objectAtIndex:self.stageIndex];
    if (stage == nil){
        return nil;
    }
    
    if (self.currentChapterIndex >= [stage.chapter count]){
        return nil;
    }
    
    PBChapter* chapter = [stage.chapter objectAtIndex:self.currentChapterIndex];
    return chapter.opusId;
}

@end

