//
//  SongCategoryView.m
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import "SongCategoryView.h"
#import "AutoCreateViewByXib.h"
#import "Sing.pb.h"
#import "SongTagCell.h"
#import "SongCategoryManager.h"

@interface SongCategoryView()
@property (retain, nonatomic) NSArray *categorys;

@end

@implementation SongCategoryView

AUTO_CREATE_VIEW_BY_XIB(SongCategoryView);

- (void)dealloc {
    [_tableView release];
    [_categorys release];
    [super dealloc];
}

+ (id)createCategoryView{
    SongCategoryView *view  = [self createView];
    view.categorys = [[SongCategoryManager defaultManager] categorys];
//    view.categorys = [SongCategoryManager createTestData];
    return view;
}

- (void)showInView:(UIView *)view{
    
    [view addSubview:self];
}

- (void)dismiss{
    
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_categorys count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [SongTagCell getCellHeightWithCategory:[_categorys objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SongTagCell *cell = [tableView dequeueReusableCellWithIdentifier:[SongTagCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SongTagCell createCell:self];
    }
    
    NSDictionary *category = [_categorys objectAtIndex:indexPath.row];
    [cell setCellInfo:category];

    return cell;
}

- (IBAction)clickBgButton:(id)sender {
    if ([_delegate respondsToSelector:@selector(didClickBgButton)]) {
        [_delegate didClickBgButton];
    }
}

- (void)didClickTag:(NSString *)tag{
    if ([_delegate respondsToSelector:@selector(didSelectTag:)]) {
        [_delegate didSelectTag:tag];
    }
}


@end
