//
//  Game.m
//  iOSDevUK
//

#import "Game.h"
#import "Media.h"
#import "SXParticleSystem.h"

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)setup;
- (void)createStar;
- (void)updateStars;
- (void)checkCollision;
- (void)playParticle:(SPPoint*)point;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation Game

@synthesize layer_1, layer_2, layer_3, layer_4, player, stars, scoreText;

- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
        
        score = 0;
        isJump = false;
        
        stars = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    // release any resources here
    [Media releaseAtlas];
    [Media releaseSound];
}

- (void)setup
{
    /* STEP 1
     *
     * Using SPImage to add a static image to the game
     */
    
    SPImage *background = [SPImage imageWithContentsOfFile:@"bg_sky.jpg"];
    
    [self addChild:background];
    
    
    
    /* STEP 2
     *
     * Using my custom game object extends SPSprite, the ParallaxSprite
     */
    
    layer_1 = [[ParallaxSprite alloc] initWithTexture:[SPTexture textureWithContentsOfFile:@"bg_cloud.png"] speed:2];
    layer_2 = [[ParallaxSprite alloc] initWithTexture:[SPTexture textureWithContentsOfFile:@"bg_mountains.png"] speed:3];
    layer_3 = [[ParallaxSprite alloc] initWithTexture:[SPTexture textureWithContentsOfFile:@"bg_cloud_2.png"] speed:4];
    layer_4 = [[ParallaxSprite alloc] initWithTexture:[SPTexture textureWithContentsOfFile:@"bg_grass.png"] speed:5];

    [self addChild:layer_1];
    [self addChild:layer_2];
    [self addChild:layer_3];
    [self addChild:layer_4];
    
    
    
    /* STEP 2.1
     *
     * Create a Enter Frame event listener
     */
    
    [self addEventListener:@selector(onEnterFrame:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    
    
    /* STEP 3
     *
     * Create Texture with TexturePacker
     * 
     * Initialise the texture atlas in the Media class
     */
    
    [Media initAtlas];
    
    
    
    /* STEP 3.1
     *
     * Create a SPMoveClip to animate the character
     */
    
    player = [SPMovieClip movieWithFrames:[Media atlasTexturesWithPrefix:@"flight_"] fps:20];
    player.y = [Sparrow stage].height - player.height - 50;
    player.x = ([Sparrow stage].width - player.width) / 2 - 50;

    [self addChild:player];
    
   
    
    /* STEP 3.2
     *
     * Add the movie clip to the juggler
     */
    
    [[Sparrow juggler] addObject:player];
    
    
    
    
    /* STEP 4
     *
     * Create Touch event listener
     */
    
    [self addEventListener:@selector(onTouch:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    
    
    
    /* STEP 6
     *
     * Create Font with Glyph Designer
     *
     * Register the bitmap font
     */
    
    [SPTextField registerBitmapFontFromFile:@"sparrow_fnt.fnt"];
    
    
    
    /* STEP 6.1
     *
     * Create score text with SPText and use the bitmap font
     */
    
    scoreText = [SPTextField textFieldWithWidth:600 height:47 text:@"SCORE: 0" fontName:@"sparrow_fnt" fontSize:40 color:0xFFFFFF];
    scoreText.hAlign = SPHAlignLeft;
    scoreText.x = 10;
    scoreText.y = 10;
    
    [self addChild:scoreText];
    
    
    
    
    /* STEP 7
     *
     * Initialise the sound in the Media class
     */
    
    [Media initSound];
}

/* STEP 2.1
 *
 * onEnterFrame function handler
 */

- (void) onEnterFrame: (SPEnterFrameEvent*) event
{
    /* STEP 2.2
     *
     * Call the update function on the background layers to play the parallax effect
     */
    
    [layer_1 update];
    [layer_2 update];
    [layer_3 update];
    [layer_4 update];
    
    
    
    /* STEP 5
     *
     * Call update coin function to start creating coins
     */
    
    [self updateStars];
    
    
    
    /* STEP 5.5
     *
     * Check for collision detections with the player and the coins
     */
    
    [self checkCollision];
    
    
    
    /* STEP 6.3
     *
     * Update the score text with a NSString
     */
    
    scoreText.text = [NSString stringWithFormat:@"SCORE: %i", score];
}


/* STEP 4.1
 *
 * onTouch function handler
 */

- (void)onTouch:(SPTouchEvent*)event
{
    if(!isJump)
    {
        /* STEP 4.2
         *
         * Check the event if the touch has occured
         */
        
        SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
        if (touch)
        {
            /* STEP 4.3
             *
             * Create a tween effect to make the character jump
             */
            
            SPTween *tween = [SPTween tweenWithTarget:player time:0.3f transition:SP_TRANSITION_EASE_OUT];
            [tween animateProperty:@"y" targetValue:player.y - 100];
            tween.reverse = YES;
            tween.repeatCount = 2;
            
            [player pause];
            isJump = YES;
            
            [[Sparrow juggler] addObject:tween];
            
            
            
            /* STEP 4.4
             *
             * Use the onComplete block to reset the player state
             */
            
            tween.onComplete = ^{
                isJump = NO;
                
                [player play];
            };
        }
    }
}



/* STEP 5.1
 *
 * updateCoin function
 */

- (void)updateStars
{
    /* STEP 5.2
     *
     * Increase the framecount and check every 50 Frames and create a coin
     */

    frameCount++;
    
    if(frameCount % 50 == 0)
    {
        [self createStar];
    }
    
    
    
    /* STEP 5.4
     *
     * Go through the pool of coins and move them along the x axis towards the player
     * Destroy them if they travel off the screen
     */
    
    for(int i = stars.count - 1; i >= 0; i--)
    {
        ((SPImage*)stars[i]).x -= 10;
        
        if(((SPImage*)stars[i]).x < 0 - ((SPImage*)stars[i]).pivotX)
        {
            [((SPImage*)stars[i]) removeFromParent];
            [stars removeObjectAtIndex:i];
        }
    }
}


/* STEP 5.6
 *
 * checkCollision function
 */

- (void)checkCollision
{
    for(int i = stars.count - 1; i >= 0; i--)
    {
        /* STEP 5.7
         *
         * Check the rectangle bounds of the player and the current coin
         * Check if they intersect
         * If so we destroy the coin and remove it
         */
        
        if([((SPImage*)stars[i]).bounds intersectsRectangle: [self getPlayerBounds:player.bounds]])
        {
            /* STEP 6.2
             *
             * Imcrement the score by 1 every time we collide with a coin
             */
            
            score++;
            
            
            
            /* STEP 7.1
             *
             * Play the .caf sound file when we collide with a coin
             */
            
            [Media playSound:@"star.caf"];
            
            
            
            /* STEP 8
             *
             * Trigger a particle effect when we collide with a coin
             */
            
            [self playParticle:[SPPoint pointWithX:((SPImage*)stars[i]).x y:((SPImage*)stars[i]).y ]];
            
            
            
            
            [((SPImage*)stars[i]) removeFromParent];
            [stars removeObjectAtIndex:i];
        }
    }
}

- (void)createStar
{
    /* STEP 5.3
     *
     * Create a coin using SPImage, place it off the screen
     * Add it to an array of coins
     */
    
    SPImage* star = [SPImage imageWithTexture:[SPTexture textureWithContentsOfFile:@"star.png"]];
    star.pivotX = star.width/2;
    star.pivotY = star.height/2;
    star.x = [Sparrow stage].width + star.pivotX;
    star.y = (([Sparrow stage].height - player.height - 40) - star.pivotY) - (arc4random() % 65);
    
    [self addChild:star];
    
    [stars addObject:star];
}

- (void)playParticle:(SPPoint*)point
{
    /* STEP 8.1
     *
     * Create a pex particle effect with Particle Designer
     *
     * Create a SXParticleSystem when the coin collided
     */
    
    SXParticleSystem* particle = [[SXParticleSystem alloc] initWithContentsOfFile:@"star_spark.pex"];
    particle.x = point.x;
    particle.y = point.y;
    
    [self addChild:particle];
    [[Sparrow juggler] addObject:particle];
    
    [particle startBurst:0.1];
}

/* OFF SET THE CHARACTERS BOUNDS */
- (SPRectangle*)getPlayerBounds:(SPRectangle*)bounds
{
    bounds.height -= 80;
    bounds.y += 40;
    
    return bounds;
}

@end
