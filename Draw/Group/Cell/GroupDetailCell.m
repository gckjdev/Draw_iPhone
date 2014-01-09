//
//  GroupDetailCell.m
//  Draw
//
//  Created by Gamy on 13-11-18.
//
//


#import "GroupDetailCell.h"
#import "GroupUIManager.h"
#import "StableView.h"
#import "GroupConstants.h"
#import "GroupModelExt.h"
#import "GroupManager.h"
#import "UILabel+Touchable.h"

#define MEMBER_NUMBER_PERROW (ISIPAD?7:5)
#define TITLE_INFO_HEIGHT (ISIPAD?55:30)
#define CREATOR_AVATAR_HEIGHT (ISIPAD?70:40)
#define MEMBER_AVATAR_HEIGHT (ISIPAD?70:40)
#define MEMBER_AVATAR_SPACE (ISIPAD?30:12)
#define INFO_LABEL_WIDTH (ISIPAD?720:306)

#define CREATOR_CELL_HEIGHT (ISIPAD?140:70)

#define MULTIPLE_LINE_TEXT_Y_SPACE (ISIPAD?20:10)



@interface GroupDetailCell()
@property(nonatomic, assign) PBGroup *group;
@property(nonatomic, assign) CellRowPosition position;
@property(nonatomic, assign) ColorStyle colorStyle;
@property(nonatomic, assign) DetailCellStyle cellStyle;
@property(nonatomic, retain) PBGroupUsersByTitle *members;
//@property(nonatomic, assign) NSArray *userList;
//@property(nonatomic, copy) NSString *text;
@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet UIView *splitLine;
@property (retain, nonatomic) IBOutlet UIImageView *boundImage;

@end

@implementation GroupDetailCell

- (void)dealloc
{
    PPRelease(_text);
    [_infoLabel release];
    [_splitLine release];
    [_boundImage release];
    PPRelease(_members);
    [super dealloc];
}

- (void)updateView
{
    [self.infoLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.infoLabel setFont:CELL_NICK_FONT];
    [self.infoLabel setTextColor:COLOR_BROWN];
    [self.infoLabel setNumberOfLines:0];
    [self.infoLabel setBackgroundColor:[UIColor clearColor]];
}

+ (id)createCell:(id<GroupDetailCellDelegate>)delegate
{
    GroupDetailCell *cell = [self createViewWithXibIdentifier:[self getCellIdentifier] ofViewIndex:ISIPAD];
    cell.delegate = delegate;
    [cell updateView];
    return cell;
}

+ (CGFloat)getCellHeightForSingleLineText
{
    return ISIPAD?100.0f:50.0f;
}

