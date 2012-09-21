//
//  RankFirstCell.m
//  Draw
//
//  Created by  on 12-9-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RankFirstCell.h"
#import "DrawFeed.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"

@implementation RankFirstCell
@synthesize drawImage = _drawImage;
@synthesize drawTitle = _drawTitle;
@synthesize drawAutor = _drawAutor;
@synthesize feed = _feed;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"RankFirstCell";
}

+ (CGFloat)getCellHeight
{
    return [DeviceDetection isIPAD] ? 300 : 137;
}

- (void)setCellInfo:(DrawFeed *)feed
{
    [self.drawAutor setText:feed.feedUser.nickName];
    [self.drawTitle setText:feed.wordText];
    
    self.feed = feed;
    [self.drawImage clear];
    [self.drawImage setUrl:[NSURL URLWithString:feed.drawImageUrl]];
    [GlobalGetImageCache() manage:self.drawImage];
}

- (void)dealloc {
    PPRelease(_drawImage);
    PPRelease(_drawTitle);
    PPRelease(_drawAutor);
    PPRelease(_feed);
    [super dealloc];
}
@end
