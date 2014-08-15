//
//  TwoInputFieldViewStyle2.h
//  Draw
//
//  Created by ChaoSo on 14-8-15.
//
//

#import <UIKit/UIKit.h>

@interface TwoInputFieldViewStyle2 : UIView<UITextFieldDelegate>


@property (nonatomic, retain)  IBOutlet UILabel* textFieldTitle1;
@property (nonatomic,  retain) IBOutlet UILabel* textFieldTitle2;

@property (retain, nonatomic)  IBOutlet UITextField *textField1;
@property (retain, nonatomic)  IBOutlet UITextField *textField2;

+ (id)create;

@end
