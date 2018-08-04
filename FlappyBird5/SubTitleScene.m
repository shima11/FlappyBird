//
//  SubTitleScene.m
//  FlappyBird5
//
//  Created by shima jinsei on 2014/11/06.
//  Copyright (c) 2014年 Jinsei Shima. All rights reserved.
//

#import "SubTitleScene.h"
#import "GameScene.h"


@interface SubTitleScene(){
    SKSpriteNode *titleImage;
    SKSpriteNode *startImage;
    SKSpriteNode *backImage;
    
}
@end



@implementation SubTitleScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        //背景
        SKTexture *textur = [SKTexture textureWithImageNamed:@"angry_back4"];
        backImage = [[SKSpriteNode alloc] initWithTexture:textur];
        backImage.size = CGSizeMake(textur.size.width, textur.size.height);
        backImage.yScale = self.size.height / textur.size.height;
        backImage.xScale = self.size.height / textur.size.height;;
        backImage.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:backImage];
        
        //タイトル
        SKTexture *texture = [SKTexture textureWithImageNamed:@"title"];
        titleImage = [[SKSpriteNode alloc] initWithTexture:texture];
        titleImage.size = CGSizeMake(texture.size.width, texture.size.height);
        titleImage.xScale = 0.4;
        titleImage.yScale = 0.4;
        titleImage.position = CGPointMake(self.size.width/2, self.size.height*0.6);
        [self addChild:titleImage];
        
        //スタートボタン
        SKTexture *textures = [SKTexture textureWithImageNamed:@"playButton"];
        startImage = [[SKSpriteNode alloc] initWithTexture:textures];
        startImage.size = CGSizeMake(textures.size.width, textures.size.height);
        startImage.name = @"playButton";
        startImage.xScale = 0.5;
        startImage.yScale = 0.5;
        startImage.position = CGPointMake(self.size.width/2, self.size.height*0.3);
        [self addChild:startImage];
        
        
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
    
    
}



@end
