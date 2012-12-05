//
//  BBSTableViewCell.m
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "BBSTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "BBSManager.h"

@implementation BBSTableViewCell
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize content = _content;
@synthesize timestamp = _timestamp;
@synthesize image = _image;
@synthesize imageMask = _imageMask;
@synthesize avatarMask = _avatarMask;
@synthesize superController = _superController;

#define BORDER_WIDTH ISIPAD ? 5 : 2.5
#define IMAGE_CORNER_RADIUS ISIPAD ? 10 : 5


+ (void)initMaskViewsWithCell:(BBSTableViewCell *)cell
{
    cell.avatarMask = [UIButton buttonWithType:UIButtonTypeCustom];
    [cell.avatarMask setClipsToBounds:YES];
    cell.avatarMask.autoresizingMask = 63;
    [cell.avatarMask setFrame:cell.avatar.bounds];
    [cell.avatarMask addTarget:cell action:@selector(clickAvatarButton:)
              forControlEvents:UIControlEventTouchUpInside];
    [cell.avatar addSubview:cell.avatarMask];
    
    cell.imageMask = [UIButton buttonWithType:UIButtonTypeCustom];
    cell.imageMask.autoresizingMask = 63;
    [cell.imageMask setFrame:cell.image.bounds];
    [cell.imageMask addTarget:cell action:@selector(clickImageButton:)
             forControlEvents:UIControlEventTouchUpInside];
    [cell.imageMask setClipsToBounds:YES];
    [cell.image addSubview:cell.imageMask];

    [cell.image setUserInteractionEnabled:YES];
    [cell.avatar setUserInteractionEnabled:YES];
    
    [cell.content setLineBreakMode:NSLineBreakByTruncatingTail];
    
    BBSImageManager *_bbsImageManager = [BBSImageManager defaultManager];
    BBSColorManager *_bbsColorManager = [BBSColorManager defaultManager];
    BBSFontManager *_bbsFontManager = [BBSFontManager defaultManager];

    //avatar
    [cell.avatar.layer setBorderColor:([_bbsColorManager postAvatarColor].CGColor)];
    [cell.avatar.layer setCornerRadius:cell.avatar.frame.size.width/2];
    cell.avatar.layer.masksToBounds = YES;
    [cell.avatar.layer setBorderWidth:BORDER_WIDTH];
    //image
    [cell.image.layer setCornerRadius:IMAGE_CORNER_RADIUS];
    cell.image.layer.masksToBounds = YES;

    //nick
    [BBSViewManager updateLable:cell.nickName
                        bgColor:[UIColor clearColor]
                           font:[_bbsFontManager postNickFont]
                      textColor:[_bbsColorManager postNickColor]
                           text:nil];
    
    //content
    [cell.bgImageView setImage:[_bbsImageManager bbsPostContentBGImage]];
    [BBSViewManager updateLable:cell.content
                        bgColor:[UIColor clearColor]
                           font:[_bbsFontManager postContentFont]
                      textColor:[UIColor blackColor]
                           text:nil];
    
    [BBSViewManager updateLable:cell.timestamp
                        bgColor:[UIColor clearColor]
                           font:[_bbsFontManager postDateFont]
                      textColor:[_bbsColorManager postDateColor]
                           text:nil];

}

+ (id)createCellWithIdentifier:(NSString *)identifier
                      delegate:(id)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    
    BBSTableViewCell  *cell = (BBSTableViewCell *)[topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    [BBSTableViewCell initMaskViewsWithCell:cell];
    return cell;

}

- (void)updateImageViewFrameWithImage:(UIImage *)image
{
    if (image) {
        CGSize size = [[BBSImageManager defaultManager]
                       image:image
                       sizeWithConstHeight:IMAGE_HEIGHT
                       maxWidth:CGRectGetWidth(self.content.frame)];
        CGRect frame = self.image.frame;
        frame.size = size;
        self.image.frame = frame;
    }
}

- (void)dealloc
{
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_content);
    PPRelease(_timestamp);
    PPRelease(_image);
    PPRelease(_imageMask);
    PPRelease(_avatarMask);
    PPRelease(_superController);
    PPRelease(_bgImageView);
    [super dealloc];
}

- (void)clickAvatarButton:(id)sender
{
    PPDebug(@"<clickAvatarButton>");
}
- (void)clickImageButton:(id)sender
{
    PPDebug(@"<clickImageButton>");    
}

@end
