//
//  StatementCell.m
//  Draw
//
//  Created by 王 小涛 on 14-1-8.
//
//

#import "StatementCell.h"

@interface StatementCell()
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *contestLabel;
@end

@implementation StatementCell

+ (float)getCellHeightWithContent:(NSString *)content{
    
    return [self getTextHeight:content] + 10 * 2;
}

+ (float)getTextHeight:(NSString *)text{
    
    CGSize contrainedSize = CGSizeMake(231, 79);
    CGSize size = [text sizeWithFont:FONT_BUTTON constrainedToSize:contrainedSize lineBreakMode:NSLineBreakByTruncatingTail];
    
    float height = MAX(21, size.height);
    
    return MAX(65, height);
}

+ (NSString *)getCellIdentifier{
    
    return @"StatementCell";
}

+ (id)createCell:(id)delegate{
    
    StatementCell *cell = [super createCell:delegate];
    cell.titleLabel.textColor = COLOR_BROWN;
    cell.contestLabel.textColor = COLOR_BROWN;
    return cell;
}

- (void)setCellTitle:(NSString *)title content:(NSString *)content{
 
    self.titleLabel.text = title;
    self.contestLabel.text = content;
    
    [self.contestLabel updateHeight:[StatementCell getTextHeight:content]];

    [self.bgImageView updateHeight:(CGRectGetHeight(self.contestLabel.bounds) + 5*2)];
    
    if (self.indexPath.row % 2 == 0) {
        self.bgImageView.image = [ShareImageManager statementCellBg1];
    }else{
        self.bgImageView.image = [ShareImageManager statementCellBg2];
    }
    
    [self.contestLabel updateCenterY:self.bgImageView.center.y];
}


- (void)dealloc {
    [_bgImageView release];
    [_titleLabel release];
    [_contestLabel release];
    [super dealloc];
}
@end
