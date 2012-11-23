//
//  BBSPostDetailCell.m
//  Draw
//
//  Created by gamy on 12-11-22.
//
//

#import "BBSPostDetailCell.h"
#import "UIImageView+WebCache.h"
#import "TimeUtils.h"

#define SPACE_CONTENT_TOP 10
#define TEXT_WIDTH 300
#define TEXT_MAX_HEIGHT 999999999
#define IMAGE_HEIGHT 150
#define SPACE_TEXT_IMAGE 10
#define Y_CONTENT_TEXT 5
#define SPACE_CONTENT_BOTTOM_IMAGE (200) //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT 40 //TEXT TYPE

#define CONTENT_FONT [UIFont systemFontOfSize:16]
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

    [view.textContent setNumberOfLines:0];
    [view.textContent setLineBreakMode:NSLineBreakByCharWrapping];
    [view.textContent setFont:CONTENT_FONT];
    
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

+ (CGFloat)getTextContentHeightWithText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(TEXT_WIDTH, TEXT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}

+ (CGFloat)getCellHeightWithPost:(PBBBSPost *)post
{
    CGFloat height = [BBSPostDetailCell getTextContentHeightWithText:post.content.text];
    if (post.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_IMAGE);
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_TEXT);
    }
    return height;

}

- (void)updateContent:(PBBBSContent *)content
{
    [self.textContent setText:content.text];
    
    //reset the size
    CGRect frame = self.textContent.frame;
    frame.size.height = [BBSPostDetailCell getTextContentHeightWithText:content.text];
    self.textContent.frame = frame;
    
    if (content.hasThumbImage) {
        [self.imageContent setImageWithURL:content.thumbImageURL placeholderImage:nil];
        self.imageContent.hidden = NO;
    }else{
        self.imageContent.hidden = YES;
    }
}


- (void)updateTime:(NSInteger)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *dateString = dateToLocaleString(date);
    [self.time setText:dateString];

}
- (void)updateCellWithPost:(PBBBSPost *)post
{
    [self updateContent:post.content];
    [self updateTime:post.createDate];
}

- (void)dealloc {
    [_textContent release];
    [_imageContent release];
    [_time release];
    [super dealloc];
}
@end
