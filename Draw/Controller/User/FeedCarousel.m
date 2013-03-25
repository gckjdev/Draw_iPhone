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
#import "UIButton+WebCache.h"

@interface FeedCarousel()
@property (retain, nonatomic) NSArray *drawFeeds;

@end

@implementation FeedCarousel

AUTO_CREATE_VIEW_BY_XIB(FeedCarousel);

+ (id)createFeedCarousel
{
    FeedCarousel *view = [self createView];
    view.carousel.delegate = self;
    view.carousel.dataSource = self;
    view.carousel.type = iCarouselTypeCoverFlow2;

    return view;
}

- (void)setDrawFeedList:(NSArray *)drawFeeds
{
    self.drawFeeds = drawFeeds;
    [self.carousel reloadData];
}

- (void)dealloc {
    _carousel.delegate = nil;
    _carousel.dataSource = nil;
    [_drawFeeds release];
    [_bgImageView release];
    [_carousel release];
    [super dealloc];
}

#pragma mark -
#pragma mark iCarousel methods


- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return 5;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(ReflectionView *)view
{
	UIButton *button = nil;
	
	//create new view if no view is available for recycling
	if (view == nil)
	{
        //set up reflection view
		view = [[[ReflectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)] autorelease];
        
        button = [[[UIButton alloc] initWithFrame:view.bounds] autorelease];
        //set up content
		button.backgroundColor = [UIColor lightGrayColor];
		button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 4.0f;
        button.layer.cornerRadius = 8.0f;
        button.tag = 9999;
        [button addTarget:self action:@selector(clickFeedButton:) forControlEvents:UIControlEventTouchUpInside];
		[view addSubview:button];
	}
	else
	{
		button = (UIButton *)[view viewWithTag:9999];
	}
	
    //set label
	[button setTitle:[NSString stringWithFormat:@"%i", index] forState:UIControlStateNormal];
    
    //update reflection
    //this step is expensive, so if you don't need
    //unique reflections for each item, don't do this
    //and you'll get much smoother peformance
    [view update];
	
	return view;
}

- (void)clickFeedButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    PPDebug(@"click button: %@", [button titleForState:UIControlStateNormal]);
}




@end
