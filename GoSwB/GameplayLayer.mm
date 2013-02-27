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

@implementation GameplayLayer


#define NOTAG -1
#define BACKGROUND_DEPTH 1
#define OBJECT_DEPTH -1

-(id) init {
    if (self = [super init]) {
        
        self.isTouchEnabled = YES;      //enable touch
        touchedObjectTag = NOTAG;              //the tag for the sprite being touched right now
        touchOperation = NONE;
        touchArray = [CCArray array];  //this is the array used for recording touches
        [touchArray retain];  //since this is a autorelease object, retain it
        
        //by making background sprite center on lower left corner will make it
        //easier to contain all the children
        objectsContainer = [CCSprite spriteWithFile:@"play_bg.png"];
        [objectsContainer setAnchorPoint:ccp(0, 0)];
        [objectsContainer setPosition:ccp(100, 100)];  //this is the relative position to the layer
        [self addChild:objectsContainer z:BACKGROUND_DEPTH tag:[GameplayScene TagGenerater]];
        
        
        //add rotation circle to the layer
        //make it invisible
        rotationCircle = [CCSprite spriteWithFile:@"rotate_circle.png"];
        [rotationCircle retain];
        
        // Physics section.
        [self initPhysics];
        [self setupObjects];
        [self scheduleUpdate];
    }
    
    return self;
}

