//
//  ShadowsLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import "ShadowsLayer.h"
#import "GameplayScene.h"

#define rotationThreshold 3.0f
@implementation ShadowsLayer

-(id) init {
    if (self = [super init]) {
        shadowHeightFactor = 2.0f;
        shadowWidthFactor = 2.0f;
        objShadowTable = [[NSMutableDictionary alloc] init];

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
        
        [self addChild:shadow];
        
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
    
    for (int i = 0; i < 768; ++i) {
        for (int j = 0; j < 1024; ++j) {
            shadowMap[i][j] = false;
        }
    }
    
    for (CCSprite* cur in self.children) {
        CGRect boundingBox = cur.boundingBox;
        CGRect textureRect = cur.textureRect;
                
        //if there is no rotation, just scan all points of boundingBox
        if (cur.rotation < rotationThreshold or (360.0f - cur.rotation) < rotationThreshold) {
            
            CGPoint origin = boundingBox.origin;
            for (int i = 0; i < boundingBox.size.height; ++i) {
                for (int j = 0; j < boundingBox.size.width; ++j) {
                    shadowMap[i + (int)origin.y][j + (int)origin.x] = true;
                }
            }
        } else {
            //if there is big rotation
            CGPoint origin = boundingBox.origin;
            for (int i = 0; i < boundingBox.size.height; ++i) {
                for (int j = 0; j < boundingBox.size.width; ++j) {
                    CGPoint pointInBoundingBox = ccpAdd(origin, ccp(j, i));
                    
                    if (CGRectContainsPoint(textureRect, [cur convertToNodeSpace:pointInBoundingBox])) {
                        shadowMap[(int)pointInBoundingBox.y][(int)pointInBoundingBox.x] = true;
                    }
                }
            }
        }
    }
}

-(void) testShadowMap:(CGPoint)testPoint {
    CCLOG(@"%@", NSStringFromCGPoint(testPoint));
    
    int x = (int) testPoint.x;
    int y = (int) testPoint.y;
    
    if (shadowMap[y][x]) {
        CCLOG(@"yes");
    } else {
        CCLOG(@"no");
    }
    
}

@end
