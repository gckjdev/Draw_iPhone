//
//  StarryLoadingView.m
//  Draw
//
//  Created by Kira on 12-11-26.
//
//

#import "StarryLoadingView.h"
#import "CommonImageManager.h"
#import "UIView+MDCShineEffect.h"
#import "AnimationManager.h"

@interface StarryLoadingView (PrivateMethods)
- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode;
@end


@implementation StarryLoadingView
@synthesize radius;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define WIDTH_MARGIN_IPHONE 20
#define WIDTH_MARGIN_IPAD (WIDTH_MARGIN_IPHONE*2)
#define WIDTH_MARGIN ([self isIPAD] ? (WIDTH_MARGIN_IPAD) : (WIDTH_MARGIN_IPHONE))

#define HEIGHT_MARGIN_IPHONE 20
#define HEIGHT_MARGIN_IPAD (HEIGHT_MARGIN_IPHONE*2)
#define HEIGHT_MARGIN ([self isIPAD] ? (HEIGHT_MARGIN_IPAD) : (HEIGHT_MARGIN_IPHONE))

#define WIDTH_OF_LOADING_VIEW_IPHONE 280
#define WIDTH_OF_LOADING_VIEW_IPAD (WIDTH_OF_LOADING_VIEW_IPHONE*2)
#define WIDTH_OF_LOADING_VIEW ([self isIPAD] ? (WIDTH_OF_LOADING_VIEW_IPAD) : (WIDTH_OF_LOADING_VIEW_IPHONE))

#define HEIGHT_OF_LOADING_VIEW_IPHONE 200
#define HEIGHT_OF_LOADING_VIEW_IPAD (HEIGHT_OF_LOADING_VIEW_IPHONE*2)
#define HEIGHT_OF_LOADING_VIEW ([self isIPAD] ? (HEIGHT_OF_LOADING_VIEW_IPAD) : (HEIGHT_OF_LOADING_VIEW_IPHONE))

#define FONT_OF_TITLE_IPHONE [UIFont boldSystemFontOfSize:13]
#define FONT_OF_TITLE_IPAD [UIFont boldSystemFontOfSize:13*2]
#define FONT_OF_TITLE ([self isIPAD] ? (FONT_OF_TITLE_IPAD) : (FONT_OF_TITLE_IPHONE))

#define FONT_OF_MESSAGE_IPHONE [UIFont systemFontOfSize:13]
#define FONT_OF_MESSAGE_IPAD [UIFont systemFontOfSize:13*2]
#define FONT_OF_MESSAGE ([self isIPAD] ? (FONT_OF_MESSAGE_IPAD) : (FONT_OF_MESSAGE_IPHONE))

#define LOADING_CENTER_SIZE ([DeviceDetection isIPAD]?CGSizeMake(62, 46):CGSizeMake(31, 23))

- (BOOL) isIPAD
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
}

- (id) initWithTitle:(NSString*)ttl message:(NSString*)msg{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, WIDTH_OF_LOADING_VIEW, HEIGHT_OF_LOADING_VIEW)])) return nil;
    
    _title = [ttl copy];
    _message = [msg copy];
//    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    _activity.transform = [self isIPAD] ? CGAffineTransformMakeScale(2.0, 2.0) : CGAffineTransformIdentity;
//    [self addSubview:_activity];
    _hidden = YES;
    self.backgroundColor = [UIColor clearColor];
	[self initView];
	return self;
}
- (id) initWithTitle:(NSString*)ttl{
	if(![self initWithTitle:ttl message:nil]) return nil;
	return self;
}

