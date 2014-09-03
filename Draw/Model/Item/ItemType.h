

//#define ITEM_TYPE_TIPS      1
//#define ITEM_TYPE_TOMATO    2
//#define ITEM_TYPE_FLOWER    3
//#define ITEM_TYPE_REMOVE_AD 10
//#define ITEM_TYPE_COLORS    100     // star from 100


typedef enum
{
    ItemTypeListEndFlag = -1000,
    
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
    PolygonPen,
    PenCount,
    ItemTypeCopyPaint,

    ItemTypeShadow,
    ItemTypeGradient,
    ItemTypeSelector,

    ItemTypeText,
    ItemTypeFX,
    
    
    DeprecatedEraser = 1100,
    PaletteItem = 1101,
    ColorAlphaItem = 1102,
    PaintPlayerItem = 1103,
    ColorStrawItem = 1104,
    Eraser = 1105, //the new EraserType, from version 7.0 of Draw
    
    ItemTypeGrid = 1106,
    
    ItemTypePurse = 1105,
    ItemTypePurseOneThousand = 1107,
    
    ItemTypeFunPen1 = 1151,
    ItemTypeFunPen2 = 1152,
    ItemTypeFunPen3 = 1153,
    ItemTypeFunPen4 = 1154,
    ItemTypeFunPen5 = 1155,
    
    ItemTypeBrushBegin = 1160,
    ItemTypeBrushGouache = 1161,
    ItemTypeBrushOil = 1162,
    ItemTypeBrushCrayon = 1163,
    ItemTypeBrushPen = 1164,
    ItemTypeBrushBlur = 1165,
    ItemTypeBrushWater = 1166,
    ItemTypeBrushEnd = 1199,
    
    
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
   //Add 2013-6-17 By Gamy 
    DrawBackground10,
    DrawBackground11,                
    DrawBackground12,
    DrawBackground13,
    DrawBackground14,
    DrawBackground15,
    DrawBackground16,
    DrawBackground17,
    ///////////////
    BasicShape = 1300,
    
    
    //add by Gamy 2013-6-7
    
    ImageShapeBasic0 = 1300,
    
    ImageShapeNature0 = 1310,
    ImageShapeNature1 = 1311,

    ImageShapeAnimal0 = 1320,
    ImageShapeAnimal1 = 1321,
    
    ImageShapeShape0 = 1330,
    ImageShapeShape1 = 1331,

    ImageShapeStuff0 = 1340,
    ImageShapeStuff1 = 1341,

    ImageShapeSign0 = 1350,
    ImageShapeSign1 = 1351,
    
    ImageShapePlant0 = 1360,
    ImageShapePlant1 = 1361,
    ImageShapePlant2 = 1362,
        
    
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

    //new rect for version 7.8
    CanvasRectContestBillboard,          // 700 * 268
    CanvasRectAndroidHorizontal,         // 480 * 800
    CanvasRectAndroidVertical,          // 800 * 480
    
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
    ItemTypeCustomDiceDefaultDice = 2500,
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


