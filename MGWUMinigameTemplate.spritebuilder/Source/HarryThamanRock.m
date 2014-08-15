//
//  Rock.m
//  MGWUMinigameTemplate
//
//  Created by Harry Thaman on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "HarryThamanRock.h"

@implementation Rock
-(void)bounce{
    if (self.position.y > 0.5) {
        self.scale = .5;
        [self.physicsBody applyForce:ccp(10000, 10000)];
    }
    NSLog(@"bounce");
}
@end
