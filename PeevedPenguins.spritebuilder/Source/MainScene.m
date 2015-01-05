//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene

- (void)play {
    // CCBReader helps load the game play scene
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    // Make a transition to the scene
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

@end
