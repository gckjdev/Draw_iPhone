//
//  CommonMessageCenter.m
//  Draw
//
//  Created by Orange on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonMessageCenter.h"
#import "DiceImageManager.h"
#import "LocaleUtils.h"
#import "CommonImageManager.h"

typedef enum {
    MessageViewTypeTextOnly = 0,
    MessageViewTypeWithSmallImage,
    MessageViewTypeWithHappyFace,
    MessageViewTypeWithUnhappyFace,
}MessageViewType;

#define MESSAGE_FONT_SIZE ([DeviceDetection isIPAD]?24:12)
#define HAPPY_FACE_FRAME   ([DeviceDetection isIPAD]?CGRectMake(0, 3, 158, 280):CGRectMake(4, 5, 79, 140))
#define UNHAPPY_FACE_FRAME   ([DeviceDetection isIPAD]?CGRectMake(4, 95, 158, 280):CGRectMake(0, 49, 79, 140))
#define SMALL_IMAGE_FRAME   ([DeviceDetection isIPAD]?CGRectMake(20, 123, 80, 80):CGRectMake(11, 64, 40, 40))
#define SEPERATOR_X ([DeviceDetection isIPAD]?10:5)

typedef enum {
    CommonMessageViewThemeDraw = 0,
    CommonMessageViewThemeDice = 1
}CommonMessageViewTheme;

CommonMessageViewTheme globalGetTheme() {
    if (isDrawApp()) {
        return CommonMessageViewThemeDraw;
    }
    if (isDiceApp()) {
        return CommonMessageViewThemeDice;
    }
    
    //TODO Check For ZJH    
    return CommonMessageViewThemeDraw;
}

#pragma mark -
@interface CommonMessageView : UIView {
	CGRect _messageRect;
	NSString *_text;
	UIImage *_image;
}
@property (retain, nonatomic) IBOutlet UIImageView *faceImageView;
@property (retain, nonatomic) IBOutlet UILabel *messageLabel;
@property (retain, nonatomic) IBOutlet UIImageView* messageBackgroundView;

- (id) init;
- (void) setMessageText:(NSString*)str;
- (void) setImage:(UIImage*)image;
- (BOOL) isIPAD;
+ (CommonMessageView*)createMessageViewByTheme:(CommonMessageViewTheme)theme;
- (void)initWithType:(MessageViewType)type
               image:(UIImage*)image
                text:(NSString*)text;
@end


#pragma mark -
@implementation CommonMessageView
@synthesize faceImageView = _faceImageView;
@synthesize messageLabel = _messageLabel;
@synthesize messageBackgroundView = _messageBackgroundView;

- (BOOL) isIPAD
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

- (id) init{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, 0, 0)])) return nil;
	_messageRect = CGRectInset(self.bounds, 10, 10);
	self.backgroundColor = [UIColor clearColor];
	return self;
	
}
- (void) dealloc{
	[_text release];
	[_image release];
    [_faceImageView release];
    [_messageLabel release];
    [_messageLabel release];
	[super dealloc];
}

- (void)initByTheme:(CommonMessageViewTheme)theme
{
    switch (theme) {
        case CommonMessageViewThemeDraw: {
            [self.messageLabel setFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE]];
        }break;
        case CommonMessageViewThemeDice: {
            [self.messageBackgroundView setImage:[DiceImageManager defaultManager].popupBackgroundImage];
        }break;
        default:
            break;
    }
}
+ (CommonMessageView*)createMessageViewByTheme:(CommonMessageViewTheme)theme
{
    CommonMessageView* view = [self createMessageView];
    [view initByTheme:theme];
    return view;
}

+ (CommonMessageView*)createMessageView
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommonMessageView" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <CommonMessageView> but cannot find cell object from Nib");
        return nil;
    }
    CommonMessageView* view =  (CommonMessageView*)[topLevelObjects objectAtIndex:0];
    view.messageLabel.numberOfLines = 5;
    if ([LocaleUtils isChinese]) {
        [view.messageLabel setLineBreakMode:UILineBreakModeCharacterWrap];
    } else {
        [view.messageLabel setLineBreakMode:UILineBreakModeWordWrap];
    }
    return view;
}

+ (CommonMessageView*)createMessageViewWithText:(NSString*)text 
                                        isHappy:(BOOL)isHappy
{
    CommonMessageView* view = [CommonMessageView createMessageViewByTheme:globalGetTheme()];
    [view.messageLabel setText:text];
    if (isHappy) {
        [view.faceImageView setImage:[UIImage imageNamed:@"super_face_smile.png"]];
        [view.faceImageView setFrame:HAPPY_FACE_FRAME];
    } else {
        [view.faceImageView setImage:[UIImage imageNamed:@"super_face_wry.png"]];
        [view.faceImageView setFrame:UNHAPPY_FACE_FRAME];
    }
    return view;
}

