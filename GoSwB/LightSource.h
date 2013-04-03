//
//  LightSource.h
//  Game of Shadows
//
//  Created by Zhoutuo Yang on 4/2/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface LightSource : CCSprite {
    @private
    NSString* on_filename;
    NSString* off_filename;
    float on_duration;
    float off_duration;
    bool isOn;
}

-(id) initWithProperties: (NSString*)on_name :(NSString*)off_name :(float)on_dur :(float) off_dur;
-(bool) isOn;
-(void) execActions;
@end
