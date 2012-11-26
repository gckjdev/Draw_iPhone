//
//  BBSTableViewCell.m
//  Draw
//
//  Created by gamy on 12-11-26.
//
//

#import "BBSTableViewCell.h"

@implementation BBSTableViewCell
@synthesize avatar = _avatar;
@synthesize nickName = _nickName;
@synthesize content = _content;
@synthesize timestamp = _timestamp;
@synthesize image = _image;
@synthesize imageMask = _imageMask;
@synthesize avatarMask = _avatarMask;
@synthesize superController = _superController;


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
