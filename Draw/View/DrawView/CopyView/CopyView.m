//
//  CopyView.m
//  Draw
//
//  Created by qqn_pipi on 14-6-24.
//
//

#import "CopyView.h"
#import "SPUserResizableView.h"
#import "MKBlockActionSheet.h"

#define COPY_VIEW_DEFAULT_WIDTH     200
#define COPY_VIEW_DEFAULT_HEIGHT    200

@interface CopyView()

@property (nonatomic, retain) PPViewController *superViewController;

@end

@implementation CopyView

+ (CopyView*)createCopyView:(PPViewController*)superViewController superView:(UIView*)superView atPoint:(CGPoint)point
{
    CGRect frame = CGRectMake(point.x, point.y, COPY_VIEW_DEFAULT_WIDTH, COPY_VIEW_DEFAULT_HEIGHT);
    CopyView *copyView = [[CopyView alloc] initWithFrame:frame];
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    [contentView setBackgroundColor:[UIColor clearColor]];
    copyView.contentView = contentView;

    [superView addSubview:copyView];
    copyView.superViewController = superViewController;
    copyView.delegate = copyView;
    
    [contentView release];
    [copyView release];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:copyView action:@selector(hideBorder)];
    [gestureRecognizer setDelegate:copyView];
    [superView addGestureRecognizer:gestureRecognizer];
    [gestureRecognizer release];

    [copyView showEditingHandles];
    
    return copyView;
}

- (void)dealloc
{
    PPRelease(_superViewController);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - SPUserResizableViewDelegate

// Called when the resizable view receives touchesBegan: and activates the editing handles.
- (void)userResizableViewDidBeginEditing:(SPUserResizableView *)userResizableView
{
    PPDebug(@"userResizableViewDidBeginEditing");
}

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)userResizableViewDidEndEditing:(SPUserResizableView *)userResizableView
{
    PPDebug(@"userResizableViewDidEndEditing");
}

- (void)userResizableViewDidTap:(SPUserResizableView*)userResizableView
{
    PPDebug(@"userResizableViewDidTap");
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self hitTest:[touch locationInView:self] withEvent:nil]) {
        return NO;
    }
    return YES;
}

- (void)hideBorder {
    // We only want the gesture recognizer to end the editing session on the last
    // edited view. We wouldn't want to dismiss an editing session in progress.
    [self hideEditingHandles];
}

@end
