//
//  LearnDrawPreViewController.h
//  Draw
//
//  Created by gamy on 13-4-15.
//
//

#import "PPViewController.h"
#import "DrawFeed.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface LearnDrawPreViewController : PPViewController <ABPeoplePickerNavigationControllerDelegate>

+ (LearnDrawPreViewController *)enterLearnDrawPreviewControllerFrom:(UIViewController *)fromController
                                                             drawFeed:(DrawFeed *)drawFeed
                                                     placeHolderImage:(UIImage *)image;

@end
