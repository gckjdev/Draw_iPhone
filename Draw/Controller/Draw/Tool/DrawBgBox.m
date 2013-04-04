//
//  DrawBgBox.m
//  Draw
//
//  Created by gamy on 13-3-4.
//
//

#import "DrawBgBox.h"
#import "Draw.pb.h"
#import "UIViewUtils.h"
#import "DrawBgManager.h"
#import "UIImageView+WebCache.h"
#import "LocaleUtils.h"
#import "CustomInfoView.h"
#import "UserGameItemManager.h"

@interface DrawBgBox()
{
    
}
- (IBAction)clickCloseButton:(id)sender;

@property(nonatomic, retain) NSString *selectedBgId;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *dataList;
@property (retain, nonatomic) CustomInfoView *infoView;

@end

@implementation DrawBgBox

- (void)dismiss
{
    [self.infoView dismiss];
    self.infoView.infoView = nil;
    self.infoView = nil;
}

+ (id)drawBgBoxWithDelegate:(id<DrawBgBoxDelegate>)delegate
{
    DrawBgBox *box = [UIView createViewWithXibIdentifier:@"DrawBgBox"];
    box.delegate = delegate;
    box.dataList = [[DrawBgManager defaultManager] pbDrawBgGroupList];
    box.tableView.delegate = box;
    box.tableView.dataSource = box;
    [box setBackgroundColor:[UIColor clearColor]];
    [box.tableView setBackgroundColor:[UIColor clearColor]];
    
    
    return box;
}

- (void)showInView:(UIView *)view
{
    if (self.infoView == nil) {
        __block typeof (self) bself = self;
        self.infoView = [CustomInfoView createWithTitle:NSLS(@"kSelectBGImage")
                                              infoView:self
                         closeHandler:^{
                             bself.infoView = nil;
                         }];
        
        [self.infoView.mainView updateCenterY:(self.infoView.mainView.center.y - (ISIPAD ? 40 : 20))];
    }

    [self.infoView showInView:view];
}
- (void)reloadView
{
    [self.tableView reloadData];
}

- (void)dealloc {
    PPRelease(_infoView);
    PPRelease(_tableView);
    PPRelease(_selectedBgId);
    PPRelease(_dataList);
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DrawBgCell getCellHeight];
}

- (PBDrawBgGroup *)groupOfIndexPath:(NSIndexPath *)indexPath
{
    PBDrawBgGroup *group = [self.dataList objectAtIndex:indexPath.row];
    return group;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawBgCell *cell = [tableView dequeueReusableCellWithIdentifier:[DrawBgCell getCellIdentifier]];
    if (cell == nil) {
        cell = [DrawBgCell createCell:self];
    }
    cell.indexPath = indexPath;
    PBDrawBgGroup *group = [self groupOfIndexPath:indexPath];
    [cell updateCellWithDrawBGGroup:group];
    return cell;
}
- (void)updateViewsWithSelectedBgId:(NSString *)bgId
{
    
}

- (void)drawBgCell:(DrawBgCell *)cell didSelectDrawBg:(PBDrawBg *)bg
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBgBox:didSelectedDrawBg:groudId:)]) {
        PBDrawBgGroup *bgGroup = [self groupOfIndexPath:cell.indexPath];
        [self.delegate drawBgBox:self didSelectedDrawBg:bg groudId:bgGroup.groupId];
    }
}
- (IBAction)clickCloseButton:(id)sender {
    [self dismiss];
}
@end



////////////////
////////////////




@implementation DrawBgCell

#define NAME_LABEL_TAG 10

- (UILabel *)nameLabel
{
    return (id)[self viewWithTag:NAME_LABEL_TAG];
}

- (void)clickButton:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBgCell:didSelectDrawBg:)]) {
        NSInteger index = sender.tag;
        PBDrawBg *bg = [self.group drawBgsAtIndex:index - 1];
        [self.delegate drawBgCell:self didSelectDrawBg:bg];
    }
}

+ (id)createCell:(id)delegate
{
    DrawBgCell *cell = [UIView createViewWithXibIdentifier:[DrawBgCell getCellIdentifier]];
    cell.delegate = delegate;
    for (UIButton *button in cell.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag > 0 && button.tag < 6) {
                [button setBackgroundColor:[UIColor clearColor]];
                [button addTarget:cell action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
                [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
        }
    }
    return cell;
}

+ (CGFloat)getCellHeight
{
    return (ISIPAD ? 152 : 76);
}

- (NSString *)nameInList:(NSArray *)list language:(NSString *)language
{
    if ([list count] == 0) {
        return nil;
    }
    NSString *defaultName = nil;
    for (PBLocalizeString *ls in list) {
        if ([[ls languageCode] isEqualToString:language]) {
            return [ls localizedText];
        }else if([[ls languageCode] isEqualToString:@"en"]){
            defaultName = [ls localizedText];
        }
    }
    if (defaultName == nil) {
        defaultName = [[list objectAtIndex:0] localizedText];
    }
    return defaultName;
}

- (void)updateName:(PBDrawBgGroup *)group
{
    NSArray *list = group.nameList;
    NSString *name = nil;
    if ([LocaleUtils isChinese]) {
        name = [self nameInList:list language:@"zh_Hans"];
    }else{
        name = [self nameInList:list language:@"en"];
    }
    if ([[UserGameItemManager defaultManager] hasItem:group.groupId]) {
        name = [NSString stringWithFormat:@"%@ [%@]", name, NSLS(@"kHasBought")];
    }
    [[self nameLabel] setText:name];
}

- (void)updateCellWithDrawBGGroup:(PBDrawBgGroup *)group
{
    self.group = group;
    NSInteger i = 1;
    [self updateName:group];
    for (PBDrawBg *bg in group.drawBgsList) {
        UIImage *image = [bg localThumb];
        UIButton *button = (UIButton *)[self viewWithTag:i];
        if (image) {
            [button setImage:image forState:UIControlStateNormal];
        }else{
            [button.imageView setImageWithURL:bg.remoteURL success:^(UIImage *image, BOOL cached) {
                [button setImage:image forState:UIControlStateNormal];
            } failure:^(NSError *error) {
                
            }];
        }
        ++ i;
    }
}

+ (NSString *)getCellIdentifier
{
    return @"DrawBgCell";
}

@end