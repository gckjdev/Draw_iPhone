//
//  CRBubble.m
//  ProductTour
//
//  Created by Clément Raussin on 12/02/2014.
//  Copyright (c) 2014 Clément Raussin. All rights reserved.
//

#import "CRBubble.h"
#define CR_PADDING 2
#define CR_RADIUS 8
#define COLOR_GLUE_BLUE [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]
#define COLOR_DARK_GRAY [UIColor colorWithWhite:0.13 alpha:1.0]
#define COLOR_ALL_WHITE [UIColor colorWithWhite:1.0 alpha:1.0]


@implementation CRBubble
@synthesize fontName;
@synthesize isVisible;
#pragma mark - Constructor


-(id)initWithAttachedView:(UIView*)view
              description:(NSString*)description
            arrowPosition:(CRArrowPosition)arrowPosition
                 fontSize:(NSInteger)fontSize
                 andColor:(UIColor*)color
{
    self = [super init];
    if(self)
    {
        if(color!=nil)
            self.color=color;
        else
            self.color=COLOR_ALL_WHITE;
        self.attachedView = view;
        self.description = description;
        self.arrowPosition = arrowPosition;
        [self setBackgroundColor:[UIColor clearColor]];
        if(fontName==NULL)
            fontName=@"BebasNeue";
        self.fontSize=fontSize;
        [self size];
    }
    
    float actualXPosition = CR_ARROW_SPACE+CR_PADDING;
    float actualYPosition = CR_ARROW_SPACE+CR_PADDING;
    float actualWidth =[self size].width;
    float actualHeight = self.fontSize/2;

    stringArray=[self.description componentsSeparatedByString:@"\n"];
    
    for (NSString *descriptionLine in stringArray) {
        
        actualYPosition+=actualHeight;
        
        actualWidth = [self size].width;
        actualHeight = self.fontSize;
        
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(actualXPosition+self.fontSize/2, actualYPosition, actualWidth, actualHeight)];
        [descriptionLabel setTextColor:COLOR_ALL_WHITE];
        [descriptionLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [descriptionLabel setText:descriptionLine];
        [descriptionLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:descriptionLabel];
        
    }
    
    [self setFrame:[self frame]];
    [self setNeedsDisplay];
    return self;
}


#pragma mark - Customs methods

-(void)setVisible:(BOOL)visible
{
    isVisible=visible;
}


#pragma mark - Drawing methods


-(CGRect)frame
{
    //Calculation of the bubble position
    float x = self.attachedView.frame.origin.x;
    float y = self.attachedView.frame.origin.y;
    
    switch (self.arrowPosition) {
        //箭头指向： 上 下 左 右 
        case CRArrowPositionTop:
        {
            x+=self.attachedView.frame.size.width/2-[self size].width/2;
            y+=self.attachedView.frame.size.height;
        } break;
        case CRArrowPositionBottom:
        {
            x+=self.attachedView.frame.size.width/2-[self size].width/2;
            y+=-[self size].height;
        } break;
        case CRArrowPositionLeft:
        {
            y+=self.attachedView.frame.size.height/2-[self size].height/2;
            x+=self.attachedView.frame.size.width;
        } break;
        case CRArrowPositionRight:
        {
            y+=self.attachedView.frame.size.height/2-[self size].height/2;
            x+=-[self size].width;
        } break;
        
        //箭头指向： 左上 右上 左下 右下
        case CRArrowPositionTopLeft:
        {
            y+= self.attachedView.frame.size.height;
        } break;
        case CRArrowPositionTopRight:
        {
            x+= +self.attachedView.frame.size.width -[self size].width;
            y+= self.attachedView.frame.size.height;
        } break;
        case CRArrowPositionBottomLeft:
        {
            y+= -[self size].height;
        } break;
        case CRArrowPositionBottomRight:
        {
            x+= +self.attachedView.frame.size.width-[self size].width;
            y+= -[self size].height;
        } break;
            
        default:
            break;
    }
    
    return CGRectMake(x, y, [self size].width, [self size].height);
}

