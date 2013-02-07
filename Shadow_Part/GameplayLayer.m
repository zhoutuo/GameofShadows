//
//  GameplayLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayLayer.h"
#import "GameplayScene.h"

@implementation GameplayLayer

-(id) init {
    if (self = [super init]) {
        
        objectsContainer = [CCNode node];

        
        CCSprite* droid1 = [CCSprite spriteWithFile:@"Droid1.png"];
        [droid1 setPosition:ccp(100, 100)];
        droid1.tag = [GameplayScene TagGenerater];

        
        [self addChild:droid1];

        self.isTouchEnabled = YES;
        touchRect = CGRectMake(0, 0, 700, 300);
        touchedObjectTag = -1;
        
    }
    
    return self;
}

-(CGPoint) getSpriteRelativePos:(CCSprite *)object {
    CGPoint relativePos;
    relativePos.x = (object.position.x - touchRect.origin.x) / touchRect.size.width;
    relativePos.y = (object.position.y - touchRect.origin.y) / touchRect.size.height;
    return relativePos;
}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    for (NSInteger i = 0; i < [self.children count]; ++i) {
        CCSprite* cur = [self.children objectAtIndex:i];
        if (CGRectContainsPoint([cur boundingBox], location)) {
            touchedObjectTag = [cur tag];
            break;
        }
    }
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    
    location = [[CCDirector sharedDirector] convertToGL:location];

    if (touchedObjectTag != -1) {
        CCSprite* touched = (CCSprite*)[self getChildByTag:touchedObjectTag];
        location.x = MIN(location.x, touchRect.origin.x + touchRect.size.width);
        location.x = MAX(location.x, touchRect.origin.x);
        location.y = MIN(location.y, touchRect.origin.y + touchRect.size.height);
        location.y = MAX(location.y, touchRect.origin.y);
        touched.position = location;
        GameplayScene* scene = (GameplayScene*)[[CCDirector sharedDirector] runningScene];
        [scene updateShadowPos:touched];
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    touchedObjectTag = -1;
}

@end
