//
//  PenFactory.m
//  Draw
//
//  Created by qqn_pipi on 13-1-19.
//
//

#import "PenFactory.h"
#import "SmoothQuadCurvePen.h"

@implementation PenFactory

+ (id<PenEffectProtocol>)getPen:(ItemType)penType
{
    PPDebug(@"Create New Pen");
    return [[[SmoothQuadCurvePen alloc] init] autorelease];
}


/* used to backup some codes
 
 
 if (self.penType == Pencil){
 // old implementation here, keep
 if (_path == NULL && self.pointCount > 0) {
 [self constructPath];
 }
 
 return _path;
 }
 
 if (_path == NULL && self.pointCount > 0) {
 // here only happen when the draw is finished, if you are drawing on screen, this cannot happen
 [self constructPath];
 [self addPoorPointsIntoPath:_path];
 return _path;
 }
 
 if (ptsComplete){
 return _path;
 
 if (_pathToShow != NULL){
 CGPathRelease(_pathToShow);
 _pathToShow = NULL;
 }
 
 _pathToShow = CGPathCreateMutableCopy(_path);
 [self addPoorPointsIntoPath:_pathToShow];
 return _pathToShow;
 }
 
 if (_pathToShow != NULL){
 CGPathRelease(_pathToShow);
 _pathToShow = NULL;
 }
 
 _pathToShow = CGPathCreateMutableCopy(_path);
 [self addPoorPointsIntoPath:_pathToShow];
 return _pathToShow;
 
 
 // if you don't understand the code below
 // please read here http://mobile.tutsplus.com/tutorials/iphone/ios-sdk_freehand-drawing/
 - (void)addPoint1:(CGPoint)point
 {
 [self addPointIntoPath:point path:_path];
 NSValue *pointValue = [NSValue valueWithCGPoint:point];
 [self.pointList addObject:pointValue];
 }
 
 - (void)releasePathToShow
 {
 if (_pathToShow != NULL){
 CGPathRelease(_pathToShow);
 _pathToShow = NULL;
 }
 }
 
 - (void)addPoorPointsIntoPath2:(CGMutablePathRef)targetPath
 {
 if (ptsCount == 1){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddQuadCurveToPoint(targetPath, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
 }
 else if (ptsCount == 2){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPoint mid = midPoint(pts[0], pts[1]);
 CGPathAddQuadCurveToPoint(targetPath, NULL, mid.x, mid.y, pts[1].x, pts[1].y);
 }
 }
 
 - (void)addPoorPointsIntoPath3:(CGMutablePathRef)targetPath
 {
 if (ptsCount == 1){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddQuadCurveToPoint(targetPath, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
 }
 else if (ptsCount == 2){
 return;
 //        CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 //        CGPoint mid = midPoint(pts[0], pts[1]);
 //        CGPathAddQuadCurveToPoint(targetPath, NULL, mid.x, mid.y, pts[1].x, pts[1].y);
 }
 }
 
 
 - (void)addPoorPointsIntoPath1:(CGMutablePathRef)targetPath
 {
 if (ptsCount == 1){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddQuadCurveToPoint(targetPath, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
 //        CGPathAddCurveToPoint(targetPath, NULL, pts[0].x, pts[0].y,
 //                              pts[0].x, pts[0].y,
 //                              pts[0].x, pts[0].y);
 }
 else if (ptsCount == 2){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPoint mid = midPoint(pts[0], pts[1]);
 CGPathAddCurveToPoint(targetPath, NULL, mid.x, mid.y,
 mid.x, mid.y,
 pts[1].x, pts[1].y);
 }
 else if (ptsCount == 3){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddCurveToPoint(targetPath, NULL, pts[1].x, pts[1].y,
 pts[1].x, pts[1].y,
 pts[2].x, pts[2].y);
 }
 }
 
 - (void)addPoorPointsIntoPath0:(CGMutablePathRef)targetPath
 {
 if (ptsCount == 1){
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddQuadCurveToPoint(targetPath, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
 }
 
 return;
 }
 
 
 - (void)addPointIntoPath:(CGPoint)point path:(CGMutablePathRef)targetPath
 {
 switch (self.penType) {
 case WaterPen:
 [self addPointIntoPath0:point path:targetPath];
 break;
 
 case Pen:
 [self addPointIntoPath1:point path:targetPath];
 break;
 
 case IcePen:
 [self addPointIntoPath2:point path:targetPath];
 break;
 
 case Quill:
 [self addPointIntoPath3:point path:targetPath];
 break;
 
 default:
 break;
 }
 return;
 }
 
 - (void)printPts
 {
 for (int i=0; i<ptsCount; i++){
 //        PPDebug(@"Point[%d]=%@", i, NSStringFromCGPoint(pts[i]));
 }
 }
 
 - (int)maxPtsCount
 {
 switch (_penType) {
 case WaterPen:
 return 5;
 break;
 
 case Pen:
 return 4;
 break;
 
 case IcePen:
 case Quill:
 return 3;
 break;
 default:
 break;
 }
 
 return 0;
 
 }
 
 - (void)addPointIntoPath3:(CGPoint)point path:(CGMutablePathRef)targetPath
 {
 if (targetPath == NULL)
 return;
 
 pts[ptsCount] = point;
 ptsCount ++;
 ptsComplete = NO;
 if (ptsCount == [self maxPtsCount]){
 //        // adjust pts[3]
 //        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0f, (pts[2].y + pts[4].y)/2.0f);
 
 CGPoint mid1 = midPoint(pts[0], pts[1]);
 CGPoint mid2 = midPoint(pts[1], pts[2]);
 
 
 CGPathMoveToPoint(targetPath, NULL, mid1.x, mid1.y);
 CGPathAddQuadCurveToPoint(_path, NULL, pts[1].x, pts[1].y, mid2.x, mid2.y);
 
 //        PPDebug(@"[BEFORE_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 
 // replace pts[0] and pts[1]
 //        pts[0] = pts[3];
 //        pts[1] = pts[4];
 //        ptsCount = 2;
 
 ptsComplete = YES;
 pts[0] = pts[1];
 pts[1] = pts[2];
 ptsCount = 2;
 
 //        PPDebug(@"[AFTER_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 }
 else{
 //        PPDebug(@"[ADD2] ptsCount=%d", ptsCount);
 [self printPts];
 }
 
 
 }
 
 - (void)addPointIntoPath2:(CGPoint)point path:(CGMutablePathRef)targetPath
 {
 if (targetPath == NULL)
 return;
 
 pts[ptsCount] = point;
 ptsCount ++;
 ptsComplete = NO;
 if (ptsCount == [self maxPtsCount]){
 //        // adjust pts[3]
 //        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0f, (pts[2].y + pts[4].y)/2.0f);
 
 
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddQuadCurveToPoint(_path, NULL, pts[1].x, pts[1].y, pts[2].x, pts[2].y);
 
 //        PPDebug(@"[BEFORE_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 
 // replace pts[0] and pts[1]
 //        pts[0] = pts[3];
 //        pts[1] = pts[4];
 //        ptsCount = 2;
 
 ptsComplete = YES;
 pts[0] = pts[2];
 ptsCount = 1;
 
 //        PPDebug(@"[AFTER_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 }
 else{
 //        PPDebug(@"[ADD2] ptsCount=%d", ptsCount);
 [self printPts];
 }
 
 
 }
 
 
 - (void)addPointIntoPath1:(CGPoint)point path:(CGMutablePathRef)targetPath
 {
 if (targetPath == NULL)
 return;
 
 pts[ptsCount] = point;
 ptsCount ++;
 ptsComplete = NO;
 if (ptsCount == [self maxPtsCount]){
 //        // adjust pts[3]
 //        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0f, (pts[2].y + pts[4].y)/2.0f);
 
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddCurveToPoint(targetPath, NULL, pts[1].x, pts[1].y,
 pts[2].x, pts[2].y,
 pts[3].x, pts[3].y);
 
 //        PPDebug(@"[BEFORE_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 
 // replace pts[0] and pts[1]
 //        pts[0] = pts[3];
 //        pts[1] = pts[4];
 //        ptsCount = 2;
 
 ptsComplete = YES;
 pts[0] = pts[3];
 ptsCount = 1;
 
 //        PPDebug(@"[AFTER_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 }
 else{
 //        PPDebug(@"[ADD2] ptsCount=%d", ptsCount);
 [self printPts];
 }
 
 
 }
 
 - (void)addPointIntoPath0:(CGPoint)point path:(CGMutablePathRef)targetPath
 {
 if (targetPath == NULL)
 return;
 
 pts[ptsCount] = point;
 ptsCount ++;
 ptsComplete = NO;
 if (ptsCount == [self maxPtsCount]){
 // adjust pts[3]
 pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0f, (pts[2].y + pts[4].y)/2.0f);
 
 CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
 CGPathAddCurveToPoint(targetPath, NULL, pts[1].x, pts[1].y,
 pts[2].x, pts[2].y,
 pts[3].x, pts[3].y);
 
 //        PPDebug(@"[BEFORE_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 
 // replace pts[0] and pts[1]
 pts[0] = pts[3];
 pts[1] = pts[4];
 ptsCount = 2;
 
 ptsComplete = YES;
 
 //        PPDebug(@"[AFTER_DRAW] ptsCount=%d", ptsCount);
 [self printPts];
 }
 else{
 //        PPDebug(@"[ADD2] ptsCount=%d", ptsCount);
 [self printPts];
 }
 
 - (void)constructPath1
 {
 if (self.pointCount > 0) {
 if (_path == NULL) {
 _path = CGPathCreateMutable();
 ptsCount = 0;
 }
 
 NSInteger count = self.pointCount;
 for (int i=0; i<count; i++){
 [self addPointIntoPath:[self pointAtIndex:i] path:_path];
 }
 }
 }
 
 }

 - (void)clearPath
 {
 if (_path != NULL){
 CGPathRelease(_path);
 _path = NULL;
 }
 
 [self releasePathToShow];
 }

*/
@end
