//
//  GameplayLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayLayer.h"
#import "GameplayScene.h"
#import "LightSource.h"
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
        //add rotation circle here
        CCSprite* rotationCircle = [CCSprite spriteWithFile:@"rotate_circle.png"];
        rotationCircle.visible = NO;
        [objectSprite addChild:rotationCircle];
        rotationCircle.position = ccpSub(objectSprite.position, objectSprite.boundingBox.origin);
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

    NSArray* ropes = [[levelObjects objectForKey: level] objectForKey:@"Ropes"];
    for (NSArray* rope in ropes)
    {
        float height = 384;
        NSString* ropeImage = [rope objectAtIndex:0];
        int numberOfSegments = [[rope objectAtIndex:1] intValue];
        int positionOfRopeOnCeiling = [[rope objectAtIndex:2] intValue];
        NSString* lightImage = [rope objectAtIndex:3];
        b2Body* previousConnector = physicsGroundBody;
        for (int i = 0; i < numberOfSegments; i++)
        {
            PhysicsSprite* ropeSprite = [PhysicsSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", ropeImage]];
            ropeSprite.position = CGPointMake(positionOfRopeOnCeiling, height);
            b2BodyDef ropeBodyDef;
            ropeBodyDef.type = b2_dynamicBody;
            ropeBodyDef.position.Set(ropeSprite.position.x / PTM_RATIO, ropeSprite.position.y / PTM_RATIO);
            ropeBodyDef.userData = ropeSprite;
            b2Body* ropeBody = physicsWorld -> CreateBody(&ropeBodyDef);
            [[GB2ShapeCache sharedShapeCache] addFixturesToBody:ropeBody forShapeName:ropeImage];
            [ropeSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:ropeImage]];
            [ropeSprite setPhysicsBody:ropeBody];
            [objectsContainer addChild:ropeSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
            b2RevoluteJointDef jointDef;
            jointDef.Initialize(previousConnector, ropeBody, [self toMeters:CGPointMake(positionOfRopeOnCeiling, height)]);
            physicsWorld -> CreateJoint(&jointDef);
            ropeBody -> SetAngularDamping(0.2f);
            ropeBody -> SetLinearDamping(0.2f);
            previousConnector = ropeBody;
            height -= (ropeSprite.boundingBox.size.height);
        }
        PhysicsSprite* lightSprite = [PhysicsSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", lightImage]];
        lightSprite.position = CGPointMake(positionOfRopeOnCeiling, height);
        b2BodyDef lightBodyDef;
        lightBodyDef.type = b2_dynamicBody;
        lightBodyDef.position.Set(lightSprite.position.x / PTM_RATIO, lightSprite.position.y / PTM_RATIO);
        lightBodyDef.userData = lightSprite;
        b2Body* lightBody = physicsWorld -> CreateBody(&lightBodyDef);
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:lightBody forShapeName:lightImage];
        [lightSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:lightImage]];
        [lightSprite setPhysicsBody:lightBody];
        [objectsContainer addChild:lightSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
        b2RevoluteJointDef jointDef;
        jointDef.Initialize(previousConnector, lightBody, [self toMeters:CGPointMake(positionOfRopeOnCeiling, height)]);
        physicsWorld -> CreateJoint(&jointDef);
        lightBody -> SetAngularDamping(0.2f);
        lightBody -> SetLinearDamping(0.2f);
    }
    
    //get the lights
    NSArray* lights = [[levelObjects objectForKey: level] objectForKey:@"Lights"];
    for(NSDictionary* lightSource in lights){
        //get sprite name
        NSString* name = [lightSource objectForKey:@"on_filename"];
        //get the on_filename
        NSString* on_name = [NSString stringWithFormat:@"%@.png", name];
        
        PhysicsSprite* source = [PhysicsSprite spriteWithFile:on_name];
        //get the initial position
        [source setPosition:ccp([[lightSource objectForKey:@"origin_x"] floatValue],
                                [[lightSource objectForKey:@"origin_y"] floatValue])];
        //add rotation circle here
        CCSprite* rotationCircle = [CCSprite spriteWithFile:@"rotate_circle.png"];
        rotationCircle.visible = NO;
        [source addChild:rotationCircle];
        rotationCircle.position = ccpSub(source.position, source.boundingBox.origin);
        b2BodyDef lightSourceBodyDef;
        lightSourceBodyDef.type = b2_dynamicBody;
        lightSourceBodyDef.position.Set(source.position.x / PTM_RATIO, source.position.y / PTM_RATIO);
        lightSourceBodyDef.userData = source;
        b2Body* lightSourceBody = physicsWorld->CreateBody(&lightSourceBodyDef);
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:lightSourceBody forShapeName:name];
        [source setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:name]];
        [source setPhysicsBody:lightSourceBody];
        [objectsContainer addChild:source z:LIGHT_DEPTH tag:[GameplayScene TagGenerater]];
    }

}

