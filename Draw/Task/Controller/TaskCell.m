//
//  TaskCell.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "TaskCell.h"

@interface TaskCell ()

@end

@implementation TaskCell

+ (float)getCellHeight{
    
    return ISIPAD ? 0 : 51;
}

+ (NSString *)getCellIdentifier{
    
    return @"TaskCell";
}

- (void)dealloc {
    [_taskNameLabel release];
    [_taskDescLabel release];
    [_taskStatusLabel release];
    [_badgeView release];
    [super dealloc];
}

@end
