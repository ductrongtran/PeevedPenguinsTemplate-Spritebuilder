//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Duc Tran on 1/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay {
    CCPhysicsNode *_physicsNode;
    CCNode *_catapultArm;
    CCNode *_levelNode;
    // The node that holds everything on the gameplay scene
    // we do this so that the retry button will flow with the camera
    // because we will scroll the contentNode not the gamePlay scene
    CCNode *_contentNode;
    // An inivisible node that is jointed with the catapult arm so that it
    // will pull the arm back when we stress it
    CCNode *_pullbackNode;
}

// The shooting mechanism will be triggered whenver a player touches the screen
// is called when CCB file has completed loading
- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    // Load level 1 to the game play scene and add it ass a child
    // to the levelNode
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
    // visual physics bodies and joints
    _physicsNode.debugDraw = true;
    
    // We don't want the _pullbackNode to collide with any other objects so we will need to set the collisionMask to be an empty array.
    // nothing shall collide with the invisible nodes
    _pullbackNode.physicsBody.collisionMask = @[];
}

- (void)retry {
    // reload the level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

// called on every touch on this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self launchPenguin];
}

- (void)launchPenguin
{
    // loads the Penguin.ccb we have set up in Spritebuilder
    CCNode *penguin = [CCBReader load:@"Penguin"];
    
    // position the penguin at the bowl of the catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    
    // add the penguin to the physicsNode of this scene (because it
    // has the physics enabled)
    [_physicsNode addChild:penguin];
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1,0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    // ensure followed object is in visible are when starting
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
    // scrolling the object that we send follow to
    [_contentNode runAction:follow];
}

@end






