+ (CGFloat)getCellHeightForText:(NSString *)text
{
    CGFloat minHeight = [self getCellHeightForSingleLineText];
    CGSize textSize = [text sizeWithFont:CELL_NICK_FONT constrainedToSize:CGSizeMake(INFO_LABEL_WIDTH, 9999999) lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat height = MAX(textSize.height +MULTIPLE_LINE_TEXT_Y_SPACE, minHeight);

    PPDebug(@"<getCellHeightForText> text = %@, height = %f",text, height);
    
    return height;
    
}

+ (NSInteger)rowForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle
{
    NSInteger memberCount = [usersByTitle.usersList count]; //add button
    if (![usersByTitle isAdminTitle] && [GroupManager isMeAdminOrCreatorInSharedGroup]) {
        memberCount += 1;
    }
    
    NSInteger remainder = memberCount%MEMBER_NUMBER_PERROW;
    NSInteger flag = (remainder == 0) ? 0 : 1;
    NSInteger row = (memberCount/MEMBER_NUMBER_PERROW) + flag;
    return row;
}

+ (CGFloat)getCellHeightForSingleAvatar
{
    return CREATOR_CELL_HEIGHT;
}

+ (CGFloat)getCellHeightForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle
{
    NSInteger row = [self rowForUsersByTitle:usersByTitle];
    return TITLE_INFO_HEIGHT+(row * (MEMBER_AVATAR_HEIGHT + MEMBER_AVATAR_SPACE));
}

+ (NSString *)getCellIdentifier
{
    return @"GroupDetailCell";
}


- (void)setCellText:(NSString *)text
           position:(CellRowPosition)position
              group:(PBGroup *)group
{
    [self setCellInfo:group
             position:position
           colorStyle:ColorStyleRed
            cellStyle:DetailCellStyleSimpleText];
    self.text = text;
}

- (void)setCellForCreatorInGroup:(PBGroup *)group
{
    [self setCellInfo:group
             position:CellRowPositionFirst
           colorStyle:ColorStyleYellow
            cellStyle:DetailCellStyleSingleAvatar];
}

- (void)setCellForCreatorInGroup:(PBGroup *)group
                        position:(CellRowPosition)position
{
    [self setCellInfo:group position:position
           colorStyle:ColorStyleYellow
            cellStyle:DetailCellStyleSingleAvatar];
}

- (void)setCellForAdminsInGroup:(PBGroup *)group
                       position:(CellRowPosition)position
{
    [self setCellInfo:group position:position
           colorStyle:ColorStyleYellow
            cellStyle:DetailCellStyleMultipleAvatars];
    self.members = [group adminsByTitle];
}


- (void)setCellForUsersByTitle:(PBGroupUsersByTitle *)usersByTitle
                      position:(CellRowPosition)position
                       inGroup:(PBGroup *)group
{
    [self setCellInfo:group position:position
           colorStyle:ColorStyleYellow
            cellStyle:DetailCellStyleMultipleAvatars];
    self.members = usersByTitle;
}


- (void)setCellInfo:(PBGroup *)group
           position:(CellRowPosition)position
         colorStyle:(ColorStyle)colorStyle
          cellStyle:(DetailCellStyle)cellStyle
{
    self.group = group;
    self.position = position;
    self.colorStyle = colorStyle;
    self.cellStyle = cellStyle;    
    self.text = nil;
    self.members = nil;
}


- (void)updateColorStyle
{
    switch (self.position) {
        case CellRowPositionMid:
            _boundImage.image = [GroupUIManager groupDetailBoundMidImageForStyle:self.colorStyle];
            break;
        case CellRowPositionFirst:
            _boundImage.image = [GroupUIManager groupDetailBoundHeaderImageForStyle:self.colorStyle];
            break;
        case CellRowPositionLast:
            _boundImage.image = [GroupUIManager groupDetailBoundFooterImageForStyle:self.colorStyle];
            break;
            
        default:
            _boundImage.image = nil;
            break;
    }

    [self.splitLine setHidden:(self.position == CellRowPositionLast)];
}

#define SPLIT_HEIGHT (ISIPAD?3:2)

- (void)updateCellTextContent
{

    [self.infoLabel setHidden:NO];
    [self.infoLabel updateOriginY:0];
    [self.infoLabel updateHeight:CGRectGetMinY(self.splitLine.frame)];
    [self.infoLabel disableTapTouch];
    
    switch (self.cellStyle) {
        case DetailCellStyleSimpleText:{
            [self.infoLabel setText:self.text];
            break;
        }
        case DetailCellStyleSingleAvatar:{
            NSString *desc = [NSString stringWithFormat:NSLS(@"kGroupCreator"),self.group.creatorNickName];
            [self.infoLabel setText:desc];
            break;
        }
        case DetailCellStyleMultipleAvatars:{
            [self.infoLabel updateHeight:TITLE_INFO_HEIGHT];
            [self.infoLabel setText:[self.members desc]];
            [self.infoLabel enableTapTouch:self selector:@selector(clickOnTitle:)];
            break;
        }
        default:
            [self.infoLabel setHidden:YES];
            break;
    }
}

- (void)clickOnTitle:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized) {
        if ([self.delegate respondsToSelector:@selector(groupDetailCell:didClickAtTitle:)]) {
            [self.delegate groupDetailCell:self didClickAtTitle:self.members.title];
        }
    }
}

- (void)cleanOldViews
{
    [self.contentView removeSubviewsWithClass:[AvatarView class]];
    [self.contentView removeSubviewsWithClass:[UIScrollView class]];
}

- (UIButton *)getAddButton
{
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setImage:[GroupUIManager addButtonImage] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(clickAddButton:) forControlEvents:UIControlEventTouchUpInside];
    return addButton;
}


