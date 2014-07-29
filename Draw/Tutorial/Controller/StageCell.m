//
//  StageCell.m
//  Draw
//
//  Created by ChaoSo on 14-7-2.
//
//

#import "StageCell.h"
#import "UIImageView+Extend.h"
#import "PBTutorial+Extend.h"

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
   
    //数组越界保护
    NSArray *stageList = [[pbUserTutorial tutorial] stagesList];
    if (stageList==nil || row >= [stageList count]){
        return ;
    }
    
    NSString* name = [[stageList objectAtIndex:row] name];
    //设置隐藏锁图片
    [self.stageListHiddenLockImageView setImage:[UIImage imageNamed:@DEFAUT_LOCK_IMAGE]];
    [self.cellName setText:[NSString stringWithFormat:@"%d.%@",row+1,name]];
    [self.cellName setShadowColor:[UIColor blackColor]];
    [self.cellName setShadowOffset:CGSizeMake(1, 1)];
    
    UIImage* starButtonBgImage = [[ShareImageManager defaultManager] startButtonBgImage];
    
    [self.stageListStarBtn setBackgroundImage:starButtonBgImage forState:UIControlStateNormal];
    [self.stageListStarBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    [self.stageListStarBtn.titleLabel setFont:AD_FONT(20, 14)];
    
    [self.hiddenNumberLabel setText:[NSString stringWithFormat:@"%d",row+1]];

    //闯关的关卡数
    if ([pbUserTutorial isStageLock:row] == NO){
        self.stageListHiddenLockImageView.hidden = YES;
        self.hiddenNumberLabel.hidden = YES;
    }
    else{
        self.stageListHiddenLockImageView.hidden = NO;
        self.hiddenNumberLabel.hidden = NO;
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
