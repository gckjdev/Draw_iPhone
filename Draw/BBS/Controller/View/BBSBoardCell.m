//
//  BBSBoardCell.m
//  Draw
//
//  Created by gamy on 12-11-15.
//
//

#import "BBSBoardCell.h"
#import "UIImageView+WebCache.h"
#import "BBSModelExt.h"
#import "TimeUtils.h"
#import "BBSManager.h"

@implementation BBSBoardCell

@synthesize delegate = _delegate;
+ (BBSBoardCell *)createCell:(id)delegate
{
    NSString *identifier = [BBSBoardCell getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSBoardCell *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    
    
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    BBSColorManager *colorManager = [BBSColorManager defaultManager];
    BBSFontManager *fontManager = [BBSFontManager defaultManager];

    [view.splitLine setImage:[imageManager bbsBoardLineImage]];
    
    [BBSViewManager updateLable:view.name
                        bgColor:[UIColor clearColor]
                           font:[fontManager indexBoardNameFont]
                      textColor:[colorManager boardTitleColor]
                           text:nil];
    
    [BBSViewManager updateLable:view.statistic
                        bgColor:[UIColor clearColor]
                           font:[fontManager indexCountFont]
                      textColor:[colorManager postNumberColor]
                           text:nil];

    [BBSViewManager updateLable:view.author
                        bgColor:[UIColor clearColor]
                           font:[fontManager indexLastPostNickFont]
                      textColor:[colorManager normalTextColor]
                           text:nil];
    
    [BBSViewManager updateLable:view.lastPost
                        bgColor:[UIColor clearColor]
                           font:[fontManager indexLastPostTextFont]
                      textColor:[colorManager normalTextColor]
                           text:nil];
    
    [BBSViewManager updateLable:view.timestamp
                        bgColor:[UIColor clearColor]
                           font:[fontManager indexLastPostDateFont]
                      textColor:[colorManager normalTextColor]
                           text:nil];


    return  view;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSBoardCell";
}

+ (CGFloat)getCellHeightLastBoard:(BOOL)isLastBoard
{
    if (!isLastBoard) {
        return [DeviceDetection isIPAD] ? 88 : 44;
    }else{
        return [DeviceDetection isIPAD] ? 90 : 46;
    }
}

- (void)updateCellWithBoard:(PBBBSBoard *)board
                isLastBoard:(BOOL)isLastBoard
{

    [self.icon setImageWithURL:board.iconURL];
    
    [self.icon setImageWithURL:[NSURL URLWithString:board.icon]];
    [self.name setText:board.name];
    
    self.statistic.text = [NSString stringWithFormat:@"%d", board.postCount];
    self.lastPost.text = [board.lastPost.content text];
    [self.author setText:board.lastPost.createUser.nickName];
    self.timestamp.text = board.lastPost.createDateString;
    
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    
    if (!isLastBoard) {
        [self.bgImageView setImage:[imageManager bbsBoardBgImage]];
        self.splitLine.hidden = NO;
    }else{
        [self.bgImageView setImage:[imageManager bbsBoardLastBgImage]];
        self.splitLine.hidden = YES;
    }
}

- (void)dealloc {
    PPRelease(_icon);
    PPRelease(_name);
    PPRelease(_statistic);
    PPRelease(_lastPost);
    PPRelease(_author);
    PPRelease(_timestamp);
    PPRelease(_bgImageView);
    PPRelease(_splitLine);
    [super dealloc];
}
@end
