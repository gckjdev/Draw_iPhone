//
//  HomeMainMenu.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeMainMenu.h"

@interface HomeMainMenu ()

- (IBAction)clickButton:(id)sender;

@end

@implementation HomeMainMenu


+ (id)createView:(id<HomeCommonViewDelegate>)delegate
{
    NSString* identifier = [HomeMainMenu getViewIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find view object from Nib", identifier);
        return nil;
    }
    HomeCommonView<HomeCommonViewProtocol> *view = [topLevelObjects objectAtIndex:0];
    view.delegate = delegate;
    [view updateView];
    return view;
}

+ (NSString *)getViewIdentifier
{
    return @"HomeMainMenu";
}
- (void)updateView
{
    
}

- (void)dealloc {
    [super dealloc];
}
@end
