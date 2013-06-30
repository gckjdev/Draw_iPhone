//
//  CommonWaterFlowController.m
//  Draw
//
//  Created by Kira on 13-6-30.
//
//

#import "CommonWaterFlowController.h"
#import "PSCollectionView.h"

@interface CommonWaterFlowController ()

@end

@implementation CommonWaterFlowController

- (void)dealloc
{
    [_dataTableWaterView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
