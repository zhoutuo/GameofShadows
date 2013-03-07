//
//  ShadowsLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import "GameplayScene.h"
#import "ShadowsLayer.h"

#define rotationThreshold 3.0f
@implementation ShadowsLayer

-(id) init {
    if (self = [super init]) {
        shadowHeightFactor = 2.0f;
        shadowWidthFactor = 2.0f;
        objShadowTable = [[NSMutableDictionary alloc] init];
        shadowMonster = [CCSprite spriteWithFile:@"shadow-monster.png"];
        [shadowMonster setPosition:ccp(500, 200)];
        [shadowMonster setVisible:NO];
        [self addChild:shadowMonster z:SHADOW_MONESTER_DEPTH];
        
        wormholeEntrance = [CCSprite spriteWithFile:@"WormholeEntrance.png"];
        [wormholeEntrance setPosition:[shadowMonster position]];
        [self addChild:wormholeEntrance z:WORMHOLE_DEPTH];
        
        wormholeExit = [CCSprite spriteWithFile:@"WormholeExit.png"];
        [wormholeExit setPosition:ccp(500, 500)];
        [self addChild:wormholeExit z:WORMHOLE_DEPTH];
        
        isExitFound = false;

        
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
                    int newX = j + (int)origin.x;
                    int newY = i + (int)origin.y;
                    newX = MAX(0, newX);
                    newX = MIN(newX, DEVICE_WIDTH);
                    
                    newY = MAX(0, newY);
                    newY = MIN(newY, DEVICE_HEIGHT);
                    shadowMap[newY][newX] = true;
                }
            }
        } else {
            //if there is big rotation
            CGPoint origin = boundingBox.origin;
            for (int i = 0; i < boundingBox.size.height; ++i) {
                for (int j = 0; j < boundingBox.size.width; ++j) {
                    CGPoint pointInBoundingBox = ccpAdd(origin, ccp(j, i));
                    if (CGRectContainsPoint(textureRect, [cur convertToNodeSpace:pointInBoundingBox])) {
                        int newX = j + (int)pointInBoundingBox.x;
                        int newY = i + (int)pointInBoundingBox.y;
                        newX = MAX(0, newX);
                        newX = MIN(newX, DEVICE_WIDTH);
                        
                        newY = MAX(0, newY);
                        newY = MIN(newY, DEVICE_HEIGHT);

                        
                        shadowMap[newY][newX] = true;
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

-(void)makeAllTrueShadowMap{
    for(int i=0; i< DEVICE_HEIGHT; i++){
        for(int j =0; j< DEVICE_WIDTH; j++){
            shadowMap[i][j] = true;
        }
    }
}


-(void)pathFinding: (CGPoint)start :(CGPoint)end {

    PathFinder* pathfinder = [[PathFinder alloc]initSize :20 :DEVICE_WIDTH :DEVICE_HEIGHT :clearanceMap];
    CCArray* path = [CCArray array];
    NSMutableArray* actions = [NSMutableArray array];
    [pathfinder findPath:start :end :path];

    for (NSInteger i = [path count] - 1; i >= 0; --i) {
        NSValue* object = [path objectAtIndex:i];
        CGPoint curPoint = object.CGPointValue;
        CCAction* action = [CCMoveTo actionWithDuration:0.01 position:curPoint];
        [actions addObject:action];
    }
    
    if ([actions count] != 0) {
        if (CGRectContainsPoint([wormholeExit boundingBox], end)) {
            isExitFound = true;
            [self scheduleUpdate];
        }
        
        [shadowMonster runAction:[CCSequence actionWithArray:actions]];
    }
}


- (void)update:(ccTime)delta {
    if (isExitFound) {
        if(CGRectContainsPoint([wormholeExit boundingBox], [shadowMonster position])) {
            CCLOG(@"CONG");
            [self unscheduleUpdate];
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

/////////////////
//test

-(bool)checkExpansionCmap: (int)x : (int)y : (int)size{
    
    if(x + size < 1024){
        for(int i =size - 1; i < size + x; i ++){
            if(shadowMap[y + size - 1][i] == false){
                return false;
            }
        }
    }
    
    if(y + size < 768){
        for(int i = size - 1; i < size + y; i ++){
            if(shadowMap[i][x + size - 1] == false){
                return false;
            }
        }
    }
    
    return true;
}

-(void)createClearanceMap{
    
    [self generateShadowMap];
    
    //nested for loop to go over all points in the shadowMap
    for(int i=0; i < 768; i ++){
        for(int j=0; j< 1024; j++){
            
            if(shadowMap[i][j] == true){
                clearanceMap[i][j] = 1;
                
                //see how large we can expand the square for clearance
                //start at 2 and then goooooo on
                for(int k = 2; k < 768; k ++){
                    //increments over the square size
                    if([self checkExpansionCmap:i :j :k] == true){
                        clearanceMap[i][j] = k;
                    }
                    //if there is not an expansion then it will break from the loop
                    else{
                        break;
                    }
                }
            }else{
                // NSLog(@"its a 0");
                clearanceMap[i][j] = 0;
            }//end else cMap i j
        }//end j for loop
    }//end i for loop
}


//end test




//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//SHADOW LAYER EVENTS
-(void) startActionMode {
    [self generateShadowMap];
    [self generateClearanceMap];
    self.isTouchEnabled = YES;
    [shadowMonster setVisible:YES];
    
    CCLOG(@"Enter Action Mode");
}

-(void) finishActionMode {
    self.isTouchEnabled = NO;
    [shadowMonster setVisible:NO];
    CCLOG(@"Leave Action Mode");
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    [self pathFinding :[shadowMonster position] :location];

}

@end
