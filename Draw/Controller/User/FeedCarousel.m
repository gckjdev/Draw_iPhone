//
//  FeedCarousel.m
//  Draw
//
//  Created by 王 小涛 on 13-3-25.
//
//

#import "FeedCarousel.h"
#import "AutoCreateViewByXib.h"
#import "ReflectionView.h"
//#import "UIButton+WebCache.h"
#import "UIButtonExt.h"
#import "UIViewUtils.h"
#import "PPConfigManager.h"

#define FEED_VIEW_FRAME (ISIPAD ? CGRectMake(0.0f, 0.0f, 240.0f, 240.0f) : CGRectMake(0.0f, 0.0f, 120.0f, 120.0f))

#define SCROLL_SPEED 0.1 //items per second, can be negative or fractional

@interface FeedCarousel()
@property (retain, nonatomic) NSArray *drawFeeds;
@property (nonatomic, assign) NSTimer *scrollTimer;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, assign) BOOL wrap;
@property (retain, nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation FeedCarousel

AUTO_CREATE_VIEW_BY_XIB(FeedCarousel);

- (void)dealloc {
    [_indicator release];
    [_scrollTimer invalidate];
    _scrollTimer = nil;
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
    [_drawFeeds release];
    [_carousel release];
    [_tipLable release];
    [super dealloc];
}


+ (id)createFeedCarousel
{
    FeedCarousel *view = [self createView];
    view.carousel.delegate = view;
    view.carousel.dataSource = view;
    view.carousel.type = [PPConfigManager getFeedCarouselType];

    return view;
}

- (void)showActivity
{
    if (_indicator == nil) {
        self.indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.indicator.center = CGRectGetCenter(self.bounds);
        [self addSubview:self.indicator];
    }
    
    self.indicator.hidden = NO;
    
    [_indicator startAnimating];
}

- (void)hideActivity
{
    [_indicator stopAnimating];
    self.indicator.hidden = YES;
}

- (void)setDrawFeedList:(NSArray *)drawFeeds
                tipText:(NSString *)tipText
{
    self.drawFeeds = drawFeeds;
    self.tipLable.backgroundColor = [UIColor clearColor];
    self.tipLable.textColor = COLOR_BROWN;
    
    [self.carousel reloadData];
    
    if ([drawFeeds count] > 0) {
        self.tipLable.hidden = YES;
    }else{
        self.tipLable.hidden = NO;
        self.tipLable.text = tipText;
    }
}

- (void)clearDrawFeedList
{
    self.tipLable.hidden = YES;
    self.drawFeeds = nil;
    [self.carousel reloadData];
}


#pragma mark -
#pragma mark iCarousel methods


- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_drawFeeds count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ReflectionView *)view
{
	UIButton *button = nil;

    
	//create new view if no view is available for recycling
	if (view == nil)
	{
        //set up reflection view
		view = [[[ReflectionView alloc] initWithFrame:FEED_VIEW_FRAME] autorelease];
        button = [[[UIButton alloc] initWithFrame:view.bounds] autorelease];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //set up content
//		button.layer.borderColor = [UIColor clearColor].CGColor;
//        button.layer.borderWidth = 4.0f;
//        button.layer.cornerRadius = 8.0f;
//        [button.layer setMasksToBounds:YES];
        button.tag = 9999;
//        [button addTarget:self action:@selector(clickFeedButton:) forControlEvents:UIControlEventTouchUpInside];
        button.userInteractionEnabled = NO;
		[view addSubview:button];
	}
	else
	{
		button = (UIButton *)[view viewWithTag:9999];
	}
    
    DrawFeed *feed = [_drawFeeds objectAtIndex:index];
    NSURL *url = [NSURL URLWithString:feed.drawImageUrl];
    [button setImageWithURL:url placeholderImage:nil];
    
    //update reflection
    //this step is expensive, so if you don't need
    //unique reflections for each item, don't do this
    //and you'll get much smoother peformance
    [view update];
	
	return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"did select: %d", index);
    if ([_delegate respondsToSelector:@selector(didSelectDrawFeed:)]) {
        [_delegate didSelectDrawFeed:[_drawFeeds objectAtIndex:index]];
    }
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
//    switch (option)
//    {
//        case iCarouselOptionWrap:
//            return _wrap;
////        case iCarouselOptionShowBackfaces:
////            return -0.2;
////        case iCarouselOptionOffsetMultiplier:
////            return -0.2;
//        case iCarouselOptionVisibleItems:
//            return value;
//;
////        case iCarouselOptionCount:
////            return -0.2;
//
//        case iCarouselOptionArc:
//            return value * (ISIPAD ? 0.8 : 1.0);
//
//            return value;
//        case iCarouselOptionAngle:
//            return value;
//
//        case iCarouselOptionRadius:
//            return value;
//
//        case iCarouselOptionTilt:
//        {
//            if(carousel.type == iCarouselTypeCoverFlow || carousel.type == iCarouselTypeCoverFlow2){
//                return value * (ISIPAD ? 0.5 : 0.9);
//            }else{
//                return value;
//            }
//        }
//            
//        case iCarouselOptionSpacing:
//        {
//            if (carousel.type == iCarouselTypeRotary || carousel.type == iCarouselTypeInvertedRotary) {
//                return value * (ISIPAD ? 1.1 : 1.1);
//            }else if(carousel.type == iCarouselTypeCoverFlow || carousel.type == iCarouselTypeCoverFlow2){
//                return 0.36;
//            }else if (carousel.type == iCarouselTypeTimeMachine || carousel.type == iCarouselTypeInvertedTimeMachine){
//                return value * 0.5;
//            }else{
//                return value * 1.05f;
//            }
//        }
//
//        case iCarouselOptionFadeMin:
//            return -0.1;
//        case iCarouselOptionFadeMax:
//            return 0.1;
//        case iCarouselOptionFadeRange:
//            return 2.0;
//        default:
//            return value;
//    }
//    return value;
    
    switch (option)
    {
        case iCarouselOptionWrap:
        {
//            NSLog(@"iCarouselOptionWrap : %d", _wrap);
            return _wrap;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                return 0.0f;
            }
//            NSLog(@"iCarouselOptionFadeMax : %f", value);
            return value;
        }
        case iCarouselOptionArc:
        {
            if (carousel.type == iCarouselTypeCylinder
                || carousel.type == iCarouselTypeInvertedCylinder) {
                
                return 2 * M_PI * 0.73;
            }else if (carousel.type == iCarouselTypeCoverFlow
                      || carousel.type == iCarouselTypeCoverFlow2){
                
                return 2 * M_PI * 1;
            }else if (carousel.type == iCarouselTypeTimeMachine
                      || carousel.type == iCarouselTypeInvertedTimeMachine){
                
                return 2 * M_PI * 1;
            }else if (carousel.type == iCarouselTypeRotary
                      || carousel.type == iCarouselTypeInvertedRotary){
                
                return 2 * M_PI * 1;
            }else if (carousel.type == iCarouselTypeWheel
                      || carousel.type == iCarouselTypeInvertedWheel){
                
                return 2 * M_PI * 0.33;
            }else if(carousel.type == iCarouselTypeLinear){
                
                return 2 * M_PI * 1;
            }else{
                
                return 2 * M_PI;
            }
//            NSLog(@"iCarouselOptionArc : %f", 2 * M_PI * _arcSlider.value);
        }
        case iCarouselOptionRadius:
        {
            if (carousel.type == iCarouselTypeCylinder
                || carousel.type == iCarouselTypeInvertedCylinder) {
                
                return value * 1.14;
            }else if (carousel.type == iCarouselTypeCoverFlow
                      || carousel.type == iCarouselTypeCoverFlow2){
                
                return value * 1;
            }else if (carousel.type == iCarouselTypeTimeMachine
                      || carousel.type == iCarouselTypeInvertedTimeMachine){
                
                return value * 1;
            }else if (carousel.type == iCarouselTypeRotary
                      || carousel.type == iCarouselTypeInvertedRotary){
                
                return value * 1.62;
            }else if (carousel.type == iCarouselTypeWheel
                      || carousel.type == iCarouselTypeInvertedWheel){
                
                return value * 1.62;
            }else if(carousel.type == iCarouselTypeLinear){
                
                return value * 1;
            }else{
                
                return value;
            }
//            NSLog(@"iCarouselOptionRadius : %f", value * _radiusSlider.value);
        }
        case iCarouselOptionTilt:
        {
//            NSLog(@"iCarouselOptionTilt : %f", _tiltSlider.value);
            
            if (carousel.type == iCarouselTypeCylinder
                || carousel.type == iCarouselTypeInvertedCylinder) {
                
                return value * 0.9;
            }else if (carousel.type == iCarouselTypeCoverFlow
                      || carousel.type == iCarouselTypeCoverFlow2){
                
                return value * 0.95;
            }else if (carousel.type == iCarouselTypeTimeMachine
                      || carousel.type == iCarouselTypeInvertedTimeMachine){
                
                return value * 0.77;
            }else if (carousel.type == iCarouselTypeRotary
                      || carousel.type == iCarouselTypeInvertedRotary){
    
                return value * 0.9;
            }else if (carousel.type == iCarouselTypeWheel
                      || carousel.type == iCarouselTypeInvertedWheel){
                
                return value * 0.9;
            }else if(carousel.type == iCarouselTypeLinear){
                
                return value * 0.9;
            }else{
                
                return value;
            }
        }
        case iCarouselOptionSpacing:
        {
//            NSLog(@"iCarouselOptionSpacing : %f", value * _spacingSlider.value);
            if (carousel.type == iCarouselTypeCylinder
                || carousel.type == iCarouselTypeInvertedCylinder) {
                
                return value * 0.95;
            }else if (carousel.type == iCarouselTypeCoverFlow
                      || carousel.type == iCarouselTypeCoverFlow2){
                
                return value * 1.28;
            }else if (carousel.type == iCarouselTypeTimeMachine
                      || carousel.type == iCarouselTypeInvertedTimeMachine){
                
                return value * 0.54;
            }else if (carousel.type == iCarouselTypeRotary
                      || carousel.type == iCarouselTypeInvertedRotary){
    
                return value * 0.86;
            }else if (carousel.type == iCarouselTypeWheel
                      || carousel.type == iCarouselTypeInvertedWheel){
                
                return value * 0.85;
            }else if(carousel.type == iCarouselTypeLinear){
                
                return value * 1.1;
            }else{
                
                return value;
            }
            
        }
        default:
        {
            return value;
        }
    }

}

//- (void)clickFeedButton:(id)sender
//{
//    UIButton *button = (UIButton *)sender;
//    PPDebug(@"click button: %@", [button titleForState:UIControlStateNormal]);
//}

#pragma mark -
#pragma mark Autoscroll

- (void)startScrolling
{
    [_scrollTimer invalidate];
    _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/24.0
                                                   target:self
                                                 selector:@selector(scrollStep)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)stopScrolling
{
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

- (void)scrollStep
{
    //calculate delta time
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    float delta = _lastTime - now;
    _lastTime = now;
    
    //don't autoscroll when user is manipulating carousel
    if (!_carousel.dragging && !_carousel.decelerating)
    {
        //scroll carousel
        _carousel.scrollOffset += delta * (float)(SCROLL_SPEED);
    }
}

- (void)enabaleWrap:(BOOL)wrap
{
    self.wrap = wrap;
    [self.carousel reloadData];
}

- (IBAction)changeType:(id)sender {
    self.carousel.type ++;
    self.carousel.type %= 10;
}

@end
