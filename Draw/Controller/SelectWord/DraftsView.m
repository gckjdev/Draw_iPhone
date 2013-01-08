//
//  DraftsView.m
//  Draw
//
//  Created by 王 小涛 on 13-1-5.
//
//

#import "DraftsView.h"
#import "AutoCreateViewByXib.h"
#import "OfflineDrawViewController.h"
#import "AnimationManager.h"

@interface DraftsView()

@end

@implementation DraftsView

AUTO_CREATE_VIEW_BY_XIB(DraftsView);

- (void)dealloc {
    [_tableView release];
    [_drafts release];
    [_titleLabel release];
    [super dealloc];
}

+ (void)showInView:(UIView *)view delegate:(id<DraftsViewDelegate>)delegate
{
    DraftsView *draftsView = [self createView];
    draftsView.titleLabel.text = NSLS(@"kDraftsBox");
    draftsView.frame = view.frame;
    draftsView.delegate = delegate;
    draftsView.tableView.delegate = draftsView;
    draftsView.tableView.dataSource = draftsView;
    
    [[MyPaintManager defaultManager] findAllDraftsFrom:0 limit:INT_MAX delegate:draftsView];

    // Animation
    CAAnimation *ani = [AnimationManager moveVerticalAnimationFrom:(view.frame.size.height + draftsView.frame.size.height/2) to:view.center.y duration:0.3];
    [draftsView.layer addAnimation:ani forKey:nil];
    
    [view addSubview:draftsView];
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = [_drafts count] / MAX_DRAFT_COUNT_PER_CELL + (([_drafts count] % MAX_DRAFT_COUNT_PER_CELL) == 0 ? 0 : 1);
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DraftCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DraftCell *cell = [tableView dequeueReusableCellWithIdentifier:[DraftCell getCellIdentifier]];
    if (cell == nil) {
        cell = [DraftCell createCell:self];
    }
    
    int start = indexPath.row * MAX_DRAFT_COUNT_PER_CELL;
    int len = MIN(MAX_DRAFT_COUNT_PER_CELL, [_drafts count] - start);
    NSRange range = NSMakeRange(start, len);
    [cell setCellInfo:[_drafts subarrayWithRange:range]];
    return cell;
}

- (void)didGetAllDrafts:(NSArray *)paints
{
    self.drafts = paints;
    [_tableView reloadData];
}

- (IBAction)clickCloseButton:(id)sender {
    [self removeFromSuperview];
}

- (void)didClickDraft:(MyPaint *)draft
{
    if([_delegate respondsToSelector:@selector(didSelectDraft:)])
    {
        [_delegate didSelectDraft:draft];
    }
}

@end
