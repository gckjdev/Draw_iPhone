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
    [_taskNameLabel setFont:CELL_CONTENT_FONT];
    [_taskDescLabel setFont:CELL_SMALLTEXT_FONT];
    
    [_taskNameLabel setTextColor:COLOR_BROWN];
    [_taskDescLabel setTextColor:COLOR_GREEN];
    
    _taskDescLabel.text = task.desc;
    _taskNameLabel.text = task.name;

    SET_BUTTON_ROUND_STYLE_ORANGE(_awardButton);
    [_awardButton setTitle:NSLS(@"kTakeAward") forState:UIControlStateNormal];
    [_awardButton.titleLabel setFont:CELL_CONTENT_FONT];
    
    [_badgeView setNumber:0];
    _taskStatusLabel.text = @"";
}

- (void)dealloc {
    [_awardButton release];
    [_taskNameLabel release];
    [_taskDescLabel release];
    [_taskStatusLabel release];
    [_badgeView release];
    [super dealloc];
}

@end
