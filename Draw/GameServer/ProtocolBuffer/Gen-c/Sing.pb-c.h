/* Generated by the protocol buffer compiler.  DO NOT EDIT! */
/* Generated from: Sing.proto */

#ifndef PROTOBUF_C_Sing_2eproto__INCLUDED
#define PROTOBUF_C_Sing_2eproto__INCLUDED

#include <protobuf-c/protobuf-c.h>

PROTOBUF_C__BEGIN_DECLS

#if PROTOBUF_C_VERSION_NUMBER < 1000000
# error This file was generated by a newer version of protoc-c which is incompatible with your libprotobuf-c headers. Please update your headers.
#elif 1001000 < PROTOBUF_C_MIN_COMPILER_VERSION
# error This file was generated by an older version of protoc-c which is incompatible with your libprotobuf-c headers. Please regenerate this file with a newer version of protoc-c.
#endif


typedef struct _Game__PBSongCategory Game__PBSongCategory;
typedef struct _Game__PBSongCategoryList Game__PBSongCategoryList;
typedef struct _Game__PBSong Game__PBSong;
typedef struct _Game__PBSongList Game__PBSongList;
typedef struct _Game__PBSingOpus Game__PBSingOpus;


/* --- enums --- */

typedef enum _Game__PBVoiceType {
  GAME__PBVOICE_TYPE__VoiceTypeOrigin = 0,
  GAME__PBVOICE_TYPE__VoiceTypeTomCat = 1,
  GAME__PBVOICE_TYPE__VoiceTypeMale = 2,
  GAME__PBVOICE_TYPE__VoiceTypeFemale = 3,
  GAME__PBVOICE_TYPE__VoiceTypeDuck = 4,
  GAME__PBVOICE_TYPE__VoiceTypeChild = 5
    PROTOBUF_C__FORCE_ENUM_TO_BE_INT_SIZE(GAME__PBVOICE_TYPE)
} Game__PBVoiceType;

/* --- messages --- */

struct  _Game__PBSongCategory
{
  ProtobufCMessage base;
  char *name;
  size_t n_songtags;
  char **songtags;
};
#define GAME__PBSONG_CATEGORY__INIT \
 { PROTOBUF_C_MESSAGE_INIT (&game__pbsong_category__descriptor) \
    , NULL, 0,NULL }


struct  _Game__PBSongCategoryList
{
  ProtobufCMessage base;
  size_t n_categorys;
  Game__PBSongCategory **categorys;
};
#define GAME__PBSONG_CATEGORY_LIST__INIT \
 { PROTOBUF_C_MESSAGE_INIT (&game__pbsong_category_list__descriptor) \
    , 0,NULL }


struct  _Game__PBSong
{
  ProtobufCMessage base;
  /*
   * 歌曲Id
   */
  char *songid;
  /*
   * 歌曲名称
   */
  char *name;
  /*
   * 作者
   */
  char *author;
  /*
   * 歌词
   */
  char *lyric;
  /*
   * 歌词的URL
   */
  char *lyricurl;
  /*
   * 标签，用于分类
   */
  size_t n_tag;
  char **tag;
};
#define GAME__PBSONG__INIT \
 { PROTOBUF_C_MESSAGE_INIT (&game__pbsong__descriptor) \
    , NULL, NULL, NULL, NULL, NULL, 0,NULL }


struct  _Game__PBSongList
{
  ProtobufCMessage base;
  size_t n_songs;
  Game__PBSong **songs;
};
#define GAME__PBSONG_LIST__INIT \
 { PROTOBUF_C_MESSAGE_INIT (&game__pbsong_list__descriptor) \
    , 0,NULL }


struct  _Game__PBSingOpus
{
  ProtobufCMessage base;
  Game__PBSong *song;
  /*
   * 声音变声器参数控制
   */
  protobuf_c_boolean has_voicetype;
  Game__PBVoiceType voicetype;
  protobuf_c_boolean has_duration;
  float duration;
  protobuf_c_boolean has_pitch;
  float pitch;
  protobuf_c_boolean has_formant;
  float formant;
  /*
   * 声音数据长度
   */
  protobuf_c_boolean has_voiceduration;
  float voiceduration;
  /*
   * 本地数据
   */
  /*
   * 本地原声数据（未做处理）
   */
  char *localnativedataurl;
};
#define GAME__PBSING_OPUS__INIT \
 { PROTOBUF_C_MESSAGE_INIT (&game__pbsing_opus__descriptor) \
    , NULL, 0,0, 0,1, 0,1, 0,1, 0,0, NULL }


/* Game__PBSongCategory methods */
void   game__pbsong_category__init
                     (Game__PBSongCategory         *message);
size_t game__pbsong_category__get_packed_size
                     (const Game__PBSongCategory   *message);
size_t game__pbsong_category__pack
                     (const Game__PBSongCategory   *message,
                      uint8_t             *out);
