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

@interface MyWordsController ()

@end

@implementation MyWordsController
@synthesize titleLabel;
@synthesize editButton;
@synthesize addWordButton;

- (void)dealloc {
    PPRelease(titleLabel);
    PPRelease(editButton);
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
    
    [titleLabel setText:NSLS(@"kCustomWordManage")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [editButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [editButton setTitle:NSLS(@"kEdit") forState:UIControlStateNormal];
    [editButton setTitle:NSLS(@"kDone") forState:UIControlStateSelected];
    
    [addWordButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [addWordButton setTitle:NSLS(@"kAddCustomWord") forState:UIControlStateNormal];
    
    
    self.dataList = [[CustomWordManager defaultManager] findAllWords];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setEditButton:nil];
    [self setAddWordButton:nil];
    [super viewDidUnload];
}

#define MY_WORDS_CELL_HEIGHT_IPHONE 40.0
#define MY_WORDS_CELL_HEIGHT_IPAD   80.0
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DeviceDetection isIPAD]) {
        return MY_WORDS_CELL_HEIGHT_IPAD;
    }else {
        return MY_WORDS_CELL_HEIGHT_IPHONE;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"myWordsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier] autorelease];
    }
    
    CustomWord *word = [dataList objectAtIndex:[indexPath row]];
    cell.textLabel.text = word.word;
    return cell;
}


- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)clickAddWordButton:(id)sender {    
    InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kInputWord") delegate:self];
    inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    [inputDialog showInView:self.view];
}

#pragma mark - InputDialogDelegate
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if ([targetText length] > 0) {
        if (!NSStringIsValidChinese(targetText)){
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kIllegalCharacter"),targetText] delayTime:2 isHappy:NO];
        }else {
            [[CustomWordManager defaultManager] createCustomWordWithType:[NSNumber numberWithInt:WordTypeCustom] word:targetText language:[NSNumber numberWithInt:ChineseType] level:[NSNumber numberWithInt:WordLeveLMedium]];
            self.dataList = [[CustomWordManager defaultManager] findAllWords];
            [dataTableView reloadData];
        }
    }
}


@end
