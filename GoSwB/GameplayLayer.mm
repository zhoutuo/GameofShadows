//
//  GameplayLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayLayer.h"
#import "GameplayScene.h"
#import "GB2ShapeCache.h"
#import "CCDrawingPrimitives.h"
#import "Globals.h"

@implementation GameplayLayer


#define NOTAG -1
#define BACKGROUND_DEPTH 1
#define OBJECT_DEPTH -1
#define LIGHT_DEPTH -2
#define OMS_MOVEMENT_SPEED 0.2

-(id) init {
    if (self = [super init]) {
        touchedObjectTag = NOTAG;              //the tag for the sprite being touched right now
        touchOperation = NONE;
                
        //by making background sprite center on lower left corner will make it
        //easier to contain all the children
        objectsContainer = [CCSprite spriteWithFile:@"play_bg.png"];
        [objectsContainer setAnchorPoint:ccp(0, 0)];
        [objectsContainer setPosition:ccp(0, 0)];  //this is the relative position to the layer
        [self addChild:objectsContainer z:BACKGROUND_DEPTH tag:[GameplayScene TagGenerater]];
        
        //background of the OMS. Shows the room.
        omsBackground = [CCSprite spriteWithFile: @"Room layout small window.png"];
        [omsBackground setOpacity: 150];
        [omsBackground setAnchorPoint:ccp(0,0)];
        [omsBackground setPosition:[objectsContainer position]];
        [self addChild:omsBackground z:OBJECT_DEPTH-1];
        
        //add rotation circle to the layer
        //make it invisible
        rotationCircle = [CCSprite spriteWithFile:@"rotate_circle.png"];
        [rotationCircle retain];
        
        // Physics section.
        [self initPhysics];
        [self setupObjects];
    }
    
    return self;
}

// Creates an initializes arrays for the game objects and their corresponding physics bodies.
- (void)setupObjects
{
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"items.plist"];
    NSDictionary* levelObjects = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelObjects" ofType:@"plist"]];
    NSString* level = [NSString stringWithFormat: @"Level %d",currentLevel];
    NSArray* objects = [[levelObjects objectForKey: level] objectForKey:@"Objects"];
    for (NSArray* objectData in objects)
    {
        PhysicsSprite* objectSprite = [PhysicsSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", [objectData objectAtIndex:0]]];
        objectSprite.position = ccp([[objectData objectAtIndex:1] floatValue],
                                    [[objectData objectAtIndex:2] floatValue]);
        b2BodyDef objectBodyDef;
        objectBodyDef.type = b2_dynamicBody;
        objectBodyDef.position.Set(objectSprite.position.x / PTM_RATIO, objectSprite.position.y / PTM_RATIO);
        objectBodyDef.userData = objectSprite;
        b2Body* objectBody = physicsWorld -> CreateBody(&objectBodyDef);
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:objectBody forShapeName:[objectData objectAtIndex:0]];
        [objectSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:[objectData objectAtIndex:0]]];
        [objectSprite setPhysicsBody:objectBody];
        [objectsContainer addChild:objectSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    }
    /*
    float height = 384;
    b2Body* previousConnector = physicsGroundBody;
    for (int i = 0; i < 5; i++)
    {
        PhysicsSprite* ropeSprite = [PhysicsSprite spriteWithFile:@"ThinRope.png"];
        ropeSprite.position = CGPointMake(320, height);
        b2BodyDef ropeBodyDef;
        ropeBodyDef.type = b2_dynamicBody;
        ropeBodyDef.position.Set(ropeSprite.position.x / PTM_RATIO, ropeSprite.position.y / PTM_RATIO);
        ropeBodyDef.userData = ropeSprite;
        b2Body* ropeBody = physicsWorld -> CreateBody(&ropeBodyDef);
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:ropeBody forShapeName:@"ThinRope"];
        [ropeSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ThinRope"]];
        [ropeSprite setPhysicsBody:ropeBody];
        [objectsContainer addChild:ropeSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
        b2RevoluteJointDef jointDef;
        jointDef.Initialize(previousConnector, ropeBody, [self toMeters:CGPointMake(320, height)]);
        physicsWorld -> CreateJoint(&jointDef);
        ropeBody -> SetAngularDamping(0.2f);
        ropeBody -> SetLinearDamping(1.0f);
        previousConnector = ropeBody;
        height -= ropeSprite.boundingBox.size.height;
    }
    */
    PhysicsSprite* lightSprite = [PhysicsSprite spriteWithFile:@"Chandelier.png"];
    lightSprite.position = CGPointMake(320, 384);
    b2BodyDef lightBodyDef;
    lightBodyDef.type = b2_dynamicBody;
    lightBodyDef.position.Set(lightSprite.position.x / PTM_RATIO, lightSprite.position.y / PTM_RATIO);
    lightBodyDef.userData = lightSprite;
    b2Body* lightBody = physicsWorld -> CreateBody(&lightBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:lightBody forShapeName:@"Chandelier"];
    [lightSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"Chandelier"]];
    [lightSprite setPhysicsBody:lightBody];
    [objectsContainer addChild:lightSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    b2RevoluteJointDef jointDef;
    jointDef.Initialize(physicsGroundBody, lightBody, [self toMeters:CGPointMake(320, 384)]);//, lightBody -> GetPosition());
    b2RevoluteJoint* joint = (b2RevoluteJoint*)physicsWorld -> CreateJoint(&jointDef);
    lightBody -> SetAngularDamping(0.2f);
    lightBody -> SetLinearDamping(0.2f);
}

