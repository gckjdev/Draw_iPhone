//
//  RoundRectShape.m
//  Draw
//
//  Created by gamy on 13-5-30.
//
//

#import "RoundRectShape.h"


@interface RoundRectShape ()

//@property(nonatomic, retain) CALayer *layer;

@end

/*
#define ROUND_RADIO (1.0/5.0)
#define R (ROUND_RADIO)

#define POINT_COUNT 8

CGFloat P[8][2]= {
    {R,0},{1-R,0}, //TOP
    
    {1,R},{1,1-R}, //RIGHT
    
    {1-R,1},{R,1}, //BOTTOM
    
    {0,1-R},{0,R}, //LEFT
};
*/

#define RADIUS 10

@implementation RoundRectShape


//- (CALayer *)la


- (void)drawInContext:(CGContextRef)context
{
    
    CGRect rrect = [self rect];//CGRectMake(210.0, 90.0, 60.0, 60.0);
	CGFloat radius = RADIUS;
    
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);


    CGContextSaveGState(context);

    if(self.stroke){
        CGContextSetLineWidth(context, self.width);
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);        
        CGContextStrokePath(context);
    }else{
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillPath(context);
    }
    CGContextRestoreGState(context);

}

@end
