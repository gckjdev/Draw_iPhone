

//#define ITEM_TYPE_TIPS      1
//#define ITEM_TYPE_TOMATO    2
//#define ITEM_TYPE_FLOWER    3
//#define ITEM_TYPE_REMOVE_AD 10
//#define ITEM_TYPE_COLORS    100     // star from 100


typedef enum
{
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
    PenCount,
    
    Eraser = 1100,
    
    //Liar dice.
//    ItemTypeChangeDice = 2000,
    ItemTypeRollAgain = 2001,
    ItemTypeCut = 2002

    
}ItemType;
