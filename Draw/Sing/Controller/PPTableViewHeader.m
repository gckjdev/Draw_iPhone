//
//  PPTableViewHeader.m
//  Draw
//
//  Created by 王 小涛 on 13-6-9.
//
//

#import "PPTableViewHeader.h"

@implementation PPTableViewHeader
@synthesize delegate = _delegate;
@synthesize indexPath = _indexPath;

- (void)dealloc
{
    [_indexPath release];
    [super dealloc];
}

+ (id)createHeader:(id)delegate
{
    NSString* headerId = [self getHeaderIdentifier];
    PPDebug(@"headerId = %@", headerId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:headerId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", headerId);
        return nil;
    }
    
    ((PPTableViewHeader*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getHeaderIdentifier
{
    return @"PPTableViewHeader";
}

+ (CGFloat)getHeaderHeight
{
    return 0;
}

@end
