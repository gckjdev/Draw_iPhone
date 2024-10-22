//
//  CreateContestController.m
//  Draw
//
//  Created by 王 小涛 on 13-12-30.
//
//

#import "CreateContestController.h"
#import "TimeUtils.h"
#import "BBSActionSheet.h"
#import "Contest.h"
#import "NSDate+TKCategory.h"
#import "CKCalendarView.h"
#import "BBSActionSheet.h"
#import "ChangeAvatar.h"
#import "StringUtil.h"
#import "ContestService.h"
#import "GroupManager.h"
#import "ContestAwardEditController.h"
#import "IQKeyBoardManager.h"
#import "UIButton+WebCache.h"
#import "CropAndFilterViewController.h"
#import "GameNetworkConstants.h"
#import "UIViewController+BGImage.h"

@interface CreateContestController ()<CKCalendarDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel *contestNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *contestNameInputField;
@property (retain, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (retain, nonatomic) IBOutlet UIButton *startTimeButton;
@property (retain, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (retain, nonatomic) IBOutlet UIButton *endTimeButton;
@property (retain, nonatomic) IBOutlet UILabel *contestDescLabel;
@property (retain, nonatomic) IBOutlet UITextView *contestDescTextView;
@property (retain, nonatomic) IBOutlet UILabel *joinersLabel;
@property (retain, nonatomic) IBOutlet UIButton *joinerButton;
@property (retain, nonatomic) IBOutlet UILabel *contestImageLabel;
@property (retain, nonatomic) IBOutlet UIButton *contestImageButton;
@property (retain, nonatomic) IBOutlet UILabel *contestAwardLabel;
@property (retain, nonatomic) IBOutlet UIButton *contestAwardButton;

@property (retain, nonatomic) Contest* contest;
@property (retain, nonatomic) CKCalendarView *calendar;
@property (retain, nonatomic) UIButton *calendarDismissButton;
@property (retain, nonatomic) ChangeAvatar *picker;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) ContestAwardEditController *awardEditController;
@property (assign, nonatomic) BOOL isNewContest;
@end

@implementation CreateContestController

+ (void)enterFromController:(PPViewController *)controller{
    
    if (![[GroupManager defaultManager] hasJoinedAGroup]) {
        POSTMSG2(NSLS(@"kCannotCreateContestPleaseJoinGroupFirst"), 2);
    }else{
        
        CreateContestController *vc = [[[CreateContestController alloc] init] autorelease];
//        [controller presentViewController:vc animated:YES completion:NULL];
        [controller.navigationController pushViewController:vc animated:YES];
    }
}

- (id)init{
    
    if (self = [super init]) {
        NSString *groupId = [[GroupManager defaultManager] userCurrentGroupId];
        self.contest = [Contest createGroupContestWithGroupId:groupId];

        [self.contest setAwardRules:@[@(5000), @(2000), @(1000), @(300), @(300),
                                    @(300),  @(300),  @(300),  @(300), @(300),
                                    @(300),  @(300),  @(300),  @(300), @(300),
                                    @(300),  @(300),  @(300),  @(300), @(300)]];
        
        self.isNewContest = YES;
    }
    
    return self;
}

+ (void)enterFromController:(PPViewController *)controller withContest:(Contest *)contest{
    
    CreateContestController *vc = [[[CreateContestController alloc] initWithContest:contest] autorelease];
//    [controller presentViewController:vc animated:YES completion:NULL];
    [controller.navigationController pushViewController:vc animated:YES];
}


- (id)initWithContest:(Contest *)contest{
    
    if (self = [super init]) {
        self.contest = contest;
        self.isNewContest = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [IQKeyBoardManager enableKeyboardManger];
    [self setDefaultBGImage];
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    if (self.isNewContest) {
        [v setTitle:NSLS(@"kCreateContest")];
    }else{
        [v setTitle:NSLS(@"kModifyContest")];
    }
    
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBack:)];
    [v setRightButtonTitle:NSLS(@"kDone")];
    [v setRightButtonSelector:@selector(clickDone:)];
    
    self.contestNameLabel.text = NSLS(@"kContestName");
    self.startTimeLabel.text = NSLS(@"kStartTime");
    self.endTimeLabel.text = NSLS(@"kEndTime");
    self.contestDescLabel.text = NSLS(@"kContestDesc");
    self.joinersLabel.text = NSLS(@"kContestJoiners");
    self.contestImageLabel.text = NSLS(@"kContestImage");
    self.contestAwardLabel.text = NSLS(@"kContestAward");
    
    
    UIToolbar* numberToolbar = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
//                           [[UIBarButtonItem alloc]initWithTitle:NSLS(@"kCancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                           [[[UIBarButtonItem alloc]initWithTitle:NSLS(@"kDone") style:UIBarButtonItemStyleDone target:self.contestDescTextView action:@selector(resignFirstResponder)] autorelease],
                           nil];
    [numberToolbar sizeToFit];
    self.contestDescTextView.inputAccessoryView = numberToolbar;
    
    self.contestNameInputField.returnKeyType = UIReturnKeyDone;
    self.contestNameInputField.delegate = self;    
    
    self.contestNameLabel.textColor = COLOR_BROWN;
    self.startTimeLabel.textColor = COLOR_BROWN;
    self.endTimeLabel.textColor = COLOR_BROWN;
    self.contestDescLabel.textColor = COLOR_BROWN;
    self.joinersLabel.textColor = COLOR_BROWN;
    self.contestImageLabel.textColor = COLOR_BROWN;
    self.contestAwardLabel.textColor = COLOR_BROWN;

    [self.startTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.startTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.endTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.endTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.joinerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.joinerButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.contestAwardButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.contestAwardButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [self.contestNameInputField.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.contestNameInputField.layer setMasksToBounds:YES];
    self.contestNameInputField.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.contestNameInputField.layer.borderColor = [COLOR_ORANGE CGColor];
    
    [self.startTimeButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.startTimeButton.layer setMasksToBounds:YES];
    self.startTimeButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.startTimeButton.layer.borderColor = [COLOR_ORANGE CGColor];
    
    [self.endTimeButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.endTimeButton.layer setMasksToBounds:YES];
    self.endTimeButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.endTimeButton.layer.borderColor = [COLOR_ORANGE CGColor];
    
    [self.contestDescTextView.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.contestDescTextView.layer setMasksToBounds:YES];
    self.contestDescTextView.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.contestDescTextView.layer.borderColor = [COLOR_YELLOW CGColor];
    
    [self.joinerButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.joinerButton.layer setMasksToBounds:YES];
    self.joinerButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.joinerButton.layer.borderColor = [COLOR_YELLOW CGColor];
    
    [self.contestImageButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.contestImageButton.layer setMasksToBounds:YES];
    self.contestImageButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.contestImageButton.layer.borderColor = [COLOR_YELLOW CGColor];
    
    [self.contestAwardButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.contestAwardButton.layer setMasksToBounds:YES];
    self.contestAwardButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.contestAwardButton.layer.borderColor = [COLOR_YELLOW CGColor];
    
    self.contestNameInputField.placeholder = NSLS(@"kInputContestName");
    [self.joinerButton setTitle:[self.contest joinersTypeString] forState:UIControlStateNormal];
    [self.contestAwardButton setTitle:[self.contest awardRulesShortDesc] forState:UIControlStateNormal];
    
    NSString *startDateString = dateToStringByFormat(self.contest.startDate, DATE_FORMAT);
    [self.startTimeButton setTitle:startDateString forState:UIControlStateNormal];
    
    NSString *endDateString = dateToStringByFormat(self.contest.endDate, DATE_FORMAT);
    [self.endTimeButton setTitle:endDateString forState:UIControlStateNormal];
    
    
    self.calendar = [[[CKCalendarView alloc] initWithStartDay:startMonday] autorelease];
    self.calendar.delegate = self;
    self.calendar.onlyShowCurrentMonth = YES;
    self.calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    if (ISIPAD) {
        self.calendar.frame = CGRectMake(134, 134, 500, 500);
    }else{
        self.calendar.frame = CGRectMake(10, 10, 300, 320);        
    }

    [self.calendar updateCenterY:CGRectGetHeight(self.view.bounds)/2];
    
    self.calendarDismissButton = [[[UIButton alloc] initWithFrame:self.view.bounds] autorelease];
    self.calendarDismissButton.backgroundColor = [UIColor blackColor];
    self.calendarDismissButton.alpha = 0.3;
    [self.calendarDismissButton addTarget:self action:@selector(dismissCalendar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.calendarDismissButton];
    
    self.calendarDismissButton.hidden = YES;
    
    self.contestNameInputField.text = [self.contest title];
    self.contestDescTextView.text = [self.contest desc];
    if ([self.contest contestUrl] != nil) {
        NSURL *url = [NSURL URLWithString:[self.contest contestUrl]];
        [self.contestImageButton setImageWithURL:url forState:UIControlStateNormal];
    }

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissCalendar{
    
    [self.calendar removeFromSuperview];
    self.calendarDismissButton.hidden = YES;

}

- (void)clickDone:(id)sender{
    
    if ([self.contestNameInputField.text isBlank]) {
        
        POSTMSG(NSLS(@"kContestNameCannotBeBlank"));
        return;
    }
    
    if (self.isNewContest && self.image == nil) {
        POSTMSG(NSLS(@"kPleaseSelectContestImage"));
        return;
    }
    
    if ([self.contest checkTotalAward] == NO){
        NSString* msg = [NSString stringWithFormat:NSLS(@"kContestTotalAwardNotEnough"), [Contest getMinGroupContestAward]];
        POSTMSG2(msg, 2);
        return;
    }

    int groupBalance = [[GroupManager defaultManager] sharedGroup].balance;
    int totalAward = [self.contest totalAward];
    if (totalAward > groupBalance){
        NSString* msg = [NSString stringWithFormat:NSLS(@"kGroupBalanceNotEnoughForContest"), groupBalance, totalAward];
        POSTMSG2(msg, 2);
        return;
    }
    
    [self.contest setTitle:self.contestNameInputField.text];
    [self.contest setDesc:self.contestDescTextView.text];
    
    
    CommonTitleView *titleView = [CommonTitleView titleView:self.view];
    [titleView hideRightButton];
    
    if (self.isNewContest) {
        [self showActivityWithText:NSLS(@"kCreatingContest")];
        [[ContestService defaultService] createContest:self.contest
                                                 image:self.image
                                             completed:^(int resultCode, Contest *contest) {
                                                 
            [self hideActivity];
            [titleView showRightButton];

            if (resultCode != 0) {
                 POSTMSG2(NSLS(@"kCreatingContestFail"), 2);
            }else{
                 POSTMSG2(NSLS(@"kCreateContestSuccess"), 2);
//                 [self dismissViewControllerAnimated:YES completion:NULL];
                [self finishController];
                 [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREATE_CONTEST_SUCCESS object:nil];
            }
        }];
    }else{
        
        [self showActivityWithText:NSLS(@"kUpdatingContest")];        
        [[ContestService defaultService] updateContest:self.contest image:self.image completed:^(int resultCode, Contest *contest) {
            
            [self hideActivity];
            [titleView showRightButton];
            
            if (resultCode != ERROR_SUCCESS) {
                NSString* msg = NSLS(@"kUpdateContestFail");
                if (resultCode == ERROR_CONTEST_CANNOT_UPDATE_AFTER_START){
                    msg = NSLS(@"kCannotUpdateStartContest");
                }

                POSTMSG2(msg, 2);
            }else{
                
                POSTMSG2(NSLS(@"kUpdateContestSuccess"), 2);
//                [self dismissViewControllerAnimated:YES completion:NULL];
                [self finishController];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CONTEST_SUCCESS object:nil];
            }
        }];
    }
}

#define CALENDAR_TAG_START_TIME 100
#define CALENDAR_TAG_END_TIME 101

- (IBAction)clickStartTimeButton:(id)sender {
    
//    [self.calendar setMinDate:nextDate([NSDate date])];
//    [self.calendar setMinDate:[NSDate date]];

//    [self.calendar setMaxDate:self.contest.endDate];
    self.calendar.tag = CALENDAR_TAG_START_TIME;
//    [self.calendar setSelectedDate:self.contest.startDate];
    [self.calendar selectDate:self.contest.startDate makeVisible:YES];
    [self.view addSubview:self.calendar];
    self.calendarDismissButton.hidden = NO;
    
    [self.contestNameInputField resignFirstResponder];
    [self.contestDescTextView resignFirstResponder];
}

- (IBAction)clickEndTimeButton:(id)sender {
    
//    [self.calendar setMinDate:self.contest.startDate];
    NSDate *maxDate = [NSDate dateWithTimeInterval:24*3600*45 sinceDate:[NSDate date]];
//    [self.calendar setMaxDate:maxDate];
    self.calendar.tag = CALENDAR_TAG_END_TIME;
    [self.calendar selectDate:self.contest.endDate makeVisible:YES];
//    [self.calendar setSelectedDate:self.contest.endDate];
    [self.view addSubview:self.calendar];
    self.calendarDismissButton.hidden = NO;
    
    [self.contestNameInputField resignFirstResponder];
    [self.contestDescTextView resignFirstResponder];
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date{

    if (calendar.tag == CALENDAR_TAG_START_TIME) {
        
        if ([date isAfterDay:[self.contest endDate]]) {
            POSTMSG2(NSLS(@"kStartDateCannotAfterEndDate"), 2);
            return;
        }
        
        [self.contest setStartDate:date];
        [self.contest setVoteStartDate:date];
        
        NSString *startDateString = dateToStringByFormat(self.contest.startDate, DATE_FORMAT);
        [self.startTimeButton setTitle:startDateString forState:UIControlStateNormal];
        
    }else if (calendar.tag == CALENDAR_TAG_END_TIME){
        
        if ([date isBeforeDay:[self.contest startDate]]) {
            POSTMSG2(NSLS(@"kEndDateCannotBeforeStartDate"), 2);
            return;
        }
        
        [self.contest setEndDate:date];
        [self.contest setVoteEndDate:nextDate(date)];
        
        NSString *endDateString = dateToStringByFormat(self.contest.endDate, DATE_FORMAT);
        [self.endTimeButton setTitle:endDateString forState:UIControlStateNormal];
    }

    [calendar removeFromSuperview];
    self.calendarDismissButton.hidden = YES;
}


- (IBAction)clickJoinersButton:(id)sender {
    
    BBSActionSheet *sheet = [[BBSActionSheet alloc] initWithTitles:[self.contest joinersTypeStringArray] callback:^(NSInteger index) {
        
        [self.contest setJoinersType:index];
        [self.joinerButton setTitle:[self.contest joinersTypeString] forState:UIControlStateNormal];
    }];
    
    [sheet showInView:self.view showAtPoint:self.view.center animated:YES];
    [sheet release];
}

- (IBAction)clickContestImageButton:(id)sender {
        
    if (self.picker == nil) {
        self.picker = [[[ChangeAvatar alloc] init] autorelease];
        [self.picker setImageSize:CGSizeZero];
        [self.picker setAutoRoundRect:NO];
        [self.picker setIsCompressImage:NO];
    }
    
    __block typeof(self) bself = self;
    [self.picker showSelectionView:self
                             title:NSLS(@"kContestImage")
                       otherTitles:nil
                           handler:NULL
                selectImageHanlder:^(UIImage *image) {
                    PPDebug(@"<selectImageHanlder> image size = %@", NSStringFromCGSize(image.size));
                    [bself showImageEditor:image];
//                    bself.image = image;
//                    [bself.contestImageButton setImage:image forState:UIControlStateNormal];
                    }
                      canTakePhoto:NO
                 userOriginalImage:YES];
    
}

- (void)showImageEditor:(UIImage *)image{
    
    CropAndFilterViewController *vc = [[CropAndFilterViewController alloc] init];
    [vc setCropAspectRatio:0.382];
    vc.delegate = self;
    vc.image = image;
    
//    [self presentViewController:vc animated:YES completion:NULL];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (void)cropViewController:(CropAndFilterViewController *)controller didFinishCroppingImage:(UIImage *)image{
    
//    [controller dismissViewControllerAnimated:YES completion:NULL];
    [controller.navigationController popViewControllerAnimated:YES];
    
    if (image != nil) {
        PPDebug(@"image selected, image size = %@", NSStringFromCGSize(image.size));
        
        self.image = image;
        [self.contestImageButton setImage:image forState:UIControlStateNormal];
    }
}

- (void)cropViewControllerDidCancel:(CropAndFilterViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)clickContestAwardButton:(id)sender {
    
    self.awardEditController = [[[ContestAwardEditController alloc] initWithContest:self.contest] autorelease];
//    [self presentViewController:self.awardEditController animated:YES completion:NULL];
    [self.navigationController pushViewController:self.awardEditController animated:YES];
    
    [self registerNotificationWithName:NotificationContestAwardEditDone
                            usingBlock:^(NSNotification *note) {
                               
                                [self contestAwardHasChanged];
                                
                            }];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contestAwardHasChanged) name:NotificationContestAwardEditDone object:nil];

}

