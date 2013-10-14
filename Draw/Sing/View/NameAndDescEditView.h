//
//  NameAndDescEditView.h
//  Draw
//
//  Created by 王 小涛 on 13-10-12.
//
//

#import <UIKit/UIKit.h>
#import "UIPlaceholderTextView.h"

@interface NameAndDescEditView : UIView <UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UIPlaceholderTextView *descTextView;

+ (id)createViewWithName:(NSString *)name
                    desc:(NSString *)desc;

@end
