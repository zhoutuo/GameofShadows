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
        /*[startPortal setAnchorPoint:CGPointMake([startPortal boundingBox].size.width/2 , [startPortal boundingBox].size.height/2 )];*/
        [wormholeEntrance setPosition:CGPointMake([[startPortalData objectAtIndex:1] floatValue], [[startPortalData objectAtIndex:2] floatValue])];
        [self addChild:wormholeEntrance z:WORMHOLE_DEPTH];
        
        NSArray* endPortalData = [portals objectAtIndex:1];
        wormholeExit = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", [endPortalData objectAtIndex:0]]];
        [wormholeExit setPosition:CGPointMake([[endPortalData objectAtIndex:1] floatValue], [[endPortalData objectAtIndex:2] floatValue])];
        [self addChild:wormholeExit z:WORMHOLE_DEPTH];
        
        
        shadowMonster = [CCSprite spriteWithFile:@"squirtle.png"];
        [shadowMonster setPosition: CGPointMake([wormholeEntrance boundingBox].origin.x
                                                , [wormholeEntrance boundingBox].origin.y)];
        [shadowMonster setAnchorPoint:ccp(0, 0)];
        [shadowMonster setVisible:NO];
        [self addChild:shadowMonster z:SHADOW_MONESTER_DEPTH];
        
        
        /*
        wormholeEntrance = [CCSprite spriteWithFile:@"WormholeEntrance.png"];
        [wormholeEntrance setPosition:[shadowMonster position]];
        [self addChild:wormholeEntrance z:WORMHOLE_DEPTH];
        
        wormholeExit = [CCSprite spriteWithFile:@"WormholeExit.png"];
        [wormholeExit setPosition:ccp(500, 500)];
        [self addChild:wormholeExit z:WORMHOLE_DEPTH];*/
        
        isExitFound = false;
        
        pathFinder = [[PathFinder alloc]init :SHADOWMONSTER_SIZE :DEVICE_WIDTH :DEVICE_HEIGHT :clearanceMap];

        
    }
    return self;
}


-(void) dealloc {
    [objShadowTable release];
    [pathFinder release];
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
    
    GameplayScene* curScene = (GameplayScene*)[[CCDirector sharedDirector] runningScene];
    
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
                        
                        //CCLOG(@"fff");

                        if([curScene checkLightSourceCoordinates :newY : newX]){
                            shadowMap[newY][newX] = false;
                        } else {
                            shadowMap[newY][newX] = true;
                        }
                    }
                }
            }
            
//            CCLOG(@"%d", count);
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
    
    int potential = 0;
    //reuse the computed valuees from the 2d array
    //the value for this pos will be at least as big as the value of neighbours - 1
    if (x != 0 and y != 0) {
        potential = MAX(clearanceMap[x - 1][y - 1],
                  MAX(clearanceMap[x][y - 1], clearanceMap[x - 1][y])) - 1;
    } else if(x == 0 xor y == 0) {
        if (x == 0) {
            potential = clearanceMap[x][y - 1] - 1;
        } else {
            potential = clearanceMap[x - 1][y] - 1;
        }
    }
    
    res = MAX(res, potential);
    
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

//-(void)makeAllTrueShadowMap{
//    for(int i=0; i< DEVICE_HEIGHT; i++){
//        for(int j =0; j< DEVICE_WIDTH; j++){
//            shadowMap[i][j] = true;
//        }
//    }
//}


-(void)pathFinding: (CGPoint)end {

    //PathFinder* pathfinder = [[PathFinder alloc]init :20 :DEVICE_WIDTH :DEVICE_HEIGHT :clearanceMap];
    NSMutableArray *path = [[NSMutableArray alloc] init];
    NSMutableArray* actions = [NSMutableArray array];
    end = ccpSub(end, ccp(shadowMonster.boundingBox.size.width / 2, shadowMonster.boundingBox.size.width / 2));
    [pathFinder findPath:shadowMonster.position :end :path];

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
    [path release];
}


- (void)update:(ccTime)delta {
    if (isExitFound) {
        
        if(CGRectContainsPoint([wormholeExit boundingBox], ccpAdd([shadowMonster position], ccp(shadowMonster.boundingBox.size.width / 2, shadowMonster.boundingBox.size.width / 2)))) {
            CCLOG(@"CONG");
            GameplayScene* scene = (GameplayScene*)[[CCDirector sharedDirector] runningScene];
            [scene shadowMonterRescued];
            [self unscheduleUpdate];
        }
    }
}


//-(void) testShadowMap:(CGPoint)testPoint {
//    CCLOG(@"%@", NSStringFromCGPoint(testPoint));
//    int x = (int) testPoint.x;
//    int y = (int) testPoint.y;
//    
//    if (shadowMap[y][x]) {
//        CCLOG(@"yes");
//    } else {
//        CCLOG(@"no");
//    }
//    
//}

///////////////////
////test
//
//-(bool)checkExpansionCmap: (int)x : (int)y : (int)size{
//    
//    if(x + size < 1024){
//        for(int i =size - 1; i < size + x; i ++){
//            if(shadowMap[y + size - 1][i] == false){
//                return false;
//            }
//        }
//    }
//    
//    if(y + size < 768){
//        for(int i = size - 1; i < size + y; i ++){
//            if(shadowMap[i][x + size - 1] == false){
//                return false;
//            }
//        }
//    }
//    
//    return true;
//}
//
//-(void)createClearanceMap{
//    
//    [self generateShadowMap];
//    
//    //nested for loop to go over all points in the shadowMap
//    for(int i=0; i < 768; i ++){
//        for(int j=0; j< 1024; j++){
//            
//            if(shadowMap[i][j] == true){
//                clearanceMap[i][j] = 1;
//                
//                //see how large we can expand the square for clearance
//                //start at 2 and then goooooo on
//                for(int k = 2; k < 768; k ++){
//                    //increments over the square size
//                    if([self checkExpansionCmap:i :j :k] == true){
//                        clearanceMap[i][j] = k;
//                    }
//                    //if there is not an expansion then it will break from the loop
//                    else{
//                        break;
//                    }
//                }
//            }else{
//                // NSLog(@"its a 0");
//                clearanceMap[i][j] = 0;
//            }//end else cMap i j
//        }//end j for loop
//    }//end i for loop
//}
//
//
////end test




//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//SHADOW LAYER EVENTS
-(void) startActionMode {
    [self generateShadowMap];
    [self generateClearanceMap];
    self.isTouchEnabled = YES;
    [shadowMonster setVisible:YES];
    
    CCLOG(@"Enter Action Mode");
    
    //check whether the shadow monster
    //is inside the shadow or not
    
    CGPoint pos = shadowMonster.position;

    CCLOG(@"%@", NSStringFromCGPoint(pos));
    if (clearanceMap[(int)pos.y][(int)pos.x] < SHADOWMONSTER_SIZE) {
        GameplayScene* scene = (GameplayScene*)[[CCDirector sharedDirector] runningScene];
        [scene shadowMonsterDead];
        CCLOG(@"died");
        CCLOG(@"%d", clearanceMap[(int)pos.y][(int)pos.x]);
    }
    
    
    
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
    [self pathFinding :location];

}

@end
