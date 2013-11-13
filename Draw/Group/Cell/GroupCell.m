//
//  GroupCell.m
//  Draw
//
//  Created by Gamy on 13-11-13.
//
//

#import "GroupCell.h"
#import "IconView.h"

@interface GroupCell()
@property (retain, nonatomic) IBOutlet GroupIconView *iconView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *sizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UIButton *followButton;

@end

@implementation GroupCell

- (void)updateView
{
    [_nameLabel setTextColor:COLOR_ORANGE];
    [_nameLabel setFont:CELL_NICK_FONT];
    
    [_descLabel setTextColor:COLOR_BROWN];
    [_descLabel setFont:CELL_CONTENT_FONT];

    [_sizeLabel setTextColor:COLOR_BROWN];
    [_sizeLabel setFont:CELL_SMALLTEXT_FONT];
    [_sizeLabel setBackgroundColor:COLOR_YELLOW];
    [_sizeLabel setTextAlignment:NSTextAlignmentCenter];
    CGFloat radius = (CGRectGetHeight(_sizeLabel.bounds)/2.0);
    SET_VIEW_ROUND_CORNER_RADIUS(self.sizeLabel, radius);
}

+ (GroupCell *)createCell:(id)delegate
{
    GroupCell *cell = [GroupCell createViewWithXibIdentifier:[self getCellIdentifier] ofViewIndex:ISIPAD];
    [cell updateView];
    return cell;
}

+ (CGFloat)getCellHeight
{
    return (ISIPAD?100:60);
}
+ (NSString*)getCellIdentifier
{
    return @"GroupCell";
}


- (void)setCellInfo:(PBGroup *)group
{
    self.group = group;
    [self setNeedsLayout];
}

- (void)dealloc {
    [_iconView release];
    [_nameLabel release];
    [_sizeLabel release];
    [_descLabel release];
    [_followButton release];
    PPRelease(_group);
    [super dealloc];
}

#define SPACE_NICK_SIZE (ISIPAD?8:5)
#define SIZE_BASE_WIDTH (ISIPAD?20:12)

- (void)layoutSubviews
{
    [self.iconView setImageURL:[NSURL URLWithString:@"http://tp2.sinaimg.cn/1843913657/180/5663565806/1"]];
    
    [self.nameLabel setText:_group.name];
    [self.descLabel setText:_group.signature];

//    [self.sizeLabel setText:[@(_group.size) stringValue]];
    NSString *sizeText = [NSString stringWithFormat:@"%d人",_group.size];
    [self.sizeLabel setText:sizeText];
    
    [self.nameLabel sizeToFit];
    [self.sizeLabel sizeToFit];
    
    CGFloat x = CGRectGetMaxX(_nameLabel.frame)+SPACE_NICK_SIZE;
    [self.sizeLabel updateOriginX:x];
    CGFloat width = SIZE_BASE_WIDTH + CGRectGetWidth(_sizeLabel.frame);
    [self.sizeLabel updateWidth:width];
    
}
@end
