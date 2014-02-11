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

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *dataList;
@property (retain, nonatomic) CustomInfoView *infoView;

@end

@implementation DrawBgBox

CGPoint boxContentOffset;

- (void)dismiss
{
    [self.infoView unregisterAllNotifications];
    
    boxContentOffset = [self.tableView contentOffset];
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
    [box.tableView setContentOffset:boxContentOffset animated:YES];
    
    return box;
}

- (void)showInView:(UIView *)view
{
    if (self.infoView == nil) {
        __block typeof (self) bself = self;
        NSString* defaultTitle = NSLS(@"kSelectBGImage");
        self.infoView = [CustomInfoView createWithTitle:defaultTitle
                                              infoView:self
                         closeHandler:^{
                             [self.infoView unregisterAllNotifications];
                             boxContentOffset = [bself.tableView contentOffset];                             
                             bself.infoView = nil;
                         }];
        
        [self.infoView registerNotificationWithName:[[DrawBgManager defaultManager] downloadProgressNotificationName]
                                         usingBlock:^(NSNotification *note) {
                                             
                                             NSDictionary* userInfo = [note userInfo];
                                             PPDebug(@"Handle background download progress, data=%@", [userInfo description]);
                                             
                                             NSNumber* progress = [userInfo objectForKey:SMART_DATA_PROGRESS];
                                             NSString* name = [userInfo objectForKey:SMART_DATA_NAME];
                                             
                                             if ([name length] > 0 && progress != nil){
                                                 NSString* title = nil;                                                 
                                                 if ([progress doubleValue] >= 99.99f){
                                                     title = defaultTitle;
                                                 }
                                                 else{
                                                     title = [NSString stringWithFormat:NSLS(@"kBgDownloading"), ([progress doubleValue]*100)];
                                                 }
                                                 [bself.infoView setTitle:title];
                                             }
                                             else{
                                                 [bself.infoView setTitle:defaultTitle];
                                             }
                                             
                                         }];
        
        [self.infoView.mainView updateCenterY:(self.infoView.mainView.center.y - (ISIPAD ? 35 : 20))];
    }

    [self.infoView showInView:view];
}
- (void)reloadView
{
    [self.tableView reloadData];
}

- (void)dealloc {
    
    [self.infoView unregisterAllNotifications];
    
    PPRelease(_infoView);
    PPRelease(_tableView);
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
#define FLAG_BUTTON_TAG 11

- (UILabel *)nameLabel
{
    return (id)[self viewWithTag:NAME_LABEL_TAG];
}

- (UIButton *)flagButton
{
    return (id)[self viewWithTag:FLAG_BUTTON_TAG];
}

- (void)clickButton:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawBgCell:didSelectDrawBg:)]) {
        NSInteger index = sender.tag;
        PBDrawBg *bg = [self.group drawBgsAtIndex:index - 1];
        [self.delegate drawBgCell:self didSelectDrawBg:bg];
    }
}
#define BUTTON_COUNT 5

+ (id)createCell:(id)delegate
{
    DrawBgCell *cell = [UIView createViewWithXibIdentifier:[DrawBgCell getCellIdentifier]];
    cell.delegate = delegate;
//    UIView *contentView = (!ISIOS7 ? cell.contentView : cell);
    for (UIButton *button in cell.contentView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            if (button.tag > 0 && button.tag <= BUTTON_COUNT) {
                [button setBackgroundColor:[UIColor clearColor]];
                [button addTarget:cell action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
                [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
        }
    }
    
    [[cell flagButton] setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    [[cell flagButton] setBackgroundColor:COLOR_BROWN];
    [[[cell flagButton] layer] setCornerRadius:(ISIPAD? 8 : 4)];
    [[[cell flagButton] layer] setMasksToBounds:YES];
    [[[cell flagButton] titleLabel] setFont:[UIFont systemFontOfSize:(ISIPAD?18:9)]];
    return cell;
}

+ (CGFloat)getCellHeight
{
    return (ISIPAD ? 152 : 80);
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

#define MAX_WITH_ITEM_NAME (ISIPAD ? 400 : 200)

- (void)updateName:(PBDrawBgGroup *)group
{
    NSArray *list = group.nameList;
    NSString *name = nil;
    if ([LocaleUtils isChinese]) {
        name = [self nameInList:list language:@"zh_Hans"];
    }else{
        name = [self nameInList:list language:@"en"];
    }
    [[self nameLabel] setText:name];
    [[self nameLabel] setTextColor:COLOR_BROWN];
    [[self nameLabel] sizeToFit];
    
    if ([[UserGameItemManager defaultManager] hasItem:group.groupId]) {
        CGFloat originX = CGRectGetMaxX([self nameLabel].frame) + 3;
        
        [[self flagButton] updateOriginX:originX];
        [[self flagButton] setHidden:NO];
        [[self flagButton] setTitle:NSLS(@"kAlreadyBought") forState:UIControlStateNormal];
//        [[self flagButton] sizeToFit];
        [[self flagButton] updateCenterY:[self nameLabel].center.y];
        
    }else{
        [[self flagButton] setHidden:YES];
    }

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
//            [button.imageView setImageWithURL:bg.remoteURL success:^(UIImage *image, BOOL cached) {
//                [button setImage:image forState:UIControlStateNormal];
//            } failure:^(NSError *error) {
//                
//            }];
            
            [button.imageView setImageWithURL:[NSURL URLWithString:bg.remoteUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                [button setImage:image forState:UIControlStateNormal];
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