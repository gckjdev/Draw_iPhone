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

@interface CreateGroupController ()
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UIButton *levelButton;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UIPickerView *levelPicker;
@property (retain, nonatomic) IBOutlet UILabel *levelTips;

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

- (void)clickDone:(id)sender
{
    
    NSString *name = _nameLabel.text;
    NSInteger level = [_levelPicker selectedRowInComponent:0]+1;
    NSInteger fee = [GroupManager monthlyFeeForLevel:level];
    
    if ([name length] == 0) {
        [DrawError postErrorWithCode:ERROR_GROUP_NAME_EMPTY];
    }
    
    if([[AccountManager defaultManager] hasEnoughBalance:fee currency:PBGameCurrencyCoin]){
        [BalanceNotEnoughAlertView showInController:self];
    }
    
    PPDebug(@"start to create group. name = %@, level = %d, fee = %d", name, level, fee);
    
    [[GroupService defaultService] createGroup:_nameLabel level:level callback:^(PBGroup *group, NSError *error) {
        if (error) {
            [DrawError postError:error];
        }else{
            //Enter Group Detail Controller
        }
    }];
}

#define BIG_FONT AD_FONT(36,20)
#define SMALL_FONT AD_FONT(18,11)

- (void)initViews
{
    //title
    [self.titleView setTitle:NSLS(@"kCreateGroup")];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self.titleView setRightButtonTitle:NSLS(@"kDone")];
    [self.titleView setRightButtonSelector:@selector(clickDone:)];
    
    //name
    [self.nameLabel setTextColor:COLOR_BROWN];
    [self.nameTextField setTextColor:COLOR_BROWN];
    
    //level
    [self.levelLabel setTextColor:COLOR_BROWN];
    [self.levelTips setTextColor:COLOR_BROWN];
    SET_BUTTON_ROUND_STYLE_ORANGE(self.levelButton);    
}


#define DEFAULT_LEVEL 10

- (void)initDefaultValues
{
    NSInteger defaultLevel = DEFAULT_LEVEL;
    [self.levelPicker selectRow:defaultLevel-1 inComponent:0 animated:NO];

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

- (void)updateLevelTips:(NSInteger)level
{
    NSInteger monthlyFee = [GroupManager monthlyFeeForLevel:level];
    NSInteger capacity = [GroupManager capacityForLevel:level];
    NSString *tips = [NSString stringWithFormat:NSLS(@"kLevelTips"), capacity, monthlyFee];
    [self.levelTips setText:tips];
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
    [self.levelButton setTitle:[@(row+1) stringValue] forState:UIControlStateNormal];
}

@end
