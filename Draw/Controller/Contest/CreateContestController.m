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

@interface CreateContestController ()<CKCalendarDelegate, UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UILabel *contestNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *contestNameInputField;
@property (retain, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (retain, nonatomic) IBOutlet UIButton *startTimeButton;
@property (retain, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (retain, nonatomic) IBOutlet UIButton *endTimeButton;
@property (retain, nonatomic) IBOutlet UILabel *contestRuleLabel;
@property (retain, nonatomic) IBOutlet UITextView *contestRuleTextView;
@property (retain, nonatomic) IBOutlet UILabel *joinersLabel;
@property (retain, nonatomic) IBOutlet UIButton *joinerButton;
@property (retain, nonatomic) IBOutlet UILabel *contestImageLabel;
@property (retain, nonatomic) IBOutlet UIButton *contestImageButton;

@property (retain, nonatomic) Contest* contest;
@property (retain, nonatomic) CKCalendarView *calendar;
@property (retain, nonatomic) UIButton *calendarDismissButton;
@property (retain, nonatomic) ChangeAvatar *picker;
@property (retain, nonatomic) UIImage *image;
@end

@implementation CreateContestController

- (id)initWithGroupId:(NSString *)groupId{
    
    if (self = [super init]) {
        self.contest = [Contest createGroupContestWithGroupId:groupId];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [v setTitle:NSLS(@"kCreateContest")];
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBack:)];
    [v setRightButtonTitle:NSLS(@"kDone")];
    [v setRightButtonSelector:@selector(clickDone:)];
    
    self.contestNameLabel.text = NSLS(@"kContestName");
    self.startTimeLabel.text = NSLS(@"kStartTime");
    self.endTimeLabel.text = NSLS(@"kEndTime");
    self.contestRuleLabel.text = NSLS(@"kContestRules");
    self.joinersLabel.text = NSLS(@"kContestJoiners");
    self.contestImageLabel.text = NSLS(@"kContestImage");
    
    UIView *accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 30)];
    accessory.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(0, 0, 50, 30)];
    [doneButton setTitle:NSLS(@"kDone") forState:UIControlStateNormal];
    [accessory addSubview:doneButton];
    [doneButton updateCenterX:(CGRectGetWidth(self.view.bounds) - CGRectGetWidth(doneButton.bounds)/2)];
    [doneButton addTarget:self.contestRuleTextView action:@selector(resignFirstResponder) forControlEvents:UIControlEventTouchUpInside];
    self.contestRuleTextView.inputAccessoryView = accessory;
    
    self.contestNameInputField.returnKeyType = UIReturnKeyDone;
    self.contestNameInputField.delegate = self;
    
    [accessory release];
    
    self.contestNameLabel.textColor = COLOR_BROWN;
    self.startTimeLabel.textColor = COLOR_BROWN;
    self.endTimeLabel.textColor = COLOR_BROWN;
    self.contestRuleLabel.textColor = COLOR_BROWN;
    self.joinersLabel.textColor = COLOR_BROWN;
    self.contestImageLabel.textColor = COLOR_BROWN;

    [self.startTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.startTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.endTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.endTimeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [self.joinerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.joinerButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
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
    
    [self.contestRuleTextView.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.contestRuleTextView.layer setMasksToBounds:YES];
    self.contestRuleTextView.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.contestRuleTextView.layer.borderColor = [COLOR_YELLOW CGColor];
    
    [self.joinerButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.joinerButton.layer setMasksToBounds:YES];
    self.joinerButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.joinerButton.layer.borderColor = [COLOR_YELLOW CGColor];
    
    [self.contestImageButton.layer setCornerRadius:TEXT_VIEW_CORNER_RADIUS];
    [self.contestImageButton.layer setMasksToBounds:YES];
    self.contestImageButton.layer.borderWidth = TEXT_VIEW_BORDER_WIDTH;
    self.contestImageButton.layer.borderColor = [COLOR_YELLOW CGColor];
    
    self.contestNameInputField.placeholder = NSLS(@"kInputContestName");
    [self.joinerButton setTitle:[self.contest joinersTypeString] forState:UIControlStateNormal];
    
    NSString *startDateString = dateToStringByFormat(self.contest.startDate, DATE_FORMAT);
    [self.startTimeButton setTitle:startDateString forState:UIControlStateNormal];
    
    NSString *endDateString = dateToStringByFormat(self.contest.endDate, DATE_FORMAT);
    [self.endTimeButton setTitle:endDateString forState:UIControlStateNormal];
    
    
    self.calendar = [[CKCalendarView alloc] initWithStartDay:startMonday];
    self.calendar.delegate = self;
    self.calendar.onlyShowCurrentMonth = YES;
    self.calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    self.calendar.frame = CGRectMake(10, 10, 300, 320);

    [self.calendar updateCenterY:CGRectGetHeight(self.view.bounds)/2];
    
    self.calendarDismissButton = [[[UIButton alloc] initWithFrame:self.view.bounds] autorelease];
    self.calendarDismissButton.backgroundColor = [UIColor blackColor];
    self.calendarDismissButton.alpha = 0.3;
    [self.calendarDismissButton addTarget:self action:@selector(dismissCalendar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.calendarDismissButton];
    
    self.calendarDismissButton.hidden = YES;
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
    
    if (self.image == nil) {
        POSTMSG(NSLS(@"kPleaseSelectContestImage"));
        return;
    }
    
    [[ContestService defaultService] createContest:self.contest
                                             image:self.image
                                         completed:^(int resultCode, Contest *contest) {
        
    }];
}

#define CALENDAR_TAG_START_TIME 100
#define CALENDAR_TAG_END_TIME 101

- (IBAction)clickStartTimeButton:(id)sender {
    
    [self.calendar setMinDate:nextDate([NSDate date])];
    [self.calendar setMaxDate:self.contest.endDate];
    self.calendar.tag = CALENDAR_TAG_START_TIME;
    [self.calendar setSelectedDate:self.contest.startDate];
    [self.view addSubview:self.calendar];
    self.calendarDismissButton.hidden = NO;
}

- (IBAction)clickEndTimeButton:(id)sender {
    
    [self.calendar setMinDate:self.contest.startDate];
    NSDate *maxDate = [NSDate dateWithTimeInterval:24*3600*14 sinceDate:[NSDate date]];
    [self.calendar setMaxDate:maxDate];
    self.calendar.tag = CALENDAR_TAG_END_TIME;
    [self.calendar setSelectedDate:self.contest.endDate];
    [self.view addSubview:self.calendar];
    self.calendarDismissButton.hidden = NO;
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date{
    

    if (calendar.tag == CALENDAR_TAG_START_TIME) {
        
        [self.contest setStartDate:date];
        
        NSString *startDateString = dateToStringByFormat(self.contest.startDate, DATE_FORMAT);
        [self.startTimeButton setTitle:startDateString forState:UIControlStateNormal];
        
    }else if (calendar.tag == CALENDAR_TAG_END_TIME){
        
        [self.contest setEndDate:date];
        
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
    }
    
    __block typeof(self) bself = self;
    [self.picker showSelectionView:self
                             title:NSLS(@"kContestImage")
                       otherTitles:nil
                           handler:NULL
                selectImageHanlder:^(UIImage *image) {
                    bself.image = image;
                    [bself.contestImageButton setImage:image forState:UIControlStateNormal];
                    }
                      canTakePhoto:NO
                 userOriginalImage:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_contestNameLabel release];
    [_contestNameInputField release];
    [_startTimeLabel release];
    [_startTimeButton release];
    [_endTimeLabel release];
    [_endTimeButton release];
    [_contestRuleLabel release];
    [_contestRuleTextView release];
    [_joinersLabel release];
    [_joinerButton release];
    [_contestImageLabel release];
    [_contestImageButton release];
    
    [_contest release];
    [_calendar release];
    [_calendarDismissButton release];
    [_picker release];
    [_image release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setContestNameLabel:nil];
    [self setContestNameInputField:nil];
    [self setStartTimeLabel:nil];
    [self setStartTimeButton:nil];
    [self setEndTimeLabel:nil];
    [self setEndTimeButton:nil];
    [self setContestRuleLabel:nil];
    [self setContestRuleTextView:nil];
    [self setJoinersLabel:nil];
    [self setJoinerButton:nil];
    [self setContestImageLabel:nil];
    [self setContestImageButton:nil];
    [self setContestNameInputField:nil];
    [super viewDidUnload];
}

@end
