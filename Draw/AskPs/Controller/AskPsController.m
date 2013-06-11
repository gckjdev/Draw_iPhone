//
//  AskPsController.m
//  Draw
//
//  Created by haodong on 13-6-8.
//
//

#import "AskPsController.h"
#import "AnimationManager.h"
#import "Opus.pb.h"
#import "AskPs.h"

@interface AskPsController ()
@property (retain, nonatomic) AskPs *askPs;
@property (retain, nonatomic) ChangeAvatar *imagePicker;
@property (retain, nonatomic) NSMutableSet *requirementSet;
@end

@implementation AskPsController

- (void)dealloc {
    [_pictureButton release];
    [_imagePicker release];
    [_requirementSet release];
    [_descTextField release];
    [_contentHolderView release];
    [_coinsPerUserTextField release];
    [_coinsMaxTotalTextField release];
    [_ingotBestUser release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPictureButton:nil];
    [self setDescTextField:nil];
    [self setContentHolderView:nil];
    [self setCoinsPerUserTextField:nil];
    [self setCoinsMaxTotalTextField:nil];
    [self setIngotBestUser:nil];
    [super viewDidUnload];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.requirementSet = [NSMutableSet set];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.contentHolderView.contentSize = CGRectMake(_contentHolderView.frame.origin.x, _contentHolderView.frame.origin.y, _contentHolderView.frame.size.width, _contentHolderView.frame.size.height + 1);
}

- (IBAction)clickPictureButton:(id)sende{
    self.imagePicker = [[[ChangeAvatar alloc] init] autorelease];
    [self.imagePicker setAutoRoundRect:NO];
    [self.imagePicker setImageSize:CGSizeMake(0, 0)];
    [self.imagePicker showSelectionView:self];
}

#pragma mark - ChangeAvatarDelegate
- (void)didImageSelected:(UIImage*)image
{
    [self.pictureButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.pictureButton setImage:image forState:UIControlStateNormal];
}

enum {
    TagPerfect = 101,
    TagCute,
    TagUglify,
    TagNotUglify,
    TagFree,
    TagChangeBackground,
    TagMakeFunny,
    TagDomineering 
};

- (NSString *)requirementForTag:(NSUInteger)tag
{
    switch (tag) {
        case TagPerfect:
            return NSLS(@"kRequirementPerfec");
        case TagCute:
            return NSLS(@"kRequirementCute");
        case TagUglify:
            return NSLS(@"kRequirementUglify");
        case TagNotUglify:
            return NSLS(@"kRequirementNotUglify");
        case TagFree:
            return NSLS(@"kRequirementFree");
        case TagChangeBackground:
            return NSLS(@"kRequirementChangeBackground");
        case TagMakeFunny:
            return NSLS(@"kRequirementMakeFunny");
        case TagDomineering:
            return NSLS(@"kRequirementDomineering");
        default:
            return @"";
    }
}

- (IBAction)clickRequirementButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSString *re = [self requirementForTag:button.tag];
    if (button.selected) {
        [_requirementSet addObject:re];
    } else {
        [_requirementSet removeObject:re];
    }
    
    PPDebug(@"list:%@", [_requirementSet allObjects]);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.descTextField) {
        [self.contentHolderView updateOriginY:-150];
    } else {
        [self.contentHolderView updateOriginY:-150];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self.contentHolderView updateOriginY:41];
    [UIView commitAnimations];
    return YES;
}

@end
