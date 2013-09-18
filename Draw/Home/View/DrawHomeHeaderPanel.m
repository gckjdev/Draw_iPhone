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
#import "StableView.h"

@interface DrawHomeHeaderPanel()
{
    CGFloat lastTouchPoint;
}
@property(nonatomic, retain)NSMutableDictionary *indexDict;

@end

@implementation DrawHomeHeaderPanel

#define ISCLOSE (DrawHeaderPanelStatusClose==self.status)
#define VALUE(X) (ISIPAD?(2*X):X)

#define HEIGHT_MINUS (ISIPHONE5?10:0)
#define CELL_HEIGHT_MINUS HEIGHT_MINUS

#define CELL_WIDTH  (ISIPAD?(ISCLOSE?520.0f:710.0f):(ISCLOSE?230.0f:290.0f))
#define SPACE (ISIPAD?20.0f:10.0f)
#define NUMBER_PERROW 3
#define CELL_HEIGHT (((ISIPAD?(ISCLOSE?150.0f:230.0f):(ISCLOSE?70.0f:90.0f)))+CELL_HEIGHT_MINUS)

#define OPUS_WIDTH (CELL_WIDTH-(NUMBER_PERROW+1)*SPACE)/NUMBER_PERROW
#define OPUS_SIZE CGSizeMake(OPUS_WIDTH,OPUS_WIDTH)
#define TAG_BASE 100

#define ROPE_X (ISIPAD?666:284)

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

- (void)initRope
{
    self.rope = [RopeView ropeView];
    [self addSubview:self.rope];
    [self.rope updateOriginX:ROPE_X];
    [self.rope setFinishHandler:^(RopeView *ropeView){
        if (self.status == DrawHeaderPanelStatusClose) {
            EXECUTE_BLOCK(self.clickRopeHandler, YES);
        }else if(self.status == DrawHeaderPanelStatusOpen){
            EXECUTE_BLOCK(self.clickRopeHandler, NO);
        }else{
            PPDebug(@"is animating!!!");
        }
    }];
}

- (void)baseInit
{
    self.indexDict = [NSMutableDictionary
                       dictionary];    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.status = DrawHeaderPanelStatusClose;
    
    [self initRope];
    
    [self updateFrameForClose];
    self.opusList = [[FeedService defaultService] getCachedFeedList:FeedListTypeHot];
    [[FeedService defaultService] getFeedList:FeedListTypeHot offset:0 limit:18 delegate:self];
    [self updateView];
    [self updateBG];
}

- (void)updateBG
{
    //set holder view color
    UIImage *homeImage = [[UserManager defaultManager] pageBgForKey:HOME_BG_KEY];
    if (homeImage) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.bgView setBackgroundColor:[UIColor clearColor]];
    }else{
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.bgView setBackgroundColor:OPAQUE_COLOR(236, 84, 46)];
    }
}

- (void)updateView
{
}


#define OPEN_HEIGHT_OFFSET (ISIPHONE5?62:0)
#define SELF_WIDTH (ISIPAD?768:320)
#define SELF_HEIGHT_OPEN ((ISIPAD?800:370)+OPEN_HEIGHT_OFFSET)
#define SELF_HEIGHT_CLOSE ((ISIPAD?200:100)+HEIGHT_MINUS)

#define HOLDER_HEIGHT_OPEN ((SELF_HEIGHT_OPEN-VALUE(2)))
#define HOLDER_HEIGHT_CLOSE ((SELF_HEIGHT_CLOSE-VALUE(2)))

#define HOLDER_WIDTH_OPEN (ISIPAD?730:310)
#define HOLDER_WIDTH_CLOSE (ISIPAD?540:250)

- (void)updateFrameForOpen
{
    
    self.frame = CGRectMake(0, 0,SELF_WIDTH, SELF_HEIGHT_OPEN);
    CGFloat x = (SELF_WIDTH - HOLDER_WIDTH_OPEN) / 2;
    self.holderView.frame = CGRectMake(x, 0, HOLDER_WIDTH_OPEN,HOLDER_HEIGHT_OPEN);
}

- (void)updateFrameForClose
{
    self.frame = CGRectMake(0, 0, SELF_WIDTH, SELF_HEIGHT_CLOSE);
    CGFloat x = (SELF_WIDTH - HOLDER_WIDTH_CLOSE) / 2;
    self.holderView.frame = CGRectMake(x, 0, HOLDER_WIDTH_CLOSE,HOLDER_HEIGHT_CLOSE);
}



- (void)openAnimated:(BOOL)animated
          completion:(void (^)(BOOL finished))completion
{
    [self.badgeView setHidden:YES];
    [self.bulletinButton setHidden:YES];
    
    void (^innerCompletion)(BOOL)  = ^(BOOL finished){
        self.status = DrawHeaderPanelStatusOpen;
        [self reloadView];
        if (NULL != completion) {
            completion(finished);
        }
        [self.superview addSubview:self.rope];
        [self.rope reset];
        [self.rope updateOriginY:CGRectGetMaxY(self.frame)];
        [self.rope updateOriginX:ROPE_X];
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
        [self.rope reset];
        [self.rope updateOriginY:0];
        [self.rope updateOriginX:ROPE_X];
        if (self.badgeView.number > 0) {
            [self.badgeView setHidden:NO];            
        }
        [self.bulletinButton setHidden:NO];
        
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
    [_badgeView release];
    [_bulletinButton release];
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
        
        [button updateOriginX:(SPACE+(tag-TAG_BASE)*(SPACE+OPUS_SIZE.width))];
        [button updateCenterY:CELL_HEIGHT/2];
        PPDebug(@"tag = %d, button frame = %@,cell width = %f", tag, NSStringFromCGRect(button.frame),self.tableView.bounds.size.width);
        
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


- (IBAction)clickBulletin:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(homeHeaderPanel:didClickBulletinButton:)]) {
        [self.delegate homeHeaderPanel:self didClickBulletinButton:sender];
        [self updateBulletinBadge:0];
    }
}

- (void)updateBulletinBadge:(int)count
{
    [self.badgeView setNumber:count];
}
@end
