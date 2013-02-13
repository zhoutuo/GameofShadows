//
//  GameplayLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayLayer.h"
#import "GameplayScene.h"
#import "GestureRecognizer.h"

@implementation GameplayLayer

@synthesize backgroundDepth = _backgroundDepth;
@synthesize itemsDepth = _itemsDepth;
#define NOTAG -1

-(id) init {
    if (self = [super init]) {

        self.isTouchEnabled = YES;      //enable touch
        touchedObjectTag = NOTAG;              //the tag for the sprite being touched right now
        _backgroundDepth = 0;           //background sprite's z-order
        _itemsDepth = 1;            //other sprites' z-order
        touchArray = [CCArray array];  //this is the array used for recording touches
        [touchArray retain];  //since this is a autorelease object, retain it
        
        //by making background sprite center on lower left corner will make it
        //easier to contain all the children
        objectsContainer = [CCSprite spriteWithFile:@"play_bg.png"];
        [objectsContainer setAnchorPoint:ccp(0, 0)];
        [objectsContainer setPosition:ccp(100, 100)];  //this is the relative position to the layer
        [self addChild:objectsContainer z:_backgroundDepth tag:[GameplayScene TagGenerater]];
        
        //add a test object for the layer
        droid1 = [CCSprite spriteWithFile:@"Droid1.png"];
        [droid1 setPosition:ccp(100, 100)]; //this is the relative position to the objects container after attaching
        [objectsContainer addChild:droid1 z:_itemsDepth tag:[GameplayScene TagGenerater]];
    }
    
    return self;
}


-(void) dealloc {
    [touchArray release]; //remove array since we retain it in the init function
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


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    [touchArray addObject:[NSValue valueWithCGPoint:location]];
    
    
    if (CGRectContainsPoint([objectsContainer boundingBox], location)) {
        touchedObjectTag = objectsContainer.tag;
        //update the location to relative position for children
        location = ccpSub(location, objectsContainer.boundingBox.origin);
        for (CCSprite* child in objectsContainer.children) {
            if (CGRectContainsPoint([child boundingBox], location)) {
                touchedObjectTag = child.tag;
                break;
            }
        }
    }
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];

    
    location = [[CCDirector sharedDirector] convertToGL:location];
    [touchArray addObject:[NSValue valueWithCGPoint:location]];

    if (touchedObjectTag != NOTAG) {
        
        //try to check whether the touched sprite is the objects container or not
        
        CCSprite* touched = nil;
        
        if (touchedObjectTag == objectsContainer.tag) {
            touched = objectsContainer;
        } else {
            touched = (CCSprite*)[objectsContainer getChildByTag:touchedObjectTag];
        }
        CGRect rect = objectsContainer.boundingBox;
        if (touched.zOrder == _backgroundDepth) {
            
            //modifer locaiton to make sure that the location is in the middle
            //of the touchrect, because default anchor point is lower left corner
            //when you try to move the rect, the center pointer is left corner, it's user unfriendly
            //make the location lefter and lower than it is supposed to
            location.x -= rect.size.width / 2;
            location.y -= rect.size.height / 2;
        
        } else {
            //since we did not change the anchor point of the children sprites
            //we do not need to change the position of locaiton
            //but we need to make sure that the location is inside the touch rect
            location = ccpSub(location, rect.origin);
            location.x = MIN(location.x, rect.size.width);
            location.x = MAX(location.x, 0);
            location.y = MIN(location.y, rect.size.height);
            location.y = MAX(location.y, 0);
            
        }
        touched.position = location;
        GameplayScene* scene = (GameplayScene*)[[CCDirector sharedDirector] runningScene];
        [scene updateShadowPos:touched];
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //clear the object tag
    touchedObjectTag = NOTAG;

    //clear the touch array
    [touchArray removeAllObjects];
}

@end