// Physics section
- (void)initPhysics
{
    b2Vec2 physicsGravity;
    physicsGravity.Set(0.0f, -10.0f);
    physicsWorld = new b2World(physicsGravity);
    
    physicsWorld -> SetAllowSleeping(true);
    physicsWorld -> SetContinuousPhysics(true);
    
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	physicsWorld->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);
    
    // Define the ground body.
    b2BodyDef physicsGroundBodyDef;
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
            float angel = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
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
    
    //tell the scene all light sources
    CCArray* lightChildren = [CCArray array];
    CCArray* lightRatios = [CCArray array];
    
    for (CCSprite* sprite in objectsContainer.children) {
        //filter out all children except object and light source
        CGPoint ratio = [self getSpriteRelativePos:sprite];
        if (sprite.zOrder == OBJECT_DEPTH) {
            [shadowVisibleChildren addObject:sprite];
            [ratios addObject:[NSValue valueWithCGPoint:ratio]];
        }
        
        if (sprite.zOrder == LIGHT_DEPTH) {
            [lightChildren addObject:sprite];
            [lightRatios addObject:[NSValue valueWithCGPoint:ratio]];
        }
        
    }
    
    [scene finishObjectsCreation:shadowVisibleChildren withRatios:ratios];
    [scene finishLightsCreation:lightChildren withRatios:lightRatios];
    [self scheduleUpdate];


}


-(void) toggleRotationCircle: (CCSprite*)parent :(BOOL)value {
    //CCLOG(@"%@", NSStringFromCGPoint(parent.position));
    CCArray* children = parent.children;
    CCSprite* rotationCircle = (CCSprite*)children.lastObject;
    rotationCircle.visible = value;
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
    return [objectsContainer convertToWorldSpace:point];
}

-(CGPoint) fromLayerCoord2Container: (CGPoint) point {
    return [objectsContainer convertToNodeSpace:point];
}