//- (void) drawRect:(CGRect)rect{
//	[[UIColor colorWithWhite:0 alpha:0.8] set];
//	[UIView drawRoundRectangleInRect:rect withRadius:10];
//	[[UIColor whiteColor] set];
//	[_text drawInRect:_messageRect withFont:FONT_OF_MESSAGE lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
//	
//	CGRect r = CGRectZero;
//	r.origin.y = 15;
//	r.origin.x = (rect.size.width-_image.size.width)/2;
//	r.size = _image.size;
//	
//	[_image drawInRect:r];
//}

#pragma mark Setter Methods
- (void) adjust{
    
//	CGSize constrainedSize = [self isIPAD] ? CGSizeMake(160*2,200*2) : CGSizeMake(160,200);
//	CGSize s = [_text sizeWithFont:FONT_OF_MESSAGE constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
//	
//	float imageAdjustment = 0;
//	if (_image) {
//		imageAdjustment = 7+_image.size.height;
//	}
//	
//	self.bounds = CGRectMake(0, 0, s.width+40, s.height+15+15+imageAdjustment);
//	
//	_messageRect.size = s;
//	_messageRect.size.height += 5;
//	_messageRect.origin.x = 20;
//	_messageRect.origin.y = 15+imageAdjustment;
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
	
}
- (void) setMessageText:(NSString*)str{
	[self.messageLabel setText:str];
}
- (void) setImage:(UIImage*)img{
	[self.faceImageView setImage:img];
}

- (void)initWithType:(MessageViewType)type
               image:(UIImage *)image
                text:(NSString *)text
{
    [self setImage:image];
    self.faceImageView.hidden = NO;
    [self.messageBackgroundView setImage:[UIImage imageNamed:[GameApp popupMessageDialogBackgroundImage]]];
    [self.messageLabel setTextColor:[GameApp popupMessageDialogFontColor]];
    [self setMessageText:text];
    

    [self.messageLabel setTextAlignment:UITextAlignmentCenter];
    
    switch (type) {
        case MessageViewTypeTextOnly: {
            [self.faceImageView setFrame:CGRectMake(0, 0, 0, 0)];
            [self.messageLabel setCenter:CGPointMake(self.bounds.size.width/2, self.messageLabel.center.y)];
        } break;
        case MessageViewTypeWithSmallImage: {
            [self.faceImageView setFrame:SMALL_IMAGE_FRAME];
            float x = (self.bounds.size.width/2 + self.faceImageView.frame.origin.x/2 + self.faceImageView.frame.size.width/2);
            [self.messageLabel setCenter:CGPointMake(x, self.messageLabel.center.y)];
        } break;
        case MessageViewTypeWithHappyFace: {
            [self.faceImageView setFrame:HAPPY_FACE_FRAME];
            [self.faceImageView setImage:[[CommonImageManager defaultManager] commonMessageCenterHappyFace]];
            
        } break;
        case MessageViewTypeWithUnhappyFace: {
            [self.faceImageView setFrame:UNHAPPY_FACE_FRAME];
            [self.faceImageView setImage:[[CommonImageManager defaultManager] commonMessageCenterUnhappyFace]];
        }
        default:
            break;
    }
    
    CGRect rect = self.messageLabel.frame;
    rect.size.width = self.bounds.size.width - SEPERATOR_X*2 - self.faceImageView.frame.size.width - self.faceImageView.frame.origin.x;
    rect.origin.x = self.faceImageView.frame.size.width + SEPERATOR_X + self.faceImageView.frame.origin.x;
    [self.messageLabel setFrame:rect];

}

@end


@implementation CommonMessageCenter
@synthesize messages = _messages;
@synthesize delegate = _delegate;

#pragma mark Init & Friends
+ (CommonMessageCenter*) defaultCenter {
	static CommonMessageCenter *defaultCenter = nil;
	if (!defaultCenter) {
		defaultCenter = [[CommonMessageCenter alloc] init];
	}
	return defaultCenter;
}
- (id) init{
	if(!(self=[super init])) return nil;
	
	_messages = [[NSMutableArray alloc] init];
	_messageView = [[CommonMessageView createMessageViewByTheme:globalGetTheme()] retain];
	_active = NO;
	
	
	_messageFrame = [UIApplication sharedApplication].keyWindow.bounds;
    
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardDidHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationWillChange:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
	return self;
}
- (void) dealloc{
	[_messages release];
	[_messageView release];
	[super dealloc];
}


#pragma mark Show Alert Message

- (void) clearMessages
{
    if ([_messages count] > 1) {
        NSObject *firstAlert = [_messages objectAtIndex:0];
        [firstAlert retain];
        [_messages removeAllObjects]; 
        [_messages addObject:firstAlert];        
        [firstAlert release];
    }
}
#define INDEX_OF_WORDS 0
#define INDEX_OF_DELAY_TIME 1
#define INDEX_OF_MESSAGE_VIEW_TYPE 2
#define INDEX_OF_IMAGE 3

