//
//  CacheDrawManager.h
//  Draw
//
//  Created by gamy on 13-6-20.
//
//


/*
 
 //绘制
    1、使用UIImage + CGLayer + UIView的方式去显示DrawAction
    2、image 将会绘制在CGLayer的最前面
    3、当前正在画的一笔直接显示在View上，如果是形状或者是改变前景色，或者前景图片，直接写进CGLayer
    4、当画完一笔之后，将这一笔加进CGLayer中去
    5、当CGLayer的笔画数超过200的时候，就将前面100笔生成和image生成新的image, cglayer显示后面的50笔
    
 //加载草稿
    1、从草稿中读取DrawActionList
    2、如果笔画数多于200笔的时候，就将后面100笔放到CGLayer中，剩下的生成图片
    3、如果不超过，直接现在CGLayer上而不生成图片

 
 //设置背景图
 
    如果有背景图的话直接显示在CGLayer的最底层 //DrawOnPhoto、聊天 ***记得测试这部分*** 
 
*/

#import <Foundation/Foundation.h>


@class DrawAction;

@interface CacheDrawManager : NSObject

@property(nonatomic, retain)UIImage* bgPhto;
@property(nonatomic, assign)CGRect rect;
@property(nonatomic, assign)BOOL showGrid;
@property(nonatomic, retain)NSArray *drawActionList; //a pointer point to drawview/showview drawActionList
@property(nonatomic, assign)BOOL useCachedImage; //default is YES, in showDrawView it is NO.

+ (id)managerWithRect:(CGRect)rect;

- (void)reset;

//add draw action and draw it in the last layer.
- (CGRect)addDrawAction:(DrawAction *)action;

//read from draft
- (void)updateWithDrawActionList:(NSArray *)drawActionList;

//show all the action render in the layer list
- (void)showInContext:(CGContextRef)context;

- (CGRect)updateLastAction:(DrawAction *)action;

- (void)finishDrawAction:(DrawAction *)action;

//Draw View Action
- (BOOL)canUndo;

- (void)undo;

//Show View Action
- (void)showToIndex:(NSInteger)index;




@end
