//
//  SingOpusInfoCell.m
//  Draw
//
//  Created by 王 小涛 on 13-6-8.
//
//

#import "SingOpusInfoCell.h"
#import "UIViewUtils.h"

#define DESC_LABEL_ORIGIN_Y 297
#define DESC_LABEL_WIDTH 306
#define DESC_LABEL_FONT [UIFont systemFontOfSize:12]
#define SPACE 30

@implementation SingOpusInfoCell

+ (NSString *)getCellIdentifier{
    return @"SingOpusInfoCell";

}

+ (CGFloat)getCellHeightWithOpus:(PBOpus *)opus{
    
    NSString *desc = opus.desc;
    if ([desc length] == 0) {
        return DESC_LABEL_ORIGIN_Y;
    }else{
        CGSize size = [desc sizeWithFont:DESC_LABEL_FONT constrainedToSize:CGSizeMake(DESC_LABEL_WIDTH, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
        return DESC_LABEL_ORIGIN_Y + size.height + SPACE;
    }
}

- (void)setOpusInfo:(PBOpus *)opus{
    
    NSString *desc = opus.desc;
    CGSize size = [desc sizeWithFont:DESC_LABEL_FONT constrainedToSize:CGSizeMake(DESC_LABEL_WIDTH, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    [self.opusDescTextView updateHeight:(size.height + SPACE)];
    
    [super setOpusInfo:opus];
}



@end
