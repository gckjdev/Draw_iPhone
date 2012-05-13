//
//  ChatController.m
//  Draw
//
//  Created by 小涛 王 on 12-5-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "ChatController.h"
#import "MessageCell.h"
#import "ExpressionManager.h"
#import "PPDebug.h"

#define WIDTH_EXPRESSION_VIEW 45
#define HEIGHT_EXPRESSION_VIEW 45
#define DISTANCE_BETWEEN_EXPRESSION_VIEW 12
#define TAG_EXPRESSION_BUTTON 210

@interface ChatController ()

@end

@implementation ChatController
@synthesize headImageHolderView;
@synthesize headView;
@synthesize nameLabel;
@synthesize microBlogImageView;
@synthesize sexLabel;
@synthesize cityLabel;
@synthesize expressionScrollView;

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
    self.dataList = [NSArray arrayWithObjects:@"a", @"b",  @"c",  @"d",  @"e",  @"f",  @"g",  @"h",  @"i",  @"j", nil];
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [dataTableView setBackgroundColor:[UIColor blackColor]];
    
    [self configureExpressionScrollView];
}

- (void)viewDidUnload
{
    [self setHeadView:nil];
    [self setNameLabel:nil];
    [self setSexLabel:nil];
    [self setCityLabel:nil];
    [self setExpressionScrollView:nil];
    [self setHeadImageHolderView:nil];
    [self setMicroBlogImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [headView release];
    [nameLabel release];
    [sexLabel release];
    [cityLabel release];
    [expressionScrollView release];
    [headImageHolderView release];
    [microBlogImageView release];
    [super dealloc];
}


#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [MessageCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([dataList count]/3+1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [MessageCell getCellIdentifier];
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [MessageCell createCell:self];
        [cell setBackgroundColor:[UIColor whiteColor]];
        cell.messageCellDelegate = self;
    }
    cell.indexPath = indexPath;
    NSInteger index = indexPath.row;
    
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    for (int i = index * 3; i < (index * 3 + 3) && i < [dataList count]; ++ i) {
        NSString *message = [self.dataList objectAtIndex:i];
        [messages addObject:message];
        [cell setCellData:messages];
    }
    [messages release];

    return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - Button actions.
- (IBAction)clickPayAttentionButton:(id)sender {
}

- (IBAction)clickClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickExpression:(id)sender
{
    NSString *key = [(UIButton*)sender titleForState:UIControlStateNormal];
    PPDebug(@"key = %@", key);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MessageCell delegate.
- (void)didSelectMessage:(NSString*)message
{
    PPDebug(@"message = %@", message);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configureExpressionScrollView
{
    NSArray *expressions = [[ExpressionManager defaultManager] allKeys];
    [expressionScrollView setContentSize:CGSizeMake(DISTANCE_BETWEEN_EXPRESSION_VIEW+(WIDTH_EXPRESSION_VIEW+DISTANCE_BETWEEN_EXPRESSION_VIEW)*[expressions count], HEIGHT_EXPRESSION_VIEW)];
    int i = 0;
    for (NSString *key in expressions) {
        UIImage *image = [[ExpressionManager defaultManager] expressionForKey:key];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(DISTANCE_BETWEEN_EXPRESSION_VIEW+(WIDTH_EXPRESSION_VIEW+DISTANCE_BETWEEN_EXPRESSION_VIEW)*i, /*expressionScrollView.frame.size.height*/0, WIDTH_EXPRESSION_VIEW, HEIGHT_EXPRESSION_VIEW)];
        button.tag = TAG_EXPRESSION_BUTTON+i++;
        [button setImage:image forState:UIControlStateNormal];
        [button setTitle:key forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickExpression:) forControlEvents:UIControlEventTouchUpInside];
        [expressionScrollView addSubview:button];
        [button release];
    }
}

//- (void)cleanAvatars
//{
//    //remove all the old avatars
//    for (AvatarView *view in avatarArray) {
//        [view removeFromSuperview];
//    }
//    [avatarArray removeAllObjects];
//}
//
//- (void)updatePlayerAvatars
//{
//    [self cleanAvatars];
//    GameSession *session = [[DrawGameService defaultService] session];
//    int i = 0;
//    for (GameSessionUser *user in session.userList) {
//        AvatarType type = Guesser;
//        if([user.userId isEqualToString:session.drawingUserId])
//        {
//            type = Drawer;
//        }
//        BOOL gender = user.gender;
//        if ([session isMe:user.userId]) {
//            gender = [[UserManager defaultManager] isUserMale];
//        }
//        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] type:type gender:gender];
//        [aView setUserId:user.userId];
//        
//        //set center
//        if ([DeviceDetection isIPAD]) {
//            aView.center = CGPointMake(70 * 2 + AVATAR_VIEW_SPACE * i, 22 * 2.2);            
//        }else{
//            aView.center = CGPointMake(70 + AVATAR_VIEW_SPACE * i, 22);
//        }
//        
//        [self.view addSubview:aView];
//        [avatarArray addObject:aView];
//        [aView release];
//        ++ i;                                  
//    }
//}


@end
