//
//  ZJHAvatarView.m
//  Draw
//
//  Created by Kira on 12-10-25.
//
//

#import "ZJHAvatarView.h"
#import "GameBasic.pb.h"
#import "HKGirlFontLabel.h"

@interface ZJHAvatarView ()

@end

@implementation ZJHAvatarView
@synthesize roundAvatar = _roundAvatar;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize nickNameLabel = _nickNameLabel;
@synthesize delegate = _delegate;
@synthesize userInfo = _userInfo;

- (void)dealloc
{
    [_roundAvatar release];
    [_backgroundImageView release];
    [_nickNameLabel release];
    [_userInfo release];
    [super dealloc];
}


- (void)addTapGuesture
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOnAvatar)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

- (CGRect)calculateRoundAvatarFrame
{
    if (self.frame.size.height >= self.frame.size.width) {
        return CGRectMake(self.frame.size.width*0.1, self.frame.size.height-self.frame.size.width*0.9, self.frame.size.width*0.8, self.frame.size.width*0.8);
    }
    return CGRectMake(self.frame.size.height*0.1, self.frame.size.height*0.1, self.frame.size.height*0.8, self.frame.size.height*0.8);
}

- (CGRect)calculateNicknameLabelFrame
{
    if (self.frame.size.height >= self.frame.size.width) {
        return CGRectMake(0, 0, self.frame.size.width, self.frame.size.width*0.3);
    }
    return CGRectMake(self.roundAvatar.frame.size.width, 0, self.frame.size.width - self.roundAvatar.frame.size.width, self.frame.size.height*0.3);
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_backgroundImageView];
        
        _roundAvatar = [[DiceAvatarView alloc] initWithFrame:[self calculateRoundAvatarFrame]];
//        _roundAvatar.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:_roundAvatar];
        self.roundAvatar.delegate = self;
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:[self calculateNicknameLabelFrame]];
        [_nickNameLabel setTextColor:[UIColor whiteColor]];
        [_nickNameLabel setBackgroundColor:[UIColor clearColor]];
        [_nickNameLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_nickNameLabel];
        
        
        [self addTapGuesture];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addTapGuesture];
    }
    return self;
}


- (void)startReciprocol:(CFTimeInterval)reciprocolTime
{
    [self.roundAvatar startReciprocol:reciprocolTime];
}

- (void)startReciprocol:(CFTimeInterval)reciprocolTime
           fromProgress:(float)progress
{
    [self.roundAvatar startReciprocol:reciprocolTime
                         fromProgress:progress];
    
}

- (void)stopReciprocol
{
    [self.roundAvatar stopReciprocol];
}



- (void)setImage:(UIImage *)image
{
    [self.roundAvatar setImage:image];
}

- (void)clickOnAvatar
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:self];
    }
}

- (void)setAvatarUrl:(NSString *)url gender:(BOOL)gender
{
    [self.roundAvatar setAvatarUrl:url
                            gender:gender];
}


- (void)setGrayAvatar:(BOOL)isGray
{
    [self.roundAvatar setGrayAvatar:isGray];
}

- (void)setGestureRecognizerEnable:(BOOL)enable
{
    self.userInteractionEnabled = enable;
}

- (void)resetAvatar
{
    [self.backgroundImageView setImage:nil];
    [self.roundAvatar setAvatarUrl:nil gender:NO];
    [self.nickNameLabel setText:nil];
    self.userInfo = nil;
    self.delegate = nil;
    self.roundAvatar.delegate = nil;
}

- (void)updateBackgroundByUser:(PBGameUser*)user
{
//    [self.backgroundImageView setImage:nil];
}

- (void)updateNicknameByUser:(PBGameUser*)user
{
    if (user) {
        [self.nickNameLabel setText:user.nickName];
    }
}

- (void)updateAvatarByUser:(PBGameUser*)user
{
    if (user) {
        [self.roundAvatar setAvatarUrl:user.avatar gender:user.gender];
    }


}

- (void)updateByPBGameUser:(PBGameUser*)user
{
    [self resetAvatar];
    [self updateBackgroundByUser:user];
    [self updateNicknameByUser:user];
    [self updateAvatarByUser:user];
    [self setUserInfo:user];
}

- (void)didClickOnAvatar:(DiceAvatarView *)view
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickOnAvatar:)]) {
        [_delegate didClickOnAvatar:self];
    }
}

- (void)reciprocalEnd:(DiceAvatarView *)view
{
    if (_delegate && [_delegate respondsToSelector:@selector(reciprocalEnd:)]) {
        [_delegate reciprocalEnd:self];
    }
}

@end
