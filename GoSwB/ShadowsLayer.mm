//
//  ShadowsLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//
#import "GameplayScene.h"
#import "ShadowsLayer.h"
#import "LightSource.h"
#import "Globals.h"

#define ROTATIONTHRESHOLD 3.0f
#define SHADOWMONSTER_SIZE 50
#define SHADOWMONSTER_SPEED 150.0f
#define SHADOW_HEIGHT_FACTOR 2.0f
#define SHADOW_WIDTH_FACTOR 2.0f
@implementation ShadowsLayer

int count_swipe_down = 0;
CCRenderTexture* renderTexture = NULL;

-(id) init {
    if (self = [super init]) {
        
        objShadowTable = [[NSMutableDictionary alloc] init];
        centerCameraX = 0;
        centerCameraX = 0;
        
        //load data from plist
        NSDictionary* levelObjects = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelObjects" ofType:@"plist"]];
        NSString* level = [NSString stringWithFormat: @"Level %d",currentLevel];
        NSArray* portals = [[levelObjects objectForKey: level] objectForKey:@"Portals"];
        
        NSString* tempN = [[levelObjects objectForKey: level] objectForKey:@"HasTransition"];
        CCLOG(@"tempN %@", tempN);

        if([tempN isEqualToString:(@"yes")]){
            CCLOG(@"YAY");
            hasTransition = true;
        }else{
            hasTransition = false;
        }
        
        CCLOG(@"Has Transition %d", hasTransition);
        
        //add startPortal
        NSArray* startPortalData = [portals objectAtIndex:0];
        CCSprite* wormholeEntrance = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", [startPortalData objectAtIndex:0]]];
        [wormholeEntrance setPosition:CGPointMake([[startPortalData objectAtIndex:1] floatValue], [[startPortalData objectAtIndex:2] floatValue])];
        [self addChild:wormholeEntrance z:WORMHOLE_DEPTH];
        
        //add transition portal and camera location
        if(hasTransition == YES){
            NSArray* transitionPortalData = [portals objectAtIndex:1];
            WormholeTransition = [CCSprite spriteWithFile: [NSString stringWithFormat:@"%@.png", [transitionPortalData objectAtIndex:0]]];
            [WormholeTransition setPosition:CGPointMake([[transitionPortalData objectAtIndex:1] floatValue], [[transitionPortalData objectAtIndex:2] floatValue])];
            [self addChild:WormholeTransition z:WORMHOLE_DEPTH];
            
            NSArray* cameraLocs = [[levelObjects objectForKey: level] objectForKey:@"CameraLocations"];
            NSArray* secondCameraLoc = [cameraLocs objectAtIndex:1];
            transitionPoint = CGPointMake([[secondCameraLoc objectAtIndex:0] floatValue], [[secondCameraLoc objectAtIndex:1] floatValue]);
                                            
        }else{
            
        }
        
        touchOFF = false;
        
        int portalLength = [portals count] - 1;

        
        //add the end portal, the last entry in portals array
        NSArray* endPortalData = [portals objectAtIndex:portalLength];
        //load position of wormholes, entrance and exit
        wormholeExit = [CCSprite spriteWithFile:
                        [NSString stringWithFormat:@"%@.png",
                         [endPortalData objectAtIndex:0]]];
        
       
        
        [wormholeExit setPosition:CGPointMake([[endPortalData objectAtIndex:1] floatValue], [[endPortalData objectAtIndex:2] floatValue])];
        [self addChild:wormholeExit z:WORMHOLE_DEPTH];
        shadowMonster = [CCSprite spriteWithFile:@"grahh2.png"];
        [shadowMonster setPosition: wormholeEntrance.position];
        [self addChild:shadowMonster z:SHADOW_MONESTER_DEPTH];
        
        //get the staticlights
        NSArray* staticLights = [[levelObjects objectForKey: level] objectForKey:@"StaticLights"];
        for(NSDictionary* lightSource in staticLights){
            //get sprite name
            NSString* name = [lightSource objectForKey:@"on_filename"];
            //get the on_filename
            NSString* on_name = [NSString stringWithFormat:@"%@.png", name];
            NSString* off_name = [NSString stringWithFormat:@"%@.png", [lightSource objectForKey:@"off_filename"]];
            int origin_x = [[lightSource objectForKey:@"origin_x"] intValue];
            int origin_y = [[lightSource objectForKey:@"origin_y"] intValue];
            float on_duration = [[lightSource objectForKey:@"on_duration"] floatValue];
            float off_duration = [[lightSource objectForKey:@"off_duration"] floatValue];
            float vertical_per = [[lightSource objectForKey:@"vertical_percentage"] floatValue];
            
            LightSource* source = [[[LightSource alloc] initWithProperties:on_name :off_name :on_duration :off_duration :vertical_per] autorelease];
            
            source.position = ccp(origin_x, origin_y);
            source.anchorPoint = ccp(0.5f, 0.5f);
            source.tag = [GameplayScene TagGenerater];
            //[source setColor:ccc3(0, 0, 0)];
            [source setScaleY:1.5*SHADOW_HEIGHT_FACTOR];
            [source setScaleX:1.5*SHADOW_WIDTH_FACTOR];
            [self addChild:source z:LIGHT_SPRITE_DEPTH];
            
            NSString* lightObjectName = [NSString stringWithFormat:@"%@.png", [lightSource objectForKey:@"lightObject"]];
            int object_x = [[lightSource objectForKey:@"object_x"] intValue];
            int object_y = [[lightSource objectForKey:@"object_y"] intValue];
            CCSprite* lightObjectSprite = [CCSprite spriteWithFile:lightObjectName];
            [lightObjectSprite setScaleX:2];
            [lightObjectSprite setScaleY:2];
            lightObjectSprite.position = ccp(object_x,object_y);
            [self addChild:lightObjectSprite z:LIGHT_SPRITE_DEPTH-1];
        }
        
    }
    return self;
}


