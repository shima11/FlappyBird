//
//  TitleScene.m
//  FlappyBird5
//
//  Created by shima jinsei on 2014/11/02.
//  Copyright (c) 2014年 Jinsei Shima. All rights reserved.
//

#import "TitleScene.h"
#import "GameScene.h"


@interface TitleScene(){
    SKSpriteNode *titleImage;
    SKSpriteNode *startImage;
    SKSpriteNode *backImage;
    SKSpriteNode *settingImage;
    
    UIToolbar *_tb;
    UIView *popView;
    
}
@end


@implementation TitleScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //背景
        SKTexture *texture1 = [SKTexture textureWithImageNamed:@"angry_back4"];
        backImage = [[SKSpriteNode alloc] initWithTexture:texture1];
        backImage.size = CGSizeMake(texture1.size.width, texture1.size.height);
        backImage.yScale = self.size.height / texture1.size.height;
        backImage.xScale = self.size.height / texture1.size.height;;
        backImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:backImage];

        //タイトル
        SKTexture *texture2 = [SKTexture textureWithImageNamed:@"title"];
        titleImage = [[SKSpriteNode alloc] initWithTexture:texture2];
        titleImage.size = CGSizeMake(texture2.size.width, texture2.size.height);
        titleImage.xScale = 0.4;
        titleImage.yScale = 0.4;
        titleImage.position = CGPointMake(self.size.width/2, self.size.height*0.6);
        [self addChild:titleImage];
        
        //スタートボタン
        SKTexture *texture3 = [SKTexture textureWithImageNamed:@"playButton"];
        startImage = [[SKSpriteNode alloc] initWithTexture:texture3];
        startImage.size = CGSizeMake(texture3.size.width, texture3.size.height);
        startImage.name = @"playButton";
        startImage.xScale = 0.5;
        startImage.yScale = 0.5;
        startImage.position = CGPointMake(self.size.width/2, self.size.height*0.3);
        [self addChild:startImage];
        
        /*
        //設定ボタン
        SKTexture *texture4 = [SKTexture textureWithImageNamed:@"settingButton"];
        settingImage = [[SKSpriteNode alloc] initWithTexture:texture4];
        settingImage.size = CGSizeMake(texture4.size.width, texture4.size.height);
        settingImage.name = @"settingButton";
        settingImage.xScale = 0.5;
        settingImage.yScale = 0.5;
        settingImage.position = CGPointMake(self.size.width*0.8, self.size.height*0.3);
        [self addChild:settingImage];
         */
        
    }
    return self;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [[touches anyObject] locationInNode:self];
    
    //スタート画面をクリックすると、画面遷移
    if (startImage != nil && [startImage containsPoint:point]) {
        SKScene *scene = [[GameScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition crossFadeWithDuration:0.4];
        [self.view presentScene:scene transition:transition];
    }
    /*
    //設定ボタン
    if (settingImage != nil && [settingImage containsPoint:point]) {
        _tb = [[UIToolbar alloc] init];
        _tb.frame = self.view.frame;
        _tb.barStyle = UIBarStyleBlack;
        _tb.translucent = YES;
        _tb.alpha = 0.6;
        _tb.tag = 2000;
        [self.view addSubview:_tb];
        
        popView = [[UIView alloc]init];
        popView.frame = CGRectMake(0,0,self.view.frame.size.width*0.7,self.view.frame.size.height*0.3);
        popView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        popView.layer.cornerRadius = 20.0;
        popView.backgroundColor = [UIColor colorWithRed:0.349 green:0.82 blue:0.67 alpha:1.0];
        [self.view addSubview:popView];
    }
     */
    
    
}



@end
