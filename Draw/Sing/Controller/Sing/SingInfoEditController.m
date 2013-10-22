//
//  SingInfoEditController.m
//  Draw
//
//  Created by 王 小涛 on 13-10-22.
//
//

#import "SingInfoEditController.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"

@interface SingInfoEditController () <UITextFieldDelegate, UITextViewDelegate>

@property (retain, nonatomic) Opus *opus;

@end

@implementation SingInfoEditController


- (void)dealloc {
    [_nameLabel release];
    [_nameTextField release];
    [_descLabel release];
    [_descTextView release];
    [_tagLabel release];
    [_opus release];
    [_comfirmButton release];
    [super dealloc];
}

- (id)initWithOpus:(Opus *)opus{
    
    if (self = [super init]) {
        self.opus = opus;
    }
    
    return self;
}

#define COMMON_TITLE_VIEW_TAG 20131022
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    v.tag = COMMON_TITLE_VIEW_TAG;
    [v setTitle:NSLS(@"kEditOpusInfo")];
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBackButton:)];
    [v setRightButtonTitle:NSLS(@"kCloseKeyboard")];
    [v setRightButtonSelector:@selector(clickCloseKeyBoard:)];
    [v hideRightButton];
    
    self.nameLabel.text = NSLS(@"kSubject");
    self.descLabel.text = NSLS(@"kDesc");
    self.tagLabel.text = NSLS(@"kTag");
    
    self.nameTextField.placeholder = NSLS(@"kSubjectPlaceholder");
    self.nameTextField.text = _opus.pbOpus.name;
    
    self.descTextView.placeholder = NSLS(@"kDescPlaceholder");
    self.descTextView.text = _opus.pbOpus.desc;
    
    
    SET_MESSAGE_LABEL_STYLE(self.nameLabel);
    SET_MESSAGE_LABEL_STYLE(self.descLabel);
    SET_MESSAGE_LABEL_STYLE(self.tagLabel);
    
    SET_INPUT_VIEW_STYLE(self.nameTextField);
    SET_INPUT_VIEW_STYLE(self.descTextView);
    
    [self.nameTextField becomeFirstResponder];
    self.nameTextField.returnKeyType = UIReturnKeyNext;
    self.nameTextField.delegate = self;
    self.descTextView.delegate = self;
    
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSString *tagString = [ConfigManager getSingTagList];
    NSArray *tagList = [tagString componentsSeparatedByString:@"$"];
    for (int index = 0; index < [tagList count]; index ++) {
        NSString *tag = [tagList objectAtIndex:index];
        UIButton *button = [self tagButtonWithTilte:tag tag:index];
        [self.view addSubview:button];
    }
    
    SET_BUTTON_ROUND_STYLE_YELLOW(self.comfirmButton);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameLabel:nil];
    [self setNameTextField:nil];
    [self setDescLabel:nil];
    [self setDescTextView:nil];
    [self setTagLabel:nil];
    [self setComfirmButton:nil];
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    CommonTitleView *v = (CommonTitleView *)[self.view viewWithTag:COMMON_TITLE_VIEW_TAG];
    [v showRightButton];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    CommonTitleView *v = (CommonTitleView *)[self.view viewWithTag:COMMON_TITLE_VIEW_TAG];
    [v hideRightButton];
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.nameTextField resignFirstResponder];
    [self.descTextView becomeFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    CommonTitleView *v = (CommonTitleView *)[self.view viewWithTag:COMMON_TITLE_VIEW_TAG];
    [v showRightButton];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    CommonTitleView *v = (CommonTitleView *)[self.view viewWithTag:COMMON_TITLE_VIEW_TAG];
    [v hideRightButton];
}

- (void)textViewDidChange:(UITextView *)textView{
    
    [self.opus setDesc:textView.text];
}

- (void)textFieldDidChange:(UITextField *)textField{
    
    if ([textField.text length] <= 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubjectPlaceCannotBlank") delayTime:1.5];
        return;
    }
    
    [self.opus setName:textField.text];
}

- (void)clickCloseKeyBoard:(id)sender{
    
    [self.nameTextField resignFirstResponder];
    [self.descTextView resignFirstResponder];
}

- (void)clickBackButton:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)clickComfirmButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIButton *)tagButtonWithTilte:(NSString *)title tag:(int)tag{
    
    CGFloat width = 70;
    CGFloat height = 35;
    
    CGFloat gapX = (self.descTextView.frame.size.width - 3 * width) / 2;
    CGFloat gapY = 48;
    
    CGFloat originX = self.descTextView.frame.origin.x + (tag % 3) * (width + gapX);
    CGFloat originY = self.tagLabel.frame.origin.y + (tag / 3) * gapY;
    
    CGRect frame = CGRectMake(originX, originY, width, height);
    
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = tag;
    [button addTarget:self action:@selector(clickTagButton:) forControlEvents:UIControlEventTouchUpInside];
    
    SET_BUTTON_ROUND_STYLE_GRAY(button);
    
    return button;
}

- (void)clickTagButton:(UIButton *)button{
    
    button.selected = !button.selected;
}

@end
