//
//  SearchPhotoController.h
//  Draw
//
//  Created by Kira on 13-6-17.
//
//

#import "PPViewController.h"

@interface SearchPhotoController : PPViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UITextField *searchTextField;

- (IBAction)clickSearch:(id)sender;
- (IBAction)clickOptions:(id)sender;
- (IBAction)clickKeywordBtn:(id)sender;

@end
