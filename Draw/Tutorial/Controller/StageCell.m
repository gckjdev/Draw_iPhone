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
#define DEFAUT_IMAGE "zuixiaoguanka"
#define DEFAUT_LOCK_IMAGE "lock_new2"
-(void)updateStageCellInfo:(PBUserTutorial *)pbUserTutorial withRow:(NSInteger)row{
   
        //隐藏了BUTTON
//    SET_BUTTON_ROUND_STYLE_ORANGE(self.stageListStarBtn);
//    [[self.stageListStarBtn titleLabel] setFont:AD_FONT(24, 14)];
    
    NSArray *stageList = [[pbUserTutorial tutorial] stagesList];
    NSString* name = [[stageList objectAtIndex:row] name];
    //设置隐藏锁图片
    [self.stageListHiddenLockImageView setImage:[UIImage imageNamed:@DEFAUT_LOCK_IMAGE]];
    [self.cellName setText:[NSString stringWithFormat:@"%d.%@",row+1,name]];
    [self.hiddenNumberLabel setText:[NSString stringWithFormat:@"%d",row+1]];
    //闯关的关卡数
    if(row<= pbUserTutorial.currentStageIndex){
        self.stageListHiddenLockImageView.hidden = YES;
        self.hiddenNumberLabel.hidden = YES;
    }
    //数组越界保护
    if(stageList==nil || row >= [stageList count]){
        return ;
    }
    
    
    //设置图片圆角
    SET_VIEW_ROUND_CORNER(self.stageCellImage);
    SET_VIEW_ROUND_CORNER(self.stageListHiddenLockImageView);
    //加载默认图片图片
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
    [self.stageCellImage
            setImageWithUrl:[NSURL URLWithString:[[stageList objectAtIndex:row] thumbImage]]
            placeholderImage:placeHolderImage
            showLoading:YES
            animated:YES];
}

- (void)dealloc {
        [_stageCellImage release];
        [_cellName release];
        [_stageListStarBtn release];
        [_stageListHiddenLockImageView release];
    [_hiddenNumberLabel release];
        [super dealloc];
}
@end