- (void)initView
{
//	int width, rWidth, rHeight, x;
//	
//	UIFont *titleFont = FONT_OF_TITLE;
//	UIFont *messageFont = FONT_OF_MESSAGE;
//	
//	CGSize s1 = [self calculateHeightOfTextFromWidth:_title font:titleFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeTailTruncation];
//	CGSize s2 = [self calculateHeightOfTextFromWidth:_message font:messageFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeCharacterWrap];
//	
//	if([_title length] < 1) s1.height = 0;
//	if([_message length] < 1) s2.height = 0;
//	
//	
//	rHeight = (s1.height + s2.height + (HEIGHT_MARGIN*2) + 10 + 30);
//	rWidth = width = (s2.width > s1.width) ? (int) s2.width : (int) s1.width;
//	rWidth += WIDTH_MARGIN * 2;
//	x = (WIDTH_OF_LOADING_VIEW - rWidth) / 2;
//	
//	_activity.center = CGPointMake(WIDTH_OF_LOADING_VIEW/2,HEIGHT_MARGIN + _activity.frame.size.height/2);
	
	
	//NSLog(@"DRAW RECT %d %f",rHeight,self.frame.size.height);
	
	// DRAW ROUNDED RECTANGLE
//	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] set];
//	CGRect r = CGRectMake(x, 0, rWidth,rHeight);
//	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75] set];
    
    self.loadingView = [[[UIView alloc] init] autorelease];
    
    //set background image
	self.backgroundImageView = [[[UIImageView alloc] init] autorelease];
    [self.backgroundImageView setImage:[CommonImageManager defaultManager].starryBackgroundImage];
    [self.loadingView addSubview:self.backgroundImageView];
    
    _starView = [[[UIImageView alloc] init] autorelease];
    [_starView setImage:[CommonImageManager defaultManager].starryLoadingStar];
    [self.loadingView addSubview:_starView];
    
    _lightView = [[[UIImageView alloc] init] autorelease];
    [_lightView setImage:[CommonImageManager defaultManager].starryLoadingLight];
    [self.loadingView addSubview:_lightView];
    
    _planetView = [[[UIImageView alloc] initWithImage:[CommonImageManager defaultManager].planetImage] autorelease];
    [_planetView setFrame:CGRectMake(0, 0, LOADING_CENTER_SIZE.width, LOADING_CENTER_SIZE.height)];
    [self.loadingView addSubview:_planetView];
	
	
	// DRAW FIRST TEXT
//	[[UIColor whiteColor] set];
//	r = CGRectMake(x+WIDTH_MARGIN, 30 + 10 + HEIGHT_MARGIN, width, s1.height);
//	CGSize s = [_title drawInRect:r withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
//    CGSize s = [self calculateHeightOfTextFromWidth:_title font:titleFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeTailTruncation];
    self.titleLabel = [[[UILabel alloc] init] autorelease];
    [self.titleLabel setText:_title];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.loadingView addSubview:self.titleLabel];
	
	
	// DRAW SECOND TEXT
//	r.origin.y += s.height;
//	r.size.height = s2.height;
//	[_message drawInRect:r withFont:messageFont lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
    self.messageLabel = [[[UILabel alloc] init] autorelease];
    [self.messageLabel setText:_title];
    [self.messageLabel setTextColor:[UIColor whiteColor]];
    [self.messageLabel setBackgroundColor:[UIColor clearColor]];
    [self.messageLabel setNumberOfLines:3];
    [self.messageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    [self.messageLabel setFont:FONT_OF_MESSAGE];
//    [self.messageLabel shineWithRepeatCount:HUGE_VALF duration:4.5 maskWidth:200.0f];
    [self.loadingView addSubview:self.messageLabel];
    
    
    
    [self addSubview:self.loadingView];
    
    
}

