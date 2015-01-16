//
//  Seal.m
//  PeevedPenguins
//
//  Created by Duc Tran on 1/5/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void)didLoadFromCBB
{
    self.physicsBody.collisionType = @"seal";
}

@end
