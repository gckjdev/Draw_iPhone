//
//  DrawBgBox.m
//  Draw
//
//  Created by gamy on 13-3-4.
//
//

#import "DrawBgBox.h"
#import "Draw.pb.h"
#import "UIViewUtils.h"
#import "DrawBgManager.h"
#import "UIImageView+WebCache.h"

@interface DrawBgBox()
{
    
}

@property(nonatomic, retain) NSString *selectedBgId;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation DrawBgBox


#define NUMBER_PER_ROW 3
#define SPACE (ISIPAD ? 10 : 5)
#define IMAGEVIEW_SIZE (ISIPAD ? CGSizeMake(160,160) : CGSizeMake(80,80))

- (UIImageView *)imageViewForDrawBG:(PBDrawBg *)drawBG
{
    CGRect rect = CGRectZero;
    rect.size = IMAGEVIEW_SIZE;
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:rect] autorelease];
    UIImage *image = [drawBG localImage];
    if (image) {
        UIColor *color = [UIColor colorWithPatternImage:image];
        [imageView setBackgroundColor:color];
    }
    return imageView;
}

- (NSArray *)pbDrawBgList
{
    DrawBgManager *bgManager = [DrawBgManager defaultManager];
    NSArray *bgList = [bgManager pbDrawBgList];
    return bgList;
}

- (void)updateViewsWithSelectedBgId:(NSString *)bgId
{
    self.selectedBgId = bgId;
    //Find the draw bg index;
    
    NSInteger index = -1;
    NSInteger i = 0;
    for (PBDrawBg *drawBg in [self pbDrawBgList]) {
        if ([drawBg.bgId isEqualToString:bgId]) {
            index = i;
            break;
        }
        ++ i;
    }
    
    for (UIView *view in self.scrollView.subviews) {
        if([view isKindOfClass:[UIControl class]]){
            if (index == view.tag) {
                view.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.3];
            }else{
                view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
            }
        }
    }
}

- (void)updateViews
{
    CGPoint origin = CGPointZero;
    NSInteger i = 0;
    
    for (PBDrawBg *drawBG in [self pbDrawBgList]) {
        UIImageView *imageView = [self imageViewForDrawBG:drawBG];
        origin.x = (i % NUMBER_PER_ROW) * (SPACE + IMAGEVIEW_SIZE.width);
        origin.y = (i / NUMBER_PER_ROW) * (SPACE + IMAGEVIEW_SIZE.height);        
        CGRect frame = imageView.frame;
        frame.origin = origin;
        imageView.frame = frame;
        [imageView setTag:i];
        [self.scrollView addSubview:imageView];
        
        //Add Action
        UIControl *control = [[[UIControl alloc] initWithFrame:frame] autorelease];
        [self.scrollView addSubview:control];
        [control setTag:i];
        [control addTarget:self action:@selector(clickOnPBDrawBgIndex:) forControlEvents:UIControlEventTouchUpInside];
        ++ i;
    }
    
    //update content size
    CGFloat height = (i/NUMBER_PER_ROW + 1) * (SPACE + IMAGEVIEW_SIZE.height) - SPACE;
    CGSize contentSize = self.scrollView.contentSize;
    if (height > contentSize.height) {
        contentSize.height = height;
        self.scrollView.contentSize = contentSize;
    }
    
    [self updateViewsWithSelectedBgId:nil];
}


- (void)clickOnPBDrawBgIndex:(UIControl *)control
{
    DrawBgManager *bgManager = [DrawBgManager defaultManager];
    NSArray *bgList = [bgManager pbDrawBgList];
    NSInteger index = control.tag;
    
    if (index < [bgList count]) {
        PBDrawBg *drawBg = [bgList objectAtIndex:index];
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawBgBox:didSelectedDrawBg:)]) {
            [self updateViewsWithSelectedBgId:drawBg.bgId];
            [self.delegate drawBgBox:self didSelectedDrawBg:drawBg];

        }
    }
}

+ (id)drawBgBoxWithDelegate:(id<DrawBgBoxDelegate>)delegate
{
    DrawBgBox *box = [UIView createViewWithXibIdentifier:@"DrawBgBox"];
    box.delegate = delegate;
    [box updateViews];
    return box;
}

- (void)dealloc {
    PPRelease(_scrollView);
    PPRelease(_selectedBgId);
    [super dealloc];
}
@end
