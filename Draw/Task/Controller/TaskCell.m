//
//  TaskCell.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "TaskCell.h"
#import "GameTask.h"

@interface TaskCell ()

@end

@implementation TaskCell

+ (float)getCellHeight{
    
    return CELL_CONST_HEIGHT;
}

+ (NSString *)getCellIdentifier{
    
    return @"TaskCell";
}

- (void)setCellInfo:(GameTask*)task
{
    [_taskNameLabel setFont:CELL_NICK_FONT];
    [_taskDescLabel setFont:CELL_SMALLTEXT_FONT];
    
    _taskDescLabel.text = task.desc;
    _taskNameLabel.text = task.name;
    [_badgeView setNumber:task.badge];
}

- (void)dealloc {
    [_taskNameLabel release];
    [_taskDescLabel release];
    [_taskStatusLabel release];
    [_badgeView release];
    [super dealloc];
}

@end
