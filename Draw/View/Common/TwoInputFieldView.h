//
//  TwoInputFieldView.h
//  Draw
//
//  Created by 王 小涛 on 13-9-6.
//
//

#import <UIKit/UIKit.h>

@interface TwoInputFieldView : UIView<UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *textField1;
@property (retain, nonatomic) IBOutlet UITextField *textField2;

+ (id)create;


+ (CommonDialog *)loginViewWithNumber:(NSString *)number passWord:(NSString *)passWord;


@end
