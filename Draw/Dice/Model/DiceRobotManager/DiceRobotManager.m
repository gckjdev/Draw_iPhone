//
//  DiceRobotManager.m
//  Draw
//
//  Created by Orange on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceRobotManager.h"

@implementation DiceResult
@synthesize dice;
@synthesize diceCount;
@synthesize isWild;
@synthesize shouldOpen;

- (void)reset
{
    self.dice = 0;
    self.diceCount = 0;
    self.shouldOpen = NO;
    self.isWild = NO;
}

@end

@interface DiceRobotManager ()
- (void)initialCall:(int)playerCount;
@end

/*
 *   多项式分布概率数组, 每一项表示n个骰子出现
 *  x个y的概率(忽略了机器人自己的5个骰子).y可以是
 *  1,2,3,4,5,6.   
 *    
 *  每一项由下列公式给出:
 *    {n!/(x!(n-x)!)} * p^x * (1-p)^(n-x)
 *   其中,x表示出现x个1(或2,或3,或4,或5,或6)
 *   的个数, p表示每个骰子出现1(或2,或3,或4,或5,或6)的概率,
 *   它的值是1/6.
 */
// In case of two players, base in probability[] is 0, etc.
static double probability[] = {
    // Two players(5 dices,except robot's 5 dices)
    0.401878,	0.401878,	0.160751,	0.0321502,	0.00321502,	0.000128601,
    
    // Three players(10 dices,except robot's 5 dices)
    0.161506,	0.323011,	0.29071,	0.155045,	0.0542659,
    0.0130238,	0.00217064, 0.000248073,
    1.86054e-05, 8.26909e-07,	1.65382e-08,
    
    // Four players(15 dices,except robot's 5 dices)
    0.0649055,	0.194716,	0.272603,	0.236256,	0.141754,	0.0623716,	0.0207905,
    0.00534613,	0.00106923,	0.000166324,	1.99589e-05,
    1.81445e-06,	1.20963e-07,	5.58291e-09,	1.59512e-10,	2.12682e-12,
    
    // Five players(20 dices,except robot's 5 dices)
    0.0260841,	0.104336,	0.198239,	0.237887,	0.202204,	0.12941,	0.0647051,	0.0258821,
    0.00841167,	0.00224311,	0.000493485,	8.97245e-05,	1.34587e-05,	1.65645e-06,
    1.65645e-07,	1.32516e-08,	8.28226e-10,	3.89753e-11,	1.29918e-12,
    2.73511e-14,	2.73511e-16,
    
    // Six players(25 dices, except robot's 5 dices)
    0.0104826,	0.052413,	0.125791,	0.19288,	0.212168,	0.178221,	0.118814,	0.064499,
    0.0290245,	0.0109648,	0.00350875,	0.000956931,	0.000223284, 4.46568e-05,	7.65544e-06,
    1.1228e-06,1.4035e-07,	1.48606e-08,	1.32094e-09,	9.73324e-11,	5.83994e-12,
    2.78093e-13,	1.01125e-14,	2.63803e-16,	4.39672e-18,	3.51738e-20,
};

static int  BASE[] = {0, 6, 17, 33, 54}; 

/*
 * 5(,10,15,20,25)个骰子中出现1(或2,...或6)的个数的期望值M,
 * 		期望值公式: M = ∑ k*pk
 *  	k表示出现0次(1次,2次.....25次)
 * 	pk是出现k次的对应概率,即上面的probablity数组
 * 		∑是连加. 如：
 *   6项(5个骰子)相加算出来是3.302, 四舍五入成3.
 */
static int  DiceMeanValue[] = {3, 5, 5, 5, 5};


// If difference is >= unsafe_difference[playerCount-2], it's not safe
static int UNSAFE_DIFFERENCE[] = {3, 5, 7, 8, 10};
// Initial benchmark probability
// 5:  0.160751;   10: 0.0542659;  15: 0.0207905;  20: 0.0258821;	25: 0.0109648
static double INI_BENCHMARK[] = {0.16, 0.05, 0.02,	0.02,  0.01} ;
// Current game's benchmark probablity
double  benchmark[5];//{INI_BENCHMARK[0], INI_BENCHMARK[1], INI_BENCHMARK[2], INI_BENCHMARK[3], INI_BENCHMARK[4]};

//
//// Robot's highest intelligence
//private static final double HIGHEST_IQ = 1;
//// IQ threshold affects how robot make decision
//private static final double IQ_THRESHOLD = 0.6d;
//// A accelerator fator that control how
//// fast the intelligence changes
//private static final double ACCELERATOR_FACTOR = Math.E / 2;
//// Robot's IQ in current game
//private  double intelligence;

//      *** NOT IMPLEMENTED NOW !!! ***
//		// Per-player's initial honesty
//		private static final int INIHONESTY = 10;
//		// At most five player(except robot itself) 
//		private int[] honesty = {INIHONESTY,INIHONESTY,INIHONESTY,INIHONESTY,INIHONESTY};

// The current this game in
int globalRound;
// How many games the robot wins
int winGame;
// How many games the robot loses
int loseGame;
// Last Game playercount, it is 2 in the beginning.
int lastPlayerCount = 2;

// A flag to indicate whether giving up calling.
BOOL giveUpCalling = NO;

// An array where we put what to call.
// index 0: the number of dices
// index 1: which dice
// index 2: is wild ?
static int IDX_NUM_OF_DICE 		= 0;
static int IDX_DICE_FACE_VALUE = 1;
static int IDX_CALL_WILD 		= 2;
int whatToCall[] = {0, 0, 0};
int lastRoundCall[] = {0, 0, 0};



