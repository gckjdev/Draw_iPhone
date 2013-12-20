//
//  CreateGroupController.m
//  Draw
//
//  Created by Gamy on 13-11-9.
//
//

#import "CreateGroupController.h"
#import "GroupManager.h"
#import "GroupService.h"
#import "UIManager.h"
#import "DrawError.h"
#import "BalanceNotEnoughAlertView.h"
#import "AccountManager.h"
#import "Group.pb.h"
#import "GroupTopicController.h"
#import "GroupDetailController.h"
#import "UIViewController+BGImage.h"

@interface CreateGroupController ()
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UIButton *levelButton;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UIPickerView *levelPicker;
@property (retain, nonatomic) IBOutlet UILabel *levelTips;
- (IBAction)clickLevelButton:(id)sender;

@end

@implementation CreateGroupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define NAME_MAX_LENGTH 16

- (void)clickDone:(id)sender
{
    [self.nameTextField resignFirstResponder];
    [self.levelPicker setHidden:YES];
    
    NSString *name = _nameTextField.text;
    NSInteger level = [_levelPicker selectedRowInComponent:0]+1;
    NSInteger fee = [GroupManager monthlyFeeForLevel:level];

    PPDebug(@"start to create group. name = %@, level = %d, fee = %d", name, level, fee);

    if ([name length] == 0) {
        [DrawError postErrorWithCode:ERROR_GROUP_NAME_EMPTY];
        return;
    }
    
    if ([name length] > NAME_MAX_LENGTH) {
        [DrawError postErrorWithCode:ERROR_GROUP_NAME_TOO_LONG];
        return;
    }
    
    if(![[AccountManager defaultManager] hasEnoughBalance:fee currency:PBGameCurrencyCoin]){
        [BalanceNotEnoughAlertView showInController:self];
    }
    
    [self showActivityWithText:NSLS(@"kCreatingGroup")];
    [[GroupService defaultService] createGroup:name level:level callback:^(PBGroup *group, NSError *error) {
        [self hideActivity];
        if (error) {
            [DrawError postError:error];
        }else{
            //Enter Group Detail Controller
            [[[GroupManager defaultManager] followedGroupIds] addObject:group.groupId];
            NSArray *controllers = [self.navigationController viewControllers];
            NSInteger length = [controllers count];
            PPViewController *superController = (id)controllers[length-2];
            [self.navigationController popViewControllerAnimated:NO];
            
            [GroupDetailController enterWithGroup:group fromController:superController];
            
//            [GroupTopicController enterWithGroup:group fromController:superController];
        }
    }];
}

#define BIG_FONT AD_FONT(32,18)
#define SMALL_FONT AD_FONT(18,12)

- (void)initViews
{
    [self setDefaultBGImage];
    //title
    [self.titleView setTitle:NSLS(@"kCreateGroup")];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setRightButtonTitle:NSLS(@"kDone")];
    [self.titleView setRightButtonSelector:@selector(clickDone:)];
    
    //name
    [self.nameLabel setTextColor:COLOR_BROWN];
    [self.nameTextField setTextColor:COLOR_BROWN];
    [self.nameLabel setFont:BIG_FONT];
    SET_INPUT_VIEW_STYLE(self.nameTextField);
    [self.nameLabel setText:NSLS(@"kName")];
    [self.nameTextField setPlaceholder:nil];
    //level
    [self.levelLabel setTextColor:COLOR_BROWN];
    [self.levelTips setTextColor:COLOR_BROWN];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.levelButton);
    [self.levelPicker setHidden:YES];
    [self.levelLabel setFont:BIG_FONT];
    [self.levelTips setFont:SMALL_FONT];
    [self.levelLabel setText:NSLS(@"kLevel")];
    [self.nameTextField becomeFirstResponder];
}


#define DEFAULT_LEVEL 10

- (void)initDefaultValues
{
    NSInteger defaultLevel = DEFAULT_LEVEL;
    [self.levelPicker selectRow:defaultLevel-1 inComponent:0 animated:NO];
    [self updateLevelViews:defaultLevel];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
    [self initDefaultValues];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_titleView release];
    [_nameLabel release];
    [_levelLabel release];
    [_levelButton release];
    [_nameTextField release];
    [_levelPicker release];
    [_levelTips release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleView:nil];
    [self setNameLabel:nil];
    [self setLevelLabel:nil];
    [self setLevelButton:nil];
    [self setNameTextField:nil];
    [self setLevelPicker:nil];
    [self setLevelTips:nil];
    [super viewDidUnload];
}

- (void)updateLevelViews:(NSInteger)level
{
    [self.levelButton setTitle:[@(level) stringValue] forState:UIControlStateNormal];

    NSInteger monthlyFee = [GroupManager monthlyFeeForLevel:level];
    NSInteger capacity = [GroupManager capacityForLevel:level];
    NSString *tips = [NSString stringWithFormat:NSLS(@"kLevelTips"), capacity, monthlyFee];
    [self.levelTips setText:tips];
    [self.levelTips sizeToFit];
}

#pragma mark- Picker Deleage

#define MAX_LEVEL 15

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return MAX_LEVEL;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [@(row+1) stringValue];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self updateLevelViews:row+1];
}

- (IBAction)clickLevelButton:(id)sender {
    if ([self.nameTextField isFirstResponder]) {
        [self.nameTextField resignFirstResponder];
    }
    [self.levelPicker setHidden:NO];
}
@end