// Physics section
- (void)initPhysics
{
    b2Vec2 physicsGravity;
    physicsGravity.Set(0.0f, -10.0f);
    physicsWorld = new b2World(physicsGravity);
    
    physicsWorld -> SetAllowSleeping(true);
    physicsWorld -> SetContinuousPhysics(true);
    
    // Define the ground body.
    b2BodyDef physicsGroundBodyDef;
    //physicsGroundBodyDef.type = b2_dynamicBody;
    physicsGroundBody = physicsWorld -> CreateBody(&physicsGroundBodyDef);
    
    physicsWorldTop = NULL;
    physicsWorldBottom = NULL;
    physicsWorldLeft = NULL;
    physicsWorldRight = NULL;
    
    [self initPhysicsGroundBody];
}

// Physics step update function.
-(void)update:(ccTime)delta
{
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    physicsWorld -> Step(delta, velocityIterations, positionIterations);
    
    
    //update the position of sprites accordingly
    GameplayScene* scene = (GameplayScene*)self.parent;
    
    for (b2Body* body = physicsWorld->GetBodyList(); body; body = body->GetNext()) {
        if (body->GetUserData()) {
            
            //translation
            CCSprite* sprite = (CCSprite*) body->GetUserData();
            sprite.position = ccp(body->GetPosition().x * PTM_RATIO,
                                  body->GetPosition().y * PTM_RATIO);
            
            //tell scene we are done with moving one object
            [scene finishMovingOneObject:sprite.tag withRatio:[self getSpriteRelativePos:sprite]];
            
            //rotation
            float angel = CC_RADIANS_TO_DEGREES(body->GetAngle());
            sprite.rotation = angel;
            [scene finishRotatingOneObject:sprite.tag withAngle:angel];

        }
    }
}

