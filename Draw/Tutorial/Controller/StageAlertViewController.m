//
//  StageAlertViewController.m
//  Draw
//
//  Created by ChaoSo on 14-8-6.
//
//

#import "StageAlertViewController.h"
#import "UserTutorialService.h"
#import "StringUtil.h"
#import "UIImageView+Extend.h"

@interface StageAlertViewController ()

@property (nonatomic, retain) PBUserTutorial* pbUserTutorial;
@property (nonatomic, assign) NSInteger stageIndex;
@end

@implementation StageAlertViewController


+(void)show:(PPViewController *)superController userTutorial:(PBUserTutorial *)pbUserTutorial stageIndex:(NSInteger)stageIndex
{
    NSArray *stageList = [[pbUserTutorial tutorial] stagesList];
    if (stageList == nil || stageIndex >= [stageList count]){
        return ;
    }
    
    PBStage *stageWithRow = [stageList objectAtIndex:stageIndex];
    NSString *stageId = stageWithRow.stageId;
    
    StageAlertViewController *savc = [[StageAlertViewController alloc] init];
    
    savc.pbUserTutorial = pbUserTutorial;
    savc.stageIndex = stageIndex;
    
    CommonDialog *dialog = [CommonDialog
                            createDialogWithTitle:stageWithRow.name
                            customView:savc.view
                            style:CommonDialogStyleDoubleButtonWithCross
                            delegate:savc];
    
    [dialog.oKButton setTitle:NSLS(@"kPass") forState:UIControlStateNormal];
    [dialog.cancelButton setTitle:NSLS(@"kPractice") forState:UIControlStateNormal];
    
    [dialog setClickOkBlock:^(id view){
        // Conquer
        [[UserTutorialService defaultService] enterConquerDraw:superController
                                                  userTutorial:pbUserTutorial
                                                       stageId:stageId
                                                    stageIndex:stageIndex];

        [savc removeFromParentViewController];
    }];
    
    [dialog setClickCancelBlock:^(id view){
        // Practice
        [[UserTutorialService defaultService] enterPracticeDraw:superController
                                                   userTutorial:pbUserTutorial
                                                        stageId:stageId
                                                     stageIndex:stageIndex];
        
        [savc removeFromParentViewController];
    }];
    
    
    [dialog showInView:superController.view];
    [superController addChildViewController:savc];
    [savc release];
}

#define DEFAUT_IMAGE "zuixiaoguanka"
#define ISIPAD_BORDER (ISIPAD ? 5 : 2)
#define ISIPAD_TEXT_HEIGHT (ISIPAD ? 80 : 40)
-(void)updateTheView{

    if(self.pbUserTutorial==nil)
    {
        PPDebug(@"<updateTheView> but the pbUserTutorial is nil or empty");
        return;
    }
    
    NSArray *stageList = [[self.pbUserTutorial tutorial] stagesList];
    int bestScoreValue = 0;
    
    if (self.stageIndex < [self.pbUserTutorial.userStagesList count]){
        PBUserStage* userStage = [self.pbUserTutorial.userStagesList objectAtIndex:self.stageIndex];
        bestScoreValue = [userStage bestScore];
    }
    
    if (stageList == nil || self.stageIndex >= [stageList count]){
        return ;
    }
    
    PBStage *stageWithRow = [stageList objectAtIndex:self.stageIndex];
    NSString *imagePath = stageWithRow.thumbImage;
    NSString *stageDesc = stageWithRow.cnDesc;
    
    NSString *bestScore = @"";
    bestScore = [NSString stringWithFormat:@"%d",bestScoreValue];

 
    UIFont *textFont = AD_FONT(20, 12);
    
    // stage image
    UIImage *placeHolderImage = [UIImage imageNamed:@DEFAUT_IMAGE];
    
    //自适应高度
    CGRect orgRect=self.stageDesc.frame;//获取原始UITextView的frame
    CGFloat  height;
//    if(ISIOS7){
//        height =  [stageDesc boundingRectWithSize:CGSizeMake(130, ISIPAD_TEXT_HEIGHT)
//                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                     attributes:[NSDictionary dictionaryWithObjectsAndKeys:textFont,NSFontAttributeName, nil] context:nil].size.height;
//        
//    }else{
//    height = [stageDesc sizeWithFont:textFont constrainedToSize:CGSizeMake(130,ISIPAD_TEXT_HEIGHT) lineBreakMode:UILineBreakModeWordWrap].height;
//    }
    height = [stageDesc sizeWithMyFont:textFont
                     constrainedToSize:CGSizeMake(130,ISIPAD_TEXT_HEIGHT)
                         lineBreakMode:UILineBreakModeWordWrap].height;
    
    orgRect.size.height=height;//获取自适应文本内容高度
    self.stageDesc.frame=orgRect;//重设UITextView的frame
    
    [self.stageDesc setEditable:NO];
    [self.stageDesc setText:stageDesc];
    [self.stageDesc setFont:textFont];
    [self.stageDesc setTextColor:COLOR_BROWN];
    
    NSString* scoreText = nil;
    if ([bestScore intValue]> 0){
        scoreText = bestScore;
    }
    else{
        scoreText = NSLS(@"kNoBestScore");
    }
    
    [self.bestScore setText:[NSString stringWithFormat:NSLS(@"kBestScoreText"),scoreText]];
    [self.bestScore setFont:AD_FONT(20, 11)];
    [self.bestScore setTextColor:COLOR_BROWN];
    [self.bestScore setTextAlignment:NSTextAlignmentLeft];
    
    [self.stageExampleImageView setImageWithUrl:[NSURL URLWithString:imagePath]
                               placeholderImage:placeHolderImage
                                    showLoading:YES
                                       animated:YES];
    
    self.view.layer.borderWidth = ISIPAD_BORDER;
    [self.view.layer setBorderColor:COLOR_YELLOW.CGColor];
    SET_VIEW_ROUND_CORNER(self.view);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateTheView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    
    PPRelease(_stageExampleImageView);
    PPRelease(_stageDesc);
    PPRelease(_bestScore);
    [super dealloc];
}

- (void)viewDidUnload {
    [self setStageExampleImageView:nil];
    [self setBestScore:nil];
    [self setStageDesc:nil];
    [super viewDidUnload];
}
@end