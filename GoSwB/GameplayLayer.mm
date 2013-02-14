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
#define BACKGROUND_DEPTH 0
#define OBJECT_DEPTH 1

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
        
        //add a test object for the layer
        droid1 = [CCSprite spriteWithFile:@"Droid1.png"];
        [droid1 setPosition:ccp(100, 100)]; //this is the relative position to the objects container after attaching
        [objectsContainer addChild:droid1 z:OBJECT_DEPTH tag:[GameplayScene TagGenerater]];
    }
    
    return self;
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


-(void) dealloc {
    [touchArray release]; //remove array since we retain it in the init function
    [rotationCircle release];
    [super dealloc];
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
            for (CCSprite* child in objectsContainer.children) {
                if (CGRectContainsPoint([child boundingBox], location)) {
                    touchedObjectTag = child.tag;
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
            touched.position = location;
        } else {
            touched = (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag];
            //since we did not change the anchor point of the children sprites
            //we do not need to change the position of locaiton
            //but we need to make sure that the location is inside the touch rect
            location = [self fromLayerCoord2Container:location];
            location.x = MIN(location.x, rect.size.width);
            location.x = MAX(location.x, 0);
            location.y = MIN(location.y, rect.size.height);
            location.y = MAX(location.y, 0);
            touched.position = location;
            GameplayScene* scene = (GameplayScene*)self.parent;
            //tell scene we are done with moving one object
            [scene finishMovingOneObject:touched.tag withRatio:[self getSpriteRelativePos:touched]];
        }
        
    } else {
        assert(touchOperation == ROTATING);
        CCSprite* rotated = (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag];
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
        GameplayScene* scene = (GameplayScene*)self.parent;
        //tell scene we are done with rotating one object
        [scene finishRotatingOneObject:touchedObjectTag withAngle:angle];
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
            touchOperation = NONE;
            touchedObjectTag = NOTAG;

        }
    }
    
    //clear the touch array
    [touchArray removeAllObjects];
}

@end
