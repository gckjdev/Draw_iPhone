//
//  DrawHomeHeaderPanel.m
//  Draw
//
//  Created by Gamy on 13-9-15.
//
//

#import "DrawHomeHeaderPanel.h"
#import "UIButton+WebCache.h"

@interface DrawHomeHeaderPanel()
{
    
}

@end

@implementation DrawHomeHeaderPanel

#define ISCLOSE (DrawHeaderPanelStatusClose==self.status)

#define CELL_WIDTH (ISCLOSE?230:290)
#define SPACE (ISIPAD?14:10)
#define NUMBER_PERROW 3
#define CELL_HEIGHT (ISCLOSE?70:90)

#define OPUS_WIDTH (CELL_WIDTH-NUMBER_PERROW*SPACE)/NUMBER_PERROW
#define OPUS_SIZE CGSizeMake(OPUS_WIDTH,OPUS_WIDTH)
#define TAG_BASE 100



+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    DrawHomeHeaderPanel *panel = [self createViewWithXibIdentifier:[self getViewIdentifier]];
    panel.delegate = delegate;
    [panel updateView];
    return panel;
}
+ (NSString *)getViewIdentifier
{
    return @"DrawHomeHeaderPanel";
}

- (UIImage *)createSnapshot
{
    UIView *contentView = [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] contentView];
    if (contentView) {
        UIImage *image = nil;
        UIGraphicsBeginImageContext(contentView.bounds.size);
        [contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    return nil;
}

- (void)reloadView
{
    if (self.status == DrawHeaderPanelStatusClose) {
        [self.tableView reloadData];
    }else if(self.status == DrawHeaderPanelStatusOpen){
        [self.tableView reloadData];
    }else {
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:2.1];
    }
}

- (void)didGetFeedList:(NSArray *)feedList feedListType:(FeedListType)type resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        self.opusList = feedList;
        [self reloadView];
    }
}
- (void)updateView
{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.status = DrawHeaderPanelStatusClose;
    [self updateFrameForClose];
    self.opusList = [[FeedService defaultService] getCachedFeedList:FeedListTypeHot];
    [[FeedService defaultService] getFeedList:FeedListTypeHot offset:0 limit:18 delegate:self];
}


- (void)updateFrameForOpen
{
    self.frame = CGRectMake(0, 0, 320, 125+3*CELL_HEIGHT);
    self.holderView.frame = CGRectMake(5, 0, 310, 120+(3*CELL_HEIGHT));
}

- (void)updateFrameForClose
{
    self.frame = CGRectMake(0, 0, 320, 105);
    self.holderView.frame = CGRectMake(35, 0, 250, 100);
}

- (void)openAnimated:(BOOL)animated
{
    
    void (^completion)(BOOL)  = ^(BOOL finished){
        self.status = DrawHeaderPanelStatusOpen;
        [self reloadView];
    };
    if (animated) {
        self.status = DrawHeaderPanelStatusAnimating;

        void (^animation)(void)  = ^{
            [self updateFrameForOpen];
        };
        [UIView animateWithDuration:2 animations:animation completion:completion];
    }else{
        [self updateFrameForOpen];
        completion(YES);
    }
}
- (void)closeAnimated:(BOOL)animated
{
    void (^completion)(BOOL)  = ^(BOOL finished){
        self.status = DrawHeaderPanelStatusClose;
        [self reloadView];
    };
    if (animated) {
        self.status = DrawHeaderPanelStatusAnimating;
        void (^animation)(void)  = ^{
            [self updateFrameForClose];
        };
        [UIView animateWithDuration:2 animations:animation completion:completion];
    }else{
        [self updateFrameForClose];
        completion(YES);
    }
}

- (void)dealloc {
    [_bgView release];
    [_tableView release];
    [_displayHolder release];
    [_rope release];
    [_holderView release];
    [super dealloc];
}


#pragma mark- Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.status == DrawHeaderPanelStatusClose) {
        return 1;
    }
    return 4;
}   




- (void)updateCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    
    
    CGRect defaultFrame = CGRectMake(0, 0, OPUS_SIZE.width, OPUS_SIZE.height);
    PPDebug(@"opus size = %@", NSStringFromCGSize(OPUS_SIZE));
    for (NSInteger tag = TAG_BASE; tag < TAG_BASE+NUMBER_PERROW; ++ tag) {
        UIButton *button = (id)[cell.contentView viewWithTag:tag];
        if (button == nil) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [button addTarget:self action:@selector(clickOpus:) forControlEvents:UIControlEventTouchUpInside];
            SET_VIEW_ROUND_CORNER(button);
            [cell.contentView addSubview:button];
//            button.autoresizingMask =
//                                        UIViewAutoresizingFlexibleLeftMargin|
//                                        UIViewAutoresizingFlexibleWidth|
//                                        UIViewAutoresizingFlexibleRightMargin|
//                                        UIViewAutoresizingFlexibleTopMargin|
//                                        UIViewAutoresizingFlexibleHeight|
//                                    UIViewAutoresizingFlexibleBottomMargin;
        }
        button.tag = tag;
        button.frame = defaultFrame;
        [button updateOriginX:(SPACE/2+(tag-TAG_BASE)*(SPACE+OPUS_SIZE.width))];
        [button updateOriginY:(CELL_HEIGHT-OPUS_SIZE.height)/2];
        NSInteger index = (NUMBER_PERROW * indexPath.row) + (tag - TAG_BASE);
        if ([self.opusList count] > index) {
            [button setHidden:NO];
            DrawFeed *opus = [self.opusList objectAtIndex:index];
            [button setImageWithURL:opus.thumbURL];
        }else{
            [button setImage:nil forState:UIControlStateNormal];
            [button setHidden:YES];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"OpusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    [self updateCell:cell withIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (void)clickOpus:(UIButton *)sender
{
    CGPoint point = [self.tableView convertPoint:sender.center fromView:sender];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    NSInteger index = (NUMBER_PERROW * indexPath.row) + (sender.tag - TAG_BASE);
    if (index < [self.opusList count]) {
        DrawFeed *opus = self.opusList[index];
        PPDebug(@"click opus, id = %@, word = %@, row = %d", opus.feedId, opus.wordText, indexPath.row);
        //TODO enter detail?
    }

}

- (IBAction)clickRope:(id)sender {
    if (self.status == DrawHeaderPanelStatusClose) {
        [self openAnimated:YES];
    }else if(self.status == DrawHeaderPanelStatusOpen){
        [self closeAnimated:YES];
    }else{
        PPDebug(@"is animating!!!");
    }
}
@end
