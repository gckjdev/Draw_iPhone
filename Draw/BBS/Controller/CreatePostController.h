//
//  CreatePostController.h
//  Draw
//
//  Created by gamy on 12-11-16.
//
//

#import "PPViewController.h"
#import "BBSService.h"

@class PBBBSBoard;
@interface CreatePostController : PPViewController<BBSServiceDelegate>
{
}


- (id)initWithBoard:(PBBBSBoard *)board;
+ (CreatePostController *)enterControllerWithBoard:(PBBBSBoard *)board
                                    fromController:(UIViewController *)fromController;
@property (retain, nonatomic) IBOutlet UITextView *textView;

- (IBAction)clickBackButton:(id)sender;

- (IBAction)clickSubmitButton:(id)sender;

@end
