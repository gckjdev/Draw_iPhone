//
//  BBSPostDetailCell.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSPostDetailCell.h"

@implementation BBSPostDetailCell

+ (BBSPostDetailCell *)createCell:(id)delegate
{
    NSString *identifier = [BBSPostDetailCell getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    BBSPostDetailCell *view = [topLevelObjects objectAtIndex:0];
    //    view.delegate = delegate;
    return  view;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostDetailCell";
}

+ (CGFloat)getCellHeight
{
    return 120.0f;
}

- (void)updateTextContentWithContent:(PBBBSContent *)content
{
    [self.textContent setText:content.text];
}
- (void)updateCellWithPost:(PBBBSPost *)post
{
    [self updateTextContentWithContent:post.content];
}

- (void)dealloc {
    [_textContent release];
    [_imageContent release];
    [super dealloc];
}
@end
