//
//  DrawHomeViewController.h
//  Draw
//
//  Created by gamy on 12-12-10.
//
//

#import "SuperHomeController.h"
#import "CommonDialog.h"
#import "HomeHeaderPanel.h"

@interface ZJHHomeViewController : SuperHomeController <CommonDialogDelegate, HomeHeaderPanelDelegate>
{
    
}
+ (id)defaultInstance;
@end
