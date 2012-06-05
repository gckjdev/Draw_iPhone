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

@interface SelectCustomWordView ()
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
    view.delegate = aDelegate;
    
    view.dataList = [[CustomWordManager defaultManager] findAllWords];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [view.closeButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    [view.closeButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    
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
    [self startRunOutAnimation];
}

#pragma mark -  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"selectCustomWordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    CustomWord *word = [dataList objectAtIndex:[indexPath row]];
    cell.textLabel.text = word.word;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self startRunOutAnimation];
    CustomWord *customWord = [dataList objectAtIndex:indexPath.row];
    NSString *word = customWord.word;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelecCustomWord:)]) {
        [self.delegate didSelecCustomWord:word];
    }
}

- (void)dealloc {
    [dataTableView release];
    [dataList release];
    [closeButton release];
    [super dealloc];
}
@end
