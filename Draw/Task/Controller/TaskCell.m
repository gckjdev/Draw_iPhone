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
    [_taskStatusLabel setFont:CELL_CONTENT_FONT];
    
    [_taskNameLabel setTextColor:COLOR_BROWN];
    [_taskDescLabel setTextColor:COLOR_BROWN];
    [_taskStatusLabel setTextColor:COLOR_GREEN];
    
    _taskDescLabel.text = task.desc;
    _taskNameLabel.text = task.name;

    SET_BUTTON_ROUND_STYLE_ORANGE(_awardButton);
    [_awardButton setTitle:NSLS(@"kTakeAward") forState:UIControlStateNormal];
    [_awardButton.titleLabel setFont:CELL_CONTENT_FONT];
    
    switch (task.status){
        case PBTaskStatusTaskStatusAlwaysOpen:
            [_badgeView setNumber:task.badge];
            _taskStatusLabel.text = @"";
            _awardButton.hidden = YES;
            break;
            
        case PBTaskStatusTaskStatusCanTake:
            [_badgeView setNumber:task.badge];
            if (task.badge > 0){
                _taskStatusLabel.text = @"";
            }
            else{
                _taskStatusLabel.text = NSLS(@"kTaskToBeTaken");
            }
            _awardButton.hidden = YES;
            [_taskStatusLabel setTextColor:COLOR_ORANGE];
            break;
            
        case PBTaskStatusTaskStatusAward:
            [_badgeView setNumber:0];
            _taskStatusLabel.text = NSLS(@"kTaskTake");
            _awardButton.hidden = YES;
            break;
                        
        case PBTaskStatusTaskStatusExpired:
            [_badgeView setNumber:0];
            _taskStatusLabel.text = NSLS(@"kTaskExpire");
            _awardButton.hidden = YES;
            break;

        case PBTaskStatusTaskStatusWaitForStart:
            [_badgeView setNumber:0];
            _taskStatusLabel.text = NSLS(@"kTaskWaitForStart");
            _awardButton.hidden = YES;
            [_taskStatusLabel setTextColor:COLOR_ORANGE];
            break;
            
        case PBTaskStatusTaskStatusDone:
            [_badgeView setNumber:0];
            _taskStatusLabel.text = @"";
            _awardButton.hidden = NO;
            break;

        default:
            [_badgeView setNumber:0];
            _taskStatusLabel.text = @"";
            _awardButton.hidden = YES;
            break;
    }
}

- (void)dealloc {
    [_awardButton release];
    [_taskNameLabel release];
    [_taskDescLabel release];
    [_taskStatusLabel release];
    [_badgeView release];
    [super dealloc];
}

- (IBAction)clickSelectButton:(id)sender {
    
    if ([delegate respondsToSelector:@selector(clickTakeAwardButton:)]) {        
        [delegate performSelector:@selector(clickTakeAwardButton:) withObject:self.indexPath];
    }
    
}

@end
