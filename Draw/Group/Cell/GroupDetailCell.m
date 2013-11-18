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

#define MEMBER_NUMBER_PERROW 5
#define TITLE_INFO_HEIGHT 25
#define CREATOR_AVATAR_HEIGHT 50
#define MEMBER_AVATAR_HEIGHT 40
#define MEMBER_AVATAR_SPACE 10

@interface GroupDetailCell()
@property(nonatomic, assign) PBGroup *group;
@property(nonatomic, assign) CellRowPosition position;
@property(nonatomic, assign) ColorStyle colorStyle;
@property(nonatomic, assign) DetailCellStyle cellStyle;
@property(nonatomic, assign) PBGroupUsersByTitle *members;
@property(nonatomic, copy) NSString *text;
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
    [super dealloc];
}

+ (id)createCell:(id<GroupDetailCellDelegate>)delegate
{
    GroupDetailCell *cell = [self createViewWithXibIdentifier:[self getCellIdentifier]];
    cell.delegate = delegate;
    return cell;
}

+ (CGFloat)getCellHeightForSimpleText
{
    return 50.0f;
}
+ (CGFloat)getCellHeightForSingleAvatar
{
    return 70.0f;
}

+ (NSInteger)rowForMemberCount:(NSInteger)memberCount
{
    NSInteger remainder = memberCount%MEMBER_NUMBER_PERROW;
    NSInteger flag = (remainder == 0) ? 0 : 1;
    NSInteger row = (memberCount/MEMBER_NUMBER_PERROW) + flag;
    return row;
}

+ (CGFloat)getCellHeightForMultipleAvatar:(NSInteger)avatarCount
{
    NSInteger row = [self rowForMemberCount:avatarCount];
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

- (void)setCellForMembers:(PBGroupUsersByTitle *)members
                 position:(CellRowPosition)position
                  InGroup:(PBGroup *)group
{
    [self setCellInfo:group
             position:position
           colorStyle:ColorStyleYellow
            cellStyle:DetailCellStyleMultipleAvatars];
    self.members = members;
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

- (void)updateCellTextContent
{
    self.infoLabel.center = CGRectGetCenter(self.bounds);
    [self.infoLabel setHidden:NO];
    
    switch (self.cellStyle) {
        case DetailCellStyleSimpleText:{
            [self.infoLabel setText:self.text];
            break;
        }
        case DetailCellStyleSingleAvatar:{
            //TODO show title
            [self.infoLabel setText:self.group.creator.user.nickName];
            break;
        }
        case DetailCellStyleMultipleAvatars:{
            [self.infoLabel updateOriginY:0];
            //TODO show size.
            [self.infoLabel setText:self.members.title.title];
            break;
        }
        default:
            [self.infoLabel setHidden:YES];
            break;
    }
}

- (void)cleanOldViews
{
    [self.contentView removeSubviewsWithClass:[AvatarView class]];
    [self.contentView removeSubviewsWithClass:[UIScrollView class]];
}

- (PBGameUser *)createUser
{
    return _group.creator.user;
}

- (void)updateCellImageContent
{
    switch (self.cellStyle) {
        case DetailCellStyleSingleAvatar:{
            {
                CGFloat avWidth = CREATOR_AVATAR_HEIGHT;
                CGRect frame = CGRectMake(0, 0, avWidth, avWidth);
                CGFloat x = CGRectGetWidth(self.bounds)/5;
                CGFloat y = CGRectGetMinY(self.bounds);
                PBGameUser *user = [self createUser];
                AvatarView *av = [[AvatarView alloc] initWithFrame:frame user:user];
                av.center = CGPointMake(x, y);
                [self.contentView addSubview:av];
                av.delegate = self;
            }
            break;
        }
        case DetailCellStyleMultipleAvatars:{
            CGFloat row = [GroupDetailCell rowForMemberCount:_members.usersList.count];
            CGFloat height = (MEMBER_AVATAR_HEIGHT+MEMBER_AVATAR_SPACE) * row;

            CGFloat width = MEMBER_NUMBER_PERROW * MEMBER_AVATAR_HEIGHT;
            width += (MEMBER_NUMBER_PERROW - 1) * MEMBER_AVATAR_SPACE;
            CGFloat x = CGRectGetWidth(self.bounds)/2 - width;
            CGFloat y = TITLE_INFO_HEIGHT;
            CGRect frame = CGRectMake(x, y, width, height);
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
            [self.contentView addSubview:scrollView];
            [scrollView release];
            
            x = y = 0;
            NSInteger index = 0;
            NSInteger count = [[_members usersList] count];
            for (PBGroupUser *user in _members.usersList) {
                y = (index / count) * (MEMBER_AVATAR_SPACE + MEMBER_AVATAR_HEIGHT);
                x = (index % count) * (MEMBER_AVATAR_HEIGHT + MEMBER_AVATAR_SPACE);                
                CGRect frame = CGRectMake(x, y, MEMBER_AVATAR_HEIGHT, MEMBER_AVATAR_HEIGHT);
                AvatarView *av = [[AvatarView alloc] initWithFrame:frame user:user.user];
                [scrollView addSubview:av];
                av.delegate = self;
                index ++;
            }
            break;
        }
        default:
            break;
    }
}

- (void)didClickOnAvatarView:(AvatarView *)avatarView
{
    //TODO handle the click action.
}

- (void)layoutSubviews
{
    [self cleanOldViews];
    [self updateColorStyle];
    [self updateCellTextContent];
    [self updateCellImageContent];
}

@end
