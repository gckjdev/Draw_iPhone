//
//  StatementCell.m
//  Draw
//
//  Created by 王 小涛 on 14-1-8.
//
//

#import "StatementCell.h"
#import "StringUtil.h"

@interface StatementCell()
@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UILabel *contestLabel;
@end

@implementation StatementCell

#define CELL_VERTICAL_INSET (ISIPAD?30:15)
#define LABEL_WIDTH (ISIPAD?618:241)
#define CELL_MIN_HEIGHT (ISIPAD?140:80)
#define LABEL_HEIGHT_PERLINE (ISIPAD?40:22)


+ (CGFloat)getCellHeightWithType:(StatementCellType)type
{
    switch (type) {
        case StatementCellTypeAward:
            return LABEL_HEIGHT_PERLINE * 4;
        default:
            return CELL_MIN_HEIGHT;
    }
}

+ (CGFloat)getCellHeightWithContent:(NSString *)content{    
    CGFloat height = [self getTextHeight:content];
    height = MAX(CELL_MIN_HEIGHT, height+CELL_VERTICAL_INSET);
    return height;
}

+ (CGFloat)getTextHeight:(NSString *)text{
    
    CGSize contrainedSize = CGSizeMake(LABEL_WIDTH, CGFLOAT_MAX);
    CGSize size = [text sizeWithMyFont:CELL_CONTENT_FONT constrainedToSize:contrainedSize lineBreakMode:NSLineBreakByCharWrapping];
    return size.height;
}

+ (NSString *)getCellIdentifier{
    
    return @"StatementCell";
}

+ (id)createCell:(id)delegate{
    
    StatementCell *cell = [self createViewWithXibIdentifier:[self getCellIdentifier] ofViewIndex:ISIPAD];
    cell.titleLabel.font = CELL_NICK_FONT;
    cell.contestLabel.font = CELL_CONTENT_FONT;
    cell.titleLabel.textColor = COLOR_WHITE;
    cell.contestLabel.textColor = COLOR_BROWN;
    
    cell.delegate = delegate;
    
    return cell;
}

- (void)setCellTitle:(NSString *)title content:(NSString *)content{
 
    self.titleLabel.text = title;
    self.contestLabel.text = [content length] == 0 ? NSLS(@"kNone"): content;
    
    if (self.indexPath.row % 2 == 0) {
        self.bgImageView.image = [ShareImageManager statementCellBg1];
    }else{
        self.bgImageView.image = [ShareImageManager statementCellBg2];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contestLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)dealloc {
    [_bgImageView release];
    [_titleLabel release];
    [_contestLabel release];
    [super dealloc];
}
@end
