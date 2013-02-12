//
//  GestureRecognizer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 2/11/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum {Press, Swipe} Gestures;

@interface GestureRecognizer : NSObject {
    
}



+(Gestures) recognizeGestures: (CCArray*) locations;

@end
