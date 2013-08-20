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
#import "ShareImageManager.h"

@interface DraftsView()

@end

@implementation DraftsView

AUTO_CREATE_VIEW_BY_XIB(DraftsView);

- (void)dealloc {
    [_tableView release];
    [_drafts release];
    [super dealloc];
}

+ (id)createWithdelegate:(id<DraftsViewDelegate>)delegate
{
    DraftsView *draftsView = [self createView];
    draftsView.delegate = delegate;
    draftsView.tableView.delegate = draftsView;
    draftsView.tableView.dataSource = draftsView;
    
    [[MyPaintManager defaultManager] findAllDraftsFrom:0 limit:INT_MAX delegate:draftsView];
    
    return draftsView;
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

- (void)didClickDraft:(MyPaint *)draft
{
    if([_delegate respondsToSelector:@selector(didSelectDraft:)])
    {
        [_delegate didSelectDraft:draft];
    }
}

@end