- (void) showAlertsAtHorizon:(int)horizon{
	
	if([_messages count] < 1) {
		_active = NO;
		return;
	}
	
//	_active = YES;

	NSArray *ar = [_messages objectAtIndex:0];
	
	UIImage *img = nil;
    int type = 0;
    NSString* text = @"";
	if([ar count] > INDEX_OF_MESSAGE_VIEW_TYPE)
    {
        if ([ar count] > INDEX_OF_IMAGE) img = [[_messages objectAtIndex:0] objectAtIndex:INDEX_OF_IMAGE];
        
        type = ((NSNumber*)[[_messages objectAtIndex:0] objectAtIndex:INDEX_OF_MESSAGE_VIEW_TYPE]).intValue;
        text = [[_messages objectAtIndex:0] objectAtIndex:INDEX_OF_WORDS];
    }
    
    
    [_messageView initWithType:type image:img text:text];
	
	if (_dismissTimer) {
        if ([_dismissTimer isValid]) {
            [_dismissTimer invalidate];
            [_dismissTimer release];
            _dismissTimer = nil;
        }
    }
    NSNumber* delayTime = [[_messages objectAtIndex:0] objectAtIndex:INDEX_OF_DELAY_TIME];
    _dismissTimer = [[NSTimer scheduledTimerWithTimeInterval:delayTime.floatValue target:self selector:@selector(animationStep2) userInfo:nil repeats:NO] retain];
	
	
	
	if (!_active) {
        _active = YES;
        _horizon = horizon;
        
        [[UIApplication sharedApplication].keyWindow addSubview:_messageView];
        _messageView.transform = CGAffineTransformIdentity;
        _messageView.alpha = 0;

        _messageView.center = CGPointMake(_messageFrame.origin.x+_messageFrame.size.width/2, _messageFrame.origin.y+_horizon+_messageFrame.size.height/2);
        
        
        CGRect rr = _messageView.frame;
        rr.origin.x = (int)rr.origin.x;
        rr.origin.y = (int)rr.origin.y;
        _messageView.frame = rr;
        
        UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
        CGFloat degrees = 0;
        if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
        else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
        else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
        _messageView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
        _messageView.transform = CGAffineTransformScale(_messageView.transform, 2, 2);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.15];
        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationStep2)];
        
        _messageView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
        _messageView.frame = CGRectMake((int)_messageView.frame.origin.x, (int)_messageView.frame.origin.y, _messageView.frame.size.width, _messageView.frame.size.height);
        _messageView.alpha = 1;
        
        [UIView commitAnimations];
            }

	
}
- (void) animationStep2{
	[UIView beginAnimations:nil context:nil];
    
	// depending on how many words are in the text
	// change the animation duration accordingly
	// avg person reads 200 words per minute
	//NSArray * words = [[[_messages objectAtIndex:0] objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSNumber* delayTime = [[_messages objectAtIndex:0] objectAtIndex:INDEX_OF_DELAY_TIME];
	//double duration = MAX(((double)[words count]*60.0/200.0),1);
//    double duration = delayTime.floatValue;
	
	[UIView setAnimationDelay:0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationStep3)];
	
	UIInterfaceOrientation o = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	_messageView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_messageView.transform = CGAffineTransformScale(_messageView.transform, 0.5, 0.5);
	
	_messageView.alpha = 0;
	[UIView commitAnimations];
}
- (void) animationStep3{
	
	[_messageView removeFromSuperview];
    if ([_messages count] != 0) {
        [_messages removeObjectAtIndex:0];        
    }
    if ([self.delegate respondsToSelector:@selector(didShowedAlert)]) {
        [self.delegate didShowedAlert];
    }
    _active = NO;
//	[self showAlertsAtHorizon:_horizon];
	
}
- (void)postMessageWithText:(NSString *)text 
                      image:(UIImage *)image
            messageViewType:(MessageViewType)type
                  delayTime:(float)delayTime{
	[_messages setObject:[NSArray arrayWithObjects:text, [NSNumber numberWithFloat:delayTime], [NSNumber numberWithInt:type], image, nil] atIndexedSubscript:0];
	[self showAlertsAtHorizon:0];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime{
	[self postMessageWithText:text 
                        image:nil
              messageViewType:MessageViewTypeTextOnly
                    delayTime:delayTime];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime 
                    isHappy:(BOOL)isHappy
{
    int type;
    if (isHappy) {
        type = MessageViewTypeWithHappyFace;
    } else {
        type = MessageViewTypeWithUnhappyFace;
    }
	[self postMessageWithText:text 
                        image:nil
              messageViewType:type
                    delayTime:delayTime];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime
               isSuccessful:(BOOL)isSuccessful
{
    UIImage* face;
    if (isSuccessful) {
        face = [UIImage imageNamed:@"right.png"];
    } else {
        face = [UIImage imageNamed:@"wrong.png"];
    }
	[self postMessageWithText:text
                        image:face
              messageViewType:MessageViewTypeWithSmallImage
                    delayTime:delayTime];
}

#pragma mark - show with horizon
- (void)postMessageWithText:(NSString *)text 
                      image:(UIImage *)image
            messageViewType:(MessageViewType)type
                  delayTime:(float)delayTime 
                  atHorizon:(int)horizon{
	[_messages setObject:[NSArray arrayWithObjects:text, [NSNumber numberWithFloat:delayTime], [NSNumber numberWithInt:type], image, nil] atIndexedSubscript:0];
	[self showAlertsAtHorizon:horizon];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime 
                  atHorizon:(int)horizon{
	[self postMessageWithText:text
                        image:nil
              messageViewType:MessageViewTypeTextOnly
                    delayTime:delayTime
                    atHorizon:horizon];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime 
                    isHappy:(BOOL)isHappy 
                  atHorizon:(int)horizon
{
    int type = 0;
    if (isHappy) {
        type = MessageViewTypeWithHappyFace;
    } else {
        type = MessageViewTypeWithUnhappyFace;
    }
	[self postMessageWithText:text 
                        image:nil
              messageViewType:type
                    delayTime:delayTime 
                    atHorizon:horizon];
}
- (void)postMessageWithText:(NSString *)text 
                  delayTime:(float)delayTime
               isSuccessful:(BOOL)isSuccessful 
                  atHorizon:(int)horizon
{
    UIImage* face;
    if (isSuccessful) {
        face = [UIImage imageNamed:@"right.png"];
    } else {
        face = [UIImage imageNamed:@"wrong.png"];
    }
	[self postMessageWithText:text 
                        image:face
              messageViewType:MessageViewTypeWithSmallImage
                    delayTime:delayTime 
                    atHorizon:horizon];
}



#pragma mark System Observation Changes
CGRect subtractMessageRect(CGRect wf,CGRect kf);
CGRect subtractMessageRect(CGRect wf,CGRect kf){
	
	
	
	if(!CGPointEqualToPoint(CGPointZero,kf.origin)){
		
		if(kf.origin.x>0) kf.size.width = kf.origin.x;
		if(kf.origin.y>0) kf.size.height = kf.origin.y;
		kf.origin = CGPointZero;
		
	}else{
		
		
		kf.origin.x = abs(kf.size.width - wf.size.width);
		kf.origin.y = abs(kf.size.height -  wf.size.height);
		
		
		if(kf.origin.x > 0){
			CGFloat temp = kf.origin.x;
			kf.origin.x = kf.size.width;
			kf.size.width = temp;
		}else if(kf.origin.y > 0){
			CGFloat temp = kf.origin.y;
			kf.origin.y = kf.size.height;
			kf.size.height = temp;
		}
		
	}
	return CGRectIntersection(wf, kf);
	
	
	
}
- (void) keyboardWillAppear:(NSNotification *)notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect kf = [aValue CGRectValue];
	CGRect wf = [UIApplication sharedApplication].keyWindow.bounds;
	
	[UIView beginAnimations:nil context:nil];
	_messageFrame = subtractMessageRect(wf,kf);
	_messageView.center = CGPointMake(_messageFrame.origin.x+_messageFrame.size.width/2, _messageFrame.origin.y+_messageFrame.size.height/2);
    
	[UIView commitAnimations];
    
}
- (void) keyboardWillDisappear:(NSNotification *) notification {
	_messageFrame = [UIApplication sharedApplication].keyWindow.bounds;
    
}
- (void) orientationWillChange:(NSNotification *) notification {
	
	NSDictionary *userInfo = [notification userInfo];
	NSNumber *v = [userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey];
	UIInterfaceOrientation o = [v intValue];
	
	
	
	
	CGFloat degrees = 0;
	if(o == UIInterfaceOrientationLandscapeLeft ) degrees = -90;
	else if(o == UIInterfaceOrientationLandscapeRight ) degrees = 90;
	else if(o == UIInterfaceOrientationPortraitUpsideDown) degrees = 180;
	
	[UIView beginAnimations:nil context:nil];
	_messageView.transform = CGAffineTransformMakeRotation(degrees * M_PI / 180);
	_messageView.frame = CGRectMake((int)_messageView.frame.origin.x, (int)_messageView.frame.origin.y, (int)_messageView.frame.size.width, (int)_messageView.frame.size.height);
	[UIView commitAnimations];
	
}

@end
