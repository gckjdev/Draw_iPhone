//
//  CustomActionSheet.h
//  Draw
//
//  Created by Kira on 12-12-26.
//
//

#import <UIKit/UIKit.h>
#import "HGQuadCurveMenu.h"
#import "CMPopTipView.h"
@class CustomActionSheet;
@class CMPopTipView;

@protocol CustomActionSheetDelegate <NSObject>

- (void)customActionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;


@end


@interface CustomActionSheet : UIView <HGQuadCurveMenuDelegate, CMPopTipViewDelegate>

@property(nonatomic,assign) id<CustomActionSheetDelegate> delegate;    // weak reference
//@property(nonatomic,copy) NSString *title;
@property(nonatomic,readonly) NSInteger numberOfButtons;
@property (nonatomic, assign) BOOL isVisable;


- (id)initWithTitle:(NSString *)title
           delegate:(id<CustomActionSheetDelegate>)delegate
       buttonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithTitle:(NSString *)title
           delegate:(id<CustomActionSheetDelegate>)delegate
         imageArray:(UIImage *)otherBtnImages, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButtonWithTitle:(NSString *)title image:(UIImage*)image;    // returns index of button. 0 based.
- (NSInteger)addButtonWithImage:(UIImage*)image;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (UIImage*)buttonImageAtIndex:(NSInteger)buttonIndex;


// show a sheet animated. you can specify either a toolbar, a tab bar, a bar butto item or a plain view. We do a special animation if the sheet rises from
// a toolbar, tab bar or bar button item and we will automatically select the correct style based on the bar style. if not from a bar, we use
// UIActionSheetStyleDefault if automatic style set

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated NS_AVAILABLE_IOS(3_2);
- (void)showInView:(UIView *)view onView:(UIView*)onView;
- (void)showInView:(UIView *)view
            onView:(UIView*)onView
 WithContainerSize:(CGSize)size
           columns:(int)columns
        showTitles:(BOOL)shouldShowTitles
          itemSize:(CGSize)itemSize
   backgroundImage:(UIImage*)backgroundImage;
- (void)expandInView:(UIView *)view
              onView:(UIView*)onView
           fromAngle:(float)fromAngle
             toAngle:(float)toAngle
              radius:(float)radius
            itemSize:(CGSize)size;
- (void)hideActionSheet;
- (void)setImage:(UIImage*)image
        forTitle:(NSString*)title;

- (void)setBadgeCount:(int)count
             forIndex:(int)index;

- (void)removeAllActions;
@end


