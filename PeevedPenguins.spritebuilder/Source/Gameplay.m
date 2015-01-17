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
    
    // Invible nodes to implement the drag and drop catapult
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    
    // the penguin we are going to launch and the joint
    // we will use to attach the penguin to the catapult
    CCNode *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
    
}

#pragma mark - VC Life cycle

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
    
    // Deactivate collision for the mouseJointNode
    _mouseJointNode.physicsBody.collisionMask = @[];
    
    // sign up as the collision delegate of our physics node.
    // In this game, whenever a seal is hit by a penguin or ice block,
    // it is crashed
    _physicsNode.collisionDelegate = self;
    self.physicsBody.collisionType = @"seal";
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB
{
    NSLog(@"Something collided with a seal!");
}

#pragma mark - Shooting machanism

// if a player starts touching the catapult arm, we create a sprintJoint between the mouseJointNode and the catapultArm
// whenever a touch moves, we update the position of the mouseJointNode
// when a touch ends we destroy the joint between the mouseJoitnNode and the catapultArm so taht the catapult snaps and fires the penguin

// called on every touch on this scene
- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // get the location of the touch on the content node
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        // moves the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the catapult arm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,138) restLength:0.f stiffness:3000.f damping:150.f];
        
        [self spawnAndAttachPenguin];
    }
}

- (void)spawnAndAttachPenguin
{
    // SPAWN A PENGUIN and then attach it to the scoop of the catapult arm
    // create a penguin from the ccb-file
    _currentPenguin = [CCBReader load:@"Penguin"];
    // inititially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
    CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
    // transfor the world position to the node space to which the penguin will be added (_physicsNode)
    _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
    // add it to the physics world
    [_physicsNode addChild:_currentPenguin];
    // we don't want the penguin to rotate in the scoop
    _currentPenguin.physicsBody.allowsRotation = FALSE;
    
    // create a joint to keep the penguin fixed to the scoop until the catapult arm is released
    _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
}

// whenver a touch moves, we need to update the position of the mouseJointNode so that the catapult arm is dragged in the correct direction.

- (void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    // whenever a touch moves, update the position of the mouseJointNode to the touch position
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

// when a touch ends, we want to destroy our joint and let the catapult snap because we need the code in two places
// (touchEnded:withEvent: and touchCancelled:withEvent) so we are creating a new method for it

- (void)releaseCatapult
{
    if (_mouseJoint != nil) {
        // releases the joint and let the catapult snap back
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        
        [self letThePenguinFly];
    }
}

- (void)letThePenguinFly
{
    // now we need to destroy the joint between the penguin and the scoop,
    // activate rotation for the penguin and add the camera code to
    // follow the penguin again
    // release teh joint and lets the penguin fly
    [_penguinCatapultJoint invalidate];
    _penguinCatapultJoint = nil;
    
    // after snapping, penguin's rotating is fine
    _currentPenguin.physicsBody.allowsRotation = TRUE;
    
    // follow the flying penguin
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
    [_contentNode runAction:follow];
}

// when a touch ended, it means that the user releases their finger,
// release the catapult

- (void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self releaseCatapult];
}

// when a touch cancelled, the user drags their fingers off the screen
// or onto something else, release the catapult also

- (void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event
{
    [self releaseCatapult];
}

#pragma mark - Buttons

- (void)retry {
    // reload the level
    [[CCDirector sharedDirector] replaceScene:[CCBReader loadAsScene:@"Gameplay"]];
}

#pragma mark - Penguin launching

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






















