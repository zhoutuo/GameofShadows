//
//  LightSource.h
//  Game of Shadows
//
//  Created by Zhoutuo Yang on 4/2/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PhysicsSprite.h"

@interface LightSource : PhysicsSprite {
    @private
    NSString* on_filename;
    NSString* off_filename;
    float on_duration;
    float off_duration;
    bool isOn;
    float vertical_percentage;
    CCSprite* turn_on_texture;
}


-(id) initWithProperties: (NSString*)on_name :(NSString*)off_name :(float)on_dur :(float)off_dur :(float)vertical_per;
-(bool) isOn;
-(void) execActions;
-(void) stopExecActions;
-(bool) lightSourceContains: (CGPoint)point;
@end
