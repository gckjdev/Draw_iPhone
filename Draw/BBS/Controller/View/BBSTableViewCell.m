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

- (void)initMaskViews
{
    self.avatarMask = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.avatarMask setClipsToBounds:YES];
    self.avatarMask.autoresizingMask = 63;
    [self.avatarMask setFrame:self.avatar.bounds];
    [self.avatarMask addTarget:self action:@selector(clickAvatarButton:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.avatar addSubview:self.avatarMask];
    
    self.imageMask = [UIButton buttonWithType:UIButtonTypeCustom];
    self.imageMask.autoresizingMask = 63;
    [self.imageMask setFrame:self.image.bounds];
    [self.imageMask addTarget:self action:@selector(clickImageButton:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.imageMask setClipsToBounds:YES];
    [self.image addSubview:self.imageMask];
    
    [self.image setUserInteractionEnabled:YES];
    [self.avatar setUserInteractionEnabled:YES];
    
    [self.content setLineBreakMode:NSLineBreakByTruncatingTail];
    
    
    _bbsImageManager = [BBSImageManager defaultManager];
    _bbsColorManager = [BBSColorManager defaultManager];
    _bbsFontManager = [BBSFontManager defaultManager];
    
    //avatar
    [self.avatar.layer setBorderColor:([_bbsColorManager postAvatarColor].CGColor)];
    [self.avatar.layer setCornerRadius:self.avatar.frame.size.width/2];
    self.avatar.layer.masksToBounds = YES;
    [self.avatar.layer setBorderWidth:BORDER_WIDTH];
    //image
    [self.image.layer setCornerRadius:IMAGE_CORNER_RADIUS];
    self.image.layer.masksToBounds = YES;
    
    //nick
    [BBSViewManager updateLable:self.nickName
                        bgColor:[UIColor clearColor]
                           font:[_bbsFontManager postNickFont]
                      textColor:[_bbsColorManager postNickColor]
                           text:nil];
    
    //content
    [self.bgImageView setImage:[_bbsImageManager bbsPostContentBGImage]];
    [BBSViewManager updateLable:self.content
                        bgColor:[UIColor clearColor]
                           font:[_bbsFontManager postContentFont]
                      textColor:[UIColor blackColor]
                           text:nil];
    
    [BBSViewManager updateLable:self.timestamp
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
    [cell initMaskViews];
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
