//
//  ColorBox.m
//  Draw
//
//  Created by gamy on 12-12-28.
//
//

#import "ColorBox.h"
#import "DrawColor.h"
#import "DrawColorManager.h"

#define VALUE(x) (ISIPAD?(2*x):x)
#define SPACE_POINT_POINT (ISIPAD ? 7.0  : 3.65)
#define CELL_HEIGHT VALUE(35)
#define DISPLAY_MAX_ROW 5

#define COLOR_NUMBER_FOR_ROW 10

@interface ColorBox ()
{
    DrawColorManager *drawColorManager;
}

@property (retain, nonatomic) IBOutlet UIView *defaultColorView;

@property (retain, nonatomic) IBOutlet UIView *defaultColorView2;

@property (retain, nonatomic) IBOutlet UITableView *colorTableView;
@property (assign, nonatomic) NSInteger colorRow;
- (IBAction)clickCloseButton:(id)sender;
- (IBAction)clickMoreButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;
@property (retain, nonatomic) IBOutlet UIButton *moreButton;


@end

@implementation ColorBox

- (void)dealloc {
    PPDebug(@"%@ dealloc",self);
    self.delegate = nil;
    PPRelease(_defaultColorView);
    PPRelease(_colorTableView);
    PPRelease(_closeButton);
    PPRelease(_moreButton);
    PPRelease(_defaultColorView2);
    [super dealloc];
}


//- (NSArray *)rankColorList:(NSInteger)number
//{
//    NSMutableArray *list = [NSMutableArray arrayWithCapacity:number];
//    int i = 0;
//    while (i++ < number) {
//        [list addObject:[DrawColor rankColor]];
//    }
//    return list;
//}


- (void)updateView:(UIView *)view addColorList:(NSArray *)list
{
    //reomove old views
    for (ColorPoint *point in view.subviews) {
        if ([point isKindOfClass:[ColorPoint class]]) {
            point.delegate = nil;
            [point removeFromSuperview];
        }
    }
    NSInteger i = 0;
    
    for (DrawColor *color in list) {
        ColorPoint *point = [ColorPoint pointWithColor:color];
        CGFloat pWidth = CGRectGetWidth(point.bounds);
        CGFloat x = (pWidth/2.0) + i*(pWidth + SPACE_POINT_POINT);

        CGFloat y = CGRectGetMidY(view.bounds);
        point.center = CGPointMake(x, y);
        PPDebug(@"view.bounds = %@, center = %@", NSStringFromCGRect(view.bounds), NSStringFromCGPoint(point.center));
        
        point.delegate = self;
        ++ i;
        [view addSubview:point];
    }
    //add new views
}


- (void)updateView
{
    drawColorManager = [DrawColorManager sharedDrawColorManager];
    NSInteger count = [[drawColorManager boughtColorList] count];
    self.colorRow = count / COLOR_NUMBER_FOR_ROW;
    if (count % COLOR_NUMBER_FOR_ROW != 0) {
        self.colorRow ++;
    }
    NSArray *recentList = [[DrawColorManager sharedDrawColorManager]
                           recentColorList];
    NSArray *list1 = [recentList subarrayWithRange:NSMakeRange(0, COLOR_NUMBER_FOR_ROW)];
    
    NSInteger length = MIN(COLOR_NUMBER_FOR_ROW, (recentList.count - COLOR_NUMBER_FOR_ROW));
    
    NSArray *list2 = [recentList subarrayWithRange:NSMakeRange(COLOR_NUMBER_FOR_ROW, length)];
    
    [self updateView:self.defaultColorView addColorList:list1];
    [self updateView:self.defaultColorView2 addColorList:list2];
    
    //resize tableView size
    NSInteger row = MIN(DISPLAY_MAX_ROW, self.colorRow);
    CGFloat tableHeight = row * CELL_HEIGHT;
    CGFloat viewHeiht = self.colorTableView.frame.origin.y + tableHeight;
    //update view height
    CGRect frame = self.frame;
    frame.size.height = viewHeiht;
    self.frame = frame;
    
    [self.closeButton setTitle:NSLS(@"kClose") forState:UIControlStateNormal];
    [self.moreButton setTitle:NSLS(@"kMoreColor") forState:UIControlStateNormal];
    
    
    if ([GameApp hasAllColorGroups]) {
        [self.moreButton setHidden:YES];
        self.closeButton.center = self.moreButton.center;
    }
}

+ (id)createViewWithdelegate:(id)delegate
{
    NSString *identifier = @"ColorBox";
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier
                                                             owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", identifier);
        return nil;
    }
    ColorBox  *view = (ColorBox *)[topLevelObjects objectAtIndex:0];
    view.delegate = delegate;

    PPDebug(@"<createViewWithdelegate> color row = %d", view.colorRow);
    [view updateView];
    return view;
}

- (IBAction)clickCloseButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickCloseButtonOnColorBox:)]) {
        [self.delegate didClickCloseButtonOnColorBox:self];
    }
}

- (IBAction)clickMoreButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickMoreButtonOnColorBox:)]) {
        [self.delegate didClickMoreButtonOnColorBox:self];
    }
}

#pragma mark tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _colorRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"colorBoxTableViewIdetifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), CELL_HEIGHT);
    }
    NSUInteger offset = indexPath.row * COLOR_NUMBER_FOR_ROW;
    NSArray *list = [drawColorManager boughtColorListWithOffset:offset limit:COLOR_NUMBER_FOR_ROW];
    PPDebug(@"Cell Row = %d",indexPath.row);
    [self updateView:cell.contentView addColorList:list];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}


#pragma mark - ColorPoint delegate

- (void)didSelectColorPoint:(ColorPoint *)colorPoint
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(colorBox:didSelectColor:)]) {
        [self.delegate colorBox:self didSelectColor:colorPoint.color];
    }
}
@end
