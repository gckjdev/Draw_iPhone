//
//  CustomActionSheet.h
//  Draw
//
//  Created by Kira on 12-12-26.
//
//

#import <UIKit/UIKit.h>
@class CustomActionSheet;

@protocol CustomActionSheetDelegate <NSObject>

- (void)actionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;


@end


@interface CustomActionSheet : UIView

@property(nonatomic,assign) id<CustomActionSheetDelegate> delegate;    // weak reference
//@property(nonatomic,copy) NSString *title;
@property(nonatomic,readonly) NSInteger numberOfButtons;

- (id)initWithTitle:(NSString *)title
           delegate:(id<CustomActionSheetDelegate>)delegate
       buttonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (NSInteger)addButtonWithTitle:(NSString *)title image:(UIImage*)image;    // returns index of button. 0 based.
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (UIImage*)buttonImageAtIndex:(NSInteger)buttonIndex;


// show a sheet animated. you can specify either a toolbar, a tab bar, a bar butto item or a plain view. We do a special animation if the sheet rises from
// a toolbar, tab bar or bar button item and we will automatically select the correct style based on the bar style. if not from a bar, we use
// UIActionSheetStyleDefault if automatic style set

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated NS_AVAILABLE_IOS(3_2);
- (void)showInView:(UIView *)view;


@end


