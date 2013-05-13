//
//  SaveToContactPickerView.m
//  Draw
//
//  Created by haodong on 13-5-7.
//
//

#import "SaveToContactPickerView.h"
#import "PPViewController.h"
#import "AddressBookUtils.h"
#import "CommonMessageCenter.h"

@interface SaveToContactPickerView()

@property (retain, nonatomic) UIViewController *superController;
@property (retain, nonatomic) UIImage *avatar;

@end


@implementation SaveToContactPickerView

- (void)dealloc
{
    [_superController release];
    [_avatar release];
    [super dealloc];
}

+ (SaveToContactPickerView *)createWithSuperController:(UIViewController *)controller
{
    SaveToContactPickerView *view = [[[SaveToContactPickerView alloc] init] autorelease];
    view.superController = controller;
    return view;
}

- (void)saveToContact:(UIImage *)image
{
    self.avatar = image;
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	[self.superController presentModalViewController:picker animated:YES];
    [picker release];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [peoplePicker dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    PPDebug(@"shouldContinueAfterSelectingPerson");
    
    if ([_superController isKindOfClass:[PPViewController class]]) {
        [(PPViewController *)_superController showActivityWithText:NSLS(@"kSaving")];
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    if (queue == NULL){
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
//    dispatch_async(queue, ^{

    [AddressBookUtils addImage:person image:_avatar];
    ABAddressBookSave(peoplePicker.addressBook, nil);
        
    if ([_superController isKindOfClass:[PPViewController class]]) {
        [(PPViewController *)_superController performSelector:@selector(hideActivity)];
    }
    
    [peoplePicker dismissModalViewControllerAnimated:YES];
    
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSetContactAvatarSucc") delayTime:1.5];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

@end
