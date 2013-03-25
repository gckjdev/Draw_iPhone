

//#define ITEM_TYPE_TIPS      1
//#define ITEM_TYPE_TOMATO    2
//#define ITEM_TYPE_FLOWER    3
//#define ITEM_TYPE_REMOVE_AD 10
//#define ITEM_TYPE_COLORS    100     // star from 100


typedef enum
{
    
    ItemTypeNo = 0;
    
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
    PurseItem = 1105,               //钱袋

    
    TransverseCanvas = 1150,        //横版画布
    VerticalCanvas = 1151,          //竖版画布
    SquareCanvasLarge = 1152,       //正方形画布(大)
    TransverseCanvasLarge = 1153,   //横版画布(大)
    VerticalCanvasLarge = 1154,     //竖版画布(大)
    
    VeinsBackground = 1200,         //纹理背景
    
    BasicShape = 1300,              //基本形状
    
    //Liar dice.
//    ItemTypeChangeDice = 2000,
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
