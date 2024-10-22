//
//  MoreViewController.m
//  Draw
//
//  Created by ChaoSo on 14-7-14.
//
//

#import "MoreViewController.h"
#import "MoreViewCell.h"
#import "UIViewController+BGImage.h"
#import "HomeMenuView.h"
#import "SuperHomeController.h"
#import "ContestService.h"
#import "StatisticManager.h"
#import "UserManager.h"
#import "UIImageUtil.h"
#import "UIImageExt.h"

static NSArray* itemTypeArray = nil;
static dispatch_once_t onceToken;

@interface MoreViewController ()

@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define COLLECTION_VIEW_CELL_HEIGHT (ISIPAD ? 190:100)
#define COLLECTION_VIEW_CELL_WIDTH (ISIPAD ? 200:90)
#define COLLECTION_VIEW_CELL_MINIMUM_LINE_SPACING (ISIPAD ? 40:0)
#define TOP_LEADING (ISIPAD ? 10:0)

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // set title view
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kMoreView")];
    [[CommonTitleView titleView:self.view] setTarget:self]; 
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
    
    //流布局
    UICollectionViewFlowLayout *flowLayout = [[[UICollectionViewFlowLayout alloc] init] autorelease];
    [flowLayout setItemSize:CGSizeMake(COLLECTION_VIEW_CELL_WIDTH,COLLECTION_VIEW_CELL_HEIGHT)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:COLLECTION_VIEW_CELL_MINIMUM_LINE_SPACING];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:[CommonTitleView titleView:self.view]
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1.0
                                                                   constant:TOP_LEADING];
    
    [self.view addConstraint:constraint];
    //指定xib文件
    UINib *nib = [UINib nibWithNibName:@"MoreViewCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"MoreViewCell"];
    
    //背景
    [self setDefaultBGImage];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.collectionView reloadData];
    [super viewDidAppear:animated];
}

//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[MoreViewController getItemTypeArray] count];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //寻找到指定的cell identify
    NSString *customerIdentify = @"MoreViewCell";
    MoreViewCell *item = [collectionView dequeueReusableCellWithReuseIdentifier:customerIdentify forIndexPath:indexPath];
    
    [item setController:self];
    [item updateMoreCollectionCell:indexPath.row type:[MoreViewController getItemType:indexPath.row]];
    return item;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#define UI_EDGE_INSERTS_MAKE (ISIPAD ? 35 : 10)

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE, UI_EDGE_INSERTS_MAKE);
}


- (void)dealloc {
    [_collectionView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCollectionView:nil];
    [super viewDidUnload];
}

#pragma mark - Model Data

//取得更多界面的按钮
+ (NSArray*)getItemTypeArray
{
    dispatch_once(&onceToken
                  , ^{
                      itemTypeArray = @[@(SpecialTypeUser), @(SpecialTypeUserFriend),
                                        @(HomeMenuTypeGroup), @(HomeMenuTypeDrawContest),@(HomeMenuTypeDrawPainter),@(HomeMenuTypeDrawGame),@(HomeMenuTypeDrawGuess),@(HomeMenuTypeDrawBigShop),@(HomeMenuTypeTask),@(HomeMenuTypeDrawMore)
                                        //@(HomeMenuTypeDrawFreeCoins),
                                        ];
                      
                      [itemTypeArray retain];
                                        });
    return itemTypeArray;
}

+ (int)getItemType:(NSUInteger)row
{
    if (row >= [[self getItemTypeArray] count]){
        return nil;
    }
    
    NSNumber* type = [[self getItemTypeArray] objectAtIndex:row];
    if (type == nil){
        return -1;
    }
    
    return [type integerValue];
}

+ (UIImage*)getItemImage:(NSUInteger)row
{
    if (row >= [[self getItemTypeArray] count]){
        return nil;
    }

    NSNumber* type = [[self getItemTypeArray] objectAtIndex:row];
    if (type == nil){
        return nil;
    }
    
    if ([type intValue] == SpecialTypeUser){
        
        UIImage* image = [[UserManager defaultManager] avatarImage];
        if (image == nil){
            image = [[UserManager defaultManager] defaultAvatarImage];
        }
        
        image = [UIImage createRoundedRectImage:image size:image.size];
        return image;
    }
    
    return [[SuperHomeController defaultMenuImageDictionary] objectForKey:type];
}

+ (NSString*)getItemTitle:(NSUInteger)row
{
    if (row >= [[MoreViewController getItemTypeArray] count]){
        return nil;
    }
    
    NSNumber* type = [[self getItemTypeArray] objectAtIndex:row];
    if (type == nil){
        return nil;
    }
    
    return [[SuperHomeController defaultMenuTitleDictionary] objectForKey:type];

}

+ (SEL)getItemSelector:(NSUInteger)row
{
    if (row >= [[MoreViewController getItemTypeArray] count]){
        return nil;
    }
    
    NSNumber* type = [[self getItemTypeArray] objectAtIndex:row];
    if (type == nil){
        return nil;
    }
    
    NSString* name = [[SuperHomeController defaultMenuSelectorDictionary] objectForKey:type];
    if (name == nil){
        return nil;
    }
    
    return NSSelectorFromString(name);
}

+ (NSUInteger)totalMoreBadge
{
    int userBadge = [[UserManager defaultManager] getUserBadgeCount];
    int fanBadge = [[StatisticManager defaultManager] fanCount];
    int contestBadge = [[StatisticManager defaultManager] newContestCount];
    int groupBadge = [[StatisticManager defaultManager] groupNoticeCount];
    
    return userBadge + fanBadge + contestBadge + groupBadge;
}

+ (NSUInteger)getItemBadge:(NSUInteger)row
{
    if (row >= [[MoreViewController getItemTypeArray] count]){
        return nil;
    }
    
    NSNumber* type = [[self getItemTypeArray] objectAtIndex:row];
    if (type == nil){
        return 0;
    }
    
    switch ([type integerValue]) {
        case SpecialTypeUser:
            return [[UserManager defaultManager] getUserBadgeCount];

        case SpecialTypeUserFriend:
            return [[StatisticManager defaultManager] fanCount];

        case HomeMenuTypeDrawContest:
            return [[StatisticManager defaultManager] newContestCount];
            
        case HomeMenuTypeGroup:
            return [[StatisticManager defaultManager] groupNoticeCount];
            
        default:
            break;
    }
    
    return 0;
}

- (void)handleClickItem:(NSUInteger)row
{
    SEL selector = [MoreViewController getItemSelector:row];
    if (selector && [self respondsToSelector:selector]){
        [self performSelector:selector withObject:nil];
    }
}

@end
