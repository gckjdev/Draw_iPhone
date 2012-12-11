//
//  coinView.h
//  CoinDemoUikit
//
//  Created by gump on 8/31/12.
//  Copyright (c) 2012 gump. All rights reserved.
//
#define COINPOINT_OFFSET 

@protocol FallingCoinViewDelegate <NSObject>

-(void)coinAnimationFinished;

@end

@class coinImageView;
@class ParticleEmitter3D;

@interface FallingCoinView : UIView
{
    EAGLContext         *context;
    GLuint              viewRenderbuffer, viewFramebuffer;
    GLint               backingWidth;
	GLint               backingHeight;
    GLuint              depthRenderbuffer;
    bool                bDrawPraticle;
    UILabel             *textlabel;
    NSTimer             *coinTimer;
    
    int                 coinTotleNum;
    int                 curCoinNum;
    CGPoint             coinPoint;
    int                 iticktime;
}

@property (nonatomic,strong) NSMutableArray                 *emitters;
@property (nonatomic,strong) NSMutableArray                 *images;
@property (nonatomic,strong) NSMutableArray                 *deleteemitters;
@property (nonatomic,strong) NSMutableArray                 *deleteimages;
@property (nonatomic,assign) id<FallingCoinViewDelegate>             coindelegate;

-(void)initOpenGl;
-(BOOL)createFramebuffer;
-(void)destroyFramebuffer;
-(void)createmitter:(CGPoint) point;
-(void)creatimage:(CGPoint) point;
-(id)initWithFrame:(CGRect)frame withNum:(NSInteger)num valuePerCoin:(NSInteger)value;

@end