-(CGSize)size
{
    //Cacultation of the bubble size
   
    float height = 2*self.fontSize;
    float width = 0;
    
    float descriptionWidth=0;
    for (NSString *descriptionLine in  stringArray) {
        
        if(descriptionWidth<([descriptionLine length]+3)*self.fontSize)
            descriptionWidth=([descriptionLine length]+3)*self.fontSize;
        
        height+=self.fontSize;
    }

    width+=descriptionWidth;
    return CGSizeMake(width,height);
}



- (void)drawRect:(CGRect)rect
{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:
                          CGRectMake(CR_ARROW_SPACE ,CR_ARROW_SPACE,
                                     [self size].width-2*CR_ARROW_SPACE,
                                     [self size].height-2*CR_ARROW_SPACE
                                     )
                                                    cornerRadius:CR_RADIUS].CGPath;
    CGContextAddPath(ctx, clippath);
    
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    CGPathRef InnerClipPath = [UIBezierPath bezierPathWithRoundedRect:
                               CGRectMake(CR_ARROW_SPACE + CR_PADDING,
                                          CR_ARROW_SPACE + CR_PADDING,
                                          [self size].width-CR_ARROW_SPACE*2-CR_PADDING*2,
                                          [self size].height-CR_ARROW_SPACE*2-CR_PADDING*2)
                                                         cornerRadius:CR_RADIUS].CGPath;
    CGContextAddPath(ctx, InnerClipPath);
    CGContextSetFillColorWithColor(ctx, [[UIColor blackColor]CGColor]);
    
    CGContextClosePath(ctx);
    CGContextFillPath(ctx);
    
    [self.color set];
    
    //勾勒出箭头
    CGPoint startPoint = CGPointMake(0, CR_ARROW_SIZE);
    CGPoint thirdPoint = CGPointMake(CR_ARROW_SIZE/2, 0);
    CGPoint endPoint = CGPointMake(CR_ARROW_SIZE, CR_ARROW_SIZE);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    [path addLineToPoint:thirdPoint];
    [path addLineToPoint:startPoint];
    
    
    if(self.arrowPosition==CRArrowPositionTop)
    {
        CGAffineTransform trans = CGAffineTransformMakeTranslation([self size].width/2-(CR_ARROW_SIZE)/2, 0);
        [path applyTransform:trans];
    }else if(self.arrowPosition==CRArrowPositionBottom)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform trans = CGAffineTransformMakeTranslation([self size].width/2+(CR_ARROW_SIZE)/2, [self size].height);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }else if(self.arrowPosition==CRArrowPositionLeft)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI*1.5);
        CGAffineTransform trans = CGAffineTransformMakeTranslation(0, ([self size].height+CR_ARROW_SIZE)/2);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }else if(self.arrowPosition==CRArrowPositionRight)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI*0.5);
        CGAffineTransform trans = CGAffineTransformMakeTranslation([self size].width, ([self size].height-CR_ARROW_SIZE)/2);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }
    else if(self.arrowPosition==CRArrowPositionTopLeft)
    {
        CGAffineTransform trans = CGAffineTransformMakeTranslation(CR_ARROW_SIZE+CR_RADIUS,0);
        [path applyTransform:trans];
    }
    else if(self.arrowPosition==CRArrowPositionTopRight)
    {
        CGAffineTransform trans = CGAffineTransformMakeTranslation(self.frame.size.width-2*CR_ARROW_SIZE-2*CR_RADIUS,0);
        [path applyTransform:trans];
    }
    else if(self.arrowPosition==CRArrowPositionBottomLeft)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform trans = CGAffineTransformMakeTranslation(2*CR_ARROW_SIZE+CR_RADIUS,[self size].height);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }
    else if(self.arrowPosition==CRArrowPositionBottomRight)
    {
        CGAffineTransform rot = CGAffineTransformMakeRotation(M_PI);
        CGAffineTransform trans = CGAffineTransformMakeTranslation(self.frame.size.width-2*CR_ARROW_SIZE-2*CR_RADIUS,[self size].height);
        [path applyTransform:rot];
        [path applyTransform:trans];
    }
    
    [path closePath]; // Implicitly does a line between p4 and p1
    [path fill]; // If you want it filled, or...
    [path stroke]; // ...if you want to draw the outline.
    CGContextRestoreGState(ctx);
}


@end