-(void) dealloc {
    [objShadowTable release];
    if(renderTexture != NULL){
        [renderTexture release];
        renderTexture = NULL;
    }
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


-(void) castLightFrom:(CCArray *)lights withRatios:(CCArray *)ratios withAPs:(CCArray *)APs {
    
    if (lights.count != ratios.count) {
        return;
    }
    
    for(int i = 0; i < lights.count ;++i){
        LightSource* cur = (LightSource*) [lights objectAtIndex:i];
        
        LightSource* source = [[LightSource alloc] initWithProperties:cur->on_filename :cur->off_filename :cur->on_duration :cur->off_duration :cur->vertical_percentage];
        source.anchorPoint = [[APs objectAtIndex:i] CGPointValue];
        //get sprite name
        [source setColor:ccc3(0, 0, 0)];
        [source setScaleY:SHADOW_HEIGHT_FACTOR];
        [source setScaleX:SHADOW_WIDTH_FACTOR];
        
        source.tag = [GameplayScene TagGenerater];
        [objShadowTable
         setObject:[NSNumber numberWithInteger:source.tag]
         forKey:[NSNumber numberWithInteger:cur.tag]];
        
        [self addChild:source z:LIGHT_SPRITE_DEPTH];
        CGPoint ratio = [[ratios objectAtIndex:i] CGPointValue];
        [self updateShadowPos:cur.tag withRelativePos: ratio];
        
    }
}


-(void) castShadowFrom:(CCArray*)objects withRatios:(CCArray *)ratios withAPs:(CCArray *)APs {
    
    if (objects.count != ratios.count) {
        return;
    }
    
    for (int i = 0; i < objects.count; ++i) {
        CCSprite* cur = (CCSprite*)[objects objectAtIndex:i];
        CCTexture2D* texture = cur.texture;
        
        CCSprite* shadow = [CCSprite spriteWithTexture:texture];
        CGPoint curAP = [[APs objectAtIndex:i] CGPointValue];
        shadow.anchorPoint = curAP;
        [shadow setColor:ccc3(0, 0, 0)];
        [shadow setScaleY:SHADOW_HEIGHT_FACTOR];
        [shadow setScaleX:SHADOW_WIDTH_FACTOR];
        
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

-(void) pathFinding: (CGPoint)end {
    //get the distance to calculate the duration for the moving
    float distance = ccpDistance(shadowMonster.position, end);
    id actionMove = [CCMoveTo actionWithDuration:(distance / SHADOWMONSTER_SPEED) position:end];
    //stop the current moving if any
    [shadowMonster stopAllActions];
    //do the moving here
    [shadowMonster runAction:actionMove];
}


-(CCArray*) getLightChildren {
    CCArray* children = [CCArray array];
    for (CCSprite* sprite in self.children) {
        if (sprite.zOrder == LIGHT_SPRITE_DEPTH) {
            [children addObject:sprite];
        }
    }
    return children;
}

-(CCArray*) getcornorsOfMonster {
    CCArray* arr = [CCArray array];
    //get boundingbox of shadow monster
    CGRect rect = [shadowMonster boundingBox];
    //get lowerleft corner
    CGPoint lowerLeft = ccpAdd(rect.origin, ccp(rect.size.width / 4, rect.size.height / 4));
    //get leftupper corner
    CGPoint upperLeft = ccpAdd(lowerLeft, ccp(0, rect.size.height / 2));
    //get rightupper corner
    CGPoint upperRight = ccpAdd(lowerLeft, ccp(rect.size.width / 2, rect.size.height / 2));
    //get lowerRight corner
    CGPoint lowerRight = ccpAdd(lowerLeft, ccp(rect.size.width / 2, 0));
    [arr addObject: [NSValue valueWithCGPoint:upperLeft]];
    [arr addObject: [NSValue valueWithCGPoint:upperRight]];
    [arr addObject: [NSValue valueWithCGPoint:lowerLeft]];
    [arr addObject: [NSValue valueWithCGPoint:lowerRight]];
    return arr;
    
}

-(void) shiftToGoal:(CGPoint)goal :(int)stepSize{
    float centerX, centerY, centerZ;
	float eyeX, eyeY, eyeZ;
	[self.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
	[self.camera eyeX:&eyeX eyeY:&eyeY eyeZ:&eyeZ];
    GameplayScene* temp = (GameplayScene*)self.parent;
   // [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    
    float slope = (centerY - goal.y) / (centerX - goal.x);
    //y = mx + b
    float b = goal.y - (slope * goal.x);
    
    if(fabs(centerX - goal.x) > stepSize){
        if(centerX < goal.x){
            centerX += stepSize;
            centerY = (slope * centerX) + b;
        }else{
            centerX -=stepSize;
            centerY = (slope * centerX) + b;
        }
    }else{
        centerX = goal.x;
        centerY = goal.y;
     //   [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    
    CGPoint backgroundPoint;
    
    backgroundPoint.x = centerX;
    backgroundPoint.y = centerY;
    [temp shift:backgroundPoint];
    [self.camera setCenterX:centerX centerY:centerY centerZ:centerZ];
    [self.camera setEyeX:centerX eyeY:centerY eyeZ:eyeZ];
    
}


-(void) update:(ccTime)delta {
    CCArray* cornors = [self getcornorsOfMonster];
    GameplayScene* scene = (GameplayScene*)self.parent;
    if(self.isTouchEnabled){
        [self generateShadowMap2];
    }
    for (NSValue* value in cornors) {
        CGPoint tmp = value.CGPointValue;
        int x = tmp.x;
        int y = tmp.y;
        if ([self getShadowMap:x :y] == false) {
            [scene shadowMonsterDead];
            return;
        }
    }
    float centerX, centerY, centerZ;
    [self.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
    centerCameraX = centerX;
    centerCameraY = centerY;
    
    if(hasTransition == YES && CGRectContainsPoint([WormholeTransition boundingBox], shadowMonster.position)){
        //do the Transition
        
        if(touchOFF == false && centerX !=transitionPoint.x && centerY != transitionPoint.y){
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            touchOFF = true;
        }
        
        if(centerX == transitionPoint.x && centerY == transitionPoint.y){
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            CCLOG(@"Touch Points Back On");
            touchOFF = false;

        }else{
            [self shiftToGoal:transitionPoint:10];
        }
    }
    
   else if(CGRectContainsPoint([wormholeExit boundingBox], shadowMonster.position)) {
        CCLOG(@"CONG");
        //game accomplish event triggered
        [scene shadowMonterRescued];
    }

}

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
// SHADOW MAP METHOD
-(void) generateShadowMap2{
    
    CGRect monsterBoundingBox = shadowMonster.boundingBox;
    CGPoint leftBottom = monsterBoundingBox.origin;
    CGPoint rightBottom = ccp(leftBottom.x + monsterBoundingBox.size.width, leftBottom.y);
    CGPoint leftTop = ccp(leftBottom.x, leftBottom.y + monsterBoundingBox.size.height);
    CGPoint rightTop = ccp(leftBottom.x + monsterBoundingBox.size.width, leftBottom.y+monsterBoundingBox.size.height);

    
    for (int i = 0; i < monsterBoundingBox.size.width; ++i) {
        for (int j = 0; j < monsterBoundingBox.size.height; ++j) {
            int newX = j + (int)leftBottom.x;
            int newY = i + (int)leftBottom.y;
            newX = MAX(0, newX);
            newX = MIN(newX, DEVICE_WIDTH);
            
            newY = MAX(0, newY);
            newY = MIN(newY, DEVICE_HEIGHT);
            [self setShadowMap:newX :newY :false];
        }
    }
    for(CCSprite* cur in self.children){
        if (!(cur.zOrder == SHADOW_SPRITE_DEPTH || cur.zOrder == LIGHT_SPRITE_DEPTH)) {
            continue;
        }
        CGRect boundingBox = cur.boundingBox;
        CGPoint origin = boundingBox.origin;
        
        if(CGRectContainsPoint(boundingBox, leftBottom) || CGRectContainsPoint(boundingBox, rightBottom) || CGRectContainsPoint(boundingBox, leftTop)|| CGRectContainsPoint(boundingBox, rightTop)){
            
            
            for (int i = 0; i < shadowMonster.boundingBox.size.height; i+=SHADOW_BLOCK_SIZE/2) {
                for (int j = 0; j < shadowMonster.boundingBox.size.width; j+=SHADOW_BLOCK_SIZE/2) {
                    int newX = j + (int)leftBottom.x;
                    int newY = i + (int)leftBottom.y;
                    newX = MAX(0, newX);
                    newX = MIN(newX, DEVICE_WIDTH);
                    
                    newY = MAX(0, newY);
                    newY = MIN(newY, DEVICE_HEIGHT);
                    
                    float omsX = newX/2;
                    float omsY = newY/2;
                    
                    b2Vec2 worldPoint = b2Vec2(omsX / PTM_RATIO, omsY / PTM_RATIO);
                    GameplayScene* scene = (GameplayScene*)[self parent];
                    if([scene checkIfPointInFixture:worldPoint :origin]){
                        for(int newi = i-SHADOW_BLOCK_SIZE/2; newi < i+SHADOW_BLOCK_SIZE/2; newi++){
                            for(int newj = j-SHADOW_BLOCK_SIZE/2; newj < j+SHADOW_BLOCK_SIZE/2; newj++){
                                newX = newj + (int)leftBottom.x;
                                newY = newi + (int)leftBottom.y;
                                newX = MAX(0, newX);
                                newX = MIN(newX, DEVICE_WIDTH);
                                
                                newY = MAX(0, newY);
                                newY = MIN(newY, DEVICE_HEIGHT);
                                
                                [self setShadowMap:newX :newY :true];
                            }
                        }
                    }
                }
            }
        }
    }
    //[self drawShadowMap];//for debugging
}

-(void) drawShadowMap {
    NSLog(@"drawing shadow map");
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    renderTexture = [[CCRenderTexture renderTextureWithWidth:size.width height:size.height] retain]; 
    [self addChild:renderTexture z:10];
    [renderTexture setPosition:ccp( size.width * 0.5f, size.height * 0.5f )];
    [renderTexture clear:1.0f g:1.0f b:1.0f a:1.0f];
    
    NSLog(@"working...don't panic.");
    [renderTexture begin];
    for(int i = 0; i < DEVICE_WIDTH; i++){
        for(int j = 0; j < DEVICE_HEIGHT; j++){
            if(shadowMap[j][i] == true){
                CCSprite* pixelSprite = [CCSprite spriteWithFile:@"testPixel.png"];
                [pixelSprite setPosition:ccp(i,j)];
                [pixelSprite visit];
            }
        }
    }
    
    [renderTexture end];
}

-(void) generateShadowMap {
    
    //    GameplayScene* curScene = (GameplayScene*)self.parent;
    for (int i = 0; i < DEVICE_WIDTH; ++i) {
        for (int j = 0; j < DEVICE_HEIGHT; ++j) {
            [self setShadowMap:i :j :false];
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
                    [self setShadowMap:newX :newY :true];
                }
            }
        } else {
            //if there is big rotation
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
                        [self setShadowMap:newX :newY :true];
                    }
                }
            }
            
        }
    }
}


-(bool) getShadowMap:(int)x :(int)y {
    bool val = shadowMap[y][x];
    if (val == false) { //if it is already light in the shadow map, just return true
        return false;
    } else { //if it is dark, now checking dynamic disruption events
             //by interating all dynamic items whether they contain this point or not
             //so that we know it is dark or not
        for (CCSprite* sprite in self.children) {
            if (sprite.zOrder == LIGHT_SPRITE_DEPTH) {
                LightSource* lightSprite = (LightSource*) sprite;
                if ([lightSprite lightSourceContains:ccp(x, y)]) {
                    val = false;
                    break;
                }
                
            }
        }
        return val;
    }
}


-(void) setShadowMap:(int)x :(int)y :(bool) value {
    shadowMap[y][x] = value;
}


-(void) toggleLightSourceActions:(bool) value {
    for (LightSource* source in [self getLightChildren]) {
        if (value) {
            [source execActions];
        } else {
            [source stopExecActions];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//SHADOW LAYER EVENTS
-(void) startActionMode {
    [self generateShadowMap2];
    self.isTouchEnabled = YES;
    [self scheduleUpdate];
    [self toggleLightSourceActions:true];
    CCLOG(@"Enter Action Mode");
}

-(void) finishActionMode {
    self.isTouchEnabled = NO;
    //stop monster
    [shadowMonster stopAllActions];
    //reset the count
    count_swipe_down = 0;
    //unschedule the udpate fucntion
    [self unscheduleUpdate];
    [self toggleLightSourceActions:false];
    if(renderTexture != NULL){
        [renderTexture release];
        renderTexture = NULL;
    }
    CCLOG(@"Leave Action Mode");
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (count_swipe_down++ == 0) {
        return;
    }
    
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    //testing
    
    float centerX, centerY, centerZ;
	[self.camera centerX:&centerX centerY:&centerY centerZ:&centerZ];
    location.x += centerX;
    location.y += centerY;

    
    //testing - end
    
    [self pathFinding :location];
    
}

@end
