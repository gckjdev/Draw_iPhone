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
    NSArray *stageList = [[pbUserTutorial tutorial] stages];
    if (stageList == nil || row >= [stageList count]){
        return ;
    }
    
    BOOL isLockStage = [pbUserTutorial isStageLock:row];
    [self openStage];
    
    //闯关的关卡数
    if (isLockStage == NO){
        [self initCell:stageList WithRow:row];
        [self openStage];
        [self setupTitleBtn:pbUserTutorial withRow:row];
    }
    else{
        [self lockStage];
        [self setupLocker:row];
    }
    

}

-(void)openStage{
    self.stageListStarBtn.userInteractionEnabled = NO;
    self.stageListStarBtn.hidden = YES;
    self.cellName.hidden = NO;
    self.stageCellImage.hidden = NO;
    self.stageListHiddenLockImageView.hidden = YES;
    self.hiddenNumberLabel.hidden = YES;
    self.hiddenNumberHolderView.hidden = YES;
}
-(void)lockStage{
    self.stageListStarBtn.hidden = YES;
    self.cellName.hidden = YES;
    self.stageCellImage.hidden = YES;
    self.maskView.hidden = YES;
    self.stageListHiddenLockImageView.hidden = NO;
    self.hiddenNumberLabel.hidden = NO;
    self.hiddenNumberHolderView.hidden = NO;
}


-(void)setupTitleBtn:(PBUserTutorial *)pbUserTutorial withRow:(NSInteger)row{
    
    //闯到某一关卡才显示开始闯关字样
    if(!pbUserTutorial.tutorial.unlockAllStage){
        // star button
        UIImage* starButtonBgImage = [[ShareImageManager defaultManager] startButtonBgImage];
        [self.stageListStarBtn setBackgroundImage:starButtonBgImage forState:UIControlStateNormal];
        [self.stageListStarBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
        [self.stageListStarBtn.titleLabel setFont:AD_FONT(20, 12)];
        [self.stageListStarBtn setTitle:NSLS(@"kStartStage") forState:UIControlStateNormal];
    
    
    
        if (row == pbUserTutorial.currentStageIndex){
            //当教程没有完成时候才显示,完成了就不再显示开始闯关字样
            if([pbUserTutorial isFinishedTutorial:row]==NO){
                self.stageListStarBtn.hidden = NO;
                
                NSString* btnTitle = nil;
                if([pbUserTutorial isForStudy]){
                    if ([pbUserTutorial hasFinishPractice:row]){
                        btnTitle = NSLS(@"kContinuePracticeDraw");
                    }
                    else{
                        btnTitle = NSLS(@"kStartPracticeDraw");
                    }
                    
                }else{
                    btnTitle = NSLS(@"kStartRelaxDraw");
                }
                
                [self.stageListStarBtn setTitle:btnTitle
                                       forState:UIControlStateNormal];
            }
            
            self.maskView.alpha = 0.15f;
            self.maskView.hidden = NO;
        }
        
    }
    else{
        self.maskView.alpha = 1.0f;
        self.maskView.hidden = YES;
    }

}

-(void)initCell:(NSArray *)stageList WithRow:(NSInteger)row{
    NSString* name = [[stageList objectAtIndex:row] name];
    // stage name
    [self.cellName setText:[NSString stringWithFormat:@"%d.%@",row+1,name]];
    [self.cellName setShadowColor:[UIColor blackColor]];
    [self.cellName setShadowOffset:CGSizeMake(1, 1)];
    
    
   
    
    // stage image
    SET_VIEW_ROUND_CORNER(self.stageCellImage);
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
    [self.stageCellImage setImageWithUrl:[NSURL URLWithString:[[stageList objectAtIndex:row] thumbImage]]
                        placeholderImage:placeHolderImage
                             showLoading:YES
                                animated:YES];
    
    //mask view
    SET_VIEW_ROUND_CORNER(self.maskView);

    
}

-(void)setupLocker:(NSInteger)row{
    // lock image
    SET_VIEW_ROUND_CORNER(self.stageListHiddenLockImageView);
    [self.stageListHiddenLockImageView setImage:[UIImage imageNamed:@DEFAUT_LOCK_IMAGE]];
    
    // lock stage index number
    [self.hiddenNumberLabel setText:[NSString stringWithFormat:@"%d",row+1]];
    
}

- (void)dealloc {
    [_stageCellImage release];
    [_cellName release];
    [_stageListStarBtn release];
    [_stageListHiddenLockImageView release];
    [_hiddenNumberLabel release];
    [_hiddenNumberHolderView release];
    [_maskView release];
    [super dealloc];
}
@end
