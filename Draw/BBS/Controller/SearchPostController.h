//
//  SearchPostController.h
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "BBSController.h"

@interface SearchPostController : BBSController<UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
- (IBAction)clickSearchButton:(id)sender;
- (IBAction)didKeyWordChanged:(id)sender;

@end
