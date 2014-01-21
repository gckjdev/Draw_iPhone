//
//  GroupInfoView.m
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import "GroupInfoView.h"
#import "Group.pb.h"
#import "IconView.h"
#import "GroupUIManager.h"


#define SPACE_NICK_SIZE (ISIPAD?8:5)
#define SIZE_BASE_WIDTH (ISIPAD?20:12)
#define DEFAULT_LABEL_HEIGHT (ISIPAD?32:19)
#define DEFAULT_HEIGHT (ISIPAD?120:60)
#define DESC_LABEL_WIDTH (ISIPAD?480:200)

@interface GroupInfoView(){
    UIButton *_customButton;
}
@property (retain, nonatomic) IBOutlet GroupIconView *iconView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *sizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
//@property (assign, nonatomic) IBOutlet UIButton *customButton;

@end

@implementation GroupInfoView

- (void)updateView
{
    [_nameLabel setTextColor:COLOR_ORANGE];
    [_nameLabel setFont:CELL_NICK_FONT];
    
    [_descLabel setTextColor:COLOR_BROWN];
    [_descLabel setFont:CELL_CONTENT_FONT];
    [_descLabel setNumberOfLines:0];
    [_descLabel setLineBreakMode:NSLineBreakByCharWrapping];
    
    [_sizeLabel setTextColor:COLOR_BROWN];
    [_sizeLabel setFont:CELL_SMALLTEXT_FONT];
    [_sizeLabel setBackgroundColor:COLOR_YELLOW];
    [_sizeLabel setTextAlignment:NSTextAlignmentCenter];
    CGFloat radius = (CGRectGetHeight(_sizeLabel.bounds)/3.0);
    SET_VIEW_ROUND_CORNER_RADIUS(self.sizeLabel, radius);
    self.backgroundColor = [UIColor clearColor];
}

+ (id)infoViewWithGroup:(PBGroup *)group
{
    GroupInfoView *infoView = [self createViewWithXibIdentifier:@"GroupInfoView" ofViewIndex:ISIPAD];
    [infoView updateView];
    infoView.group = group;
    [infoView setNeedsLayout];
    return infoView;
}

- (void)updateWithGroup:(PBGroup *)group
{
    self.group = group;
    [self setNeedsLayout];
}


+ (CGFloat)recommandHeightForGroup:(PBGroup *)group
{
    CGSize size = CGSizeMake(DESC_LABEL_WIDTH, 99999999);
    CGSize textSize = [group.signature sizeWithFont:CELL_CONTENT_FONT
                              constrainedToSize:size
                                  lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat delta = textSize.height - DEFAULT_LABEL_HEIGHT;
        
    if (delta > 0) {
        return DEFAULT_HEIGHT + delta;
    }
    return DEFAULT_HEIGHT;
}

#define DEFAULT_NAME_Y (ISIPAD?15:7)

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.iconView setImageURL:[_group medalImageURL] placeholderImage:[GroupUIManager defaultGroupMedal]];
    
    [self.nameLabel setText:_group.name];
    if (!_showBalance) {
        [self.descLabel setText:_group.signature];
    }else{
        [self.descLabel setText:[NSString stringWithFormat:NSLS(@"kWealth"), _group.balance]];
    }

    
    //    [self.sizeLabel setText:[@(_group.size) stringValue]];
    NSString *sizeText = [NSString stringWithFormat:NSLS(@"kGroupMemberNumber"),_group.size];
    [self.sizeLabel setText:sizeText];
    [self.nameLabel sizeToFit];
    [self.sizeLabel sizeToFit];
    
    CGFloat x = CGRectGetMaxX(_nameLabel.frame)+SPACE_NICK_SIZE;
    [self.sizeLabel updateOriginX:x];
    CGFloat width = SIZE_BASE_WIDTH + CGRectGetWidth(_sizeLabel.frame);
    [self.sizeLabel updateWidth:width];
    
    if([_group.signature length] == 0 && _showBalance == NO){
        [self.nameLabel updateCenterY:CGRectGetMidY(self.bounds)];
    }else{
        [self.nameLabel updateOriginY:DEFAULT_NAME_Y];
    }
    [self.sizeLabel updateCenterY:_nameLabel.center.y];
    [self.customButton updateCenterY:self.center.y];   
}

+ (CGFloat)getViewHeight
{
    return DEFAULT_HEIGHT;
}

#define CUSTOM_BUTTON_SIZE (ISIPAD?45:25)
#define CUSTOM_BUTTON_CENTERX (ISIPAD?670:280)

- (void)setCustomButton:(UIButton *)button
{
    [_customButton removeFromSuperview];
    _customButton = button;
    button.frame = CGRectMake(0, 0, CUSTOM_BUTTON_SIZE, CUSTOM_BUTTON_SIZE);
    button.center = CGPointMake(CUSTOM_BUTTON_CENTERX, CGRectGetMidY(self.bounds));
    
    [self addSubview:button];
    [button removeTarget:self action:@selector(clickCustomButton:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(clickCustomButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (UIButton *)customButton
{
    return _customButton;
}

- (void)clickCustomButton:(id)sender
{
    if (self.delegate && [_delegate respondsToSelector:@selector(groupInfoView:didClickCustomButton:)]) {
        [_delegate groupInfoView:self didClickCustomButton:sender];
    }
}

- (void)dealloc
{
    [_iconView release];
    [_nameLabel release];
    [_sizeLabel release];
    [_descLabel release];
    PPRelease(_group);
    [super dealloc];
}

@end
