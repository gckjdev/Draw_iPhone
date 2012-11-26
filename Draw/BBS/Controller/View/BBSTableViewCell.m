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

@end
