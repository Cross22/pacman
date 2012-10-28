//
//  ViewController.m
//  Pac-Man
//
//  Created by grubm012 on 10/27/12.
//  Copyright (c) 2012 mg. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@end

NSString* fileNames[]=
{
    @"beginning",
    @"intermission",
    @"chomp",
    @"death",
    @"eatfruit",
    //    @"extrapac",
    @"eatghost"
};
const int MAX_SOUNDS= sizeof(fileNames)/sizeof(fileNames[0]);

bool isShuffle = false;
bool isBuffet  = false;

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeGrid];
}

SystemSoundID soundId=-1;

void systemAudioCallback(SystemSoundID soundId, void *mydata);

void playSound(int filenameIndex)
{
    NSString* str= fileNames[filenameIndex];
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"pacman_%@", str]
                                              withExtension:@"wav"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundId);
    
    void *mydata= NULL;
    AudioServicesAddSystemSoundCompletion(soundId, NULL, NULL, systemAudioCallback, mydata);
    AudioServicesPlaySystemSound( soundId );
}

void stopCurrentSound()
{
    if (soundId==-1) return;

    AudioServicesRemoveSystemSoundCompletion(soundId);
    AudioServicesDisposeSystemSoundID(soundId);
    soundId=-1;
}

void systemAudioCallback(SystemSoundID soundId, void *mydata)
{
    NSLog(@"System sound finished playing!");
    
    if (isBuffet) {
        AudioServicesPlaySystemSound( soundId ); //repeat
        return;
    }

    stopCurrentSound();
    
    if (!isShuffle) {
        return;
    }
    // find random sound
    int newId= rand() % MAX_SOUNDS ;
    playSound(newId);
}

- (void) makeGrid
{
	// Do any additional setup after loading the view, typically from a nib.
    int rows = 3; // fixed, will either be 2 or 3, depending on final size of images...
    int columns = 3;// will be determined by response from web service
    
    CGSize size= self.view.bounds.size;
    size.width /= columns;
    size.height /= rows;
    
    int currentSound= 0;
    
    for(int i = 0; i < rows; i++)
    {
        for(int j = 0; j < columns; j++)
        {
            // Create the buttons to handle button press
            UIButton *childButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            childButton.frame = CGRectMake(j * size.width, i * size.height, size.width, size.height);
            [childButton addTarget:self action:@selector(buttonClicked:)
                  forControlEvents:UIControlEventTouchUpInside];
            childButton.backgroundColor= [UIColor colorWithRed:1.0 green:1.0 blue:0.0f alpha:0.1f];
            childButton.layer.borderColor = [UIColor blackColor].CGColor;
            childButton.layer.borderWidth = 1.5f;
            childButton.layer.cornerRadius = 20.0f;
            
            // arbitrary int. assign index into our sound vector
            childButton.tag = currentSound;
            
            NSString* btnname;
            if (currentSound < MAX_SOUNDS ) {
                // within valid range ?
                btnname= fileNames[currentSound];
            } else {
                // max sounds exceeded. make custom buttons
                NSString* special[] = { @"STOP", @"RANDOM", @"BUFFET" };
                btnname= special[currentSound-MAX_SOUNDS];
            }
            ++currentSound;
            [childButton setTitle:btnname forState:UIControlStateNormal];
            [self.view addSubview:childButton];

        }
    }
    // fix special buttons
    
}


- (void) buttonClicked: (id) sender
{
    UIButton* btn= sender;
    isShuffle= false;
    isBuffet = false;
    stopCurrentSound();
    if (btn.tag < MAX_SOUNDS)
        playSound (btn.tag);
    else {
        switch (btn.tag) {
            case 6:
                break;
            case 7: //random
                isShuffle= true;
                systemAudioCallback(0,0);
                break;
            case 8:
                stopCurrentSound();
                isBuffet = true;
                playSound(2); // chomping
                break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
