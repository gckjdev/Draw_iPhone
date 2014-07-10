//
//  StageCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-2.
//
//

#import "StageCell.h"
#import "UIImageView+Extend.h"

@implementation StageCell
#define TUTORIAL_IMAGE_HEIGHT       (ISIPAD ? 100 : 45)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
            //TODO
        
            }
    return self;
}

// TODO move image name to ShareImageManager
// TODO format/refactor the code below
#define DEFAUT_IMAGE "dialogue@2x"
#define DEFAUT_LOCK_IMAGE "lock2"
-(void)updateStageCellInfo:(PBUserTutorial *)pbUserTutorial withRow:(NSInteger)row{
    
    
    
        SET_BUTTON_ROUND_STYLE_ORANGE(self.stageListStarBtn);
        [[self.stageListStarBtn titleLabel] setFont:AD_FONT(24, 14)];
    
        NSArray *stageList = [[pbUserTutorial tutorial] stagesList];
        //加载图片
        UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
    
        //设置圆角
        SET_VIEW_ROUND_CORNER(self.stageCellImage);
        SET_VIEW_ROUND_CORNER(self.stageListHiddenLockImageView);
        //设置隐藏锁图片
        [self.stageListHiddenLockImageView setImage:[UIImage imageNamed:@DEFAUT_LOCK_IMAGE]];
    
        //上一关数据 TODO
        int preStageRow = row - 1;
        //判断preStageRow是否有效
        if(preStageRow >= 0 && (preStageRow) < [stageList count]){
            
            
            //上一关的分数
//            NSInteger* bestScore = [[stageList objectAtIndex:preStageRow] bestScore];
            
            //TODO  查找bestScore
            NSInteger* bestScore = 0;
            
            
            //判断上一关没有闯关时，隐藏
            if (bestScore==nil||bestScore<=0) {
                self.stageListHiddenLockImageView.hidden = NO;
            }            
        }
    
    
        //数组越界保护
            if(stageList==nil || row >= [stageList count]){
                return ;
            }
            [self.stageCellImage
             setImageWithUrl:[NSURL URLWithString:[[stageList objectAtIndex:row] thumbImage]]
             placeholderImage:placeHolderImage
             showLoading:YES
             animated:YES];
            //设置label文字
            self.cellName.text = [[stageList objectAtIndex:row] cnName];
    
    
}

- (void)dealloc {
        [_stageCellImage release];
        [_cellName release];
        [_stageListStarBtn release];
        [_stageListHiddenLockImageView release];
        [super dealloc];
}
@end
