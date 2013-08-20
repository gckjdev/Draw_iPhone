//
//  SelectCustomWordView.m
//  Draw
//
//  Created by haodong qiu on 12年6月5日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "SelectCustomWordView.h"
#import "AnimationManager.h"
#import "CustomWordManager.h"
#import "CustomWord.h"
#import "ShareImageManager.h"
#import "DeviceDetection.h"
#import "PPDebug.h"
#import "CommonMessageCenter.h"
#import "UserService.h"
#import "StringUtil.h"
#import "SelectCustomWordCell.h"

#define INPUTDIALOG_ADD_WORD_TAG 200

@interface SelectCustomWordView ()
{
    NSInteger selectedRow;
}

@property (retain, nonatomic) NSMutableArray *dataList;
@end

@implementation SelectCustomWordView

- (void)dealloc {
    PPRelease(_dataTableView);
    PPRelease(_dataList);
    [_addWordButton release];
    [super dealloc];
}

+ (SelectCustomWordView *)createView:(id<SelectCustomWordViewDelegate>)aDelegate;
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SelectCustomWordView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <SelectCustomWordView> but cannot find object from Nib");
        return nil;
    }
    SelectCustomWordView* view =  (SelectCustomWordView*)[topLevelObjects objectAtIndex:0];
    [view.addWordButton setTitle:NSLS(@"kAddCustomWord") forState:UIControlStateNormal];

    SET_VIEW_ROUND_CORNER(view.addWordButton);
    view.addWordButton.backgroundColor = COLOR_YELLOW;
    [view.addWordButton setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
    
    view.delegate = aDelegate;
    
    view.dataList = [NSMutableArray arrayWithArray:[[CustomWordManager defaultManager] wordsFromCustomWords]];
    
    return view;
}


- (void)startRunOutAnimation
{
    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.1 duration:0.2 delegate:self removeCompeleted:NO];
    [runOut setValue:@"closeSelectCustom" forKey:@"AnimationKey"];
    [self.layer addAnimation:runOut forKey:@"closeSelectCustom"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"closeSelectCustom"]) {
        [self setHidden:YES];
        [self removeFromSuperview];
    }
    [self.layer removeAllAnimations];
}

#pragma mark -  UITableViewDataSource

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row % 2 == 0) {                       
        cell.backgroundColor = COLOR_GRAY;              
    }else{                                              
        cell.backgroundColor = COLOR_WHITE;             
    }                                                   
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SelectCustomWordCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCustomWordCell *cell = [tableView dequeueReusableCellWithIdentifier:[SelectCustomWordCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SelectCustomWordCell createCell:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    Word *word = [_dataList objectAtIndex:[indexPath row]];
    
    [cell setWord:word.text];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    selectedRow = indexPath.row;
    [self didClickOk:nil infoView:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Word *word = [_dataList objectAtIndex:indexPath.row];
    [[CustomWordManager defaultManager] deleteWord:word.text];
    
    [_dataList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didClickOk:(CommonDialog *)dialog infoView:(UITextField *)tf
{
    if (dialog.tag == INPUTDIALOG_ADD_WORD_TAG) {
        if ([CustomWordManager isValidWord:tf.text]) {
            [[CustomWordManager defaultManager] createCustomWord:tf.text];
            [[UserService defaultService] commitWords:tf.text viewController:nil];
            Word *word = [Word cusWordWithText:tf.text];
            [self.dataList addObject:word];
            [_dataTableView reloadData];
        }
    }else{
        [self startRunOutAnimation];
        Word *customWord = [_dataList objectAtIndex:selectedRow];
        NSString *word = customWord.text;
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecCustomWord:)]) {
            [self.delegate didSelecCustomWord:word];
        }
    }
}

- (IBAction)clickAddWordButton:(id)sender {
    
    CommonDialog *inputDialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kInputWord") delegate:self];
    inputDialog.tag = INPUTDIALOG_ADD_WORD_TAG;
    inputDialog.inputTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    
    [inputDialog showInView:[UIApplication sharedApplication].keyWindow];
}

@end