-(BOOL) checkIfPointInFixture: (b2Vec2) worldPoint :(CGPoint) origin{
    b2Body* body = physicsWorld -> GetBodyList();
    origin.x /=2;
    origin.y /=2;
    while(body != NULL){
        if(body -> GetUserData()){
            
            PhysicsSprite* sprite = (PhysicsSprite*)body->GetUserData();
            CGPoint bodyOrigin = sprite.boundingBox.origin;
            if(ccpDistance(bodyOrigin, origin) <= 1){
                
                b2Fixture* fixture = body -> GetFixtureList();
                NSInteger count = 0;
                while (fixture != NULL){
                    count++;
                    switch (fixture -> GetType()) {
                        case b2Shape::e_polygon:
                        {
                            if(fixture -> TestPoint(worldPoint)){
                                return true;
                            }
                        }
                    }
                    fixture = fixture -> GetNext();
                }
            }
        }
        // NSLog(@"number of fixtures: %i",count);
        body = body -> GetNext();
    }
    return false;
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
                    body -> SetAwake(true);
                    b2Vec2 centerOfMass = body -> GetWorldCenter();
                    
                    b2MouseJointDef md;
                    md.bodyB = body;
                    md.bodyA = physicsGroundBody;
                    b2Vec2 locationWorld =  centerOfMass;//[self toMeters:location];
                    md.target = locationWorld;
                    md.collideConnected = true;
                    md.maxForce = body->GetMass() * 100.0f;
                    mouseJoint = (b2MouseJoint *) physicsWorld->CreateJoint(&md);
                    break;
                }
            }
        }
    } else if(touchOperation == ROTATING) {
        location = [self fromLayerCoord2Container:location];
        //if the first tap for rotating is not inside the circle
        //cancel the rotating
        CCSprite* objectTouched = (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        CCSprite* rotationCircle = (CCSprite*)[objectTouched.children lastObject];
        CCLOG(@"%@", NSStringFromCGRect(objectTouched.boundingBox));
        CCLOG(@"%@", NSStringFromCGPoint(location));
        if (!CGRectContainsPoint(objectTouched.boundingBox, location)) {
            [self toggleRotationCircle:objectTouched :NO];
            touchedObjectTag = NOTAG;
            touchOperation = NONE;
            physicsWorld -> DestroyJoint(mouseJoint);
            mouseJoint = NULL;
            
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
        //CGRect rect = objectsContainer.boundingBox;

        //since we did not change the anchor point of the children sprites
        //we do not need to change the position of locaiton
        //but we need to make sure that the location is inside the touch rect
        
        location = [self fromLayerCoord2Container:location];

        
        touched.position = location;
        //moving the physical body as well
        b2Body* body = [(PhysicsSprite*)touched getPhysicsBody];
        body -> SetAngularVelocity(0);
        mouseJoint -> SetTarget([self toMeters:location]);
        
    } else if(touchOperation == ROTATING) {
        PhysicsSprite* rotated = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        CGPoint relativeCenter = [self fromContainerCoord2Layer:rotated.position];
//        CGPoint rotatePoint = ccpAdd(relativeCenter, ccp(0, 100));
        CGPoint rotatePoint = ccp(0, 100);
        location = ccpSub(location, relativeCenter);
        float angle = ccpAngle(location, rotatePoint);
                
        if (location.x < rotatePoint.x) {
            angle = -angle;
        }
        angle = -1* CC_RADIANS_TO_DEGREES(angle);
        //rotate the physical body as well
        b2Body* body = [rotated getPhysicsBody];
        body->SetTransform(body->GetPosition(), CC_DEGREES_TO_RADIANS(angle));

    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (touchOperation == TAP or touchOperation == MOVING) {
        //show circle around tapped object, start to rotate
        [self toggleRotationCircle: (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag] :YES];
        PhysicsSprite* rotated = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        b2Body* body = [rotated getPhysicsBody];
        body -> SetAwake(false);
        touchOperation = ROTATING;
        
    } else if(touchOperation == ROTATING) {
        //here its either rotation finished
        [self toggleRotationCircle:(CCSprite*)[objectsContainer getChildByTag:touchedObjectTag] :NO];
        //when finished with rotating object
        //wake physical calculation
        //clean
        PhysicsSprite* rotated = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        b2Body* body = [rotated getPhysicsBody];
        body -> SetAwake(true);
        touchOperation = NONE;
        touchedObjectTag = NOTAG;
        physicsWorld -> DestroyJoint(mouseJoint);
        mouseJoint = NULL;

    }
    
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    if(mouseJoint != NULL){
        physicsWorld -> DestroyJoint(mouseJoint);
        mouseJoint = NULL;
    }
}

-(void) draw
{
	/*
    // If you want to see the physics bodies, uncomment this section
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
	
	physicsWorld->DrawDebugData();
	
	kmGLPopMatrix();*/
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
    //[self scheduleUpdate];
    CCLOG(@"Enter Puzzle Mode");
}

-(void) finishPuzzleMode {
    CGFloat height = [objectsContainer boundingBox].size.height;
    CGFloat currentX = objectsContainer.position.x;
    [objectsContainer runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(currentX,-height)], nil]];
    [omsBackground runAction: [CCSequence actions:[CCMoveTo actionWithDuration:OMS_MOVEMENT_SPEED position:ccp(currentX,-height)], nil]];
    self.isTouchEnabled = NO;
    //[self unscheduleUpdate];
    CCLOG(@"Leave Puzzle Mode");
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


@end
