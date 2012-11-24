//
//  BBSUserActionCell.m
//  Draw
//
//  Created by gamy on 12-11-23.
//
//

#import "BBSUserActionCell.h"

@interface BBSUserActionCell ()

@end

#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"

#define SPACE_CONTENT_TOP 35
#define SPACE_SOURCE_BOTTOM 10

#define SPACE_TEXT_SOURCE_IMAGE 100
#define SPACE_TEXT_SOURCE_NO_IMAGE 10

#define IMAGE_HEIGHT 80

#define CONTENT_WIDTH 240
#define SOURCE_WIDTH 240
#define CONTENT_MAX_HEIGHT 99999999
#define SOURCE_MAX_HEIGHT 99999999

#define Y_CONTENT_TEXT 5
#define Y_SOURCE_TEXT 5

#define CONTENT_FONT [UIFont systemFontOfSize:15]
#define SOURCE_FONT [UIFont systemFontOfSize:13]



@implementation BBSUserActionCell
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize content = _content;
@synthesize timestamp = _timestamp;
@synthesize image = _image;
@synthesize source = _source;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_content);
    PPRelease(_timestamp);
    PPRelease(_image);
    PPRelease(_source);
    PPRelease(_action);
    [super dealloc];
}




//@synthesize delegate = _delegate;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    BBSUserActionCell *cell = ((BBSUserActionCell*)[topLevelObjects objectAtIndex:0]);
    cell.content.numberOfLines = 0;
    [cell.content setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.content.font = CONTENT_FONT;
    
    cell.source.numberOfLines = 0;
    [cell.source setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.source.font = SOURCE_FONT;

    
    cell.delegate = delegate;
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSUserActionCell";
}


+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT
                   constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT)
                       lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}

+ (CGFloat)heightForSourceText:(NSString *)text
{
    CGSize size = [text sizeWithFont:SOURCE_FONT
                   constrainedToSize:CGSizeMake(SOURCE_WIDTH, SOURCE_MAX_HEIGHT)
                       lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_SOURCE_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
    CGFloat contentHeight = [BBSUserActionCell heightForContentText:action.content.text];
    CGFloat sourceHeight = [BBSUserActionCell heightForSourceText:action.showSourceText];
    CGFloat height = contentHeight + sourceHeight;
    if (action.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_TEXT_SOURCE_IMAGE) + SPACE_SOURCE_BOTTOM;
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_TEXT_SOURCE_NO_IMAGE + SPACE_SOURCE_BOTTOM);
    }
    return height;
}

- (void)updateUserInfo:(PBBBSUser *)user
{
    [self.nickName setText:user.showNick];
    [self.avatar setImageWithURL:user.avatarURL placeholderImage:user.defaultAvatar];
}

- (void)resetView:(UIView *)view height:(CGFloat)height
{
    CGRect frame = view.frame;
//    frame.size.height = [BBSUserActionCell heightForContentText:action.content.text];
    frame.size.height = height;
    self.content.frame = frame;
}

- (void)updateContentWithAction:(PBBBSAction *)action
{
    NSString *text = [action showText];
    [self.content setText:text];

    //reset the content size
    CGFloat height = [BBSUserActionCell heightForContentText:action.content.text];
    [self resetView:self.content height:height];
    
    height = [BBSUserActionCell heightForSourceText:action.showSourceText];
    [self resetView:self.source height:height];

    
    if (action.content.hasThumbImage) {
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:nil];
        //reset image frmae center
        
        CGFloat y1 = CGRectGetMaxY(self.content.frame);
        CGFloat y2 = CGRectGetMidY(self.source.frame);
        CGFloat y = (y1+y2) / 2;
        CGFloat x = self.bounds.size.width / 2;
        self.image.center = CGPointMake(x, y);
        
        self.image.hidden = NO;
    }else{
        self.image.hidden = YES;
    }
}

- (void)updateTimeStamp:(NSInteger)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    [self.timestamp setText:dateToChineseString(date)];
}


- (void)updateCellWithBBSAction:(PBBBSAction *)action
{
    self.action = action;
    [self updateUserInfo:action.createUser];
    [self updateContentWithAction:action];
    [self updateTimeStamp:action.createDate];
}

@end
