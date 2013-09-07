//
//  ParallaxSprite.m
//  iOSDevUK
//
//  Created by Stephen Chan on 8/28/13.
//
//

#import "ParallaxSprite.h"

@interface ParallaxSprite ()

- (void)setup;

@end

@implementation ParallaxSprite

@synthesize localTexture, image1, image2, speed;

- (id) initWithTexture:(SPTexture*) texture speed:(float)s;
{
    if ((self = [super init]))
    {
        localTexture = texture;
        speed = s;
        
        [self setup];
    }
    return self;
}

- (void)setup
{
    image1 = [SPImage imageWithTexture:localTexture];
    image2 = [SPImage imageWithTexture:localTexture];
    
    image2.x = image1.width;
    
    [self addChild:image1];
    
    if(speed > 0)
    {
        [self addChild:image2];
    }
}

- (void) update
{
    if(speed > 0)
    {
        self.x -= speed;
        
        if(self.x < -image1.width)
            self.x = 0;
    }
}


@end
