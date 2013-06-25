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
#import "OpusService.h"

@interface AskPsController ()
@property (retain, nonatomic) AskPs *askPs;
@property (retain, nonatomic) ChangeAvatar *imagePicker;
@property (retain, nonatomic) UIImage *pendingImage;
@property (retain, nonatomic) NSMutableSet *requirementSet;
@end

@implementation AskPsController

- (void)dealloc {
    [_pictureButton release];
    [_imagePicker release];
    [_pendingImage release];
    [_requirementSet release];
    [_descTextField release];
    [_contentHolderView release];
    [_coinsPerUserTextField release];
    [_coinsMaxTotalTextField release];
    [_ingotBestUserTextField release];
    [_titleLabel release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPictureButton:nil];
    [self setDescTextField:nil];
    [self setContentHolderView:nil];
    [self setCoinsPerUserTextField:nil];
    [self setCoinsMaxTotalTextField:nil];
    [self setIngotBestUserTextField:nil];
    [self setTitleLabel:nil];
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
//    [self.contentHolderView updateHeight:400];
//    self.contentHolderView.contentSize = CGSizeMake(320, 531);
    [self updateButtonsTitle];
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
    self.pendingImage = image;
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

- (void)updateButtonsTitle
{
    for (NSUInteger tag = TagPerfect; tag <= TagDomineering; tag ++) {
        UIButton *button = (UIButton *)[self.contentHolderView viewWithTag:tag];
        [button setTitle:[self requirementForTag:tag] forState:UIControlStateNormal];
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

- (IBAction)touchDownBackground:(id)sender {
    [_descTextField resignFirstResponder];
    [_coinsPerUserTextField resignFirstResponder];
    [_coinsMaxTotalTextField resignFirstResponder];
    [_ingotBestUserTextField resignFirstResponder];
    [self.contentHolderView setContentOffset:CGPointMake(0,0) animated:YES];
}

- (IBAction)clickSubmitButton:(id)sender {
    int coinsPerUse = [_coinsPerUserTextField.text integerValue];
    int coinsMaxTotal = [_coinsMaxTotalTextField.text integerValue];
    int ingotBestUser = [_ingotBestUserTextField.text integerValue];
    self.askPs = [Opus opusWithCategory:PBOpusCategoryTypeAskPsCategory];
    [_askPs setRequirements:[_requirementSet allObjects]];
    [_askPs setType:PBOpusTypeAskPs];
    [_askPs setDesc:_descTextField.text];
    [_askPs setAwardCoinsPerUser:coinsPerUse];
    [_askPs setAwardCoinsMaxTotal:coinsMaxTotal];
    [_askPs setAwardIngotBestUser:ingotBestUser];
    [[OpusService defaultService] submitOpus:_askPs
                                       image:_pendingImage
                                    opusData:nil
                                 opusManager:[OpusManager askPsManager]
                            progressDelegate:nil
                                    delegate:self];
}

#pragma mark  - OpusServiceDelegate
- (void)didSubmitOpus:(int)resultCode opus:(Opus *)opus
{
    if (resultCode == ERROR_SUCCESS) {
        
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.descTextField) {
        [self.contentHolderView setContentOffset:CGPointMake(0,60) animated:YES];
    } else {
        [self.contentHolderView setContentOffset:CGPointMake(0,160) animated:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.contentHolderView setContentOffset:CGPointMake(0,0) animated:YES];
    return YES;
}

@end
