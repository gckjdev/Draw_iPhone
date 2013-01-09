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

@property (retain, nonatomic) NSArray *dataList;
@end

@implementation SelectCustomWordView
@synthesize dataTableView;
@synthesize closeButton;
@synthesize dataList;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (SelectCustomWordView *)createView:(id<SelectCustomWordViewDelegate>)aDelegate;
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SelectCustomWordView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <SelectCustomWordView> but cannot find object from Nib");
        return nil;
    }
    SelectCustomWordView* view =  (SelectCustomWordView*)[topLevelObjects objectAtIndex:0];
    view.titleLabel.text = NSLS(@"kMyWords");
    [view.addWordButton setTitle:NSLS(@"kAddCustomWord") forState:UIControlStateNormal];
    view.delegate = aDelegate;
    
    view.dataList = [[CustomWordManager defaultManager] findAllWords];
    
    return view;
}

- (void)showInView:(UIView *)superview
{
    self.frame = superview.bounds;
    [superview addSubview:self];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:0.2 delegate:self removeCompeleted:NO];
    [self.layer addAnimation:runIn forKey:@"runIn"];
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

- (IBAction)clickCloseButton:(id)sender {
    if ([delegate respondsToSelector:@selector(didCloseSelectCustomWordView:)]) {
        [delegate didCloseSelectCustomWordView:self];
    }

    [self startRunOutAnimation];
}

#pragma mark -  UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SelectCustomWordCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCustomWordCell *cell = [tableView dequeueReusableCellWithIdentifier:[SelectCustomWordCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SelectCustomWordCell createCell:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CustomWord *word = [dataList objectAtIndex:[indexPath row]];
    
    [cell setWord:word.word];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    selectedRow = indexPath.row;
//    CustomWord *customWord = [dataList objectAtIndex:selectedRow];
//    NSString *word = customWord.word;
//    CommonDialog *dialog = [CommonDialog createDialogWithTitle:nil message:[NSString stringWithFormat:NSLS(@"kSureUseThisWord"),word] style:CommonDialogStyleDoubleButton delegate:self];
//    [dialog showInView:self];
    [self clickOk:nil];
}

- (void)clickOk:(CommonDialog *)dialog
{
    [self startRunOutAnimation];
    CustomWord *customWord = [dataList objectAtIndex:selectedRow];
    NSString *word = customWord.word;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecCustomWord:)]) {
        [self.delegate didSelecCustomWord:word];
    }
}

//- (void)clickBack:(CommonDialog *)dialog
//{
//    
//}

- (void)dealloc {
    PPRelease(dataTableView);
    PPRelease(dataList);
    PPRelease(closeButton);
    [_titleLabel release];
    [_addWordButton release];
    [super dealloc];
}


- (IBAction)clickAddWordButton:(id)sender {
    InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kInputWord") delegate:self];
    inputDialog.tag = INPUTDIALOG_ADD_WORD_TAG;
    inputDialog.targetTextField.placeholder = NSLS(@"kInputWordPlaceholder");
    [inputDialog showInView:self];
}

#pragma mark - InputDialogDelegate
- (void)didClickOk:(InputDialog *)dialog targetText:(NSString *)targetText
{
    if ([CustomWordManager isValidWord:targetText]) {
        [[CustomWordManager defaultManager] createCustomWord:targetText];
        [[UserService defaultService] commitWords:targetText viewController:nil];
        self.dataList = [[CustomWordManager defaultManager] findAllWords];
        [dataTableView reloadData];
    }
}

@end
