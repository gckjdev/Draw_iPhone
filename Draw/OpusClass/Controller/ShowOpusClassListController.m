//
//  ShowOpusClassListController.m
//  Draw
//
//  Created by qqn_pipi on 14-6-17.
//
//

#import "ShowOpusClassListController.h"
#import "OpusClassInfoManager.h"
#import "OpusClassInfo.h"
#import "OpusClassMenuItem.h"
#import "UIViewController+BGImage.h"

@interface ShowOpusClassListController ()

-(void)menuSetOrReset;
-(void)populateMenu;

@end

@implementation ShowOpusClassListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_menuView);
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self menuSetOrReset];

	// Do any additional setup after loading the view.
    [CommonTitleView createTitleView:self.view];
    [[CommonTitleView titleView:self.view] setTitle:NSLS(@"kOpusClassTitle")];
    [[CommonTitleView titleView:self.view] setTarget:self];
    [[CommonTitleView titleView:self.view] setBackButtonSelector:@selector(clickBack:)];
//    [[CommonTitleView titleView:self.view] setRightButtonSelector:@selector(clickSubmit:)];
//    [[CommonTitleView titleView:self.view] setRightButtonTitle:NSLS(@"kSubmitOpusClass")];
    
    [self setDefaultBGImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (CGFloat) gridView:(UIGridView *)grid widthForColumnAt:(int)columnIndex
//{
//	return 80;
//}
//
//- (CGFloat) gridView:(UIGridView *)grid heightForRowAt:(int)rowIndex
//{
//	return 80;
//}
//
//- (NSInteger) numberOfColumnsOfGridView:(UIGridView *) grid
//{
//	return 4;
//}
//
//
//- (NSInteger) numberOfCellsOfGridView:(UIGridView *) grid
//{
//	return 33;
//}
//
//- (UIGridViewCell *) gridView:(UIGridView *)grid cellForRowAt:(int)rowIndex AndColumnAt:(int)columnIndex
//{
//	Cell *cell = (Cell *)[grid dequeueReusableCell];
//	
//	if (cell == nil) {
//		cell = [[Cell alloc] init];
//	}
//	
//	cell.label.text = [NSString stringWithFormat:@"(%d,%d)", rowIndex, columnIndex];
//	
//	return cell;
//}
//
//- (void) gridView:(UIGridView *)grid didSelectRowAt:(int)rowIndex AndColumnAt:(int)colIndex
//{
//	NSLog(@"%d, %d clicked", rowIndex, colIndex);
//}

#define COLUMN_COUNT        4
#define COLUMN_MARGIN       15
#define COLUMN_HEIGHT       80

#define MENU_VIEW_TAG       20140617

// You need a method like this to setup your menu
-(void)menuSetOrReset {

    //Reset grid
    PPRelease(_menuView);
    
    //Set your grid options here. If this is a universal app, consider different settings for iPhone/iPad
    _menuView = [[THGridMenu alloc] initWithColumns:COLUMN_COUNT
                                         marginSize:COLUMN_MARGIN
                                         gutterSize:30
                                          rowHeight:COLUMN_HEIGHT
                 clickHandler:^(NSObject *menuItemRefObject) {
                     OpusClassInfo* info = (OpusClassInfo*)menuItemRefObject;
                     PPDebug(@"click menu %@", info.name);
                 }];
    
    //Do any customization of the grid container
    _menuView.backgroundColor = [UIColor clearColor];
    CGRect frame = self.view.frame;
    frame.origin.y = COMMON_TITLE_VIEW_HEIGHT + STATUS_BAR_HEIGHT;
    frame.size.height -= COMMON_TITLE_VIEW_HEIGHT + STATUS_BAR_HEIGHT;
    _menuView.frame = frame;
    
    //Replace the root view with the newly created grid container
    _menuView.tag = MENU_VIEW_TAG;
    [self.view addSubview:_menuView];
    
    //Call your method that will populate the grid
    [self populateMenu];
}

- (UIView*)menuView
{
    return [self.view viewWithTag:MENU_VIEW_TAG];
}

// You need a method like this that can iterate through your data source and create the menu items
-(void)populateMenu {
    
    NSArray* classList = [[OpusClassInfoManager defaultManager] opusClassList];
    
    //Iterate through the data source
    for (OpusClassInfo *classInfo in classList) {
        
        //Call createMenuItem to return a THGridMenuItem with origins and width preset.
        THGridMenuItem *menuItem = [_menuView createMenuItem];
        
        //Do any setup to the item view. Here we call a function defined in a category.
        [menuItem addTitle:classInfo.name];
        [menuItem setRefObject:classInfo];

        //Add the menu item to your grid view
        [[self menuView] addSubview:menuItem];
    }
}

//Call your menu reset method any time the view will appear
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


@end