/* Introspection of robot's dices, set by introspectRobotDices method.
 * index 0: any dice of 4 or 5 instances ? 1 for yes, 0 for no.
 * index 1: which dice has 4/5 instances ? Only set if index 1 is 1.
 * index 2: any dice of 3 instances ? 1 for yes, 0 for no.
 * index 3: which dice has 3 instances ? Only set if index 3 is 1.
 * index 4: any dice of 2 instances ? 1 for yes, 0 for no.
 * index 5: which dice has 3 instances ? Only set if index 5 is 1.
 * index 6: same as index 6(There may be two dices of 2 instances).
 * index 7: distributed uniformly.  
 */
static int NUM_MORE_THAN_FOUR 	= 0;
static int DICE_MORE_THAN_FOUR = 1;
static int NUM_OF_THREE 			= 2;
static int DICE_OF_THREE 		= 3;
static int NUM_OF_TWO 			= 4;
static int DICE_OF_TWO 			= 5;
static int ANOTHER_DICE_OF_TWO = 6;
static int DISTRIBUTE_UNIFORMLY= 7;
int introspection[] = {0, 0, 0, 0, 0, 0, 0, 0};

// How dose robot's dices distribute?
static int DICE_VALUE_ONE 	= 1;
static int DICE_VALUE_TWO 	= 2;
static int DICE_VALUE_THREE = 3;
static int DICE_VALUE_FOUR 	= 4;
static int DICE_VALUE_FIVE 	= 5;
static int DICE_VALUE_SIX 	= 6;
int distribution[] = {0, 0, 0, 0, 0, 0};

// Is it safe for robot to call?
BOOL safe = YES;
// Does robot lie?
BOOL lying = NO;
// If lie, what dice it lie?
int lieDice = 0;

// In one game, we limit robot to only send one callwild message.
//		private boolean hasSendCallWilds = false;


// For chat.
//static int TEXT = 1;
//static int EXPRESSION = 2;
/*
 * index 0 : chatContent
 * index 1 : chatVoidId
 * index 2 : contentType: TEXT or EXPRESSION
 */
//static int IDX_CONTENT 		= 0;
//static int IDX_CONTENTID 	= 1;
//static int IDX_CONTNET_TYPE = 2;
//private String[ ] whatToChat = {"关注我吧。","1", "1"};
//private boolean setChat = false;

void reset(int array[], int count)
{
    for ( int i = 0; i< count; i++) {
        array[i] = 0 ;
    }
}

static DiceRobotManager* shareInstance;

@implementation DiceRobotManager
@synthesize result = _result;

- (void)dealloc
{
    [_result release];
    [super dealloc];
}

+ (DiceRobotManager*)defaultManager
{
    if (shareInstance == nil) {
        shareInstance = [[DiceRobotManager alloc] init];
    }
    return shareInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _result = [[DiceResult alloc] init];
    }
    return self;
}

- (void)newRound:(int)playerCount
{
    [self balanceAndReset:playerCount];
    [self.result reset];
    [lastCall removeAllObjects];
    [changeDiceValue removeAllObjects];
}

- (void)resetBenchmark {
    benchmark[0] = INI_BENCHMARK[0]; benchmark[1] = INI_BENCHMARK[1]; benchmark[2] = INI_BENCHMARK[2];
    benchmark[3] = INI_BENCHMARK[3]; benchmark[4] = INI_BENCHMARK[4];
}

//- (void)reset(NSArray* array) {
//    for ( int i = 0; i< array.length; i++) {
//        array[i] = 0 ;
//    }
//}

//public DiceRobotIntelligence() {
//    intelligence = HIGHEST_IQ;
//    round = 0;
//    winGame = 0;
//    loseGame = 0;
//}

// Mainly adjust robot's IQ and the probability benchmark.
- (void) balanceAndReset:(int)playerCount{
    
    [self resetBenchmark];
    winGame = 0;
    lastPlayerCount = playerCount;
    globalRound = 0;
    giveUpCalling = NO;
    safe = YES;
    lying = NO;
    lieDice = 0;
    //			hasSendCallWilds = false;
    reset(whatToCall,3);
    reset(introspection,8);
    reset(distribution,6);
}

