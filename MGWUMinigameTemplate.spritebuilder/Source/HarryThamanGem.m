//
//  Gem.m
//  MGWUMinigameTemplate
//
//  Created by Harry Thaman on 7/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "HarryThamanGem.h"

@implementation Gem
- (void)didLoadFromCCB
{
    // generate a random number between 0.0 and 2.0
    self.physicsBody.collisionType = @"Gem";
    float delay = (arc4random() % 2000) / 1000.f;
    // call method to start animation after random delay
    [self performSelector:@selector(startFlash) withObject:nil afterDelay:delay];
    self.scale = .4;
    //self.physicsBody.sensor = YES;
}

- (void)startFlash
{
    // the animation manager of each node is stored in the 'animationManager' property
    CCAnimationManager* animationManager = self.animationManager;
    // timelines can be referenced and run by name
    [animationManager runAnimationsForSequenceNamed:@"Flash"];
}



@end
