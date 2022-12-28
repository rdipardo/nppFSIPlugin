unit Constants;

// =============================================================================
// Unit: Constants
// Description: Defines constants and resource strings.
//
// Copyright 2010 Prapin Peethambaran
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================

interface

const

  FSI_PLUGIN_NAME = 'F# Interactive';
  FSI_PLUGIN_WND_TITLE = 'FSI';
  FSI_PLUGIN_LOAD_MENU = 'Load FSI';
  FSI_PLUGIN_SEND_TEXT_MENU = 'Send Text';
  FSI_PLUGIN_CONFIG_MENU = 'Options';
  FSI_PLUGIN_ABOUT_MENU = 'About';
  FSI_PLUGIN_EDITOR_CLEAR_MENU = 'Clear';
  FSI_PLUGIN_EDITOR_COPY_MENU = 'Copy';
  FSI_PLUGIN_EDITOR_CANCELEVAL_MENU = 'Cancel Evaluation';
  FSI_PLUGIN_START_FAILE_MSG = 'Failed to start FSI. Please make sure F# is installed and the' +
                               ' FSI binary path configuration is set properly';

const

  /// <summary>
  /// Name of dll containing the plugin
  /// </summary>
  FSI_PLUGIN_MODULE_FILENAME = 'NPPFSIPlugin.dll';

  /// <summary>
  /// Name of file that stores configuration information
  /// </summary>
  FSI_PLUGIN_CONFIG_FILE_NAME = 'NPPFSIPlugin.ini';

  /// <summary>
  /// Default number of spaces used when converting tabs to spaces.
  /// </summary>
  DEFAULT_TAB_LENGTH = 4;

  /// <summary>
  /// Name!
  /// </summary>
  FSI_PLUGIN_AUTHOR = 'Prapin Peethambaran';

  /// <summary>
  /// App url
  /// </summary>
  FSI_PLUGIN_URL = 'http://github.com/ppv/NPPFSIPlugin';

  // config file related
  CONFIG_FSI_SECTION_NAME = 'FSI';
  CONFIG_FSI_SECTION_USE_DOTNET_FSI = 'USE_DOTNET_FSI';
  CONFIG_FSI_SECTION_BINARY_KEY_NAME = 'BINARY';
  CONFIG_FSI_SECTION_BINARYARGS_KEY_NAME = 'BINARY_ARGS';
  CONFIG_FSIEDITOR_SECTION_NAME = 'FSI_EDITOR';
  CONFIG_FSIEDITOR_SECTION_TABTOSPACES_KEY_NAME = 'CONVERT_TABS_TO_SPACES';
  CONFIG_FSIEDITOR_SECTION_TABLENGTH_KEY_NAME = 'TAB_LENGTH';
  CONFIG_FSIEDITOR_ECHO_NPP_TEXT_KEY_NAME = 'ECHO_NPP_TEXT';

  // lexer keyword lists
  FSHARP_KEYWORDS_1 = '"' +
  'abstract and as assert async atomic base begin break checked class component const ' +
  'constraint constructor continue default delegate do done downcast downto eager elif ' +
  'else end event exception extern external false finally fixed for fun function functor ' +
  'global if in include inherit inline interface internal lazy let match member method ' +
  'mixin module mutable namespace new null object of open or override parallel private ' +
  'process protected public pure rec return sealed select static struct tailcall task ' +
  'then to trait true try type upcast use val virtual volatile void when while with yield"';

  FSHARP_KEYWORDS_2= '"' +
  'abs acos add allPairs append asin atan atan2 average averageBy base1 base2 blit bprintf cache ' +
  'cast ceil choose chunkBySize collect compareWith concat contains containsKey copy cos cosh ' +
  'count countBy create createBased delay difference distinct distinctBy empty eprintf eprintfn ' +
  'except exists exists2 exactlyOne failwith failwithf fill filter find findBack findIndex ' +
  'findIndexBack findKey floor fold fold2 foldBack foldBack2 forall forall2 fprintf fprintfn fst ' +
  'get groupBy head ignore indexed init initBased initInfinite insertAt insertManyAt intersect ' +
  'intersectMany invalidArg isEmpty isProperSubset isProperSuperset isSubset isSuperset item iter ' +
  'iter2 iteri iteri2 kbprintf kfprintf kprintf ksprintf last length length1 length2 length3 length4 ' +
  'map map2 map3 mapFold mapFoldBack mapi mapi2 max maxBy maxElement min minBy minElement nameof not ' +
  'ofArray ofList ofSeq pairwise partition permute pick pown printf printfn raise readonly rebase ' +
  'reduce reduceBack remove removeAt removeManyAt replicate rev round scan scanBack seq set sin ' +
  'singleton sinh skip skipWhile snd sort sortBy sortByDescending sortDescending sortInPlace ' +
  'sortInPlaceBy sortInPlaceWith sortWith splitAt splitInto sprintf sqrt sub sum sumBy tail take ' +
  'takeWhile tan tanh toArray toList toSeq transpose truncate tryExactlyOne tryFind tryFindBack ' +
  'tryFindIndex tryFindIndexBack tryHead tryItem tryFindKey tryLast tryPick typeof unfold union ' +
  'unionMany unzip unzip3 updateAt where windowed zeroCreate zeroCreateBased zip zip3"';

  FSHARP_KEYWORDS_3= '"' +
  'array bigint bool byte byref char comparison decimal double enum equality exn float float32 ' +
  'inref int int8 int16 int32 int64 list nativeint nativeptr None obj Ok option Option outref ref ' +
  'Result sbyte Some single string unmanaged unativeint uint uint8 uint16 uint32 uint64 unit void ' +
  'voidptr voption"';

  FSHARP_KEYWORDS_4='"' +
  'ArgumentException Array Array2D Array3D Array4D BigInteger Boolean Byte Char Collections Console ' +
  'Core CultureInfo DateTime Decimal Diagnostics Double Environment Error Exception Expr Float FSharp ' +
  'Globalization Int16 Int32 Int64 IntPtr IO Linq List Map Math Microsoft NumberStyles Object Path ' +
  'Parallel Patterns Printf Quotations Random Regex ResizeArray SByte Seq Set Single String System ' +
  'UInt16 UInt32 UInt64 UIntPtr"';

implementation

end.
