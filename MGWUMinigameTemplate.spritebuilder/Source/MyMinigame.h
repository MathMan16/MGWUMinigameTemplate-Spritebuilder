//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MGWUMinigame.h"
#import "MyCharacter.h"
#import "ccPhysics+ObjectiveChipmunk.h"
#import "HarryThamanGem.h"

@interface MyMinigame : MGWUMinigame <CCPhysicsCollisionDelegate>

// DO NOT DELETE!
@property (nonatomic,retain) MyCharacter *hero;
// DO NOT DELETE!

@end
