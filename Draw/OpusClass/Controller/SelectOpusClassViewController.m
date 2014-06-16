//
//  SelectOpusClassViewController.m
//  ifengNewsOrderDemo
//
//  Created by zer0 on 14-2-27.
//  Copyright (c) 2014年 zer0. All rights reserved.
//

#import "SelectOpusClassViewController.h"
#import "OpusClassInfo.h"
#import "ClassTagView.h"
#import "ClassTagButton.h"
#import "SelectTagHeader.h"
#import "OpusClassInfoManager.h"
#import "UIViewController+BGImage.h"

@interface SelectOpusClassViewController ()

@end

@implementation SelectOpusClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSelectedTags:(NSArray*)selectedTags arrayForSelection:(NSArray*)arrayForSelection
{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.modelArr1 = selectedTags;
        self.modelArrayForSelect = arrayForSelection;
    }
    return self;
}

- (NSMutableArray*)getTagsForSelection:(NSArray*)selectedArray
{
    NSMutableArray* retArray = [NSMutableArray array];
    
    OpusClassInfoManager* manager = [OpusClassInfoManager defaultManager];
    NSMutableArray* all = nil;
    if ([self.modelArrayForSelect count] == 0){
        all = manager.opusClassList;
    }
    else{
        all = [NSMutableArray arrayWithArray:self.modelArrayForSelect];
    }
    
    [retArray addObjectsFromArray:all];
    
    NSMutableArray* toBeRemoved = [NSMutableArray array];
    for (OpusClassInfo* info in retArray){
        for (OpusClassInfo* selected in selectedArray){
            if ([selected.classId isEqualToString:info.classId]){
                [toBeRemoved addObject:info];
            }
        }
    }

    // remove selected tags
    [retArray removeObjectsInArray:toBeRemoved];
    return retArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"设置分类")];
    
    [self setDefaultBGImage];
    
    // load model
    NSArray * modelArr2 = [self getTagsForSelection:self.modelArr1];
    
    _viewArr1 = [[NSMutableArray alloc] init];
    _viewArr2 = [[NSMutableArray alloc] init];
    
    CGPoint center;
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, TAG_LABEL_START_Y, LABEL_WIDTH, LABEL_HEIGHT)];
    _titleLabel.text = @"已选择标签";
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setTextColor:TAG_LABEL_TEXT_COLOR];
    [_titleLabel setBackgroundColor:TAG_LABEL_BG_COLOR];
    [_titleLabel setFont:TAG_LABEL_FONT_SIZE];
    
    center = _titleLabel.center;
    center.x = self.view.center.x;
    [_titleLabel setCenter:center];
    
    [self.view addSubview:_titleLabel];
    
    int array2StartY = [self array2StartY];

    
    _titleLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(110, KTableStartPointY + KButtonHeight * (array2StartY - 1), LABEL_WIDTH, LABEL_HEIGHT)];
    _titleLabel2.text = @"请选择作品分类";
    [_titleLabel2 setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel2 setTextColor:TAG_LABEL_TEXT_COLOR];
    [_titleLabel2 setBackgroundColor:TAG_LABEL_BG_COLOR];
    [_titleLabel2 setFont:TAG_LABEL_FONT_SIZE];

    center = _titleLabel2.center;
    center.x = self.view.center.x;
    [_titleLabel2 setCenter:center];

    [self.view addSubview:_titleLabel2];
    
    
    for (int i = 0; i < _modelArr1.count; i++) {
        ClassTagView * touchView = [[ClassTagView alloc] initWithFrame:CGRectMake(KTableStartPointX + KButtonWidth * (i%COLUMN_PER_ROW), KTableStartPointY + KButtonHeight * (i/COLUMN_PER_ROW), KButtonWidth, KButtonHeight)];

//        [touchView setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];
//        [touchView setBackgroundColor:[UIColor clearColor]];
        
        [_viewArr1 addObject:touchView];
        [touchView release];
        touchView->_array = _viewArr1;
//        if (i == 0) {
//            [touchView.label setTextColor:[UIColor colorWithRed:187/255.0 green:1/255.0 blue:1/255.0 alpha:1.0]];
//        }
//        else{
//            
//            [touchView.label setTextColor:[UIColor colorWithRed:99/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]];
//        }
        touchView.label.text = [[_modelArr1 objectAtIndex:i] title];
        [touchView.label setTextAlignment:NSTextAlignmentCenter];
        [touchView setMoreChannelsLabel:_titleLabel2];
        touchView->_viewArr11 = _viewArr1;
        touchView->_viewArr22 = _viewArr2;
        [touchView setTouchViewModel:[_modelArr1 objectAtIndex:i]];
        
        [self.view addSubview:touchView];
    }
    
    for (int i = 0; i < modelArr2.count; i++) {
        ClassTagView * touchView = [[ClassTagView alloc] initWithFrame:CGRectMake(KTableStartPointX + KButtonWidth * (i%COLUMN_PER_ROW), KTableStartPointY + array2StartY * KButtonHeight + KButtonHeight * (i/COLUMN_PER_ROW), KButtonWidth, KButtonHeight)];
        
//        [touchView setBackgroundColor:[UIColor colorWithRed:210/255.0 green:210/255.0 blue:210/255.0 alpha:1.0]];

//        [touchView setBackgroundColor:[UIColor clearColor]];
        
        [_viewArr2 addObject:touchView];
        touchView->_array = _viewArr2;
        
        touchView.label.text = [[modelArr2 objectAtIndex:i] title];
//        [touchView.label setTextColor:TAG_BUTTON_TEXT_COLOR];
        [touchView.label setTextAlignment:NSTextAlignmentCenter];
        [touchView setMoreChannelsLabel:_titleLabel2];
        touchView->_viewArr11 = _viewArr1;
        touchView->_viewArr22 = _viewArr2;
        [touchView setTouchViewModel:[modelArr2 objectAtIndex:i]];
        
        [self.view addSubview:touchView];
        
        [touchView release];
        
    }
    
    

    

    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:CGRectMake(self.view.bounds.size.width - 56, self.view.bounds.size.height - 44, 56, 44)];
    [self.backButton setImage:[UIImage imageNamed:@"order_back.png"] forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@"order_back_select.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.backButton];
}

- (void)dealloc{
    [_backButton release];
    [_titleArr release];
    [_urlStringArr release];
    [_titleLabel2 release];
    [_titleLabel release];
    [_viewArr1 release];
    [_viewArr2 release];
    [super dealloc];
}


- (unsigned long )array2StartY{
    
    unsigned long y = 0;

    y = _modelArr1.count/COLUMN_PER_ROW + 2;
    if (_modelArr1.count%COLUMN_PER_ROW == 0) {
        y -= 1;
    }
    return y;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