- (CGFloat)avatarBaseX
{
    CGFloat width = MEMBER_NUMBER_PERROW * MEMBER_AVATAR_HEIGHT;
    width += (MEMBER_NUMBER_PERROW - 1) * MEMBER_AVATAR_SPACE;
    CGFloat x = (CGRectGetWidth(self.bounds) - width)/2;
    return x;
}

- (void)updateCellImageContent
{
    switch (self.cellStyle) {
        case DetailCellStyleSingleAvatar:{
            {
                CGFloat avWidth = CREATOR_AVATAR_HEIGHT;
                CGRect frame = CGRectMake([self avatarBaseX], CGRectGetMidY(self.bounds), avWidth, avWidth);
                PBGameUser *user = _group.creator;
                AvatarView *av = [[AvatarView alloc] initWithFrame:frame user:user];
                [av updateCenterY:CGRectGetMidY(self.bounds)];
                av.delegate = self;
                [self.contentView addSubview:av];
                [av release];

            }
            break;
        }
        case DetailCellStyleMultipleAvatars:{
            CGFloat row = [GroupDetailCell rowForUsersByTitle:self.members];
            CGFloat height = (MEMBER_AVATAR_HEIGHT+MEMBER_AVATAR_SPACE) * row;

            CGFloat width = MEMBER_NUMBER_PERROW * MEMBER_AVATAR_HEIGHT;
            width += (MEMBER_NUMBER_PERROW - 1) * MEMBER_AVATAR_SPACE;
            CGFloat x = [self avatarBaseX];
            CGFloat y = TITLE_INFO_HEIGHT;
            CGRect frame = CGRectMake(x, y, width, height);
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
            
            scrollView.autoresizingMask = self.boundImage.autoresizingMask;
            scrollView.backgroundColor = [UIColor clearColor];
            scrollView.contentSize = frame.size;
            [self.contentView addSubview:scrollView];
            [scrollView release];
            
            x = y = 0;
            NSInteger index = 0;
            BOOL hasAddButton = ![self.members isAdminTitle] && [GroupManager isMeAdminOrCreatorInSharedGroup];

            NSInteger count = [[_members usersList] count] + hasAddButton;
            
            while (index < count) {
                y = (index / MEMBER_NUMBER_PERROW) * (MEMBER_AVATAR_SPACE + MEMBER_AVATAR_HEIGHT);
                x = (index % MEMBER_NUMBER_PERROW) * (MEMBER_AVATAR_HEIGHT + MEMBER_AVATAR_SPACE);
                
                CGRect frame = CGRectMake(x, y, MEMBER_AVATAR_HEIGHT, MEMBER_AVATAR_HEIGHT);
                if (index == count-1 && hasAddButton) {
                    UIButton *addButton = [self getAddButton];
                    [addButton setFrame:frame];
                    [scrollView addSubview:addButton];
                }else{
                    PBGameUser *user = self.members.usersList[index];
                    AvatarView *av = [[AvatarView alloc] initWithFrame:frame user:user];
                    [av setDelegate:self];
                    [scrollView addSubview:av];
                    av.delegate = self;
                    [av release];
                }
                index ++;
            }
            break;
        }
        default:
            break;
    }
    [self.contentView bringSubviewToFront:self.splitLine];
    [self.splitLine updateHeight:SPLIT_HEIGHT];
}

- (void)clickAddButton:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(groupDetailCell:didClickAddButtonAtTitle:)]) {
        [self.delegate groupDetailCell:self didClickAddButtonAtTitle:self.members.title];
    }
}

- (void)didClickOnAvatarView:(AvatarView *)avatarView
{
    if (self.cellStyle == DetailCellStyleSingleAvatar) {
        if ([self.delegate respondsToSelector:@selector(groupDetailCell:didClickCreator:)]) {
            [self.delegate groupDetailCell:self didClickCreator:avatarView.user];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(groupDetailCell:didClickUser:title:)]) {
            [self.delegate groupDetailCell:self
                              didClickUser:avatarView.user
                                     title:self.members.title];
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self cleanOldViews];
    [self updateColorStyle];
    [self updateCellTextContent];
    [self updateCellImageContent];
}

- (NSInteger)avatarCount
{
    return [self.members.usersList count];
}

@end