// Creates an initializes arrays for the game objects and their corresponding physics bodies.
- (void)setupObjects
{
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"items.plist"];
    NSDictionary* levelObjects = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelObjects" ofType:@"plist"]];
    NSArray* objects = [levelObjects objectForKey:@"Level 01"];
    float startX = 100.0f;
    for (NSString* objectName in objects)
    {
        PhysicsSprite* objectSprite = [PhysicsSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", objectName]];
        objectSprite.position = CGPointMake(startX, 200.0f);
        b2BodyDef objectBodyDef;
        objectBodyDef.type = b2_dynamicBody;
        objectBodyDef.position.Set(objectSprite.position.x / PTM_RATIO, objectSprite.position.y / PTM_RATIO);
        objectBodyDef.userData = objectSprite;
        b2Body* objectBody = physicsWorld -> CreateBody(&objectBodyDef);
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:objectBody forShapeName:objectName];
        [objectSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:objectName]];
        [objectSprite setPhysicsBody:objectBody];
        [objectsContainer addChild:objectSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
        startX += 150.0f;
    }

    /*
    PhysicsSprite* armchairSprite = [PhysicsSprite spriteWithFile:@"ArmChair.png"];
    armchairSprite.position = CGPointMake(200, 200);
    b2BodyDef armchairBodyDef;
    armchairBodyDef.type = b2_dynamicBody;
    armchairBodyDef.position.Set(armchairSprite.position.x / PTM_RATIO, armchairSprite.position.y / PTM_RATIO);
    armchairBodyDef.userData = armchairSprite;
    b2Body* armchairBody = physicsWorld -> CreateBody(&armchairBodyDef);
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:armchairBody forShapeName:@"ArmChair"];
    [armchairSprite setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"ArmChair"]];
    [armchairSprite setPhysicsBody:armchairBody];
    [objectsContainer addChild:armchairSprite z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    
    //add a test object for the layer
    droid1 = [PhysicsSprite spriteWithFile:@"Droid1.png"];
    [droid1 setPosition:ccp(100, 100)]; //this is the relative position to the objects container after attaching
    [objectsContainer addChild:droid1 z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    
    // Create a body for the droid object.
    b2BodyDef droid1BodyDef;
    droid1BodyDef.type = b2_dynamicBody;
    droid1BodyDef.position = [self toMeters:droid1.position];
    droid1Body = physicsWorld -> CreateBody(&droid1BodyDef);
    droid1Body -> SetUserData((void*)droid1);
    
    //Using PhysicsEditor
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"droid1_physicsBody.plist"];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:droid1Body forShapeName: @"Droid1"];
    
    [droid1 setPhysicsBody:droid1Body];
    [droid1 setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape: @"Droid1"]];
    
    droid1 = [PhysicsSprite spriteWithFile:@"Droid1.png"];
    [droid1 setPosition:ccp(200, 100)]; //this is the relative position to the objects container after attaching
    [objectsContainer addChild:droid1 z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    
    // Create a body for the droid object.
    b2BodyDef droid2BodyDef;
    droid2BodyDef.type = b2_dynamicBody;
    droid2BodyDef.position = [self toMeters:droid1.position];
    droid1Body = physicsWorld -> CreateBody(&droid1BodyDef);
    droid1Body -> SetUserData((void*)droid1);
    
    //Using PhysicsEditor
    [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"droid1_physicsBody.plist"];
    [[GB2ShapeCache sharedShapeCache] addFixturesToBody:droid1Body forShapeName: @"Droid1"];
    
    [droid1 setPhysicsBody:droid1Body];
    [droid1 setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape: @"Droid1"]];
    
    
    
    // Add sprite and body to object arrays.
    [objectSpriteArray addObject:droid1];
    //[objectBodyArray addObject:(id)droid1Body];
    */
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
- (void)update:(ccTime)delta
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
//            CCLOG(@"%f", CC_RADIANS_TO_DEGREES(radians));
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
    
    
    //CCLOG(@"OMS Origin = %.2f, %.2f", OMSOriginX, OMSOriginY);
    //CCLOG(@"OMS Size = %.2f, %.2f", physicsGroundBoxWidth, physicsGroundBoxHeight);
    
    // Ground Box Bottom.
    physicsGroundBox.Set(b2Vec2(OMSOriginX, OMSOriginY), b2Vec2(OMSOriginX + physicsGroundBoxWidth, OMSOriginY));
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
    [touchArray release]; //remove array since we retain it in the init function
    [rotationCircle release];
    
    // Physics cleanup section.
    // Remove existing fixtures, if any.
    if (physicsWorldBottom != NULL) physicsGroundBody -> DestroyFixture(physicsWorldBottom);
    if (physicsWorldTop != NULL) physicsGroundBody -> DestroyFixture(physicsWorldTop);
    if (physicsWorldLeft != NULL) physicsGroundBody -> DestroyFixture(physicsWorldLeft);
    if (physicsWorldRight != NULL) physicsGroundBody -> DestroyFixture(physicsWorldRight);
    delete physicsWorld; physicsWorld = NULL;
    delete physicsWorldTop; physicsWorldTop = NULL;
    delete physicsWorldBottom; physicsWorldBottom = NULL;
    delete physicsWorldLeft; physicsWorldLeft = NULL;
    delete physicsWorldRight; physicsWorldRight = NULL;
    
    // Release object arrays.
    [objectSpriteArray release];
    [objectBodyArray release];
    
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
    [touchArray addObject:[NSValue valueWithCGPoint:location]];
    if (touchOperation == NONE) {
        //user a tap will invoker this function
        touchOperation = TAP;
        if (CGRectContainsPoint([objectsContainer boundingBox], location)) {
            //update the location to relative position for children
            location = [self fromLayerCoord2Container:location];
            for (PhysicsSprite* child in objectsContainer.children) {
                if (CGRectContainsPoint([child boundingBox], location)) {
                    touchedObjectTag = child.tag;
                    b2Body* body = [child getPhysicsBody];
                    body->SetAwake(false);
                    body->SetActive(false);
                    break;
                }
            }
        }
    } else {
        assert(touchOperation == ROTATING);
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
        }
    }
    
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    if (touchedObjectTag == NOTAG) {
        return;
    }
    
    //all touch opeartions entering this method can only be tap/moving or rotation
    if (touchOperation == TAP || touchOperation == MOVING) {
        //since our touch is moving
        touchOperation = MOVING;
        [touchArray addObject:[NSValue valueWithCGPoint:location]];

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
        CCLOG(@"%f, %f", location.x, location.y);
        //moving the physical body as well
        b2Body* body = [(PhysicsSprite*)touched getPhysicsBody];
        body->SetTransform([self toMeters:location], body->GetAngle());
        
    } else {
        assert(touchOperation == ROTATING);
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
    
    if (touchedObjectTag == NOTAG) {
        touchOperation = NONE;
    } else {
        if (touchOperation == TAP) {
            //show circle around tapped object, start to rotate
            [self showRotationCircle:[objectsContainer getChildByTag:touchedObjectTag].position];
            touchOperation = ROTATING;
            
        } else {
            //here its either rotation finished or moving finished
            if (touchOperation == ROTATING) {
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
            } else {
                //show circle around tapped object, start to rotate
                [self showRotationCircle:[objectsContainer getChildByTag:touchedObjectTag].position];
                touchOperation = ROTATING;
            }
        }
    }
    
    //clear the touch array
    [touchArray removeAllObjects];
}

@end
