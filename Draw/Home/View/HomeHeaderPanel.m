//
//  HomeHeaderView.m
//  Draw
//
//  Created by gamy on 12-12-8.
//
//

#import "HomeHeaderPanel.h"

@implementation HomeHeaderPanel

+ (id)createView:(id)delegate
{
    NSString* identifier = [HomeHeaderPanel getViewIdentifier];
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
    return @"HomeHeaderPanel";
}
- (void)updateView
{
    
}

@end
