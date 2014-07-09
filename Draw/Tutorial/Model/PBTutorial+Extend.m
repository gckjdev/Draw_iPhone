//
//  PBTutorial+Extend.m
//  Draw
//
//  Created by qqn_pipi on 14-6-28.
//
//

#import "PBTutorial+Extend.h"
#import "LocaleUtils.h"

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
