//
//  ResultSeal.m
//  Draw
//
//  Created by ChaoSo on 14-8-6.
//
//

#import "ResultSeal.h"

@implementation ResultSeal
@synthesize borderColor = _borderColor;
@synthesize context = _context;
@synthesize textFont = _textFont;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        [self setDefault];
        [self updateResultView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        if(color!=nil){
            self.borderColor = color;
        }
        [self setDefault];
        [self updateResultView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)color font:(UIFont *)font text:(NSString *)text
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        if(color!=nil){
            self.borderColor = color;
        }
        if(font!=nil){
            self.textFont = font;
        }
        if(text!=nil){
            self.context = text;
        }
        [self setDefault];
        [self updateResultView];
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
-(void)borderWidth:(CGFloat)width{
    
    self.borderWidth = width;
    
}
-(void)setDefault{
    if(self.borderColor==nil){
        self.borderColor = [UIColor blackColor];
    }
    if(self.context==nil){
        self.context = NSLS(@"kPass");
    }
    if(self.textFont == nil){
        self.textFont = AD_FONT(20, 13);
    }
}


-(void)drawRect:(CGRect)rect{
    
    
    //一个不透明类型的Quartz 2D绘画环境,相当于一个画布,你可以在上面任意绘画
    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIColor*aColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1];
//    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    
    //画笔线的颜色
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, self.borderWidth);//线的宽度
    CGContextAddArc(context, (self.bounds.size.width/2), (self.bounds.size.height/2),
                    self.bounds.size.width/2-self.borderWidth, 0, 2*M_PI, 0); //添加一个圆
    //kCGPathFill填充非零绕数规则,kCGPathEOFill表示用奇偶规则,kCGPathStroke路径,kCGPathFillStroke路径填充,kCGPathEOFillStroke表示描线，不是填充
    CGContextDrawPath(context, kCGPathStroke); //绘制路径加填充
    
}

-(void)updateResultView{
    
    //TODO 将其改成与self frame 有关
    CGFloat radius = self.bounds.size.width/2;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(radius/5.0, 2.0*radius/5.0,8.0*radius/5.0, 6.0*radius/5.0)];
    label.text = self.context;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = COLOR_RED;
    label.backgroundColor = [UIColor clearColor];
    label.font = self.textFont;
    [self addSubview:label];
    [label release];
    
    //旋转
    CGAffineTransform at = CGAffineTransformMakeRotation(-M_PI_4);
    at = CGAffineTransformTranslate(at, 0, 0);
    [self setTransform:at];
    
}
-(void)dealloc{
    PPRelease(_borderColor);
    PPRelease(_context);
    [super dealloc];
}
@end
