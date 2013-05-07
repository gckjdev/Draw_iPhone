//
//  SaveToContactPickerView.h
//  Draw
//
//  Created by haodong on 13-5-7.
//
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface SaveToContactPickerView : NSObject <ABPeoplePickerNavigationControllerDelegate>

+ (SaveToContactPickerView *)createWithSuperController:(UIViewController *)controller;

- (void)saveToContact:(UIImage *)iamge;

@end
