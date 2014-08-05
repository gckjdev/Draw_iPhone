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
#define DEFAUT_LOCK_IMAGE "lock_new2.jpg"

-(void)updateStageCellInfo:(PBUserTutorial *)pbUserTutorial withRow:(NSInteger)row{
   
    //数组越界保护
    NSArray *stageList = [[pbUserTutorial tutorial] stagesList];
    if (stageList == nil || row >= [stageList count]){
        return ;
    }
    
    BOOL isLockStage = [pbUserTutorial isStageLock:row];
    
    NSString* name = [[stageList objectAtIndex:row] name];

    if (isLockStage){
        
    }

    self.stageListStarBtn.userInteractionEnabled = NO;

    
    //闯关的关卡数
    if (isLockStage == NO){
        
        // stage name
        [self.cellName setText:[NSString stringWithFormat:@"%d.%@",row+1,name]];
        [self.cellName setShadowColor:[UIColor blackColor]];
        [self.cellName setShadowOffset:CGSizeMake(1, 1)];
        
        // star button
        UIImage* starButtonBgImage = [[ShareImageManager defaultManager] startButtonBgImage];
        
        // start button
        [self.stageListStarBtn setBackgroundImage:starButtonBgImage forState:UIControlStateNormal];
        [self.stageListStarBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        [self.stageListStarBtn.titleLabel setFont:AD_FONT(20, 14)];
        [self.stageListStarBtn setTitle:NSLS(@"kStartStage") forState:UIControlStateNormal];

        // stage image
        SET_VIEW_ROUND_CORNER(self.stageCellImage);
        UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
        [self.stageCellImage setImageWithUrl:[NSURL URLWithString:[[stageList objectAtIndex:row] thumbImage]]
                            placeholderImage:placeHolderImage
                                 showLoading:YES
                                    animated:YES];
        
        self.stageListStarBtn.hidden = NO;
        self.cellName.hidden = NO;
        self.stageCellImage.hidden = NO;
        self.stageListHiddenLockImageView.hidden = YES;
        self.hiddenNumberLabel.hidden = YES;
        self.hiddenNumberHolderView.hidden = YES;

    }
    else{
        
        self.stageListStarBtn.hidden = YES;
        self.cellName.hidden = YES;
        self.stageCellImage.hidden = YES;
        
        self.stageListHiddenLockImageView.hidden = NO;
        self.hiddenNumberLabel.hidden = NO;
        self.hiddenNumberHolderView.hidden = NO;
                
        // lock image
        SET_VIEW_ROUND_CORNER(self.stageListHiddenLockImageView);
        [self.stageListHiddenLockImageView setImage:[UIImage imageNamed:@DEFAUT_LOCK_IMAGE]];
        
        // lock stage index number
        [self.hiddenNumberLabel setText:[NSString stringWithFormat:@"%d",row+1]];
    }
    

}

- (void)dealloc {
    [_stageCellImage release];
    [_cellName release];
    [_stageListStarBtn release];
    [_stageListHiddenLockImageView release];
    [_hiddenNumberLabel release];
    [_hiddenNumberHolderView release];
    [super dealloc];
}
@end
