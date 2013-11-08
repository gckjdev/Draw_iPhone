//
//  DrawTest.h
//  DrawTest
//
//  Created by Gamy on 13-11-5.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "GameBasic.pb.h"

@class GroupService;

@interface DrawTest : SenTestCase
@property(nonatomic, strong)PBGroup *group;
@property(nonatomic, strong)NSArray *groups;
@property(nonatomic, strong)NSError *error;
@property(nonatomic, weak)GroupService *groupService;

@end
