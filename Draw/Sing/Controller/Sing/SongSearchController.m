//
//  SongSearchController.m
//  Draw
//
//  Created by 王 小涛 on 13-10-23.
//
//

#import "SongSearchController.h"
#import "SongService.h"
#import "SongCell.h"
#import "StringUtil.h"

@interface SongSearchController ()<UITextFieldDelegate>

@property (retain, nonatomic) NSArray *songs;
@property (retain, nonatomic) SingOpus *singOpus;

@end

@implementation SongSearchController


- (void)dealloc {
    [_songs release];
    [_singOpus release];
    [super dealloc];
}

- (id)initWithSingOpus:(SingOpus *)opus{
    
    if (self = [super init]) {
        self.singOpus = opus;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self.dataTableView updateWidth:CGRectGetWidth(self.view.bounds)];
    [self.dataTableView updateOriginX:0];

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CommonTitleView *v = self.titleView;
    [v hideBackButton];
    [v setRightButtonTitle:NSLS(@"kClose")];
    [v setRightButtonSelector:@selector(clickBackButton:)];
}

SET_CELL_BG_IN_CONTROLLER;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didSelectSong:(PBSong *)song{
    
    [self.singOpus setSong:song];
    
    if (NSStringIsValidChinese(song.name)
        || NSStringISValidEnglish(song.name)){
        
        NSRange range = NSMakeRange(0, MIN(7, [song.name length]));
        NSString *name = [song.name substringWithRange:range];
        [self.singOpus setName:name];
    }else{
        [self.singOpus setName:NSLS(@"kSong")];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_SELECT_SONG object:nil];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)clickBackButton:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


//override

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kLoading")];
    
    TableTab *tab = [_tabManager tabForID:tabID];    
    [[SongService defaultService]
     searchSongWithName:key
     offset:tab.offset
     limit:tab.limit
     completed:^(int resultCode, NSArray *songs) {
        
        [self hideActivity];
        if (resultCode == 0) {
            [self finishLoadDataForTabID:tabID resultList:songs];
        }else{
            [self failLoadDataForTabID:tabID];
        }
    }];

}

- (UITableViewCell *)cellForData:(id)data
{
    SongCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:[SongCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SongCell createCell:self];
    }
    
    [cell setCellData:data];
    
    return cell;

}
- (CGFloat)heightForData:(id)data
{
    return [SongCell getCellHeight];
}

- (void)didSelectedCellWithData:(id)data
{
}
- (NSString *)headerTitle
{
    return NSLS(@"kSearchSong");
}
- (NSString *)searchTips
{
    return NSLS(@"kInputSongNameForSearch");
}
- (NSString *)historyStoreKey
{
    return @"SONG_SEARCHED_KEY";
}

- (BOOL)isTitleViewTransparentStyle{
    return NO;
}
@end
