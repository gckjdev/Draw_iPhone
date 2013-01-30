//
//  ReplaceOpusView.m
//  Draw
//
//  Created by 王 小涛 on 13-1-28.
//
//

#import "ReplaceOpusView.h"

@interface ReplaceOpusView()
@property (retain, nonatomic) UITableView *tableView;

@end

@implementation ReplaceOpusView

- (void)dealloc
{
    [_tableView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.tableView = [[[UITableView alloc] initWithFrame:frame] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}






@end
