//
//  ParallaxSprite.h
//  iOSDevUK
//
//  Created by Stephen Chan on 8/28/13.
//
//

#import "SPSprite.h"

@interface ParallaxSprite : SPSprite
{
    
}

- (id)initWithTexture:(SPTexture*) texture speed:(float)s;

@property (nonatomic, retain) SPTexture* localTexture;

@property (nonatomic, retain) SPImage* image1;
@property (nonatomic, retain) SPImage* image2;

@property (nonatomic, assign) float speed;

- (void) update;

@end
