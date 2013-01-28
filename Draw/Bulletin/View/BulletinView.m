//
//  BulletinView.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinView.h"
#import "BulletinService.h"
#import "BulletinCell.h"
#import "Bulletin.h"
#import "JumpHandler.h"

@implementation BulletinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initView
{
    self.bulletinsTableView.dataSource = self;
    self.bulletinsTableView.delegate = self;
    
    [self.titleLabel setText:NSLS(@"kBulletin")];
    [self.closeButton setTitle:NSLS(@"kClose") forState:UIControlStateNormal];
}

+ (void)showBulletinInController:(PPViewController*)controller
{
    BulletinView* view = (BulletinView*)[BulletinView createInfoViewByXibName:@"BulletinView"];
    [view initView];
    view.superController = controller;
    [view showInView:controller.view];
}

- (IBAction)clickClose:(id)sender
{
    [[BulletinService defaultService] readAllBulletins];
    [self disappear];
}

#pragma mark - tableView delegate and dataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [BulletinCell getCellIdentifier];
	BulletinCell *cell = [_bulletinsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BulletinCell createCell:self];
	}
    if (indexPath.row < [BulletinService defaultService].bulletins.count) {
        [cell setCellByBulletin:[[BulletinService defaultService].bulletins objectAtIndex:([BulletinService defaultService].bulletins.count - indexPath.row - 1)]];
    }
    
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [BulletinService defaultService].bulletins.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BulletinService* service = [BulletinService defaultService];
    Bulletin* bulletin;
    if (indexPath.row < service.bulletins.count) {
        bulletin = [[BulletinService defaultService].bulletins objectAtIndex:([BulletinService defaultService].bulletins.count - indexPath.row - 1)];
        
    }
    return [BulletinCell cellSizeForContent:bulletin.message].height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BulletinService* service = [BulletinService defaultService];
    Bulletin* bulletin;
    if (indexPath.row < service.bulletins.count) {
        bulletin = [service.bulletins objectAtIndex:([BulletinService defaultService].bulletins.count - indexPath.row - 1)];
        bulletin.hasRead = YES;
        [self.bulletinsTableView reloadData];
        [JumpHandler handleBulletinJump:self.superController bulletin:bulletin];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_bulletinsTableView release];
    [_downCloseButton release];
    [_titleLabel release];
    [_closeButton release];
    [_topImageView release];
    [_downImageView release];
    [super dealloc];
}
@end