- (void)contestAwardHasChanged{
    
//    [self.awardEditController dismissViewControllerAnimated:YES completion:NULL];
    [self.awardEditController.navigationController popViewControllerAnimated:YES];
    [self.contestAwardButton setTitle:[self.contest awardRulesShortDesc] forState:UIControlStateNormal];
    
    [self unregisterNotificationWithName:NotificationContestAwardEditDone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickBack:(id)sender{
    
    [IQKeyBoardManager disableKeyboardManager];
//    [self dismissViewControllerAnimated:YES completion:NULL];
    [self finishController];
}

- (void)finishController{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [IQKeyBoardManager disableKeyboardManager];
    [_contestNameLabel release];
    [_contestNameInputField release];
    [_startTimeLabel release];
    [_startTimeButton release];
    [_endTimeLabel release];
    [_endTimeButton release];
    [_contestDescLabel release];
    [_contestDescTextView release];
    [_joinersLabel release];
    [_joinerButton release];
    [_contestImageLabel release];
    [_contestImageButton release];
    
    [_contest release];
    [_calendar release];
    [_calendarDismissButton release];
    [_picker release];
    [_image release];
    [_contestAwardLabel release];
    [_contestAwardButton release];
    [_awardEditController release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setContestNameLabel:nil];
    [self setContestNameInputField:nil];
    [self setStartTimeLabel:nil];
    [self setStartTimeButton:nil];
    [self setEndTimeLabel:nil];
    [self setEndTimeButton:nil];
    [self setContestDescLabel:nil];
    [self setContestDescTextView:nil];
    [self setJoinersLabel:nil];
    [self setJoinerButton:nil];
    [self setContestImageLabel:nil];
    [self setContestImageButton:nil];
    [self setContestNameInputField:nil];
    [self setContestAwardLabel:nil];
    [self setContestAwardButton:nil];
    [super viewDidUnload];
}

@end
