//
//  MyWordsController.m
//  Draw
//
//  Created by haodong qiu on 12年6月4日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "MyWordsController.h"
#import "CustomWord.h"
#import "CustomWordManager.h"
#import "DeviceDetection.h"
#import "StringUtil.h"
#import "UserManager.h"
#import "Word.h"
#import "CommonMessageCenter.h"
#import "ShareImageManager.h"
#import "UserService.h"

@interface MyWordsController ()
{
    NSInteger updateRow;
}

@end

@implementation MyWordsController

@synthesize addWordButton;

- (void)dealloc {

    PPRelease(addWordButton);
    [super dealloc];
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
    
    [addWordButton setTitle:NSLS(@"kAddCustomWord") forState:UIControlStateNormal];
    SET_BUTTON_ROUND_STYLE_YELLOW(addWordButton);
    
    
    self.dataList = [[CustomWordManager defaultManager] findAllWords];
    
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [v setTitle:NSLS(@"kCustomWordManage")];
    
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBack:)];
    [v setRightButtonTitle:NSLS(@"kEdit")];
    [v.rightButton setTitle:NSLS(@"kDone") forState:UIControlStateSelected];
    [v setRightButtonSelector:@selector(clickEditButton:)];
}

- (void)viewDidUnload
{
    [self setAddWordButton:nil];
    [super viewDidUnload];
}

#define MY_WORDS_CELL_HEIGHT_IPHONE 44.0
#define MY_WORDS_CELL_HEIGHT_IPAD   88.0
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DeviceDetection isIPAD]) {
        return MY_WORDS_CELL_HEIGHT_IPAD;
    }else {
        return MY_WORDS_CELL_HEIGHT_IPHONE;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if ([self.dataList count] == 0) {
        [self showTipsOnTableView:NSLS(@"kNoData")];
    }else{
        [self hideTipsOnTableView];
    }
    
    return [dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"myWordsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    CustomWord *word = [dataList objectAtIndex:[indexPath row]];
    cell.textLabel.text = word.word;
    cell.textLabel.textAlignment = UITextAlignmentCenter;
//    cell.textLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1.0];
    
    cell.textLabel.textColor = COLOR_BROWN;

    if ([DeviceDetection isIPAD]) {
        [cell.textLabel setFont:[UIFont systemFontOfSize:36]];
    }else {
        [cell.textLabel setFont:[UIFont systemFontOfSize:18]];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomWord *customWord = [dataList objectAtIndex:indexPath.row];
    [[CustomWordManager defaultManager] deleteWord:customWord.word];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:dataList];
    [mutableArray removeObjectAtIndex:indexPath.row];
    self.dataList = mutableArray;
    
    [dataTableView reloadData];
}


#define  INPUTDIALOG_UPDATE_TAG 120
#define  INPUTDIALOG_ADD_TAG    121
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    updateRow = indexPath.row;
    CustomWord *customWord = [dataList objectAtIndex:updateRow];
    
    
    CommonDialog *inputDialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kUpdateWord") delegate:self];
    inputDialog.tag = INPUTDIALOG_UPDATE_TAG;
    inputDialog.inputTextField.text = customWord.word;
    inputDialog.inputTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    
    [inputDialog showInView:self.view];
}

SET_CELL_BG_IN_CONTROLLER;

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickAddWordButton:(id)sender {    
    
    CommonDialog *inputDialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kInputWord") delegate:self];
    inputDialog.tag = INPUTDIALOG_ADD_TAG;
    inputDialog.inputTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    
    [inputDialog showInView:self.view];
}

- (IBAction)clickEditButton:(UIButton *)editButton {
    editButton.selected = !editButton.selected;
    if (editButton.selected) {
        [dataTableView setEditing:YES animated:YES];
    }else {
        [dataTableView setEditing:NO animated:YES];
    }
}

#pragma mark - InputDialogDelegate
- (void)didClickOk:(CommonDialog *)dialog infoView:(UITextField *)tf
{
    if ([tf.text length] == 0) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kInputWordEmpty"),tf.text] delayTime:2 isHappy:NO];
        return;
    }
    
    if ([tf.text length] > 7) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kWordTooLong"),tf.text] delayTime:2 isHappy:NO];
        return;
    }
    
    if (!NSStringIsValidChinese(tf.text)){
        [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kIllegalCharacter"),tf.text] delayTime:2 isHappy:NO];
        return;
    }
    
    
    if (dialog.tag == INPUTDIALOG_ADD_TAG) {
        if ([[CustomWordManager defaultManager] isExist:tf.text]) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kExistWord"),tf.text] delayTime:2 isHappy:NO];
            return;
        }
        [[CustomWordManager defaultManager] createCustomWordWithType:[NSNumber numberWithInt:PBWordTypeCustom] word:tf.text language:[NSNumber numberWithInt:ChineseType] level:[NSNumber numberWithInt:WordLeveLMedium]];
        
        [[UserService defaultService] commitWords:tf.text viewController:nil];
    }
    else if (dialog.tag == INPUTDIALOG_UPDATE_TAG){
        CustomWord *customWord = [dataList objectAtIndex:updateRow];
        if ([tf.text isEqualToString:customWord.word]) {
            return ;
        }else  if ([[CustomWordManager defaultManager] isExist:tf.text]) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kExistWord"),tf.text] delayTime:2 isHappy:NO];
            return;
        }
        [[CustomWordManager defaultManager] update:customWord.word newWord:tf.text];
        
        [[UserService defaultService] commitWords:tf.text viewController:nil];
    }
    
    self.dataList = [[CustomWordManager defaultManager] findAllWords];
    [dataTableView reloadData];

}


@end