size_t game__pbsong_category__pack_to_buffer
                     (const Game__PBSongCategory   *message,
                      ProtobufCBuffer     *buffer);
Game__PBSongCategory *
       game__pbsong_category__unpack
                     (ProtobufCAllocator  *allocator,
                      size_t               len,
                      const uint8_t       *data);
void   game__pbsong_category__free_unpacked
                     (Game__PBSongCategory *message,
                      ProtobufCAllocator *allocator);
/* Game__PBSongCategoryList methods */
void   game__pbsong_category_list__init
                     (Game__PBSongCategoryList         *message);
size_t game__pbsong_category_list__get_packed_size
                     (const Game__PBSongCategoryList   *message);
size_t game__pbsong_category_list__pack
                     (const Game__PBSongCategoryList   *message,
                      uint8_t             *out);
size_t game__pbsong_category_list__pack_to_buffer
                     (const Game__PBSongCategoryList   *message,
                      ProtobufCBuffer     *buffer);
Game__PBSongCategoryList *
       game__pbsong_category_list__unpack
                     (ProtobufCAllocator  *allocator,
                      size_t               len,
                      const uint8_t       *data);
void   game__pbsong_category_list__free_unpacked
                     (Game__PBSongCategoryList *message,
                      ProtobufCAllocator *allocator);
/* Game__PBSong methods */
void   game__pbsong__init
                     (Game__PBSong         *message);
size_t game__pbsong__get_packed_size
                     (const Game__PBSong   *message);
size_t game__pbsong__pack
                     (const Game__PBSong   *message,
                      uint8_t             *out);
size_t game__pbsong__pack_to_buffer
                     (const Game__PBSong   *message,
                      ProtobufCBuffer     *buffer);
Game__PBSong *
       game__pbsong__unpack
                     (ProtobufCAllocator  *allocator,
                      size_t               len,
                      const uint8_t       *data);
void   game__pbsong__free_unpacked
                     (Game__PBSong *message,
                      ProtobufCAllocator *allocator);
/* Game__PBSongList methods */
void   game__pbsong_list__init
                     (Game__PBSongList         *message);
size_t game__pbsong_list__get_packed_size
                     (const Game__PBSongList   *message);
size_t game__pbsong_list__pack
                     (const Game__PBSongList   *message,
                      uint8_t             *out);
size_t game__pbsong_list__pack_to_buffer
                     (const Game__PBSongList   *message,
                      ProtobufCBuffer     *buffer);
Game__PBSongList *
       game__pbsong_list__unpack
                     (ProtobufCAllocator  *allocator,
                      size_t               len,
                      const uint8_t       *data);
void   game__pbsong_list__free_unpacked
                     (Game__PBSongList *message,
                      ProtobufCAllocator *allocator);
/* Game__PBSingOpus methods */
void   game__pbsing_opus__init
                     (Game__PBSingOpus         *message);
size_t game__pbsing_opus__get_packed_size
                     (const Game__PBSingOpus   *message);
size_t game__pbsing_opus__pack
                     (const Game__PBSingOpus   *message,
                      uint8_t             *out);
size_t game__pbsing_opus__pack_to_buffer
                     (const Game__PBSingOpus   *message,
                      ProtobufCBuffer     *buffer);
Game__PBSingOpus *
       game__pbsing_opus__unpack
                     (ProtobufCAllocator  *allocator,
                      size_t               len,
                      const uint8_t       *data);
void   game__pbsing_opus__free_unpacked
                     (Game__PBSingOpus *message,
                      ProtobufCAllocator *allocator);
/* --- per-message closures --- */

typedef void (*Game__PBSongCategory_Closure)
                 (const Game__PBSongCategory *message,
                  void *closure_data);
typedef void (*Game__PBSongCategoryList_Closure)
                 (const Game__PBSongCategoryList *message,
                  void *closure_data);
typedef void (*Game__PBSong_Closure)
                 (const Game__PBSong *message,
                  void *closure_data);
typedef void (*Game__PBSongList_Closure)
                 (const Game__PBSongList *message,
                  void *closure_data);
typedef void (*Game__PBSingOpus_Closure)
                 (const Game__PBSingOpus *message,
                  void *closure_data);

/* --- services --- */


/* --- descriptors --- */

extern const ProtobufCEnumDescriptor    game__pbvoice_type__descriptor;
extern const ProtobufCMessageDescriptor game__pbsong_category__descriptor;
extern const ProtobufCMessageDescriptor game__pbsong_category_list__descriptor;
extern const ProtobufCMessageDescriptor game__pbsong__descriptor;
extern const ProtobufCMessageDescriptor game__pbsong_list__descriptor;
extern const ProtobufCMessageDescriptor game__pbsing_opus__descriptor;

PROTOBUF_C__END_DECLS


#endif  /* PROTOBUF_C_Sing_2eproto__INCLUDED */