//- (void) drawRect:(CGRect)rect {
//	
//	if(_hidden) return;
//	int width, rWidth, rHeight, x;
//	
//	UIFont *titleFont = FONT_OF_TITLE;
//	UIFont *messageFont = FONT_OF_MESSAGE;
//	
//	CGSize s1 = [self calculateHeightOfTextFromWidth:_title font:titleFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeTailTruncation];
//	CGSize s2 = [self calculateHeightOfTextFromWidth:_message font:messageFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeCharacterWrap];
//	
//	if([_title length] < 1) s1.height = 0;
//	if([_message length] < 1) s2.height = 0;
//	
//	
//	rHeight = (s1.height + s2.height + (HEIGHT_MARGIN*2) + 10 + _activity.frame.size.height);
//	rWidth = width = (s2.width > s1.width) ? (int) s2.width : (int) s1.width;
//	rWidth += WIDTH_MARGIN * 2;
//	x = (WIDTH_OF_LOADING_VIEW - rWidth) / 2;
//	
//	_activity.center = CGPointMake(WIDTH_OF_LOADING_VIEW/2,HEIGHT_MARGIN + _activity.frame.size.height/2);
//	
//	
//	//NSLog(@"DRAW RECT %d %f",rHeight,self.frame.size.height);
//	
//	// DRAW ROUNDED RECTANGLE
//	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.9] set];
//	CGRect r = CGRectMake(x, 0, rWidth,rHeight);
//	[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.75] set];
//	[UIView drawRoundRectangleInRect:r withRadius:10.0];
//	
//	
//	// DRAW FIRST TEXT
//	[[UIColor whiteColor] set];
//	r = CGRectMake(x+WIDTH_MARGIN, _activity.frame.size.height + 10 + HEIGHT_MARGIN, width, s1.height);
//	CGSize s = [_title drawInRect:r withFont:titleFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
//	
//	
//	// DRAW SECOND TEXT
//	r.origin.y += s.height;
//	r.size.height = s2.height;
//	[_message drawInRect:r withFont:messageFont lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentCenter];
//	
//	
//	
//}
//

- (void)showInView:(UIView*)superView
{
    _superView = superView;
    [self adjustSize];
    [_superView addSubview:self];
    [_superView bringSubviewToFront:self];
}

- (CGSize)calLoadingViewSize
{

    CGSize s1 = self.titleLabel.frame.size;
	CGSize s2 = self.messageLabel.frame.size;
    
    CGFloat height = s1.height*2 + _planetView.frame.size.height + s2.height;
    CGFloat width = height/0.618;
    
    return CGSizeMake(width, height);
}


- (void)adjustSize
{
    [self setFrame:_superView.bounds];
    PPDebug(@"<test-kira> super bounds = (%.2f, %.2f, %.2f, %.2f)", _superView.frame.origin.x, _superView.frame.origin.y, _superView.frame.size.width, _superView.frame.size.height);
    
    UIFont *titleFont = FONT_OF_TITLE;
	UIFont *messageFont = FONT_OF_MESSAGE;
    CGSize s1 = [self calculateHeightOfTextFromWidth:@" " font:titleFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeTailTruncation];
	CGSize s2 = [self calculateHeightOfTextFromWidth:_message font:messageFont width:HEIGHT_OF_LOADING_VIEW linebreak:UILineBreakModeCharacterWrap];
    
    [self.titleLabel setFrame:CGRectMake(0, 0, s1.width, s1.height)];
    [self.messageLabel setFrame:CGRectMake(0, 0, s2.width, s2.height)];
    
    CGSize loadingViewSize = [self calLoadingViewSize];
    [self.loadingView setFrame:CGRectMake(0, 0, loadingViewSize.width, loadingViewSize.height)];
    [self.loadingView setCenter:CGPointMake(_superView.bounds.size.width/2, _superView.bounds.size.height/2)];
    [self.backgroundImageView setFrame:CGRectMake(0, 0, self.loadingView.frame.size.width, self.loadingView.frame.size.height)];
    [_starView setFrame:self.backgroundImageView.frame];
    [_lightView setFrame:self.backgroundImageView.frame];
    
    PPDebug(@"<test-kira> loading view's size = (%.2f, %.2f), center = (%.2f, %.2f)", self.loadingView.frame.size.width, self.loadingView.frame.size.height, self.loadingView.center.x, self.loadingView.center.y);
    
    
    
    [self.titleLabel setCenter:CGPointMake(self.loadingView.frame.size.width/2, s1.height)];
    [_planetView setCenter:CGPointMake(self.loadingView.frame.size.width/2, self.titleLabel.center.y + self.titleLabel.frame.size.height/2 + _planetView.frame.size.height/2)];
    [self.messageLabel setCenter:CGPointMake(self.loadingView.frame.size.width/2, _planetView.center.y + _planetView.frame.size.height/2 + self.messageLabel.frame.size.height/2)];
    
    
                                       
//    [self.messageLabel setCenter:CGPointMake(self.loadingView.frame.size.width/2, s1.height + _planetView.frame.size.height + self.messageLabel.frame.size.height/2)];
    
    [self.messageLabel addUnlockShiningEffectDuration:2.5];
}

