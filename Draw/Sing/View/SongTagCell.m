//
//  SongTagCell.m
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import "SongTagCell.h"
#import "UIViewUtils.h"
#import "UIColor+UIColorExt.h"

#define GAP 4
#define FIRST_TAG_ORIGIN_X  16
#define FIRST_TAG_ORIGIN_Y  47
#define TAG_WIDTH  58
#define TAG_HEIGHT 23

@implementation SongTagCell

+ (NSString*)getCellIdentifier{
    return @"SongTagCell";
}

+ (CGFloat)getCellHeightWithCategory:(PBSongCategory *)category{
    return 65 + 23 * ceil([category.songTagsList count] / TagsPerCell);
}

- (void)setCellInfo:(PBSongCategory *)category{

    for (UIView *view in self.subviews) {
        if ([[view class] isSubclassOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    [self updateHeight:[SongTagCell getCellHeightWithCategory:category]];
    
    self.categoryLabel.text = category.name;

    NSArray *tags = category.songTagsList;
    int count = [tags count];
    for (int index = 0; index < count; index++) {
        
        PBSongTag *songTag = [tags objectAtIndex:index];
        UIButton *button = [self buttonWithTag:songTag.tagId index:index];
        [button setTitle:songTag.tagName forState:UIControlStateNormal];
        [self addSubview:button];
    }
    
    [self.seperator updateOriginY:(self.frame.size.height - self.seperator.frame.size.height)];
}

- (UIButton *)buttonWithTag:(int)tag index:(int)index{
    
    CGFloat originX = FIRST_TAG_ORIGIN_X + (TAG_WIDTH + GAP) * (index%(int)TagsPerCell);
    CGFloat originY = FIRST_TAG_ORIGIN_Y + (TAG_HEIGHT) * (index / (int)TagsPerCell);
    
    CGRect rect = CGRectMake(originX, originY, TAG_WIDTH, TAG_HEIGHT);
    
    UIButton *button = [[[UIButton alloc] initWithFrame:rect] autorelease];
    button.tag = tag;
    
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor colorWithIntegerRed:42 green:140 blue:204 alpha:1] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)clickButton:(UIButton *)button{
    if ([delegate respondsToSelector:@selector(didClickTag:)]) {
        int tagId = button.tag;
        [delegate didClickTag:tagId];
    }
}

- (void)dealloc {
    [_categoryLabel release];
    [_seperator release];
    [super dealloc];
}

@end