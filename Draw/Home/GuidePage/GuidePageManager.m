//
//  GuidePageManager
//  Draw
//
//  Created by ChaoSo on 14-7-21.
//
//

#import "GuidePageManager.h"
#import "UIViewController+CommonHome.h"
#import "MetroHomeController.h"

@implementation GuidePageManager

+ (void)showGuidePage:(UIViewController*)superController
{
    
    ICETutorialPage *layr1 = nil;
    ICETutorialPage *layr2 = nil;
    ICETutorialPage *layr3 = nil;
    ICETutorialPage *layr4 = nil;

    layr1 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-1.png"
                                          duration:3.0];
    
    layr2 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-2.png"
                                          duration:3.0];
    
    layr3 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-3.png"
                                          duration:2.0];

    layr4 = [[ICETutorialPage alloc] initWithTitle:@""
                                          subTitle:@""
                                       pictureName:@"iphone5-4.png"
                                          duration:3.0];
    
    ICETutorialLabelStyle *titleStyle = [[[ICETutorialLabelStyle alloc] init] autorelease];
    
    [titleStyle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
    [titleStyle setTextColor:[UIColor whiteColor]];
    [titleStyle setLinesNumber:1];
    [titleStyle setOffset:180];
    
    [[ICETutorialStyle sharedInstance] setTitleStyle:titleStyle];
    
    // Set the subTitles style with few properties and let the others by default.
    [[ICETutorialStyle sharedInstance] setSubTitleColor:[UIColor whiteColor]];
    [[ICETutorialStyle sharedInstance] setSubTitleOffset:150];
    
    // Load into an array.
    NSArray *tutorialLayers = @[layr1,layr2,layr3,layr4];
    
    // create guide page
    GuidePageManager *guidePage = [[[GuidePageManager alloc] initWithPages:tutorialLayers delegate:nil] autorelease];
    guidePage.delegate = guidePage;

    [superController.navigationController presentViewController:guidePage animated:NO completion:^{
        
    }];
    
    return;
}

- (void)tutorialController:(ICETutorialController *)tutorialController scrollingFromPageIndex:(NSUInteger)fromIndex toPageIndex:(NSUInteger)toIndex
{
    NSLog(@"Scrolling from page %lu to page %lu.", (unsigned long)fromIndex, (unsigned long)toIndex);
}

//左键
- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController
{
    NSLog(@"Tutorial reached the last page.");
}

//右键
- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnLeftButton:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnRightButton:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    PPRelease(_layerList);
    [super dealloc];
}

-(void)addNewLayer:(NSString *)title WithSubTitle:(NSString *)subTitle WithPicName:(NSString *)picName WithDuration:(NSTimeInterval)duration{
   ICETutorialPage *layer  = [[ICETutorialPage alloc] initWithTitle:title
                                                            subTitle:subTitle
                                                         pictureName:picName
                                                            duration:duration];

    [self.layerList addObject:layer];
}
@end
