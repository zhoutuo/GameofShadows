//
//  LightSource.m
//  Game of Shadows
//
//  Created by Zhoutuo Yang on 4/2/13.
//
//

#import "LightSource.h"

@implementation LightSource

-(id) initWithProperties: (NSString*)on_name :(NSString*)off_name :(float)on_dur :(float) off_dur :(float)vertical_per {
    if(self = [super initWithFile:on_name]) {
        on_filename = [[NSString alloc] initWithString:on_name];
        off_filename = [[NSString alloc] initWithString:off_name];
        on_duration = on_dur;
        off_duration = off_dur;
        vertical_percentage = vertical_per;
        turn_on_texture = [CCSprite spriteWithFile:off_filename];
        turn_on_texture.visible = NO;
        turn_on_texture.position = ccp(self.boundingBox.size.width / 2, self.boundingBox.size.height * vertical_per);
        [self addChild:turn_on_texture];
    }
    return self;
}


-(void) dealloc {
    [super dealloc];
    [on_filename release];
    [off_filename release];
}

-(void) execActions {
    if (on_duration > 0.0 or off_duration > 0.0) {
        //this is a fake action just used for the duration
        id on_action = [CCMoveBy actionWithDuration:on_duration position:ccp(0, 0)];
        id on_callback = [CCCallFunc actionWithTarget:self selector:@selector(turnOn)];
        id off_action = [CCMoveBy actionWithDuration:off_duration position:ccp(0, 0)];
        id off_callback = [CCCallFunc actionWithTarget:self selector:@selector(turnOff)];
        id seq = [CCSequence actions:on_action, on_callback, off_action, off_callback, nil];
        [self runAction:[CCRepeatForever actionWithAction:seq]];
    }
}



-(void) turnOn {
    isOn = true;
    turn_on_texture.visible = YES;
}

-(void) turnOff {
    isOn = false;
    turn_on_texture.visible = NO;
}

-(bool) isOn {
    return isOn;
}

-(CGRect) getInnerBoundingBox {
    CGRect innerBoundingBox;
    //init the inner bouding box
    innerBoundingBox.size.width = turn_on_texture.boundingBox.size.width / 2;
    innerBoundingBox.size.height = turn_on_texture.boundingBox.size.height / 2;
    innerBoundingBox.origin = ccpAdd(turn_on_texture.boundingBox.origin,
                                     ccp(turn_on_texture.boundingBox.size.width / 4, turn_on_texture.boundingBox.size.height / 4));
    return innerBoundingBox;
}

-(bool) lightSourceContains:(CGPoint)point {
    CGPoint innerPoint = [self convertToNodeSpace:point];
    if (isOn) {
        return CGRectContainsPoint([self getInnerBoundingBox], innerPoint);
    } else {
        return false;
    }
}


@end
