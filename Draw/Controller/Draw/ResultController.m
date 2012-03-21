//
//  ResultController.m
//  Draw
//
//  Created by  on 12-3-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResultController.h"

@implementation ResultController
@synthesize drawImage;
@synthesize upButton;
@synthesize downButton;
@synthesize continueButton;
@synthesize saveButton;
@synthesize exitButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (id)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
//        [self.drawImage setImage:image];        
        _image = image;
        [_image retain];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.drawImage setImage:_image];
}

- (void)viewDidUnload
{
    [self setUpButton:nil];
    [self setDownButton:nil];
    [self setContinueButton:nil];
    [self setSaveButton:nil];
    [self setExitButton:nil];
    [self setDrawImage:nil];
    _image = nil;
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [upButton release];
    [downButton release];
    [continueButton release];
    [saveButton release];
    [exitButton release];
    [drawImage release];
    [_image release];
    [super dealloc];
}
- (IBAction)clickUpButton:(id)sender {
}

- (IBAction)clickDownButton:(id)sender {
}

- (IBAction)clickContinueButton:(id)sender {
}

- (IBAction)clickSaveButton:(id)sender {
    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
}

- (IBAction)clickExitButton:(id)sender {
}
@end
