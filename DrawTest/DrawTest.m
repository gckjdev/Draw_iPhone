//
//  DrawTest.m
//  DrawTest
//
//  Created by Gamy on 13-11-5.
//
//

#import "DrawTest.h"
#import "GroupService.h"
#import "GameNetworkConstants.h"
#import "UserManager.h"

@implementation DrawTest

//checked
- (void)createGroup:(NSString *)name level:(NSInteger)level
{
    [self.groupService createGroup:name
                             level:level
                          callback:^(PBGroup *group, NSError *error) {
        self.group = group;
        self.error = error;
    }];
}

//checked
- (void)getGroup:(NSString *)groupId
{
    [self.groupService getGroup:groupId callback:^(PBGroup *group, NSError *error) {
        self.group = group;
        self.error = error;
    }];
}

//checked
- (void)getNewGroups
{
    [self.groupService getNewGroups:0 limit:20 callback:^(NSArray *list, NSError *error) {
        self.groups = list;
        self.error = error;
    }];
}



- (void)setUp
{
    [super setUp];
    self.groupService = [GroupService defaultService];
    [self.groupService setTestMode:YES];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
    self.groupService = nil;
    [self.groupService setTestMode:NO];
}
NSString *groupId = @"527b5ba40364c3b63ddf5386";
NSString *uid = @"4f95717e260967aa715a5af4";


- (void)t1estAcceptGroup
{
    [self.groupService acceptUser:uid group:groupId callback:^(NSError *error) {
        STAssertNil(error, @"success!!!");
        STAssertTrue(error.code == ERROR_GROUP_USER_NOT_REQUESTSTATUS, error.localizedDescription);
    }];
}


- (void)testRejectGroup
{
    [self.groupService rejectUser:uid group:groupId reason:@"get out!!!" callback:^(NSError *error) {
        STAssertNil(error, @"success!!!");
        STAssertTrue(error.code == ERROR_GROUP_USER_NOT_REQUESTSTATUS, error.localizedDescription);
    }];
}

- (void)t1estJoinGroup{
    [self.groupService joinGroup:groupId message:@"let me in!!!" callback:^(NSError *error) {
        STAssertNil(error, @"success!!!");
        STAssertTrue(error.code == ERROR_GROUP_MULTIREQUESTED, error.localizedDescription);
    }];
}



- (void)t1estCreateGroup{
    [self createGroup:@"DS家族" level:12];
    STAssertNotNil(self.group, @"group should not be null!!");
    STAssertNil(self.error, @"error should be nil");
}


@end
