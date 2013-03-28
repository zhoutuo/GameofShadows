//
//  ShadowsLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import "GameplayScene.h"
#import "ShadowsLayer.h"
#import "Globals.h"

#define ROTATIONTHRESHOLD 3.0f
#define SHADOWMONSTER_SIZE 50
#define SHADOWMONSTER_SPEED 80.0f
@implementation ShadowsLayer

-(id) init {
    if (self = [super init]) {
        shadowHeightFactor = 2.0f;
        shadowWidthFactor = 2.0f;
        objShadowTable = [[NSMutableDictionary alloc] init];
        
        
        NSDictionary* levelObjects = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelObjects" ofType:@"plist"]];
        NSString* level = [NSString stringWithFormat: @"Level %d",currentLevel];
        NSArray* portals = [[levelObjects objectForKey: level] objectForKey:@"Portals"];
        
        NSArray* startPortalData = [portals objectAtIndex:0];        
        wormholeEntrance = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", [startPortalData objectAtIndex:0]]];
        [wormholeEntrance setPosition:CGPointMake([[startPortalData objectAtIndex:1] floatValue], [[startPortalData objectAtIndex:2] floatValue])];
        [self addChild:wormholeEntrance z:WORMHOLE_DEPTH];
        
        NSArray* endPortalData = [portals objectAtIndex:1];
        wormholeExit = [CCSprite spriteWithFile:
                        [NSString stringWithFormat:@"%@.png",
                         [endPortalData objectAtIndex:0]]];
        [wormholeExit setPosition:CGPointMake([[endPortalData objectAtIndex:1] floatValue], [[endPortalData objectAtIndex:2] floatValue])];
        [self addChild:wormholeExit z:WORMHOLE_DEPTH];
        
        
        shadowMonster = [CCSprite spriteWithFile:@"squirtle.png"];
        [shadowMonster setPosition: wormholeEntrance.position];
        [shadowMonster setVisible:NO];
        [self addChild:shadowMonster z:SHADOW_MONESTER_DEPTH];
        isMonsterMoving = true; //this is a fake value here to validate the spawn position againt the light
    }
    return self;
}


-(void) dealloc {
    [objShadowTable release];
    [super dealloc];
}

-(CGPoint) calculateShadowPos:(CGPoint)objectRelativePos {
    CGSize wins = [[CCDirector sharedDirector] winSize];
    NSInteger posY = wins.height * objectRelativePos.y;
    NSInteger posX = wins.width * objectRelativePos.x;
    return ccp(posX, posY);
}

-(CCSprite*) getShadowSpriteFromTag: (NSInteger) objectSpriteTag {
    NSNumber* tag = (NSNumber*)[objShadowTable objectForKey:[NSNumber numberWithInteger:objectSpriteTag]];
    NSInteger tagInteger = [tag unsignedIntegerValue];
    CCSprite* child = (CCSprite*)[self getChildByTag:tagInteger];
    return child;
}


-(void) castShadowFrom:(CCArray*)objects withRatios:(CCArray *)ratios {
    
    if (objects.count != ratios.count) {
        return;
    }
    for (int i = 0; i < objects.count; ++i) {
        CCSprite* cur = (CCSprite*)[objects objectAtIndex:i];
        CCTexture2D* texture = cur.texture;
        
        CCSprite* shadow = [CCSprite spriteWithTexture:texture];
        [shadow setColor:ccc3(0, 0, 0)];
        [shadow setScaleY:shadowHeightFactor];
        [shadow setScaleX:shadowWidthFactor];
        
        shadow.tag = [GameplayScene TagGenerater];
        
        [objShadowTable
         setObject:[NSNumber numberWithInteger:shadow.tag]
         forKey:[NSNumber numberWithInteger:cur.tag]];
        
        [self addChild:shadow z:SHADOW_SPRITE_DEPTH];
        
        CGPoint ratio = [[ratios objectAtIndex:i] CGPointValue];
        
        [self updateShadowPos:cur.tag withRelativePos: ratio];
        
    }
}

-(void) updateShadowPos:(NSInteger)objectSpriteTag withRelativePos:(CGPoint)relativePos {
    
    CCSprite* child = [self getShadowSpriteFromTag:objectSpriteTag];
    if (child != nil) {
        child.position = [self calculateShadowPos: relativePos];
    }
}

-(void) updateShadowRot:(NSInteger)objectSpriteTag withAngle:(float)angle {
    CCSprite* child = [self getShadowSpriteFromTag:objectSpriteTag];
    if (child != nil) {
        child.rotation = angle;
    }
}

