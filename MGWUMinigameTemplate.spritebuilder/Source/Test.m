//
//  Test.m
//  MGWUMinigameTemplate
//
//  Created by Harry Thaman on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Test.h"

@implementation Test
-(void)roll{
    NSLog(@"roll");
    [self.physicsBody applyTorque:10000];
}
@end
