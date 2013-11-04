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
    [_tagsHolderView release];
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
    [v hideBackButton];
    
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
    
//    [self.nameTextField becomeFirstResponder];
    self.nameTextField.returnKeyType = UIReturnKeyNext;
    self.nameTextField.delegate = self;
    self.descTextView.delegate = self;
    
    [self.nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    NSString *tagString = [ConfigManager getSingTagList];
    NSArray *tagList = [tagString componentsSeparatedByString:@"$"];
    for (int index = 0; index < [tagList count]; index ++) {
        NSString *tag = [tagList objectAtIndex:index];
        UIButton *button = [self tagButtonWithTilte:tag tag:index];
        [self.tagsHolderView addSubview:button];
    }
    
    for (int index = 0; index < [self.opus.pbOpus.tagsList count]; index ++) {
        NSString *tag = [self.opus.pbOpus.tagsList objectAtIndex:index];
        [self setTagButtonSelectWithTitle:tag];
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
    [self setTagsHolderView:nil];
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
    
    
    if ([self.nameTextField.text length] <= 0) {
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
    
    if ([self.nameTextField.text length] <= 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSubjectPlaceCannotBlank") delayTime:1.5];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KEY_NOTIFICATION_SING_INFO_CHANGE object:nil];
        
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIButton *)tagButtonWithTilte:(NSString *)title tag:(int)tag{
    
    CGFloat width =  ISIPAD ? 70*2.18 : 70;
    CGFloat height = ISIPAD ? 35*2.18 : 35;
    
    CGFloat gapX = (self.descTextView.frame.size.width - 3 * width) / 2;
    CGFloat gapY = ISIPAD ? 48*2.18 : 48;
    
    CGFloat originX = self.descTextView.frame.origin.x + (tag % 3) * (width + gapX);
    CGFloat originY = self.tagLabel.frame.origin.y + (tag / 3) * gapY;
    
    CGRect frame = CGRectMake(originX, originY, width, height);
    
    UIButton *button = [[[UIButton alloc] initWithFrame:frame] autorelease];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickTagButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [ShareImageManager setButtonStyle:button
                     normalTitleColor:COLOR_COFFEE
                   selectedTitleColor:COLOR_WHITE
                highlightedTitleColor:COLOR_WHITE
                                 font:FONT_BUTTON
                          normalColor:COLOR_YELLOW
                        selectedColor:COLOR_ORANGE
                     highlightedColor:COLOR_ORANGE
                                round:YES];
    
    return button;
}

- (void)setTagButtonSelectWithTitle:(NSString *)title{
    
    [self.tagsHolderView enumSubviewsWithClass:[UIButton class] handler:^(UIButton *button) {
        
        if ([title isEqualToString:[button titleForState:UIControlStateNormal]]) {
            button.selected = YES;
        }
    }];
}

- (void)clickTagButton:(UIButton *)button{
    
    button.selected = !button.selected;
    NSString *tag = [button titleForState:UIControlStateNormal];
    
    NSMutableArray *tags = [NSMutableArray arrayWithArray:self.opus.pbOpus.tagsList];
    BOOL contained = [tags containsObject:tag];
    
    if (button.selected && !contained) {
        
        [tags addObject:tag];
        [self.opus setTags:tags];
    }
    
    if (!button.selected && contained) {
        [tags removeObject:tag];
        [self.opus setTags:tags];
    }
}

@end