- (void)update
{
//    [self.loadingView setBackgroundColor:[UIColor colorWithRed:(rand()%255)/255.0 green:(rand()%255)/255.0 blue:(rand()%255)/255.0 alpha:1]];
}

- (void)killTimer
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        [_timer release];
        _timer = nil;
    }
}

- (void)startFlashingBackground
{
    [self killTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(update) userInfo:nil repeats:YES];
    [_timer retain];
    
    CAAnimation* flashing = [AnimationManager disappearAnimationFrom:0 to:1 delay:0 duration:1];
    CAAnimation* flashing2 = [AnimationManager disappearAnimationFrom:1 to:0 delay:0 duration:1];
    [flashing2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [flashing setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    flashing.autoreverses = YES;
    flashing.repeatCount = HUGE_VAL;
    flashing2.autoreverses = YES;
    flashing2.repeatCount = HUGE_VAL;
    
    [_starView.layer addAnimation:flashing forKey:nil];
    [_lightView.layer addAnimation:flashing2 forKey:nil];
}

- (void) setTitle:(NSString*)str{
	[_title release];
	_title = [str copy];
	//[self updateHeight];
	[self setNeedsDisplay];
}
- (NSString*) title{
	return _title;
}

- (void) setMessage:(NSString*)str{
	[_message release];
	_message = [str copy];
    [self.messageLabel setText:str];
    [self adjustSize];
//	[self setNeedsDisplay];
}
- (NSString*) message{
	return _message;
}

- (void) setRadius:(float)f{
	if(f==radius) return;
	
	radius = f;
	[self setNeedsDisplay];
	
}

- (void) startAnimating{
	if(!_hidden) return;
	_hidden = NO;
    
    [self startFlashingBackground];
//	[self setNeedsDisplay];
//	[_activity startAnimating];
	
}
- (void) stopAnimating{
	if(_hidden) return;
	_hidden = YES;
    [self killTimer];
//	[self setNeedsDisplay];
//	[_activity stopAnimating];
	
}


- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode{
	return [text sizeWithFont:withFont
			constrainedToSize:CGSizeMake(width, FLT_MAX)
				lineBreakMode:lineBreakMode];
}



- (CGSize) heightWithString:(NSString*)str font:(UIFont*)withFont width:(float)width linebreak:(UILineBreakMode)lineBreakMode{
	
	
	CGSize suggestedSize = [str sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	return suggestedSize;
}


- (void) adjustHeight{
	
	CGSize s1 = [self heightWithString:_title font:[UIFont boldSystemFontOfSize:16.0]
								 width:HEIGHT_OF_LOADING_VIEW
							 linebreak:UILineBreakModeTailTruncation];
	
	CGSize s2 = [self heightWithString:_message font:[UIFont systemFontOfSize:12.0]
                                 width:HEIGHT_OF_LOADING_VIEW
                             linebreak:UILineBreakModeCharacterWrap];
    
	CGRect r = self.frame;
	r.size.height = s1.height + s2.height + 20;
	self.frame = r;
}


- (void) dealloc{
//	[_activity release];
	[_title release];
	[_message release];
    [_backgroundImageView release];
    [_titleLabel release];
    [_messageLabel release];
    [_loadingView release];
    [_planetView release];
	[super dealloc];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
