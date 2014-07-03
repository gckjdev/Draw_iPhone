//
//  StageCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-2.
//
//

#import "StageCell.h"

@implementation StageCell
#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//        // 初始化时加载StageCell。xib文件
//        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"StageCell" owner:self options:nil];
//        if (arrayOfViews.count < 1)
//        {
//            return nil;
//        }
//        // 如果xib中view不属于UICollectionViewCell类，return nil
//        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
//        {
//            return nil;
//        }
//        // 加载nib
//        self = [arrayOfViews objectAtIndex:0];
//        
//    }
//    return self;
//}




- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // change to our custom selected background view
//        CustomCellBackground *backgroundView = [[CustomCellBackground alloc] initWithFrame:CGRectZero];
//        self.selectedBackgroundView = backgroundView;
        
            }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_stageCellImage release];
    [_cellName release];
    [super dealloc];
}
@end
