//
//  ItemUseRecorder.m
//  Draw
//
//  Created by 王 小涛 on 13-6-25.
//
//

#import "ItemUseRecorder.h"

@implementation ItemUseRecorder

+ (void)increaseItemTimes:(ItemType)itemType onOpus:(NSString *)opusId{
  
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self opusKeyWithItem:itemType opusId:opusId];
    NSNumber *value = [defaults objectForKey:key];
    int count = value.intValue + 1;
    
    NSNumber *number = [NSNumber numberWithInt:count];
    [defaults setObject:number forKey:key];
    [defaults synchronize];
}

+ (int)itemTimes:(ItemType)itemType onOpus:(NSString *)opusId{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [self opusKeyWithItem:itemType opusId:opusId];
    NSNumber *value = [defaults objectForKey:key];
    
    return value.intValue;
}

+ (NSString *)opusKeyWithItem:(ItemType)itemType opusId:(NSString *)opusId{
    
    return [NSString stringWithFormat:@"item_%d_opusId_%@", itemType, opusId];
}

@end
