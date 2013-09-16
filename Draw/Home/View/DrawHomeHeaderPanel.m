//
//  DrawHomeHeaderPanel.m
//  Draw
//
//  Created by Gamy on 13-9-15.
//
//

#import "DrawHomeHeaderPanel.h"
#import "UIButton+WebCache.h"
#import "ShowFeedController.h"
#import "UseItemScene.h"

@interface DrawHomeHeaderPanel()
{
    
}
@property(nonatomic, retain)NSMutableDictionary *indexDict;

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
    [panel baseInit];
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
    [self.tableView reloadData];
    return;
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

- (void)baseInit
{
    self.indexDict = [NSMutableDictionary
                       dictionary];    
    [self.rope.imageView setContentMode:UIViewContentModeBottom];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.status = DrawHeaderPanelStatusClose;
    [self updateFrameForClose];
    self.opusList = [[FeedService defaultService] getCachedFeedList:FeedListTypeHot];
    [[FeedService defaultService] getFeedList:FeedListTypeHot offset:0 limit:18 delegate:self];
    [self updateView];
}

- (void)updateView
{
    
}


- (void)updateFrameForOpen
{
    self.frame = CGRectMake(0, 0, 320, 100+3*CELL_HEIGHT);
    self.holderView.frame = CGRectMake(5, 0, 310, 98+(3*CELL_HEIGHT));
}

- (void)updateFrameForClose
{
    self.frame = CGRectMake(0, 0, 320, 100);
    self.holderView.frame = CGRectMake(35, 0, 250, 98);
}

- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion
{
    void (^innerCompletion)(BOOL)  = ^(BOOL finished){
        self.status = DrawHeaderPanelStatusOpen;
        [self reloadView];
        if (NULL != completion) {
            completion(finished);
        }
        [self.superview addSubview:self.rope];
        self.rope.hidden = NO;
        [self.rope updateOriginY:CGRectGetMaxY(self.frame)];
    };
    if (animated) {
        self.status = DrawHeaderPanelStatusAnimating;
        [self reloadView];
        void (^animation)(void)  = ^{
            [self updateFrameForOpen];
        };
        [UIView animateWithDuration:HEADER_ANIMATION_INTEVAL animations:animation completion:innerCompletion];
    }else{
        [self updateFrameForOpen];
        innerCompletion(YES);
    }
}
- (void)closeAnimated:(BOOL)animated
           completion:(void (^)(BOOL finished))completion
{
    void (^innerCompletion)(BOOL)  = ^(BOOL finished){
        self.status = DrawHeaderPanelStatusClose;
        [self reloadView];
        if (NULL != completion) {
            completion(finished);
        }
        [self addSubview:self.rope];
        self.rope.hidden = NO;
        [self.rope updateOriginY:0];
        
    };
    if (animated) {
        self.status = DrawHeaderPanelStatusAnimating;
        void (^animation)(void)  = ^{
            [self updateFrameForClose];
        };
        [UIView animateWithDuration:HEADER_ANIMATION_INTEVAL animations:animation completion:innerCompletion];
    }else{
        [self updateFrameForClose];
        innerCompletion(YES);
    }
}

- (void)dealloc {
    [_bgView release];
    [_tableView release];
    [_displayHolder release];
    [_rope release];
    [_holderView release];
    RELEASE_BLOCK(_clickRopeHandler);
    PPRelease(_indexDict);
    [super dealloc];
}


#pragma mark- Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.status == DrawHeaderPanelStatusClose) {
        return 1;
    }
    return 4;
}   


#define OPUS_INDEX_KEY @"OPUS_INDEX_KEY"

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
        }
        button.tag = tag;
        button.frame = defaultFrame;
        
        [button updateOriginX:(SPACE/2+(tag-TAG_BASE)*(SPACE+OPUS_SIZE.width))];
        [button updateOriginY:(CELL_HEIGHT-OPUS_SIZE.height)/2];
        NSInteger index = (NUMBER_PERROW * indexPath.row) + (tag - TAG_BASE);
        [self.indexDict setObject:button forKey:@(index)];
        
        
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
    __block NSInteger index = 0;
    [self.indexDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == sender) {
            index = [key integerValue];
            stop = YES;
        }
    }];
    PPDebug(@"click index = %d", index);
    if (index < [self.opusList count]) {
        DrawFeed *opus = self.opusList[index];
        ShowFeedController *sc = [[ShowFeedController alloc] initWithFeed:opus scene:[UseItemScene createSceneByType:UseSceneTypeShowFeedDetail feed:opus]];
        [[[self theViewController] navigationController] pushViewController:sc animated:YES];
        [sc release];

    }

}

- (IBAction)clickRope:(id)sender {

    self.rope.hidden = YES;
    if (self.status == DrawHeaderPanelStatusClose) {
        EXECUTE_BLOCK(self.clickRopeHandler, YES);
    }else if(self.status == DrawHeaderPanelStatusOpen){
        EXECUTE_BLOCK(self.clickRopeHandler, NO);
    }else{
        PPDebug(@"is animating!!!");
        self.rope.hidden = NO;
    }

}
@end
