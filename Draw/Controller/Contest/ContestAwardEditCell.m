//
//  ContestAwardEditCell.m
//  Draw
//
//  Created by 王 小涛 on 14-1-3.
//
//

#import "ContestAwardEditCell.h"
#import "StringUtil.h"

@interface ContestAwardEditCell()<UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UILabel *numberLabel;
@property (retain, nonatomic) IBOutlet UITextField *awardTextField;
@property (retain, nonatomic) IBOutlet UILabel *coinLabel;

@end

@implementation ContestAwardEditCell

+ (id)createCell:(id)delegate{
    
    ContestAwardEditCell *cell = [super createCell:delegate];
    cell.numberLabel.textColor = COLOR_BROWN;
    cell.coinLabel.textColor = COLOR_BROWN;
    cell.awardTextField.textColor = COLOR_ORANGE;
    
    cell.coinLabel.text = NSLS(@"kCoin");
    cell.awardTextField.returnKeyType = UIReturnKeyDone;
    cell.awardTextField.delegate = cell;
    cell.awardTextField.keyboardType = UIKeyboardTypeNumberPad;    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:NSLS(@"kDone") style:UIBarButtonItemStyleDone target:cell.awardTextField action:@selector(resignFirstResponder)],
                           nil];
    [numberToolbar sizeToFit];
    cell.awardTextField.inputAccessoryView = numberToolbar;
    
    [cell.awardTextField addTarget:cell action:@selector(awardTextFieldValueChanged:) forControlEvents:UIControlEventEditingDidEnd];
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];

    return YES;
}

- (void)awardTextFieldValueChanged:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(didEditRow:award:)]) {
        [self.delegate didEditRow:self.indexPath.row award:[textField.text toNumber].intValue];
    }
}

+ (NSString *)getCellIdentifier{
    
    return @"ContestAwardEditCell";
}

+ (float)getCellHeight{
    
    return 44;
}

- (void)setRank:(NSString *)rank award:(int)award{
    
    self.numberLabel.text = rank;
    self.awardTextField.text = [NSString stringWithFormat:NSLS(@"%d"), award];
    
}

- (void)dealloc {
    [_numberLabel release];
    [_awardTextField release];
    [_coinLabel release];
    [super dealloc];
}

@end