- (BOOL)canOpenDice:(int)playerCount 
             userId:(NSString*)userId
             number:(int)num 
               dice:(int)dice 
             isWild:(BOOL)isWild {
    
    BOOL canOpen = NO;
    
    int notWild = (isWild == NO? 1 : 0);
    // How many "dice" robot have.
    int numOfDice = distribution[dice-1] + ((dice == DICE_VALUE_ONE)?0:distribution[DICE_VALUE_ONE-1] * notWild);
    int difference = num - numOfDice;
    
    NSNumber* diceInteger = [NSNumber numberWithInt:dice];
    if ( [lastCall objectForKey:userId] == nil ) {
        [lastCall setObject:diceInteger forKey:userId];
        [changeDiceValue setObject:[NSNumber numberWithBool:NO] forKey:userId];
    } else {
        if ( ![(NSNumber*)[lastCall objectForKey:userId] isEqualToNumber:diceInteger ]) {
            [changeDiceValue setObject:[NSNumber numberWithBool:YES] forKey:userId];
            //changeDiceValue.put(userId, new Boolean(true));
            [lastCall setObject:diceInteger forKey:userId];
            //lastCall.put(userId, diceInteger);
        } else {
            [changeDiceValue setObject:[NSNumber numberWithBool:NO] forKey:userId];
        }
    }
    
    // Make a decision...
//    if ( intelligence < IQ_THRESHOLD ) {
//        canOpen = ((int)HIGHEST_IQ/intelligence >= 2 && difference > UNSAFE_DIFFERENCE[playerCount-2] ? true : false);
//        if(canOpen) {
//            logger.info("robot is not smart, it decides to open!");
//            //					setChatContent(TEXT,chatContent.getContent(DiceRobotChatContent.VoiceContent.DONT_FOOL_ME));
//        }
//        return canOpen;
//    }
    
    // Ok, below starts hard work, since robot is quite smart ^_^
    // lying means robot call a dice value that it even doesn't have one!
    if ( lying && dice == lieDice && difference >= UNSAFE_DIFFERENCE[playerCount-2]) {
        canOpen = (rand()%2 == 1)? YES : NO;
        PPDebug(@"Robot is lying and player is fooled,open!");
        //					setChatContent(TEXT,chatContent.getContent(DiceRobotChatContent.VoiceContent.YOU_ARE_FOOL));
        //setChatContent(EXPRESSION, chatContent.getExpression(DiceRobotChatContent.Expression.PROUND));
        return canOpen;
    }
    
    // If difference <= 0, of course robot won't chanllenge.
    if ( difference > 0 ) {
        if ( difference > UNSAFE_DIFFERENCE[playerCount-2] ) {
            canOpen = YES;
            PPDebug(@"Call to much, open!");
        }
        // Distributed uniformly & quantity is too big, it's not safe to call.
        else if ( introspection[DISTRIBUTE_UNIFORMLY] == 1 && difference >= UNSAFE_DIFFERENCE[playerCount-2]) {
            canOpen = YES;
            PPDebug(@"Distributed uniformly & call too much, open!");
        }
        else if ( probability[BASE[playerCount-2] + difference]  < benchmark[playerCount-2] ) {
            if ( globalRound <= 2 ){
                canOpen = ( difference > UNSAFE_DIFFERENCE[playerCount-2] ?  YES : NO );
                if (canOpen)
                    PPDebug(@"round <=2, call too much, open!");
            }
            if (globalRound == 2 || globalRound == 3) {
                if ( ((NSNumber*)[changeDiceValue objectForKey:userId]).boolValue) {
                    canOpen = (((globalRound + rand()%2) > 2)?YES :NO);
                    if(canOpen) {
                        PPDebug(@"round 2 or round 3, player changes dice face value, he/she may be cheating, open!");
                        //								setChatContent(TEXT,chatContent.getContent(DiceRobotChatContent.VoiceContent.DONT_FOOL_ME));	
                        return canOpen;
                    }
                }
                if ( difference >= UNSAFE_DIFFERENCE[playerCount-2] ) {
                    canOpen = (globalRound + rand()%2 > 2 ? YES : NO);
                    if(canOpen)
                        PPDebug(@"round 2 or round 3, call too much, open!");
                }
                else if ( !safe ){
                    canOpen = (rand()%2 == 1 ? YES : NO );
                    if(canOpen)
                        PPDebug(@"Not safe, open!");
                }
            }
            else if ( globalRound > 4) {
                canOpen = true;
                PPDebug(@"Too much round, calling is dangerous, open!");
            }
        }	
    }
    // For chat
//    if (canOpen == true && RandomUtils.nextInt(3) == 1) {
//        //				setChatContent(TEXT,chatContent.getContent(DiceRobotChatContent.VoiceContent.BELIEVE_IT));
//        if ( RandomUtils.nextInt(2) == 0 )
//            setChatContent(EXPRESSION, chatContent.getExpression(DiceRobotChatContent.Expression.SMILE));
//        else 
//            setChatContent(EXPRESSION, chatContent.getExpression(DiceRobotChatContent.Expression.PROUND));
//    } 
    
    
    return canOpen;
}


