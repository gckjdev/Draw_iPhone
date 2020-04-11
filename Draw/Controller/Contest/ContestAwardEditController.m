//
//  ContestAwardEditController.m
//  Draw
//
//  Created by 王 小涛 on 14-1-3.
//
//

#import "ContestAwardEditController.h"
#import "ContestAwardEditCell.h"
#import "UIViewController+BGImage.h"

@interface ContestAwardEditController ()<ContestAwardEditCellDelegate>

@property (retain, nonatomic) Contest *contest;
@end

@implementation ContestAwardEditController

- (void)dealloc{
    
    [_contest release];
    [super dealloc];
}

- (id)initWithContest:(Contest *)contest{
    
    if (self = [super init]) {
        
        self.contest = contest;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view from its nib.
    [self setDefaultBGImage];
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [v setTitle:NSLS(@"kContestAward")];
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBack:)];
    [v setRightButtonTitle:NSLS(@"kDone")];
    [v setRightButtonSelector:@selector(clickDone:)];
    
    //update tableView frame
    
    if (ISIPAD) {
        CGFloat originY = CGRectGetMinY(self.dataTableView.frame);
        CGFloat originHiehgt = CGRectGetHeight(self.dataTableView.frame);
        CGFloat y = 100;
        [self.dataTableView updateOriginY:y];
        [self.dataTableView updateHeight:originHiehgt-(y-originY)];
    }
}

- (void)clickBack:(id)sender{
    
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 4;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [ContestAwardEditCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ContestAwardEditCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContestAwardEditCell getCellIdentifier]];
    if (cell == nil) {
        cell = [ContestAwardEditCell createCell:self];
    }
    
    cell.indexPath = indexPath;
    
    int award = [self.contest awardWithRank:indexPath.row];
    NSString *rankDesc = nil;
    if (indexPath.row < 3) {
        rankDesc = [NSString stringWithFormat:NSLS(@"kRankIs"), indexPath.row + 1];
    }else{
        rankDesc = [NSString stringWithFormat:NSLS(@"kRankRange"), @"4~20"];
    }
    
    [cell setRank:rankDesc award:award];
    return cell;
}

- (void)didEditRow:(int)row award:(int)award{
    
    if (row < 3) {
        [self.contest setRank:row award:award];
    }else{
        for (int i = 3; i < [[self.contest awardRules] count]; i ++) {
            [self.contest setRank:i award:award];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickDone:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationContestAwardEditDone
                                                        object:nil];
}

@end
