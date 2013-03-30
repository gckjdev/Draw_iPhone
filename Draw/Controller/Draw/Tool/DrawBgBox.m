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

@interface DrawBgBox()
{
    PBDrawBgMeta *bgMeta;
}

@property(nonatomic, retain) NSString *selectedBgId;
@property (retain, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation DrawBgBox


+ (id)drawBgBoxWithDelegate:(id<DrawBgBoxDelegate>)delegate
{
    DrawBgBox *box = [UIView createViewWithXibIdentifier:@"DrawBgBox"];
    box.delegate = delegate;
    [box updateViews];
    return box;
}

- (void)dealloc {
    PPRelease(_scrollView);
    PPRelease(_selectedBgId);
    [super dealloc];
}
@end



////////////////
////////////////


@implementation DrawBgCell

+ (id)createCell:(id)delegate
{
    DrawBgCell *cell = [UIView createViewWithXibIdentifier:[DrawBgCell getCellIdentifier]];
    cell.delegate = delegate;
    return cell;
}

+ (CGFloat)getCellHeight
{
    return 60;
}

- (void)updateCellWithDrawBGGroup:(PBDrawBgGroup *)group
{
    
}

+ (NSString *)getCellIdentifier
{
    return @"DrawBgCell"
}

@end