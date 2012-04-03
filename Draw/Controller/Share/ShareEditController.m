//
//  ShareEditController.m
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareEditController.h"
#import "SynthesisView.h"
#define PATTERN_TAG_OFFSET 20120403

@interface ShareEditController ()

@end

@implementation ShareEditController
@synthesize myImage = _myImage;
@synthesize patternsGallery = _patternsGallery;
@synthesize patternsArray = _patternsArray;
@synthesize infuseImageView = _infuseImageView;

- (void)dealloc
{
    [_myImage release];
    [_patternsGallery release];
    [_patternsArray release];
    [_infuseImageView release];
    [super dealloc];
}

- (void)initPatterns
{
    UIImage* myPettern = [UIImage imageNamed:@"guess_pattern.png"];
    [self.patternsArray addObject:myPettern];
}

- (void)initPattenrsGallery
{
    float heigth = self.patternsGallery.frame.size.height;
    
    UIButton* noPatternButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, heigth, heigth)] autorelease];
    noPatternButton.tag = PATTERN_TAG_OFFSET;
    [self.patternsGallery addSubview:noPatternButton];
    [noPatternButton addTarget:self action:@selector(selectPattern:) forControlEvents:UIControlEventTouchUpInside];
    
    
    for (int index = 1; index <= self.patternsArray.count; index ++) {
        UIButton* btn = [[[UIButton alloc] initWithFrame:CGRectMake(heigth*index, 0, heigth, heigth)] autorelease];
        btn.tag = PATTERN_TAG_OFFSET+index;
        [btn setBackgroundImage:[_patternsArray objectAtIndex:index-1] forState:UIControlStateNormal];
        [self.patternsGallery addSubview:btn];
        [btn addTarget:self action:@selector(selectPattern:) forControlEvents:UIControlEventTouchUpInside];
    }

}

- (void)selectPattern:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    if (btn.tag == PATTERN_TAG_OFFSET) {
        [self.infuseImageView setPatternImage:nil];
        [self.infuseImageView setNeedsDisplay];
    } else {
        UIImage* patternImage = [_patternsArray objectAtIndex:0];
        [self.infuseImageView setPatternImage:patternImage];
    }
  
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithImage:(UIImage*)anImage
{
    self = [super init];
    if (self) {
        self.myImage = anImage;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _patternsArray = [[NSMutableArray alloc] init];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initPatterns];
    [self initPattenrsGallery];
    
    [self.infuseImageView setDrawImage:self.myImage];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPatternsGallery:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
