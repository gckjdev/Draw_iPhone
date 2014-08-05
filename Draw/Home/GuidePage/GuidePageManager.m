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

//初始化指导页
-(ICETutorialController *)initGuidePage{
    ICETutorialPage *layr1 = nil;
    ICETutorialPage *layr2 = nil;
    ICETutorialPage *layr3 = nil;
    ICETutorialPage *layr4 = nil;
//    if(ISIPAD){
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
        
//    }else{
//        layr1 = [[ICETutorialPage alloc] initWithTitle:@""
//                                                                subTitle:@""
//                                                             pictureName:@"1.png"
//                                                                duration:3.0];
//        layr2 = [[ICETutorialPage alloc] initWithTitle:@""
//                                                                subTitle:@""
//                                                             pictureName:@"2.png"
//                                                                duration:3.0];
//        layr3 = [[ICETutorialPage alloc] initWithTitle:@""
//                                                                subTitle:@""
//                                                             pictureName:@"3.png"
//                                                                duration:2.0];
//        
//        layr4 = [[ICETutorialPage alloc] initWithTitle:@""
//                                                                subTitle:@""
//                                                             pictureName:@"4.png"
//                                                                duration:3.0];
//        
//        
//    }
    
    
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
    
    ICETutorialController *guidePage = [[[ICETutorialController alloc] initWithPages:tutorialLayers delegate:self] autorelease];
    return guidePage;
}


- (void)tutorialController:(ICETutorialController *)tutorialController scrollingFromPageIndex:(NSUInteger)fromIndex toPageIndex:(NSUInteger)toIndex {
    NSLog(@"Scrolling from page %lu to page %lu.", (unsigned long)fromIndex, (unsigned long)toIndex);
}
//左键
- (void)tutorialControllerDidReachLastPage:(ICETutorialController *)tutorialController {
    NSLog(@"Tutorial reached the last page.");
    //TODO
}

//右键
- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnLeftButton:(UIButton *)sender {
    NSLog(@"Button 1 pressed.");
    [self performSelector: @selector(clickBack:) withObject:nil afterDelay:0];
    //TODO
}

- (void)tutorialController:(ICETutorialController *)tutorialController didClickOnRightButton:(UIButton *)sender {
    
    MetroHomeController *mc = [[MetroHomeController alloc] init];
    [self.navigationController pushViewController:mc animated:YES];
    [mc release];
//    [self.viewController stopScrolling];
}

- (void)dealloc
{
    [super dealloc];
    PPRelease(_layerList);
}

-(void)addNewLayer:(NSString *)title WithSubTitle:(NSString *)subTitle WithPicName:(NSString *)picName WithDuration:(NSTimeInterval)duration{
   ICETutorialPage *layer  = [[ICETutorialPage alloc] initWithTitle:title
                                                            subTitle:subTitle
                                                         pictureName:picName
                                                            duration:duration];

    [self.layerList addObject:layer];
}
@end