-(void) generateShadowMap {
    
    GameplayScene* curScene = [GameplayScene getCurrentScene];
    
    for (int i = 0; i < DEVICE_HEIGHT; ++i) {
        for (int j = 0; j < DEVICE_WIDTH; ++j) {
            shadowMap[i][j] = false;
        }
    }
    
    
        
    for (CCSprite* cur in self.children) {
        
        if (cur.zOrder != SHADOW_SPRITE_DEPTH) {
            continue;
        }
        
        CGRect boundingBox = cur.boundingBox;
        CGRect textureRect = cur.textureRect;
        
        CCLOG(@"%f", fabsf(cur.rotation));
        
        
        //if there is no rotation, just scan all points of boundingBox
        if (fabsf(cur.rotation) < ROTATIONTHRESHOLD) {
            CGPoint origin = boundingBox.origin;
            
            for (int i = 0; i < boundingBox.size.height; ++i) {
                for (int j = 0; j < boundingBox.size.width; ++j) {
                    int newX = j + (int)origin.x;
                    int newY = i + (int)origin.y;
                    newX = MAX(0, newX);
                    newX = MIN(newX, DEVICE_WIDTH);
                    
                    newY = MAX(0, newY);
                    newY = MIN(newY, DEVICE_HEIGHT);
                    if([curScene checkLightSourceCoordinates :newY : newX]){
                        shadowMap[newY][newX] = false;
                    }else{
                        shadowMap[newY][newX] = true;
                    }
                    
                }
            }
        } else {
            //if there is big rotation
            int count = 0;
            CGPoint origin = boundingBox.origin;
            for (int i = 0; i < boundingBox.size.height; ++i) {
                for (int j = 0; j < boundingBox.size.width; ++j) {
                    CGPoint pointInBoundingBox = ccpAdd(origin, ccp(j, i));
                    if (CGRectContainsPoint(textureRect, [cur convertToNodeSpace:pointInBoundingBox])) {
                        int newX = (int)pointInBoundingBox.x;
                        int newY = (int)pointInBoundingBox.y;
                        newX = MAX(0, newX);
                        newX = MIN(newX, DEVICE_WIDTH);
                        
                        newY = MAX(0, newY);
                        newY = MIN(newY, DEVICE_HEIGHT);
                        ++count;
                        
                        if([curScene checkLightSourceCoordinates :newY : newX]){
                            shadowMap[newY][newX] = false;
                        } else {
                            shadowMap[newY][newX] = true;
                        }
                    }
                }
            }
            
        }
    }
}


-(void) pathFinding: (CGPoint)end {
    //get the distance to calculate the duration for the moving
    float distance = ccpDistance(shadowMonster.position, end);
    id actionMove = [CCMoveTo actionWithDuration:(distance / SHADOWMONSTER_SPEED) position:end];
    //create callback function which turn the moving off when the moving is done
    id actionCallback = [CCCallFunc actionWithTarget:self selector:@selector(monsterStopsMoving)];
    isMonsterMoving = true;
    //stop the current moving if any
    [shadowMonster stopAllActions];
    //do the moving here
    id actionSeq = [CCSequence actions:actionMove, actionCallback, nil];
    [shadowMonster runAction:actionSeq];
}

-(void) monsterStopsMoving {
    isMonsterMoving = false;
}


-(CCArray*) getCornersOfMonster {
    CCArray* arr = [CCArray array];
    //get boundingbox of shadow monster
    CGRect rect = [shadowMonster boundingBox];
    //get leftupper corner
    CGPoint upperLeft = ccpAdd(rect.origin, ccp(0, rect.size.height));
    //get rightupper corner
    CGPoint upperRight = ccpAdd(rect.origin, ccp(rect.size.width, rect.size.height));
    //get lowerleft corner
    CGPoint lowerLeft = rect.origin;
    //get lowerRight corner
    CGPoint lowerRight = ccpAdd(rect.origin, ccp(rect.size.width, 0));
    [arr addObject: [NSValue valueWithCGPoint:upperLeft]];
    [arr addObject: [NSValue valueWithCGPoint:upperRight]];
    [arr addObject: [NSValue valueWithCGPoint:lowerLeft]];
    [arr addObject: [NSValue valueWithCGPoint:lowerRight]];
    return arr;
    
}


-(void) update:(ccTime)delta {
    if (isMonsterMoving) {
        CCArray* corners = [self getCornersOfMonster];
        GameplayScene* scene = [GameplayScene getCurrentScene];
        for (NSValue* value in corners) {
            CGPoint tmp = value.CGPointValue;
            int x = tmp.x;
            int y = tmp.y;
            if (shadowMap[y][x] == false) {
                [scene shadowMonsterDead];
                return;
            }
        }
        
        
        if(CGRectContainsPoint([wormholeExit boundingBox], shadowMonster.position)) {
            CCLOG(@"CONG");
            //game accomplish event triggered
            [scene shadowMonterRescued];
        }
    }

}



//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//SHADOW LAYER EVENTS
-(void) startActionMode {
    [self generateShadowMap];
    //[self generateClearanceMap];
    self.isTouchEnabled = YES;
    [shadowMonster setVisible:YES];
    [self scheduleUpdate];
    CCLOG(@"Enter Action Mode");
}

-(void) finishActionMode {
    self.isTouchEnabled = NO;
    [shadowMonster setVisible:NO];
    //unschedule the udpate fucntion
    [self unscheduleUpdate];
    CCLOG(@"Leave Action Mode");
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    [self pathFinding :location];

}

@end