// Helper methods for pixel-meter conversions for Box2D.
- (b2Vec2)toMeters:(CGPoint)point
{
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

- (CGPoint)toPixels:(b2Vec2)vector
{
    return ccpMult(CGPointMake(vector.x, vector.y), PTM_RATIO);
}

- (void)initPhysicsGroundBody
{
    
    // Define the ground box shape.
    // This should be the OMS.
    CGSize OMSSize = [objectsContainer boundingBox].size;
    float physicsGroundBoxWidth = OMSSize.width / PTM_RATIO;
    float physicsGroundBoxHeight = OMSSize.height / PTM_RATIO;
    b2EdgeShape physicsGroundBox;
    int density = 0;
    
    float OMSOriginX = 0.0f;
    float OMSOriginY = 0.0f;
    
    // Ground Box Bottom.
    physicsGroundBox.Set(b2Vec2(OMSOriginX, OMSOriginY), b2Vec2(OMSOriginX + physicsGroundBoxWidth, OMSOriginY));
    physicsGroundBody -> SetLinearDamping(0.6);
    physicsWorldBottom = physicsGroundBody -> CreateFixture(&physicsGroundBox, density);
    
    // Ground Box Top.
    physicsGroundBox.Set(b2Vec2(OMSOriginX, OMSOriginY + physicsGroundBoxHeight), b2Vec2(OMSOriginX + physicsGroundBoxWidth, OMSOriginY + physicsGroundBoxHeight));
    physicsWorldTop = physicsGroundBody -> CreateFixture(&physicsGroundBox, density);
    
    // Ground Box Left.
    physicsGroundBox.Set(b2Vec2(OMSOriginX, OMSOriginY), b2Vec2(OMSOriginX, OMSOriginY + physicsGroundBoxHeight));
    physicsWorldLeft = physicsGroundBody -> CreateFixture(&physicsGroundBox, density);

    // Ground Box Right.
    physicsGroundBox.Set(b2Vec2(OMSOriginX + physicsGroundBoxWidth, OMSOriginY + physicsGroundBoxHeight), b2Vec2(OMSOriginX + physicsGroundBoxWidth, OMSOriginY));
    physicsWorldRight = physicsGroundBody -> CreateFixture(&physicsGroundBox, density);
}


-(void) dealloc {
    [rotationCircle release];
    
    // Physics cleanup section.
    // Remove existing fixtures, if any.
    if (physicsWorldBottom != NULL) physicsGroundBody -> DestroyFixture(physicsWorldBottom);
    if (physicsWorldTop != NULL) physicsGroundBody -> DestroyFixture(physicsWorldTop);
    if (physicsWorldLeft != NULL) physicsGroundBody -> DestroyFixture(physicsWorldLeft);
    if (physicsWorldRight != NULL) physicsGroundBody -> DestroyFixture(physicsWorldRight);
    delete physicsWorld; physicsWorld = NULL;
    physicsWorldTop = NULL;
    physicsWorldBottom = NULL;
    physicsWorldLeft = NULL;
    physicsWorldRight = NULL;
    
    [super dealloc];
}


-(void) onEnter {
    [super onEnter];
    
    //tell the scene we are done with rendering all objects
    GameplayScene* scene = (GameplayScene*)self.parent;
    CCArray* shadowVisibleChildren = [CCArray array];
    CCArray* ratios = [CCArray array];
    for (CCSprite* sprite in objectsContainer.children) {
        
        if (sprite.zOrder == OBJECT_DEPTH) {
            [shadowVisibleChildren addObject:sprite];
            CGPoint ratio = [self getSpriteRelativePos:sprite];
            [ratios addObject:[NSValue valueWithCGPoint:ratio]];
        }
        
    }
    
    [scene finishObjectsCreation:shadowVisibleChildren withRatios:ratios];
}


-(void) showRotationCircle: (CGPoint)position {
    [self toggleRotationCircle: YES];
    rotationCircle.position = position;
}

-(void) toggleRotationCircle: (BOOL)value {
    if (value == NO) {
        if (rotationCircle.parent == nil) {
            return;
        }
        [objectsContainer removeChild:rotationCircle cleanup:NO];
    } else {
        if (rotationCircle.parent != nil) {
            return;
        }
        [objectsContainer addChild:rotationCircle z:BACKGROUND_DEPTH];
    }
}

-(void) fadeOutTouchRect {
    id action = [CCFadeOut actionWithDuration:2];
    [objectsContainer runAction:action];
}

-(void) fadeInTouchRect {
    id action = [CCFadeIn actionWithDuration:2];
    [objectsContainer runAction:action];
}

-(CGPoint) getSpriteRelativePos:(CCSprite *)object {
    CGRect rect = objectsContainer.boundingBox;
    CGPoint relativePos;
    relativePos.x = object.position.x / rect.size.width;
    relativePos.y = object.position.y / rect.size.height;
    return relativePos;
}

-(CGPoint) fromContainerCoord2Layer: (CGPoint) point {
    return ccpAdd(point, objectsContainer.boundingBox.origin);
}

-(CGPoint) fromLayerCoord2Container: (CGPoint) point {
    return ccpSub(point, objectsContainer.boundingBox.origin);
}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
        
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
        
    if (touchOperation == NONE) {
        //user a tap will invoker this function
        if (CGRectContainsPoint([objectsContainer boundingBox], location)) {
            //update the location to relative position for children
            location = [self fromLayerCoord2Container:location];
            for (PhysicsSprite* child in objectsContainer.children) {
                if (CGRectContainsPoint([child boundingBox], location)) {
                    touchOperation = TAP;
                    touchedObjectTag = child.tag;
                    b2Body* body = [child getPhysicsBody];
                    body->SetAwake(false);
                    body->SetActive(false);
                    break;
                }
            }
        }
    } else if(touchOperation == ROTATING) {
        location = [self fromLayerCoord2Container:location];
        
        //if the first tap for rotating is not inside the circle
        //cancel the rotating
        if (!CGRectContainsPoint(rotationCircle.boundingBox, location)) {
            [self toggleRotationCircle:NO];
            PhysicsSprite* cur = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
            b2Body* body = [cur getPhysicsBody];
            body->SetActive(true);
            body->SetAwake(true);
            touchedObjectTag = NOTAG;
            touchOperation = NONE;
        }
    }
        
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    
    location = [[CCDirector sharedDirector] convertToGL:location];
        
    //all touch opeartions entering this method can only be tap/moving or rotation
    if (touchOperation == TAP || touchOperation == MOVING) {
        //since our touch is moving
        touchOperation = MOVING;

        //try to check whether the touched sprite is the objects container or not
        CCSprite* touched = (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        CGRect rect = objectsContainer.boundingBox;

        //since we did not change the anchor point of the children sprites
        //we do not need to change the position of locaiton
        //but we need to make sure that the location is inside the touch rect
        location = [self fromLayerCoord2Container:location];
        
        CGSize spriteBox = [touched boundingBox].size;
        location.x = MIN(location.x, rect.size.width - spriteBox.width / 2);
        location.x = MAX(location.x, spriteBox.width / 2);
        location.y = MIN(location.y, rect.size.height - spriteBox.height / 2);
        location.y = MAX(location.y, spriteBox.height / 2);
        touched.position = location;
        //moving the physical body as well
        b2Body* body = [(PhysicsSprite*)touched getPhysicsBody];
        body->SetTransform([self toMeters:location], body->GetAngle());
        
    } else if(touchOperation == ROTATING) {
        PhysicsSprite* rotated = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        CGPoint relativeCenter = [self fromContainerCoord2Layer:rotated.position];
        CGPoint rotatePoint = ccpAdd(relativeCenter, ccp(0, 100));
        rotatePoint = ccpSub(rotatePoint, relativeCenter);
        location = ccpSub(location, relativeCenter);
        float angle = ccpAngle(location, rotatePoint);
                
        if (location.x < rotatePoint.x) {
            angle = -angle;
        }
        angle = CC_RADIANS_TO_DEGREES(angle);
        rotated.rotation = angle;
        //rotate the physical body as well
        b2Body* body = [rotated getPhysicsBody];
        body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(angle));

    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchOperation == TAP or touchOperation == MOVING) {
        //show circle around tapped object, start to rotate
        [self showRotationCircle:[objectsContainer getChildByTag:touchedObjectTag].position];
        touchOperation = ROTATING;
        
    } else if(touchOperation == ROTATING) {
        //here its either rotation finished
        [self toggleRotationCircle:NO];
        //when finished with rotating object
        //wake physical calculation
        PhysicsSprite* cur = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        b2Body* body = [cur getPhysicsBody];
        body->SetActive(true);
        body->SetAwake(true);
        //clean
        touchOperation = NONE;
        touchedObjectTag = NOTAG;
        
    }
    
}



//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//GAMEPLAY LAYER EVENTS
-(void) moveOMStoLeft {
    [objectsContainer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(0,0)], nil]];
    [omsBackground runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(0,0)], nil]];
}

-(void) moveOMStoRight {
    CGFloat winWidth = [CCDirector sharedDirector].winSize.width;
    CGFloat width = [objectsContainer boundingBox].size.width;
    [objectsContainer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(winWidth - width,0)], nil]];
    [omsBackground runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(winWidth - width,0)], nil]];

}

-(void) startPuzzleMode {
    CGFloat currentX = objectsContainer.position.x;
    [objectsContainer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(currentX,0)], nil]];
    [omsBackground runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(currentX,0)], nil]];
    self.isTouchEnabled = YES;
    [self scheduleUpdate];
    CCLOG(@"Enter Puzzle Mode");
}

-(void) finishPuzzleMode {
    CGFloat height = [objectsContainer boundingBox].size.height;
    CGFloat currentX = objectsContainer.position.x;
    [objectsContainer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(currentX,-height)], nil]];
    [omsBackground runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(currentX,-height)], nil]];
    self.isTouchEnabled = NO;
    [self unscheduleUpdate];
    CCLOG(@"Leave Puzzle Mode");
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


@end