- (void) decideWhatToCall:(int)playerCount 
                   number:(int)num 
                     dice:(int)dice 
                   isWild:(BOOL)isWild 
                   myDice:(int[])robotDices 
{
    
    int tmp = 0;
    
    giveUpCalling = false;
    whatToCall[IDX_NUM_OF_DICE] = 0;
    whatToCall[IDX_DICE_FACE_VALUE] = 0;
    whatToCall[IDX_CALL_WILD] = 0;
    
    // We are first to call 
    if ( num == -1 || dice == -1) {
        [self initialCall:playerCount];
        return;
    }
    
    // Just adding one even exceeds the limit, we should not call. 
    if ( num + 1 >= playerCount * 5 ) {
        giveUpCalling = true;
        return ;
    }
    
    PPDebug(@"Now the playerCount is %d", playerCount);
    PPDebug(@"Now the benchmark is %f ", benchmark[playerCount-2]);
    PPDebug(@"Current round is Round is %d ", (globalRound +1));
    
    int notWild = (isWild == NO? 1 : 0);
    // How many "dice" robot have.
    int numOfDice = distribution[dice-1] + ((dice == DICE_VALUE_ONE)?0:distribution[DICE_VALUE_ONE-1] * notWild);
    int difference = num - numOfDice;
    
    
    // Make decision...
    if (isWild){
        // Not so intelligent, just add 1
//        if ( intelligence < IQ_THRESHOLD ){
//            if (num + 1 - distribution[dice-1] <= UNSAFE_DIFFERENCE[playerCount-2] ) {
//                recordCall(num+1, dice,1, playerCount);
//                safe = false;
//                logger.info("<DiceRobotIntelligence> isWild & not so smart, just add one, call "
//                            + whatToCall[IDX_NUM_OF_DICE]  + " X " + whatToCall[IDX_DICE_FACE_VALUE] );
//            } else {
//                giveUpCalling = true;
//                logger.info("<DiceRobotIntelligence> isWild & not so smart, not safe to call, give up!");
//                return;
//            }
//        }
        // Quite smart, do some deep thought.
        
        // We don't have as many dices as called.
        if ( difference > 0 ) {
            for( int i= 0; i < 6; i++ ) {
                if ( i + 1 > dice && distribution[i] >= difference ) {
                    [self recordCall:num + (dice == DICE_VALUE_ONE ? 1 : 0) 
                                dice:i+1 
                              isWild:1 
                         playerCount:playerCount];
                    //recordCall(num + (dice == DICE_VALUE_ONE ? 1 : 0), i+1, 1,playerCount);
                    globalRound++;
                    PPDebug(@"<DiceRobotIntelligence> isWild & smart, change dice, call %d X %d "
                                ,whatToCall[IDX_NUM_OF_DICE]  ,whatToCall[IDX_DICE_FACE_VALUE] );
                    return;
                }
                else if ( i+1 <= dice && distribution[i] > difference ){
                    [self recordCall:num+1 
                                dice:i+1 
                              isWild:1 
                         playerCount:playerCount];
                    //recordCall(num + 1, i+1, 1,playerCount);
                    globalRound++;
                    PPDebug(@"<DiceRobotIntelligence> isWild & smart, change dice, call %d X %d"
                                , whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE] );
                    return;
                }
            }
            // round+1 is current round, if current round is 3, it must be true,
            // if current round is 2, it is 50% true. 
            if ( difference+1 < UNSAFE_DIFFERENCE[playerCount-2] && (globalRound == 0 || (globalRound + 1 + rand()%2) > 2) ){
                [self recordCall:num+1 dice:dice isWild:1 playerCount:playerCount];
                //recordCall(num+1, dice,1,playerCount);
                safe = NO;
                PPDebug(@"<DiceRobotIntelligence> isWild & smart, just add one, call %d X %d"
                            ,whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE] );
            } else {
                PPDebug(@"<DiceRobotIntelligence> isWild &  smart, but not safe to call, give up calling");
                giveUpCalling = true;
                globalRound++;
                return;
            }
        } 
        // We have more dices than that called.
        else {
            // Some dice has more than 4 instances...
            if ( introspection[NUM_MORE_THAN_FOUR] == 1 ) {
                [self recordCall:(introspection[DICE_MORE_THAN_FOUR] > dice && dice != DICE_VALUE_ONE ? num : num +1) 
                            dice:introspection[DICE_MORE_THAN_FOUR] 
                          isWild:1 
                     playerCount:playerCount];
                //recordCall((introspection[DICE_MORE_THAN_FOUR] > dice && dice != DICE_VALUE_ONE ? num : num +1),
                          // introspection[DICE_MORE_THAN_FOUR], 1,playerCount);
                PPDebug(@"<DiceRobotIntelligence> isWild & smart, %d has more than 4 instances, so change dice to %d, call %d X %d", introspection[DICE_MORE_THAN_FOUR], introspection[DICE_MORE_THAN_FOUR], whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
                //PPDebug("<DiceRobotIntelligence> isWild & smart, "+introspection[DICE_MORE_THAN_FOUR] 
                //            + "has more than 4 instances, so change dice to " + introspection[DICE_MORE_THAN_FOUR]+
                //            ", call "+ whatToCall[IDX_NUM_OF_DICE] + " X " + whatToCall[IDX_DICE_FACE_VALUE]);
                // Some dice has 3 instances...
            } else if ( introspection[NUM_OF_THREE] == 1 ) {
                [self recordCall:(introspection[DICE_OF_THREE] > dice && dice != DICE_VALUE_ONE? num : num +1) 
                            dice:introspection[DICE_OF_THREE] 
                          isWild:1 
                     playerCount:playerCount];
                //recordCall((introspection[DICE_OF_THREE] > dice && dice != DICE_VALUE_ONE? num : num +1),
                //           introspection[DICE_OF_THREE], 1,playerCount);
                PPDebug(@"<DiceRobotIntelligence> isWild & smart, %d has more than 4 instances, so change dice to %d, call %d X %d", introspection[DICE_OF_THREE], introspection[DICE_OF_THREE], whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
//                PPDebug(@"<DiceRobotIntelligence> isWild & smart, "+introspection[DICE_OF_THREE] 
//                            + "has 3 instances, so change dice to " + introspection[DICE_OF_THREE]+
//                            ", call "+ whatToCall[IDX_NUM_OF_DICE] + " X " + whatToCall[IDX_DICE_FACE_VALUE]);
            }
            else {
                [self recordCall:num+1 
                            dice:dice 
                          isWild:1 
                     playerCount:playerCount];
                //recordCall(num+1, dice, 1, playerCount);
                safe = NO;
                PPDebug(@"<DiceRobotIntelligence> isWild &  smart, just add one, call %d X %d "
                            , whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE] );
            }
        }
        
    } // end of if(isWilds) 
    // Not wild~
    else {
//        int quotient = (int)(IQ_THRESHOLD/intelligence);
//        int extra = (num > playerCount*5* 2/3)? 0 : 
//        (quotient ==0 ? 0 : (quotient > 3 ? 1+RandomUtils.nextInt(2) + (playerCount/3) : (3 + playerCount/4 )/(round+1)+ RandomUtils.nextInt(2))); 
        // Does robot have more than 3 ONEs?
        if ( distribution[DICE_VALUE_ONE-1] >= 3 ){
            // YES, call ONE(auto wild)
            if ( num <= DiceMeanValue[playerCount-2] + distribution[DICE_VALUE_ONE-1] && probability[BASE[playerCount-2] + num] > benchmark[playerCount-2] ) {
                [self recordCall:num dice:1 isWild:1 playerCount:playerCount];
                //recordCall(num + extra, 1, 1, playerCount);
                safe = NO;
                PPDebug(@"<DiceRobotIntelligence> Not Wild & , many ONEs, call one! Call %d X %d"
                        , whatToCall[IDX_NUM_OF_DICE], dice);
//                PPDebug(@"<DiceRobotIntelligence> Not Wild & " + (intelligence< IQ_THRESHOLD? "not ":"")+ "smart, many ONEs, call one! Call "
//                            + whatToCall[IDX_NUM_OF_DICE]  + " X " + dice );
            } else {
                // YES, but the num is some little big, call wilds is not safe,
                // we should be careful.
                // 3 X 1 + 2 X ?
                if ( introspection[NUM_OF_TWO] == 1) {
                    [self recordCall:(dice > introspection[DICE_OF_TWO] ? num+1 : num) 
                                dice:introspection[DICE_OF_TWO] 
                              isWild:0 
                         playerCount:playerCount];
//                    recordCall((dice > introspection[DICE_OF_TWO] ? num+1 : num)+extra, introspection[DICE_OF_TWO], 0, playerCount);
                    safe = NO;
                    PPDebug(@"<DiceRobotIntelligence> Not Wild &  many ONEs & has dice of 2 instances, call %d X %d"
                                , whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
                }
                else {
                    tmp = probability[BASE[playerCount-2] + num + 2] > benchmark[playerCount-2]? num + 2 : num + 1;
                    [self recordCall:tmp 
                                dice:dice 
                              isWild:0 
                         playerCount:playerCount];
                    //recordCall(tmp+extra, dice, 0, playerCount);
                    PPDebug(@"<DiceRobotIntelligence> Not Wild &  many ONEs & has dice of 2 instances, call %d X %d"
                            , whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
                }
            }
            
        } 
        // We have any dice of more than 4 instances, change dice...
        else if ( introspection[NUM_MORE_THAN_FOUR] == 1 ) {
            [self recordCall:(dice >= introspection[DICE_MORE_THAN_FOUR] ? num + 1 : num) 
                        dice:introspection[DICE_MORE_THAN_FOUR] 
                      isWild:0 
                 playerCount:playerCount];
//            recordCall((dice >= introspection[DICE_MORE_THAN_FOUR] ? num + 1 : num)+extra, introspection[DICE_MORE_THAN_FOUR], 0, playerCount);
            PPDebug(@"<DiceRobotIntelligence> Not Wild & has more than 4 %d, so change dice to %d, call %d X %d",introspection[DICE_MORE_THAN_FOUR], introspection[DICE_MORE_THAN_FOUR], whatToCall[IDX_NUM_OF_DICE] 
                    , whatToCall[IDX_DICE_FACE_VALUE]);
//            PPDebug(@"<DiceRobotIntelligence> Not Wild & has more than 4 "+introspection[DICE_MORE_THAN_FOUR]+
//                        ", so change dice to " + introspection[DICE_MORE_THAN_FOUR]+", call "+ whatToCall[IDX_NUM_OF_DICE] 
//                        + " X " + whatToCall[IDX_DICE_FACE_VALUE]);
        }
        // We have dice of 3 instances...(not ONE, otherwise this branch won't be executed)
        else if ( introspection[NUM_OF_THREE] == 1 ){ //&& distribution[DICE_VALUE_ONE-1] == 2) {
            [self recordCall:num+1 dice:introspection[DICE_OF_THREE] isWild:0 playerCount:playerCount];
//            recordCall(num + 1+extra, introspection[DICE_OF_THREE], 0, playerCount);
            PPDebug(@"<DiceRobotIntelligence> Not Wild &  has 3 %d & 2 ONEs, call %d X %d", introspection[DICE_OF_THREE],
                     whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
//            PPDebug(@"<DiceRobotIntelligence> Not Wild &  has 3 "+introspection[DICE_OF_THREE]+ " & 2 ONEs, call "
//                        + whatToCall[IDX_NUM_OF_DICE]  + " X " + whatToCall[IDX_DICE_FACE_VALUE]);
        }
        // We have dice of 2 intances...
        else if ( introspection[NUM_OF_TWO] == 1) {
            if (introspection[ANOTHER_DICE_OF_TWO] != 0  ) {
                if ( introspection[ANOTHER_DICE_OF_TWO] == DICE_VALUE_ONE || introspection[DICE_OF_TWO] == DICE_VALUE_ONE) {
                    if ( introspection[ANOTHER_DICE_OF_TWO] == DICE_VALUE_ONE ) {
                        [self recordCall:num + (introspection[DICE_OF_TWO]> dice ? 0 : 1) dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                        recordCall(num + (introspection[DICE_OF_TWO]> dice ? 0 : 1)+extra,introspection[DICE_OF_TWO], 0, playerCount);
                    } else {
                        [self recordCall:num + (introspection[ANOTHER_DICE_OF_TWO]> dice ? 0 : 1) dice:introspection[ANOTHER_DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                        recordCall(num + (introspection[ANOTHER_DICE_OF_TWO]> dice ? 0 : 1)+extra,introspection[ANOTHER_DICE_OF_TWO], 0, playerCount);
                    }
                    PPDebug(@"<DiceRobotIntelligence> Not Wild &  has 2 X %d and 2 X 1, call %d X %d", introspection[DICE_OF_TWO], whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
//                    logger.info("<DiceRobotIntelligence> Not Wild & " + (intelligence< IQ_THRESHOLD? "not ":"")+ "smart, has 2 X "+introspection[DICE_OF_TWO]+ " and 2 X 1, call "
//                                + whatToCall[IDX_NUM_OF_DICE]  + " X " + whatToCall[IDX_DICE_FACE_VALUE]);
                    globalRound++;
                    return;
                }
                else if ( introspection[ANOTHER_DICE_OF_TWO] > dice ) {
                    [self recordCall:num dice:introspection[ANOTHER_DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                    recordCall(num+extra, introspection[ANOTHER_DICE_OF_TWO], 0, playerCount);
                }
                else if ( introspection[DICE_OF_TWO] > dice ) {
                    [self recordCall:num dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                    recordCall(num+extra, introspection[DICE_OF_TWO], 0, playerCount);
                }
                else if ( num+1 - distribution[introspection[ANOTHER_DICE_OF_TWO]-1] - distribution[DICE_VALUE_ONE-1] < UNSAFE_DIFFERENCE[playerCount-2] ) {
                    [self recordCall:num+1 dice:introspection[ANOTHER_DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                    recordCall(num+1+extra, introspection[ANOTHER_DICE_OF_TWO], 0, playerCount);
                }
                else if ( num+1 - distribution[introspection[DICE_OF_TWO]-1] - distribution[DICE_VALUE_ONE-1] < UNSAFE_DIFFERENCE[playerCount-2] ) {
                    [self recordCall:num+1 dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                    recordCall(num+1+extra, introspection[DICE_OF_TWO], 0, playerCount);
                }
                else {
                    giveUpCalling = YES;
                    PPDebug(@"<DiceRobotIntelligence> Not Wild & has 2 instances of dice, but not safe to call, give up calling");
                    return;
                }
                PPDebug(@"<DiceRobotIntelligence> Not Wild &  has 2 X %d, call %d X %d", introspection[ANOTHER_DICE_OF_TWO], whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
            } 
            else {
                if ( introspection[DICE_OF_TWO] == DICE_VALUE_ONE ) {
                    for ( int i = 1; i <= 6; i++ ) {
                        if ( distribution[i-1] == 1 && probability[BASE[playerCount-2] + num+1-(introspection[DICE_OF_TWO]+1)] > benchmark[playerCount-2]) {
                            [self recordCall:num+1 dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                            recordCall(num+1+extra, introspection[DICE_OF_TWO], 0, playerCount);
                            PPDebug(@"<DiceRobotIntelligence> Not Wild & has 2 X 1, call %d X %d"
                                        , whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
                            globalRound++;
                            return;
                        }
                    }
                    [self recordCall:num+1 dice:dice isWild:0 playerCount:playerCount];
//                    recordCall(num+1+extra, dice, 0, playerCount);
                    PPDebug(@"<DiceRobotIntelligence> Not Wild & has 2 X 1, call %d X %d"
                                , whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
                }
                else if ( introspection[DICE_OF_TWO] > dice ) {
                    [self recordCall:num dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                    recordCall(num+extra, introspection[DICE_OF_TWO], 0, playerCount);
                }
                else if ( num+1 - distribution[introspection[DICE_OF_TWO]-1] - distribution[DICE_VALUE_ONE-1] < UNSAFE_DIFFERENCE[playerCount-2] ) {
                    [self recordCall:num+1 dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
//                    recordCall(num+1+extra, introspection[DICE_OF_TWO], 0, playerCount);
                }
                else {
                    giveUpCalling = YES;
                    PPDebug(@"<DiceRobotIntelligence> Not Wild & has 2 X %d, but not safe to call, give up calling", introspection[DICE_OF_TWO]);
                    return;
                }
                PPDebug(@"<DiceRobotIntelligence> Not Wild &  has 2 X %d, call %d X %d", introspection[ANOTHER_DICE_OF_TWO],
                            whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
            }
            
        }
        // We have our dices distributed uniformly,do a safe call.
        else {
            [self recordCall:num+1 dice:dice isWild:0 playerCount:playerCount];
//            recordCall(num + 1 + extra, dice, 0, playerCount);
            PPDebug(@"<DiceRobotIntelligence> Not Wild & ,dices distributed uniformly, just do a safe call , call %d X %d"
                        ,whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
        }
    } // end of not Wild
    
    globalRound++;
}

// Record what robot wants to call
- (void)recordCall:(int)num 
              dice:(int)dice 
            isWild:(int)isWild 
       playerCount:(int)playerCount {
    
    // We should avoid call the same as last round
    // (eg: robot calls 3x4, player calls 3x1, robot may call 3x4 again, which is not permitted)
    // Just add the quantity by one
    if ( lastRoundCall[IDX_NUM_OF_DICE] == num && lastRoundCall[IDX_DICE_FACE_VALUE] == dice  ) {
        num++;
    }
    
    whatToCall[IDX_NUM_OF_DICE] = lastRoundCall[IDX_NUM_OF_DICE] = num;
    whatToCall[IDX_DICE_FACE_VALUE] = lastRoundCall[IDX_DICE_FACE_VALUE] = dice;
    // If callNum is the same as playerCount , auto wild,
    // If dice is ONE,no doubt it is  wild.  
    if ( whatToCall[IDX_NUM_OF_DICE] == playerCount || whatToCall[IDX_DICE_FACE_VALUE] == DICE_VALUE_ONE) {
        whatToCall[IDX_CALL_WILD] = lastRoundCall[IDX_CALL_WILD] = 1;
    } else {
        whatToCall[IDX_CALL_WILD] = lastRoundCall[IDX_CALL_WILD] = isWild;
    }
    //		if ( whatToCall[IDX_CALL_WILD] == 1 && hasSendCallWilds == false && RandomUtils.nextInt(2) == 1) {
    //			logger.info("*****Robot call wilds! Set chat content*****");
    //			setChatContent(TEXT,chatContent.getContent(DiceRobotChatContent.VoiceContent.CALL_WILDS));
    //			hasSendCallWilds = true;
    //		} else if ( RandomUtils.nextInt(4) == 1 && safe == true ) {
    //			setChatContent(TEXT,chatContent.getContent(DiceRobotChatNot Wild &  smartContent.VoiceContent.BITE_ME));
    //		}
//    if ( RandomUtils.nextInt(3) == 1 ) {
//        if ( safe == true ) {
//            setChatContent(EXPRESSION, chatContent.getExpression(DiceRobotChatContent.Expression.PROUND));
//        } 
//        else if ( RandomUtils.nextInt(2) == 0 ) {
//            setChatContent(EXPRESSION, chatContent.getExpression(DiceRobotChatContent.Expression.SMILE));
//        }
//        else {
//            setChatContent(EXPRESSION, chatContent.getExpression(DiceRobotChatContent.Expression.EMBARRASS));
//        }
//    }
}

// Robot initiates the call.
- (void)initialCall:(int)playerCount {
    
    int tmp = (rand()%5 == 0? 0 : 1);
    
//    if ( intelligence < IQ_THRESHOLD) {
//        recordCall( playerCount + tmp, 1+RandomUtils.nextInt(6), 0, playerCount );
//        safe = false;
//        logger.info("<intialCall> Initially, not smart, just do a random call , call "
//					+ whatToCall[IDX_NUM_OF_DICE]  + " X " + whatToCall[IDX_DICE_FACE_VALUE] );
//        if ( distribution[whatToCall[IDX_DICE_FACE_VALUE]-1] == 0 ) {
//            lying  = true;
//            lieDice  = whatToCall[IDX_DICE_FACE_VALUE];
//        }
//    }
    // Smart...
//    else {
        // Does robot have more than 3 ONEs?
        if ( distribution[DICE_VALUE_ONE-1] >= 3 ){
            if ( rand()%2 == 1 ) {
                [self recordCall:playerCount dice:DICE_VALUE_ONE isWild:1 playerCount:playerCount];
//                recordCall(distribution[DICE_VALUE_ONE-1], DICE_VALUE_ONE, 1, playerCount);
                safe = NO;
            } else {
                [self recordCall:playerCount+tmp dice:rand()%5+2 isWild:0 playerCount:playerCount];
//                recordCall(distribution[DICE_VALUE_ONE-1], rand()%5+2, 0, playerCount);
                safe = false;
            } 
            PPDebug(@"<intialCall> Initially,smart, has more than 3 ONEs,just call ONE or do a random call , call %d X %d"
						, whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE] );
        }
        else if ( introspection[NUM_MORE_THAN_FOUR] == 1 ) {
            [self recordCall:playerCount+tmp dice:introspection[DICE_MORE_THAN_FOUR] isWild:0 playerCount:playerCount];
//            recordCall(distribution[introspection[DICE_MORE_THAN_FOUR]-1], introspection[DICE_MORE_THAN_FOUR], 0, playerCount);
            PPDebug(@"<intialCall> Initial call,has more than 4 %d, so call %d X %d", introspection[DICE_MORE_THAN_FOUR], whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
        }
        else if ( introspection[NUM_OF_THREE] == 1) {
            [self recordCall:playerCount+tmp dice:introspection[DICE_OF_THREE] isWild:rand()%2 playerCount:playerCount];
//            recordCall(3, introspection[DICE_OF_THREE], RandomUtils.nextInt(2), playerCount);
            PPDebug(@"<intialCall> Initial call,has 3 %d, so call %d X %d",introspection[DICE_OF_THREE], whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
        }
        else if ( introspection[NUM_OF_TWO] == 1 ){
            if ( introspection[ANOTHER_DICE_OF_TWO] != 0 ) {
                int quantity = 2 + (introspection[ANOTHER_DICE_OF_TWO] != DICE_VALUE_ONE ? distribution[DICE_VALUE_ONE-1] : 0); 
//                recordCall( (quantity >= playerCount ? quantity : playerCount+1), 
//                           introspection[ANOTHER_DICE_OF_TWO], 0, playerCount);
                [self recordCall:(quantity >= playerCount ? quantity : playerCount+1) dice:introspection[ANOTHER_DICE_OF_TWO] isWild:0 playerCount:playerCount];
            }
            else {
                int quantity = 2 + (introspection[DICE_OF_TWO] != DICE_VALUE_ONE ? distribution[DICE_VALUE_ONE-1] : 0);
//                recordCall((quantity >= playerCount ? quantity : playerCount+1) ,
//                           introspection[DICE_OF_TWO], 0, playerCount);
                [self recordCall:(quantity >= playerCount ? quantity : playerCount+1) dice:introspection[DICE_OF_TWO] isWild:0 playerCount:playerCount];
            }
            PPDebug(@"<intialCall> Initial call,has dice of 2 instances, so call %d X %d"
						, whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
        }
        else {
            [self recordCall:playerCount + tmp dice:2+rand()%5 isWild:(rand()%10 == 1? 1 : 0) playerCount:playerCount];
//            recordCall(playerCount + tmp, 2 + RandomUtils.nextInt(5), (RandomUtils.nextInt(10) == 1? 1 : 0), playerCount);
            safe = NO;
            PPDebug(@"<intialCall> Initially, smart,dices distributed uniformly,  do a random call , call %d X %d"
						,whatToCall[IDX_NUM_OF_DICE], whatToCall[IDX_DICE_FACE_VALUE]);
            if ( distribution[whatToCall[IDX_DICE_FACE_VALUE]-1] == 0 ) {
                lying  = YES;
                lieDice  = whatToCall[IDX_DICE_FACE_VALUE];
            }
        }
//    }
    globalRound++;
    
    [self updateResult];
}

- (BOOL)giveUpCall {
    return giveUpCalling;
}

//-(int[])getWhatTocall{
//    
//    int result[3] = {0, 0, 0};
//    
//    result[IDX_NUM_OF_DICE] = whatToCall[IDX_NUM_OF_DICE];
//    result[IDX_DICE_FACE_VALUE] = whatToCall[IDX_DICE_FACE_VALUE];
//    result[IDX_CALL_WILD] = whatToCall[IDX_CALL_WILD];
//    
//    return result;
//}

- (void)updateResult
{
    self.result.dice = whatToCall[IDX_DICE_FACE_VALUE];
    self.result.diceCount = whatToCall[IDX_NUM_OF_DICE];
    self.result.isWild = (whatToCall[IDX_CALL_WILD] == 1);
}


- (void)introspectRobotDices:(int[])robotDices {
    
    PPDebug(@"robot's Dices are: %d-%d-%d-%d-%d", robotDices[0], robotDices[1], robotDices[2], robotDices[3], robotDices[4]);
    
    for ( int i= 0; i < 5;i++ ) {
        switch (robotDices[i]) {
            case 1:
                distribution[DICE_VALUE_ONE-1]++;
                break;
            case 2:
                distribution[DICE_VALUE_TWO-1]++;
                break;
            case 3:
                distribution[DICE_VALUE_THREE-1]++;
                break;
            case 4:
                distribution[DICE_VALUE_FOUR-1]++;
                break;
            case 5:
                distribution[DICE_VALUE_FIVE-1]++;
                break;
            case 6:
                distribution[DICE_VALUE_SIX-1]++;
                break;
            default:
                break;
        }
        
    }
    for (int i = 0;i < 6; i++) {
        if ( distribution[i] >= 4 ) {
            introspection[NUM_MORE_THAN_FOUR] = 1;
            introspection[DICE_MORE_THAN_FOUR] = i+1;
        } 
        else if ( distribution[i] == 3 ) {
            introspection[NUM_OF_THREE] = 1;
            introspection[DICE_OF_THREE] = i+1;
        }
        else if ( distribution[i] == 2 ) {
            introspection[NUM_OF_TWO] = 1;
            if ( introspection[DICE_OF_TWO] == 0 ) {
                introspection[DICE_OF_TWO] = i+1;
            }
            else {
                introspection[ANOTHER_DICE_OF_TWO] = i+1;
            }
        }
        
    }// end of for
    
    if ( introspection[NUM_MORE_THAN_FOUR] == 0 && introspection[NUM_OF_THREE] == 0 && introspection[NUM_OF_TWO] == 0) {
        introspection[DISTRIBUTE_UNIFORMLY] = 1;
    }
}

- (void)updateDecitionByPlayerCount:(int)playerCount 
                             userId:(NSString*)userId 
                             number:(int)num 
                               dice:(int)dice 
                             isWild:(BOOL)isWild 
                         myDiceList:(int[])myDiceList
{
    [self.result reset];
    if ([self canOpenDice:playerCount userId:userId number:num dice:dice isWild:isWild]) {
        self.result.shouldOpen = YES;
    } else {
        [self decideWhatToCall:playerCount number:num dice:dice isWild:isWild myDice:myDiceList];
        if (giveUpCalling) {
            self.result.shouldOpen = YES;
        } else {
            self.result.shouldOpen = NO;
            [self updateResult];
        }
    }
}

//public boolean hasSetChat() {
//    return setChat;
//}
//
//public void resetHasSetChat() {
//    this.setChat = false;
//}
//
//public String[] getChatContent(){
//    String[] result = {null,null, null};
//    
//    result[IDX_CONTENT] = whatToChat[IDX_CONTENT];
//    result[IDX_CONTENTID] = whatToChat[IDX_CONTENTID];
//    result[IDX_CONTNET_TYPE]= whatToChat[IDX_CONTNET_TYPE];
//    
//    return result;
//}
//
//private void setChatContent(int contentType,String[] content) {
//    
//    this.setChat = true;
//    
//    whatToChat[IDX_CONTENT] = content[IDX_CONTENT];
//    whatToChat[IDX_CONTENTID] = content[IDX_CONTENTID];
//    whatToChat[IDX_CONTNET_TYPE] = Integer.toString(contentType);
//}
//
//}

@end
