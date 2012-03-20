//
//  SelectWordController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectWordController.h"
#import "Word.h"
#import "WordManager.h"
#import "SelectWordCell.h"
#import "DrawViewController.h"
#import "ShowDrawController.h"
#import "DrawGameService.h"

@implementation SelectWordController
@synthesize wordTableView = _wordTableView;
@synthesize wordArray = _wordArray;


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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wordArray = [[WordManager defaultManager]randDrawWordList];
}

- (void)viewDidUnload
{
    [self setWordTableView:nil];
    [self setWordArray:nil];
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
    [_wordTableView release];
    [super dealloc];
}
- (IBAction)clickChangeWordButton:(id)sender {
    self.wordArray = [[WordManager defaultManager]randDrawWordList];
    [self.wordTableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *cellIdentifier = @"WordCell";
    SelectWordCell *cell = [tableView dequeueReusableCellWithIdentifier:[SelectWordCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SelectWordCell createCell:self];
    }
    
    Word *word = [self.wordArray objectAtIndex:indexPath.row];
    [cell setCellInfo:word];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Word *word = [self.wordArray objectAtIndex:indexPath.row];
    DrawGameService *gameService = [DrawGameService defaultService];
    DrawViewController *vc = [DrawViewController instance];
    vc.word = word;
    [[DrawGameService defaultService] startDraw:word.text level:word.level];
    [self.navigationController pushViewController:vc animated:NO];

}
@end
