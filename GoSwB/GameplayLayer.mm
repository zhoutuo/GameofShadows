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
    objectSpriteArray = [[NSMutableArray alloc] init];
    objectBodyArray = [[NSMutableArray alloc] init];
    
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
    
    // Define a box shape (for now) for the droid object.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(1.3f, 1.3f);
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    droid1Body -> CreateFixture(&fixtureDef);
    [droid1 setPhysicsBody:droid1Body];
    
    droid1 = [PhysicsSprite spriteWithFile:@"Droid1.png"];
    [droid1 setPosition:ccp(200, 100)]; //this is the relative position to the objects container after attaching
    [objectsContainer addChild:droid1 z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    
    // Create a body for the droid object.
    b2BodyDef droid2BodyDef;
    droid2BodyDef.type = b2_dynamicBody;
    droid2BodyDef.position = [self toMeters:droid1.position];
    droid1Body = physicsWorld -> CreateBody(&droid1BodyDef);
    droid1Body -> SetUserData((void*)droid1);
    
    // Define a box shape (for now) for the droid object.
    b2PolygonShape dynamicBox2;
    dynamicBox2.SetAsBox(0.7f, 1.3f);
    b2FixtureDef fixtureDef2;
    fixtureDef2.shape = &dynamicBox;
    fixtureDef2.density = 1.0f;
    fixtureDef2.friction = 0.3f;
    fixtureDef2.restitution = 0.2f;
    droid1Body -> CreateFixture(&fixtureDef2);
    [droid1 setPhysicsBody:droid1Body];
    
    // Add sprite and body to object arrays.
    [objectSpriteArray addObject:droid1];
    //[objectBodyArray addObject:(id)droid1Body];
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
    // Remove existing fixtures, if any.
    if (physicsWorldBottom != NULL)
        physicsGroundBody -> DestroyFixture(physicsWorldBottom);
    if (physicsWorldTop != NULL)
        physicsGroundBody -> DestroyFixture(physicsWorldTop);
    if (physicsWorldLeft != NULL)
        physicsGroundBody -> DestroyFixture(physicsWorldLeft);
    if (physicsWorldRight != NULL)
        physicsGroundBody -> DestroyFixture(physicsWorldRight);
    
    // Define the ground box shape.
    // This should be the OMS.
    CGSize OMSSize = [objectsContainer boundingBox].size;
    float physicsGroundBoxWidth = OMSSize.width / PTM_RATIO;
    float physicsGroundBoxHeight = OMSSize.height / PTM_RATIO;
    b2EdgeShape physicsGroundBox;
    int density = 0;
    
    float OMSOriginX = 0.0f; //[objectsContainer position].x / PTM_RATIO;
    float OMSOriginY = 0.0f; //[objectsContainer position].y / PTM_RATIO;
    
    
    CCLOG(@"OMS Origin = %.2f, %.2f", OMSOriginX, OMSOriginY);
    CCLOG(@"OMS Size = %.2f, %.2f", physicsGroundBoxWidth, physicsGroundBoxHeight);
    
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

//-(void)updateSprite:(int)index
//{
//    //PhysicsSprite* selectedSprite = (PhysicsSprite*)[objectSpriteArray objectAtIndex:index];
//    //b2Body* selectedBody = (b2Body*)[objectBodyArray objectAtIndex:index];
//    //selectedBody -> SetTransform([self toMeters:selectedSprite.position], 0.0);
//    droid1Body -> SetTransform([self toMeters:droid1.position], 0.0);
//}


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
            touchedObjectTag = objectsContainer.tag;
            //update the location to relative position for children
            location = [self fromLayerCoord2Container:location];
            for (PhysicsSprite* child in objectsContainer.children) {
                if (CGRectContainsPoint([child boundingBox], location)) {
                    touchedObjectTag = child.tag;
                    b2Body* body = [child getPhysicsBody];
                    body->SetAwake(false);
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
            [self toggleRotationCircle: NO];
            touchedObjectTag = NOTAG;
        }
    }
    
    // Physics section. Turn off all physics calculations.
    //droid1Body -> SetAwake(false);
    /*for (id body in objectBodyArray)
    {
        b2Body* objectBody = (b2Body*)body;
        objectBody -> SetAwake(false);
    }*/
    
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
        CCSprite* touched = nil;
        CGRect rect = objectsContainer.boundingBox;
        if (touchedObjectTag == objectsContainer.tag) {
            touched = objectsContainer;
            //modifer locaiton to make sure that the location is in the middle
            //of the touchrect, because default anchor point is lower left corner
            //when you try to move the rect, the center pointer is left corner, it's user unfriendly
            //make the location lefter and lower than it is supposed to
            location.x -= rect.size.width / 2;
            location.y -= rect.size.height / 2;
            
            //make sure that the OMS is inside the screen
            CGSize wins = [[CCDirector sharedDirector] winSize];
            location.x = MAX(0, location.x);
            location.x = MIN(wins.width - rect.size.width,  location.x);
            
            location.y = MAX(0, location.y);
            location.y = MIN(wins.height - rect.size.height, location.y);
            
            
            touched.position = location;
        } else {
            touched = (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag];
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
            
//            GameplayScene* scene = (GameplayScene*)self.parent;
//            //tell scene we are done with moving one object
//            [scene finishMovingOneObject:touched.tag withRatio:[self getSpriteRelativePos:touched]];
        }
        
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
//        GameplayScene* scene = (GameplayScene*)self.parent;
//        //tell scene we are done with rotating one object
//        [scene finishRotatingOneObject:touchedObjectTag withAngle:angle];
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //if user touch somewhere else in the screen other than OMS
    if (touchedObjectTag == NOTAG) {
        touchOperation = NONE;
    } else {
        if (touchOperation == TAP) {
            //then check which part of tapped
            if (touchedObjectTag == objectsContainer.tag) {
                //if OMS itself got tapped, then cleanning
                touchOperation = NONE;
                touchedObjectTag = NOTAG;
                //[self updatePhysicsGroundBody];
            } else {
                //show circle around tapped object, start to rotate
                [self showRotationCircle:[objectsContainer getChildByTag:touchedObjectTag].position];
                touchOperation = ROTATING;
                
            }
        } else {
            //here its either rotation finished or moving finished
            if (touchOperation == ROTATING) {
                [self toggleRotationCircle:NO];
            }
            
            //when finished with moving or rotating object
            //wake physical calculation
            if (touchedObjectTag != objectsContainer.tag) {
                PhysicsSprite* cur = (PhysicsSprite*)[objectsContainer getChildByTag:touchedObjectTag];
                [cur getPhysicsBody]->SetAwake(true);
            }
            

            
            touchOperation = NONE;
            touchedObjectTag = NOTAG;

        }
    }
    
    //clear the touch array
    [touchArray removeAllObjects];
    
    // Physics section. Turn on all physics calculations.
    //droid1Body -> SetAwake(true);
    /*for (id body in objectBodyArray)
    {
        b2Body* objectBody = (b2Body*)body;
        objectBody -> SetAwake(true);
    }*/
}

@end
