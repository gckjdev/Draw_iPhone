

//#define ITEM_TYPE_TIPS      1
//#define ITEM_TYPE_TOMATO    2
//#define ITEM_TYPE_FLOWER    3
//#define ITEM_TYPE_REMOVE_AD 10
//#define ITEM_TYPE_COLORS    100     // star from 100


typedef enum
{
    ItemTypeTaoBao = -1,
    ItemTypeNo = 0,
    
    ItemTypeTips = 1,
    ItemTypeFlower = 6,
    ItemTypeTomato = 7,
    ItemTypeRemoveAd = 10,
    
    ItemTypeColor = 100, // star from 100

    //pen type
    Pencil = 1000,
    WaterPen,
    Pen,
    IcePen,
    Quill,
    DottedLinePen,
    SmoothPen,
    PenCount,
    
    Eraser = 1100,
    PaletteItem = 1101,
    ColorAlphaItem = 1102,
    PaintPlayerItem = 1103,
    ColorStrawItem = 1104,
    
    ItemTypeGrid = 1106,
    
    ItemTypePurse = 1105,            
    
    DrawBackgroundStart = 1200,
    DrawBackground1,                
    DrawBackground2,
    DrawBackground3,
    DrawBackground4,
    DrawBackground5,
    DrawBackground6,
    DrawBackground7,
    DrawBackground8,
    DrawBackground9,
    
    ///////////////
    BasicShape = 1300,
    
    CanvasRectStart = 1400,         
    CanvasRectiPhoneDefault,            // 300 * 300
    CanvasRectiPadDefault,              // 700 * 700
    CanvasRectiPadHorizontal,           // 700 * 432
    CanvasRectiPadVertical,             // 432 * 700
    CanvasRectiPadLarge,                // 1024 * 1024
    CanvasRectiPadScreenHorizontal,     // 1024 * 768
    CanvasRectiPadScreenVertical,       // 768 * 1024
    CanvasRectiPhone5Horizontal,        // 1136 * 640
    CanvasRectiPhone5Vertical,          // 640 * 1136
    
    //Liar dice.
    ItemTypeRollAgain = 2001,
    ItemTypeCut = 2002,
    ItemTypePeek = 2003,
    ItemTypeReverse = 2004,
    ItemTypeIncTime = 2005,
    ItemTypeDecTime = 2006,
    ItemTypeDiceRobot = 2007,
    ItemTypeSkip = 2008,
    ItemTypeDoubleKill = 2009,
    ItemTypeDiceFlower = 2010,
    ItemTypeDiceTomato = 2011,
    
    //custom dice start here
    ItemTypeCustomDiceStart = 2500,
    ItemTypeCustomDicePatriotDice = 2501,
    ItemTypeCustomDiceGoldenDice = 2502,
    ItemTypeCustomDiceWoodDice = 2503,
    ItemTypeCustomDiceBlueCrystalDice = 2504,
    ItemTypeCustomDicePinkCrystalDice = 2505,
    ItemTypeCustomDiceGreenCrystalDice = 2506,
    ItemTypeCustomDicePurpleCrystalDice = 2507,
    ItemTypeCustomDiceBlueDiamondDice = 2508,
    ItemTypeCustomDicePinkDiamondDice = 2509,
    ItemTypeCustomDiceGreenDiamondDice = 2510,
    ItemTypeCustomDicePurpleDiamondDice = 2511,
    ItemTypeCustomDiceEnd = 2512
}ItemType;


