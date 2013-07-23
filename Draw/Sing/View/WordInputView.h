//
//  WordInputView.h
//  Draw
//
//  Created by 王 小涛 on 13-6-18.
//
//

#import <Foundation/Foundation.h>

@class WordInputView;

@protocol WordInputViewDelegate <NSObject>

@optional
- (void)wordInputView:(WordInputView *)wordInputView
           didGetWord:(NSString *)word
            isCorrect:(BOOL)isCorrect;

@end

typedef enum _WordInputViewAlignment{
    
    WordInputViewStyleAlignmentLeft = 0,
    WordInputViewStyleAlignmentCenter = 1,
    WordInputViewStyleAlignmentRight = 2,
    WordInputViewStyleAlignmentCustom = 3,
    
}WordInputViewAlignment;

@interface WordInputView : UIView

// required
@property (copy, nonatomic) NSString *answer;
@property (assign, nonatomic) id<WordInputViewDelegate> delegate;

// optional
@property (assign, nonatomic) WordInputViewAlignment alignment;

@property (retain, nonatomic) UIColor *candidateColor;
@property (retain, nonatomic) UIColor *answerColor;
@property (assign, nonatomic) CGFloat hGap;
@property (assign, nonatomic) CGFloat wGap;


- (void)setCandidates:(NSString *)characters
               column:(int)column;
- (void)bomb:(int)count;
- (void)bombHalf;

- (void)reset;

@end


