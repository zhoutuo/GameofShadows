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
    
    for (int i = 0; i < DEVICE_HEIGHT; ++i) {
        for (int j = 0; j < DEVICE_WIDTH; ++j) {
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

//this method generate a clearance map from shadow map
//this is mainly for a* algorithm to navigate in
//a clearance map plz refer to http://aigamedev.com/open/article/clearance-based-pathfinding/
-(void) generateClearanceMap {
    for (int i = 0; i < DEVICE_HEIGHT; ++i) {
        for (int j = 0; j < DEVICE_WIDTH; ++j) {
            if (shadowMap[i][j]) {
                clearanceMap[i][j] = [self checkingClearanceSize:ccp(i, j)];
            } else {
                clearanceMap[i][j] = 0;
            }
        }
    }
}

//The value on a point shows that how big a clearance squire it can have
//ATTENTION: the point is the lower left corner of the clearance squire
-(int) checkingClearanceSize: (CGPoint) point {
    int res = 1;
    int x = (int)point.x;
    int y = (int)point.y;
    
    //reuse the computed valuees from the 2d array
    //the value for this pos will be at least as big as the value of neighbours - 1
    if (x != 0 and y != 0) {
        res = MAX(clearanceMap[x - 1][y - 1],
                  MAX(clearanceMap[x][y - 1], clearanceMap[x - 1][y])) - 1;
    } else if(x == 0 xor y == 0) {
        if (x == 0) {
            res = clearanceMap[x][y - 1] - 1;
        } else {
            res = clearanceMap[x - 1][y] - 1;
        }
    }
    
    //loop through the boudry of the potential size
    while ((x + res < DEVICE_HEIGHT) and (y + res < DEVICE_WIDTH)) {
        for (int delX = 0; delX <= res; ++delX) {
            if (!shadowMap[x + delX][y + res]) {
                return res;
            }
        }
        
        for (int delY = 0; delY <= res; ++delY) {
            if (!shadowMap[x + res][y + delY]) {
                return res;
            }
        }
        
        //keep increasing the size until we hit the size of the screen
        //or hit non-shaow part
        ++res;
    }

    return res;
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
