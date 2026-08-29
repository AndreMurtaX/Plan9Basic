{******************************************************************************
  Plan9Basic Interpreter Engine

  MIT License
  Copyright (c) 2024-2026 André Murta

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
******************************************************************************}
unit exec;

interface

uses
  System.Classes, System.SysUtils, System.Character, System.Generics.Collections,
  System.TypInfo, System.Math, System.Diagnostics, System.UITypes, System.SyncObjs,

  UnitUtils, lexer, UnitGC;

const
  // Stack and memory limits
  MAXSTACK = 16384;   // Maximum stack items (both main and auxiliary)
  MAXLOCALS = 259;    // (256 args && locals) + 3 local registers (@3 @4 @5)
  MAXVARS = 515;      // 512 global vars + 3 generic registers (@0 @1 @2)
  INITASMSIZE = 1000; // Asm program initial allocation size

  // Default execution timeout in seconds (0 = no timeout)
  DEFAULT_TIMEOUT = 30;

  // Numeric limits for integer type
  MAX_INTEGER_VALUE = 2147483647.0;  // Values above this become float

  // UI refresh throttling for PRINT statements (in milliseconds)
  // Lower = more responsive but slower execution
  // Higher = faster execution but less responsive UI
  // 0 = refresh on every PRINT (original behavior)
  DEFAULT_UI_REFRESH_INTERVAL = 50;
  //How wide and how deep the reusable argument buffers are. Neither is a limit
  //on the language: a call that does not fit takes the allocating path it
  //always took. A function taking more than sixty-four arguments must keep
  //working, not start erroring, which is the difference between an
  //optimisation and a compatibility break.
  ARGBUF_WIDTH = 64;  //arguments in one call
  ARGBUF_DEPTH = 16;  //native calls in flight at once


type
  //Assembly tokens
  TAsmToken = (
    {A}
    atkAdd, atkAddCRLFS, atkAddS, atkAnd, atkAppendS, atkAssert,
    {B}
    atkBreak, atkBreakpoint, atkCRLF, atkCallFar, atkCallFarP, atkCallFarS, atkCallNear,
    atkCls, atkComma, atkComment, atkContinue,
    {C}
    atkCaseEnd, atkCaseElse, atkCaseStart,
    {D}
    atkData, atkDataS, atkDiv, atkDoStart, atkDoUntil, atkDoWhile, atkDump,
    {E}
    atkElse, atkElseIfBody, atkElseIfTest, atkEnd, atkEndFunction, atkEndIf,
    atkEndWhile, atkEq, atkEqs, atkErr, atkExit,
    {F}
    atkFloat, {atkFnAddress,} atkForCycle, atkFunction,
    {G}
    atkGe, atkGeS, atkGt, atkGtS,
    {H}
    {I}
    atkIdentifier, atkIf, atkIndirectCall, atkInitFunc, atkInput, atkInputS,
    atkInteger, atkInv,
    {J}
    atkJsonObj, atkJump,
    {K}
    {L}
    atkLabel, atkLe, atkLeS, atkLoopEnd, atkLoopUntil, atkLoopWhile, atkLt, atkLtS,
    {M}
    atkMax, atkMin, atkMod, atkMul,
    {N}
    atkNe, atkNeS, atkNext, atkNone, atkNop, atkNot, atkNull,
    {O}
    atkOnCallFar, atkOnCallFarP, atkOnCallFarS, atkOnGoto, atkOnGosub, atkOr,
    {P}
    atkPause, atkPointerFunction, atkPointerIdentifier, atkPop, atkPopAux,
    atkPopStore, atkPopStorePtr, atkPopStoreS, atkPopnCall, atkPopnJump, atkPopnJump_CRLF,
    atkPopnJump_EndIf, atkPow, atkPrint, atkPush, atkPushAux, atkPushAuxS, atkPushAuxTOS,
    atkPushC, atkPushCS, atkPushPtr, atkPushPtrTag, atkPushS,
    {Q}
    {R}
    atkRead, atkReadS, atkRefreshRate, atkRepeat, atkRetFunction, atkReturn, atkRestore,
    {S}
    atkStrIdentifier, atkString, atkSub, atkSubS, atkSymbol,
    {T}
    atkTo, atkTrace, atkTraceOff, atkTraceOn,
    {U}
    atkUnknown, atkUntil, atkUnwatch,
    {V}
    {W}
    atkWatch, atkWhile
    {X}
    {Y}
    {Z}
  );

  //TAsmDataType = (dtNum, dtPtr, dtStr);
  TAsmData = record //Data cell format
    n: Extended;
    p: Pointer;
    s: String;
  end;

  //Type for functions that will be integrated into the basic engine
  TBindFunction = function(var Args: Array of TAsmData): TAsmData;
  TLinkFunction = record //Functions call type and entry point
    FarCall: Boolean; //True: imported from Delphi / False: user defined
    Entry: TBindFunction; //Function header if imported
    //True for a library that touches FireMonkey. FMX is not thread-safe, so
    //when the VM is not on the UI thread these calls have to be handed to it
    //rather than made where the VM stands. A library sets this once in its
    //Register procedure, before its first Add, because the record is copied by
    //value into every entry.
    //
    //It costs nothing while the VM runs on the UI thread: with no marshaller
    //installed, CallNative calls straight through.
    NeedsUIThread: Boolean;
  end;
  //The function signature is the dictionary index
  TFunctionsDictionary = TDictionary<String, TLinkFunction>;

  //Function type
  TExeFunc = procedure of object;
  //PRINT function type
  TPrintProc = procedure(p: PChar) of object;

  //--------------------------------------------------------------------------
  // Host interaction
  //
  // The engine does not know how the host talks to a person. An FMX host opens
  // a dialog; a console host reads stdin; a server host may refuse outright.
  // These follow the same shape as TPrintProc above, which already kept the
  // PRINT statement free of any UI dependency.
  //
  // Both requests carry a continuation instead of returning a value, so a host
  // whose dialogs are asynchronous can answer later without blocking the VM.
  // While it waits the VM sits in esIdle and calls YieldProc.
  //--------------------------------------------------------------------------

  //Answer to an input request: Confirmed is False when the person cancelled.
  TInputDoneProc = reference to procedure(Confirmed: Boolean;
                                          const AValues: array of String);
  TInputProc = procedure(const ACaption: String; const ALabels: array of String;
                         const ADefaults: array of String;
                         const ADone: TInputDoneProc) of object;

  //Answer to a yes/no question, used by BREAKPOINT.
  TConfirmDoneProc = reference to procedure(Confirmed: Boolean);
  TConfirmProc = procedure(const AMessage: String;
                           const ADone: TConfirmDoneProc) of object;

  //Called while the VM is idle, and periodically during PRINT. A host with a
  //message loop pumps it here. A headless host leaves it nil.
  TYieldProc = procedure of object;

  //Runs AProc on whatever thread FireMonkey belongs to, and does not return
  //until it has. A host that keeps the VM on the UI thread leaves this nil,
  //and every native call is made where the VM already stands.
  //
  //This is the seam the VM needs in order to move off the UI thread: the GUI
  //libraries touch FMX from 3,899 functions, but the VM reaches all of them
  //through one place, so the handover belongs here and not in the libraries.
  TMarshalProc = procedure(const AProc: TThreadMethod) of object;

  //Called on the VM's own thread, at a fixed instruction interval, so a host
  //that moved the VM off the UI thread has somewhere to run what the UI thread
  //queued while the program is running.
  //
  //The existing yield points are not enough for that, which the first attempt
  //discovered by hanging: YieldProc fires only when the VM is paused, or after
  //a PRINT, and a program that computes without printing reaches neither. That
  //is fine for pumping a message loop -- there is nothing to see -- and no use
  //at all for answering a click.
  //
  //Nil for a host that kept the VM on the UI thread, which is why this costs a
  //null test per interval rather than a call.
  TDrainProc = procedure of object;
  //BASIC tokenized instructions
  TBasInstr = record
    id: TBasToken; //Token type
    pos, len: Integer; //position, length
    n: Extended; //Numeric constant value
  end;
  TBasArray = array of TBasInstr;

  //Assembly tokenized instructions
  TInstr = record
    proc: TExeFunc; //Delphi function associated to the ASM instruction
    token: TAsmToken; //The token identification
    i: Integer; //string offset, variable index
    n: Extended; //Numeric constant value
  end;
  TInstrArray = array of TInstr;

  //One native call site, resolved once when the program is loaded.
  //
  //The three CALLEX handlers used to open by building a fresh heap String out
  //of the constant pool and hashing it twice -- ContainsKey, then the lookup --
  //on every execution, for a signature that is a compile-time constant sitting
  //in the instruction. Roughly 55 ns a call, and not on a rare path: a#[i]
  //compiles to a CALLEX of narr_get@#n, so every array element access paid it.
  TFarTarget = record
    Fn: TLinkFunction;  //entry point and the flags that travel with it
    Name: String;       //kept because the error text names the function
    Known: Boolean;     //False when the signature is not registered
  end;
  TFarTable = array of TFarTarget;

  //Argument buffers for native calls, reused instead of allocated.
  //
  //Every CALLEX used to SetLength a local `array of TAsmData`: a heap block
  //allocated, zeroed, registered for finalisation and finalised again on the
  //way out, for a call that is often one number.
  //
  //Static, and it has to be. Slice is the only way to hand a routine expecting
  //an open array a prefix of a larger buffer -- the callee reads Length(Args)
  //to know how many arguments it got -- and Slice takes a static array. It
  //refuses a dynamic one, which is worth writing down because the shape that
  //grows on demand is the obvious design and does not compile.
  //
  //Two dimensions because a native call can re-enter the VM: a control callback
  //runs BASIC, which makes another native call, and that call must not write
  //over the arguments of the one still in flight.
  TArgRow = array[0..ARGBUF_WIDTH - 1] of TAsmData;
  TArgBuf = array[0..ARGBUF_DEPTH - 1] of TArgRow;

  //Type used by the DATA/READ statements
  TDataItem = record
    DataType: AnsiChar; //String '$' or numeric 'n'
    DataPos: Integer; //Position at the code
  end;
  TDataItems = TList<TDataItem>;

  //Token identification
  TStringToken = record
    Str: String; //Textual representation of the token
    Token: TAsmToken; //Token 'id'
  end;
  TStringTokens = TList<TStringToken>;

  //Types of expresion
  TExprKind = (ekNumber, ekPointer, ekString);

  //Stack machine execution status
  TExecStatus = (esRun, esIdle);

  //Runtime errors
  TRTErrors = (
    rteStackOverflow, rteStackUnderflow, rteStackTypeMismatch, rteInvalidParams,
    rteDimIndexBound, rtePrintStackOverflow, rtePrintSyntaxMismatch,
    rteAuxStackTypeMismatch, rteAuxStackOverflow, rteAuxStackUnderflow,
    rteDivisionByZero, rteStringSize, rteUnknownInstr, rteUserMessage
  );

  TStrList = TList<String>; //Type for a list of strings

  //*********
  //TAsmLexer
  //*********
  //
  //Intermediate code lexer.
  //Used by the compiler and stack machine to tokenize postfix code.
  //
  TAsmLexer = class(TObject)
  private
    pSource: PChar;
    idx: Integer;
    //Identify assembly instructions
    function AsmIdentKind(orig: TAsmToken; tokstr: String): TAsmToken;
    //Postfix tokenizer
    procedure AsmGetToken(var tokenstr: String; var tokenPos: Integer; var tok: TAsmToken);
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadLine(p: PChar);
    //Get the second argument of an instruction
    function SecondArg(s: String): String;
    //get the String representation of the next token
    function NextString(): String;
    //Advance to the next token. After execution "data" holds the token string
    //representation, "tokenPos" holds the token start position, "tok" holds the
    //token label.
    procedure Advance(var data: String; var tokenPos: Integer; var tok: TAsmToken);
  end;

  //TExec
  //*****
  //
  // Stack machine for the final assembly code
  //
  TExec = class
  private
    PRG_IP, //current instruction index
    STKP, //top of stack
    BASEP: Integer; //functions and jumps control
    AuxStackIdx: Integer; //SELECT CASE top of stack
    //Keeps the last error message
    FErrorMessage: String;
    //Keeps the relationship between the Asm instructions and the BASIC source
    //code lines responsible for its generation.
    srcLine: Integer;
    FPrintProc: TPrintProc;
    FInputProc: TInputProc;
    FConfirmProc: TConfirmProc;
    FYieldProc: TYieldProc;
    FMarshalProc: TMarshalProc;
    FDrainProc: TDrainProc;
    //How many drains are in flight. Draining runs a queued call, a queued call
    //runs ExecuteFunction, and ExecuteFunction drains -- so this is re-entrant
    //by construction, and nothing else bounds how deep it goes.
    FDrainDepth: Integer;
    //Set for the duration of one marshalled call, because an open array cannot
    //be captured by the parameterless method Synchronize wants.
    FCallFn: TLinkFunction;
    FCallArgs: TArray<TAsmData>;
    FCallResult: TAsmData;
    strConst: String;
    sourceAlloc, ended: Boolean;
    asmLexer: TAsmLexer;
    asmProg: TInstrArray; //List of Asm code to exec
    //One entry per CALLEX instruction; asmProg[i].i indexes it.
    FFarTable: TFarTable;
    FArgBuf: TArgBuf;
    FArgDepth: Integer; //how many native calls are in flight
    FTotInsts: Integer; //Total of Asm instructions
    FCallbackProc: TNotifyEvent;
    FCallbackObj: TObject;
    FTimeOut: Int64; //Exec timeout
    ExecStatus: TExecStatus;
    FTraceLevel: Integer; //Debug trace level (0=off, 1=basic, 2=standard, 3=verbose)
    FWatchList: TStringList; //List of variables to watch during trace
    FCurrentFunction: String; //Name of current function being executed
    FGlobalVarNames: TStrList; //Variable names list (for WATCH value lookup)
    //UI refresh throttling for PRINT statements
    FUIRefreshInterval: Integer; //Minimum ms between UI refreshes (0=every print)
    FLastUIRefresh: Cardinal; //Tick count of last UI refresh
    //FTraceEnabled: Boolean; //Debug trace mode flag
    //--------------------------------------------------------------------------
    //Data comes from TCompiler
    //--------------------------------------------------------------------------
    HeapMem: array [0 .. MAXVARS] of TAsmData; //Global data area
    StackMem: array [0 .. MAXSTACK] of TAsmData; //Local vars stack
    TypeStack: array [0 .. MAXSTACK] of TExprKind; //Local vars types
    AuxStack: array[0 .. MAXSTACK] of TAsmData; //Auxiliary stack
    AuxStackTypes: array [0 .. MAXSTACK] of TExprKind; //Auxiliary stack types
    //auxiliary functions
    //Validates an index into HeapMem before it is used. Locals and the stack
    //already have guards (see fInitFunc); globals did not, and range checking
    //is enabled only in the Debug configuration.
    function GlobalIndexValid(Index: Integer): Boolean;
    procedure RunPendingCall();
    procedure Drain();
    //Every native call the VM makes goes through here.
    function CallNative(const AFn: TLinkFunction;
                        var Args: array of TAsmData): TAsmData;
    procedure PushAsmData(const dt: TAsmData; st: TExprKind);
    function PopAsmData(checkType: TExprKind): TAsmData;
    //The same two operations for the case that is almost all of them: a number,
    //moved without building a TAsmData to carry it. See their bodies for why
    //that record is expensive to hand around.
    procedure ResolveFarCalls();
    function AcquireArgs(n: Integer): Integer;
    procedure TakeArg(var cell: TAsmData);
    procedure PushNum(const v: Extended);
    function PopNum(): Extended;
    procedure Pop();
    function TokenToFunc(tk: TAsmToken): TExeFunc;
    function ICallReturnType(signature: String): String;
    function ICallGetParams(signature: String): String;
    //Stack machine assembly instructions
    procedure fPop(); //decrease top of stack.
    procedure fPush(); //push numeric variable content
    procedure fPushPtr(); //push pointer variable content
    procedure fPushPtrTag(); //Push pointer TAG constant
    procedure fPushC(); //push(n)
    procedure fPushS(); //push string variable content
    procedure fPushSC(); //push(s)
    procedure fAdd(); //pop(n1), pop(n2), push(n1+n2)
    procedure fSub(); //pop(n1), pop(n2), push(n1-n2)
    procedure fMul(); //pop(n1), pop(n2), push(n1*n2)
    procedure fDiv(); //pop(n1), pop(n2), push(n1/n2)
    procedure fMod(); //pop(n1), pop(n2), push(n1%n2)
    procedure fInv(); //pop(n1), push(inv(n1))
    procedure fMin(); //pop(n1), pop(n2), (n1<n2)?push(n1):push(n2)
    procedure fMax(); //pop(n1), pop(n2), (n1>n2)?push(n1):push(n2)
    procedure fPow(); //pop(n1), pop(n2), push(n1^n2)
    procedure fNot(); //pop(n1), (n1==0)?push(1):push(0)
    procedure fGE(); //pop(n1), pop(n2), (n1>=n2)?push(1):push(0)
    procedure fGT(); //pop(n1), pop(n2), (n1>n2)?push(1):push(0)
    procedure fLE(); //pop(n1), pop(n2), (n1<=n2)?push(1):push(0)
    procedure fLT(); //pop(n1), pop(n2), (n1<n2)?push(1):push(0)
    procedure fNE(); //pop(n1), pop(n2), (n1!=n2)?push(1):push(0)
    procedure fEQ(); //pop(n1), pop(n2), (n1==n2)?push(1):push(0)
    procedure fGES(); //pop(s1), pop(s2), (s1>=s2)?push(1):push(0)
    procedure fGTS(); //pop(s1), pop(s2), (s1>s2)?push(1):push(0)
    procedure fLES(); //pop(s1), pop(s2), (s1<=s2)?push(1):push(0)
    procedure fLTS(); //pop(s1), pop(s2), (s1<s2)?push(1):push(0)
    procedure fNES(); //pop(s1), pop(s2), (s1!=s2)?push(1):push(0)
    procedure fEQS(); //pop(s1), pop(s2), (s1==s2)?push(1):push(0)
    procedure fAddS();
    procedure fAppendS(); //pop(s1), pop(s2), push(s1+s2)
    procedure fSubS(); //pop(n1), pop(s1), push(s1[0,length(s1)-n1])
    procedure fAddCRLFS(); //pop(s1), pop(s2), push(s1+'/n'+s2)
    procedure fRead();
    procedure fReadS();
    procedure fRefreshRate(); //Set UI refresh interval
    procedure fRestore();
    procedure fInput();
    procedure fInputS();
    procedure fForCycle();
    procedure fPopStore(); //pop(n)
    procedure fPopStoreS(); //pop(s)
    procedure fPopStorePtr(); //pop(p)
    procedure fCallNear(); //push(p)
    procedure fCallFar(); //pop(n), push(n)
    procedure fCallFarS(); //pop(n), push(s)
    procedure fCallFarP(); //pop(n), push(p)
    procedure fOnCallFar(); //pop(n), pop(n), pop(s), push(n)
    procedure fOnCallFarS(); //pop(n), pop(s), pop(s), push(s)
    procedure fOnCallFarP(); //pop(n), pop(p), pop(s), push(p)
    procedure fJump();
    procedure fPopNCall();
    procedure fPopNJump();
    procedure fReturn(); //pop(p)
    procedure fInitFunc(); //push(p)
    procedure fRetFunction(); //pop(p), pop(p), pop(n)
    procedure fNOp();
    procedure fEnd();
    procedure fCls();
    procedure fPrint(); //pop(?)[,pop(?)]*
    procedure fErr();
    procedure fComma();
    procedure TraceComma();
    //procedure fFnAddr; //pop(s), push(n)
    procedure fIndirectCall();
    procedure fPushAuxStack();
    procedure fPushAuxStackS();
    procedure fPopAuxStack();
    procedure fPushAuxTOS();
    //Debug instructions
    procedure fAssert();      //assert condition with message
    procedure fBreakpoint();  //breakpoint (only when trace enabled)
    procedure fDump();        //dump all global variables
    procedure fTrace();       //set trace level
    procedure fTraceOn();     //enable trace mode (legacy)
    procedure fTraceOff();    //disable trace mode (legacy)
    procedure fWatch();       //add variables to watch list
    procedure fUnwatch();     //remove variables from watch list
    //Debug helper functions
    function GetTraceEnabled(): Boolean;
    function GetVariableValue(const varName: String): String;
    function GetWatchedVariablesInfo(): String;
  public
    //Entry point for every function available to the running program.
    ProgramFunctions: TFunctionsDictionary;
    //--------------------------------------------------------------------------
    DataStmts: TDataItems; //DATA statements type and position
    ReadIdx: Integer; //READ statement index
    //--------------------------------------------------------------------------
    TagObject: Pointer;

    constructor Create();
    destructor Destroy(); override;
    procedure Clear();
    procedure LoadSource(ls: TStringTokens);
    procedure ExecuteFunction(
      Entry: Integer; //function entry point
      ParamCount: Integer; //total arguments
      ParamType: Array of TExprKind; //arguments type
      Params: Array of TAsmData; //parameters value
      RetType: TExprKind; //function return type
      out RetValue: TAsmData //function return value
    );
    //execute from the beginning
    procedure ExecuteProgram();
    //Get global var contents
    function GetGlobalNum(const Index: Integer): Extended;
    function GetGlobalPtr(const Index: Integer): Pointer;
    function GetGlobalStr(const Index: Integer): String;
    //Runtime error
    procedure RTError(msg: TRTErrors; unkInstr: TAsmToken; auxMsg: String='');
    procedure Stop(); //Immediately stops the VM

    property ErrorMessage: String read FErrorMessage;
    property TotalASMInst: Integer Read FTotInsts;
    property IP: Integer read PRG_IP;
    property SourceLine: Integer read srcLine;
    property PrintProc: TPrintProc read FPrintProc write FPrintProc;
    //Leave these nil in a host with no user to ask: INPUT then yields its
    //default value and BREAKPOINT simply continues.
    property InputProc: TInputProc read FInputProc write FInputProc;
    property ConfirmProc: TConfirmProc read FConfirmProc write FConfirmProc;
    property YieldProc: TYieldProc read FYieldProc write FYieldProc;
    property MarshalProc: TMarshalProc read FMarshalProc write FMarshalProc;
    property DrainProc: TDrainProc read FDrainProc write FDrainProc;
    property CallbackProc: TNotifyEvent read FCallbackProc write FCallbackProc;
    property CallbackObj: TObject read FCallbackObj write FCallbackObj;
    property TimeOut: Int64 read FTimeOut write FTimeOut;
    property TraceLevel: Integer read FTraceLevel write FTraceLevel;
    property TraceEnabled: Boolean read GetTraceEnabled; //Legacy - returns TraceLevel > 0
    property WatchList: TStringList read FWatchList;
    property GlobalVarNames: TList<String> read FGlobalVarNames write FGlobalVarNames;
    property UIRefreshInterval: Integer read FUIRefreshInterval write FUIRefreshInterval;
  end;

//BREAKPOINT parks the VM in a wait loop on whatever thread called
//ExecuteProgram, and resumes only when the host answers. That works wherever
//the host can still deliver the answer while that thread is blocked: the
//Windows, Linux and macOS message queues all let a modal dialog run from
//inside such a loop.
//
//It does not work on Android or iOS. There the answer comes back through the
//platform's own looper, which is the very thing that called into the
//application. A parked VM blocks the mechanism that would wake it, the wait
//never ends, and the system reports the process as unresponsive.
//
//The engine consults this itself before parking, so no host can cause the hang
//by assigning ConfirmProc where it cannot work. Hosts should still consult it,
//since there is no point installing a handler that will never be called, but
//the guarantee does not rest on their doing so.
//
//Where the VM may not park, BREAKPOINT degrades to a trace dump of the frame,
//which is the part that still carries meaning on a device, where the
//application is its own debugger and there is no separate window to pause.
//
//That degradation is no longer about the platform, though it was written when
//it was. A host that runs the VM on a thread of its own can pause anywhere,
//phones included, because the thread that delivers the answer is not the one
//waiting for it.
function CanPauseForHostDialog: Boolean;

implementation

//How often the two dispatch loops step outside the program to look at the
//world. Both intervals used to be local constants inside ExecuteProgram, which
//is exactly how the two loops came to disagree: the commit that throttled the
//timeout check to one instruction in ten thousand landed in ExecuteProgram and
//not in ExecuteFunction, 120 lines away in this file, and ExecuteFunction went
//on calling QueryPerformanceCounter twice per instruction for every callback.
//That cost nothing where it was written -- the IDE sets ScriptTimeOut to 0, so
//the branch never runs there -- and 1.7x of the frame time on a device, where
//runner\AppletRunner.pas sets 30. Here, neither loop can drift from the other
//without someone editing a line that says both.
const
  //Small enough that a runaway callback is still stopped close to its deadline,
  //large enough that the clock disappears into the dispatch loop it sits in.
  TIMEOUT_CHECK_INTERVAL = 10000;
  //Small enough that a click is answered without a visible wait, large enough
  //that the null test disappears into the dispatch loop it sits in.
  DRAIN_CHECK_INTERVAL = 512;

function CanPauseForHostDialog: Boolean;
begin
  //Parking is safe whenever the thread that would answer is not the thread
  //that parks. With the VM on a worker that is always true, on every platform,
  //which is the whole point of moving it: the looper stays free to deliver the
  //dialog, and BREAKPOINT can stop on a phone.
  if TThread.Current.ThreadID <> MainThreadID then
    Exit(True);

  //On the UI thread it depends on the platform, and not because desktop is
  //better behaved. There the pause loop pumps messages, so the answer still
  //arrives while the VM waits. Android and iOS judge a blocked main looper by
  //the clock rather than by what it is doing, and kill the application in about
  //three seconds however busy that loop is.
  {$IF DEFINED(ANDROID) or DEFINED(IOS)}
  Result := False;
  {$ELSE}
  Result := True;
  {$ENDIF}
end;

procedure TExec.RunPendingCall();
begin
  FCallResult := FCallFn.Entry(FCallArgs);
end;

//Runs whatever another thread queued for the VM, and is the only way either
//dispatch loop should reach FDrainProc.
//
//Draining is re-entrant by construction: it runs a queued call, the queued call
//runs ExecuteFunction, and ExecuteFunction drains again. That nesting is not
//new and is not in itself unsafe -- it is the same shape the engine already
//tolerates when a control callback fires in the middle of the main program, and
//ExecuteFunction is built for it, saving and restoring the whole VM state and
//building its frame on top of the existing stack rather than at zero.
//
//What nothing bounded was the depth. A queued call that computes for a while,
//answering more queued calls that also compute, would nest as far as the host
//kept asking, spending VM stack and Delphi stack on every level. The cap is not
//a guess about what is safe so much as a statement that the queue is a queue:
//past this depth the remaining calls wait for the ones already running to
//finish, which is what they would have done before any of this existed.
procedure TExec.Drain();
const
  //Deep enough that ordinary nesting -- a program, a timer tick, a click
  //handler the tick provoked -- never notices; shallow enough that a runaway
  //cannot walk the stack down.
  MAX_DRAIN_DEPTH = 8;
begin
  if not Assigned(FDrainProc) then
    Exit();
  if FDrainDepth >= MAX_DRAIN_DEPTH then
    Exit();
  Inc(FDrainDepth);
  try
    FDrainProc();
  finally
    Dec(FDrainDepth);
  end;
end;

function TExec.CallNative(const AFn: TLinkFunction;
                          var Args: array of TAsmData): TAsmData;
var
  i: Integer;
begin
  //The ordinary path, and the only one taken while the VM owns the UI thread.
  if not (AFn.NeedsUIThread and Assigned(FMarshalProc)) then
    Exit(AFn.Entry(Args));

  //Synchronize takes a parameterless method, so the call travels in fields.
  SetLength(FCallArgs, Length(Args));
  for i := 0 to High(Args) do
    FCallArgs[i] := Args[i];
  FCallFn := AFn;
  FMarshalProc(RunPendingCall);
  Result := FCallResult;
end;

{ TAsmLexer }

procedure TAsmLexer.Advance(var data: String; var tokenPos: Integer; var tok: TAsmToken);
begin
  AsmGetToken(data, tokenPos, tok);
end;

procedure TAsmLexer.AsmGetToken(var tokenstr: String; var tokenPos: Integer; var tok: TAsmToken);
var
  d: Double;
  ok: Boolean;
  ch: Char;
  isEscaped: Boolean;
begin
  ch := pSource[idx];
  while ch.IsInArray([#8, #9, #32]) do //skip blanks
  begin
    Inc(idx);
    ch := pSource[idx];
  end;
  tokenPos := idx;
  case pSource[idx] of
    ';': //comment
    begin
      tokenPos := idx;
      {$IFDEF ANDROID}
      while (pSource[idx] <> System.sLineBreak) do
      {$ENDIF}
      {$IFDEF MSWINDOWS}
      while (pSource[idx] <> #0) do
      {$ENDIF}
        Inc(idx);
      SetString(tokenStr, pSource + tokenPos, idx - tokenPos);
      tok := atkComment;
    end;
    'A' .. 'Z', 'a' .. 'z', '_', '@': //identifier
    begin
      tokenPos := idx;
      Inc(idx);
      Ch := pSource[idx];
      while Ch.IsInArray(['A','B','C','D','E','F','G','H','I','J','K','L','M',
                          'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                          'a','b','c','d','e','f','g','h','i','j','k','l','m',
                          'n','o','p','q','r','s','t','u','v','w','x','y','z',
                          '0','1','2','3','4','5','6','7','8','9',
                          '_','$','#','@','.']) do
      begin
        Inc(idx);
        Ch := pSource[idx];
      end;
      setstring(tokenStr, pSource + tokenPos, idx - tokenPos);
      tok := atkIdentifier;
      case pSource[idx - 1] of
        '$': tok := atkStrIdentifier;
        '#': tok := atkPointerIdentifier;
      end;
      tok := AsmIdentKind(tok, tokenStr)
    end;
    '-', '0' .. '9', '.': //number
    begin
      tokenPos := idx;
      Inc(idx);
      tok := atkInteger;
      Ch := pSource[idx];
      while Ch.IsInArray(['0','1','2','3','4','5','6','7','8','9','.','e','E']) do
      begin
        case pSource[idx] of
          '.': tok := atkFloat;
          'e', 'E':
          begin
            Inc(idx);
            Ch := pSource[idx];
            tok := atkFloat;
          end;
        end;
        Inc(idx);
        Ch := pSource[idx];
      end;
      SetString(tokenStr, pSource + tokenPos, idx - tokenPos);
      if pSource[tokenPos] = '.' then
      begin
        tok := atkFloat;
        tokenStr := '0' + tokenStr;
      end;
      d := TUtils.StrToFloat2(tokenStr, ok);
      if not ok then tok := atkUnknown;
      if d > MAX_INTEGER_VALUE then tok := atkFloat;
      if pSource[idx] = '#' then Inc(idx);
    end;
    #10: //CRLF
    begin
      tok := atkCRLF;
      tokenStr := System.sLineBreak;
      tokenPos := idx;
      Inc(idx);
    end;
    #13: //CRLF
    begin
      tok := atkCRLF;
      tokenStr := System.sLineBreak;
      tokenPos := idx;
      Inc(idx);
      if pSource[idx] = Char(#10) then
        Inc(idx);
    end;
    '%', '/', '&', '('..',', ':', '<'..'?', '['..'^', '{'..'~': //operator
    begin
      tokenPos := idx;
      tok := atkSymbol;
      if pSource[idx] = ',' then tok := atkComma;
      Inc(idx);
      SetString(tokenStr, pSource + tokenPos, idx - tokenPos);
    end;
    '"': //It's a string constant
    begin
      tok := atkString;
      tokenStr := '';
      isEscaped := False;
      repeat
        case pSource[idx] of
          #0, #10, #13:
          begin
            Dec(idx);
            tok := atkUnknown;
            Break;
          end;
          '\':
          begin
            if isEscaped then
            begin
              tokenStr := tokenStr + '\';
              isEscaped := False;
            end
            else
              isEscaped := True;
          end;
          else
          begin
            if isEscaped then
            begin
              case pSource[idx] of
                '"': tokenStr := tokenStr + '"';   // \"  -> "
                '\': tokenStr := tokenStr + '\';   // \\  -> \
                'n': tokenStr := tokenStr + #10;   // \n  -> newline (LF)
                'r': tokenStr := tokenStr + #13;   // \r  -> carriage return (CR)
                't': tokenStr := tokenStr + #9;    // \t  -> horizontal tab
                '0': tokenStr := tokenStr + #0;    // \0  -> null character
                'b': tokenStr := tokenStr + #8;    // \b  -> backspace
                'f': tokenStr := tokenStr + #12;   // \f  -> form feed
                'v': tokenStr := tokenStr + #11;   // \v  -> vertical tab
                'a': tokenStr := tokenStr + #7;    // \a  -> alert/bell
                else tokenStr := tokenStr + '\' + pSource[idx]; // Invalid sequence
              end;
              isEscaped := False;
            end
            else if pSource[idx] <> '"' then
              tokenStr := tokenStr + pSource[idx];
          end;
        end;
        Inc(idx);
      until (not isEscaped) and (pSource[idx] = '"');
      Inc(idx);
      tokenPos := tokenPos + 1;
    end;
    #0:
    begin
      tok := atkNull;
      tokenStr := '';
      tokenPos := idx;
    end;
    else
    begin
      tokenPos := idx;
      Inc(idx);
      tok := atkUnknown;
      SetString(tokenStr, pSource + tokenPos, idx - tokenPos);
    end;
  end;
end;

function TAsmLexer.AsmIdentKind(orig: TAsmToken; tokstr: String): TAsmToken;
var
  code: Integer;
begin
  result := orig;
  tokstr := UpperCase(tokstr);
  code := TUtils.StringCode(tokstr);
  if (code < 140) or (code > 1086) then
    Exit();
  case code of
    140: if tokStr = 'GE' then Result := atkGe;
    145: if tokStr = 'LE' then Result := atkLe;
    147: if tokStr = 'NE' then Result := atkNe;
    150: if tokStr = 'EQ' then Result := atkEq;
    155: if tokStr = 'GT' then Result := atkGt;
    160: if tokStr = 'LT' then Result := atkLt;
    161: if tokStr = 'OR' then Result := atkOr;
    176: if tokStr = 'GE$' then Result := atkGeS;
    181: if tokStr = 'LE$' then Result := atkLeS;
    183: if tokStr = 'NE$' then Result := atkNeS;
    186: if tokStr = 'EQ$' then Result := atkEqS;
    191: if tokStr = 'GT$' then Result := atkGtS;
    196: if tokStr = 'LT$' then Result := atkLtS;
    201: if tokStr = 'ADD' then Result := atkAdd;
    211: if tokStr = 'AND' then Result := atkAnd;
    215: if tokStr = 'END' then Result := atkEnd;
    224: if tokStr = 'MOD' then Result := atkMod;
    226: if tokStr = 'CLS' then Result := atkCls;
    227: if tokStr = 'DIV' then Result := atkDiv;
    228: if tokStr = 'MIN' then Result := atkMin;
    230: if tokStr = 'MAX' then Result := atkMax;
    233: if tokStr = 'ERR' then Result := atkErr;
    234: if tokStr = 'SUB' then Result := atkSub;
    237:
    begin
      if tokStr = 'INV' then Result := atkInv
      else if tokStr = 'NOP' then Result := atkNop
      else if tokStr = 'ADD$' then Result := atkAddS;
    end;
    238: if tokStr = 'MUL' then Result := atkMul;
    239: if tokStr = 'POP' then Result := atkPop;
    241: if tokStr = 'NOT' then Result := atkNot;
    246: if tokStr = 'POW' then Result := atkPow;
    270: if tokStr = 'SUB$' then Result := atkSubS;
    282: if tokStr = 'DATA' then Result := atkData;
    //283: if tokStr = 'ADDR' then Result := atkFnAddress;
    284:
    begin
      if tokStr = 'CALL' then Result := atkCallNear
      else if tokStr = 'READ' then Result := atkRead;
    end;
    297: if tokStr = 'ELSE' then Result := atkElse;
    310: if tokStr = 'DUMP' then Result := atkDump;
    314: if tokStr = 'EXIT' then Result := atkExit;
    316: if tokStr = 'JUMP' then Result := atkJump;
    318: if tokStr = 'DATA$' then Result := atkDataS;
    319: if tokStr = 'NEXT' then Result := atkNext;
    320:
    begin
      if tokStr = 'PUSH' then Result := atkPush
      else if tokStr = 'READ$' then Result := atkReadS;
    end;
    355: if tokStr = 'PUSH#' then Result := atkPushPtr;
    356: if tokStr = 'PUSH$' then Result := atkPushS;
    357: if tokStr = 'BREAK' then Result := atkBreak;
    358: if tokStr = 'ENDIF' then Result := atkEndIf;
    367: if tokStr = 'TRACE' then Result := atkTrace;
    375: if tokStr = 'WATCH' then Result := atkWatch;
    377: if tokStr = 'WHILE' then Result := atkWhile;
    382: if tokStr = 'PAUSE' then Result := atkPause;
    387: if tokStr = 'PUSHC' then Result := atkPushC;
    396: if tokStr = 'UNTIL' then Result := atkUntil;
    397: if tokStr = 'PRINT' then Result := atkPrint;
    400: if tokStr = 'INPUT' then Result := atkInput;
    423: if tokStr = 'PUSHC$' then Result := atkPushCS;
    436: if tokStr = 'INPUT$' then Result := atkInputS;
    441: if tokStr = 'CALLEX' then Result := atkCallFar;
    449: if tokStr = 'REPEAT' then Result := atkRepeat;
    452: if tokStr = 'I_CALL' then Result := atkIndirectCall;
    466: if tokStr = 'ASSERT' then Result := atkAssert;
    470: if tokStr = 'ONGOTO' then Result := atkOnGoto;
    476:
    begin
      if tokStr = 'CALLEX#' then Result := atkCallFarP
      else if tokStr = 'APPEND$' then Result := atkAppendS;
    end;
    477:
    begin
      if tokStr = 'CALLEX$' then Result := atkCallFarS
      else if tokStr = 'POPAUX' then Result := atkPopAux;
    end;
    480: if tokStr = 'RETURN' then Result := atkReturn;
    499: if tokStr = 'CASEEND' then Result := atkCaseEnd;
    524: if tokStr = 'TRACEON' then Result := atkTraceOn;
    532: if tokStr = 'ADDCRLF$' then Result := atkAddCRLFS;
    538: if tokStr = 'UNWATCH' then Result := atkUnwatch;
    541: if tokStr = 'ONGOSUB' then Result := atkOnGosub;
    548: if tokStr = 'RESTORE' then Result := atkRestore;
    558: if tokStr = 'PUSHAUX' then Result := atkPushAux;
    581: if tokStr = 'CASEELSE' then Result := atkCaseElse;
    586: if tokStr = 'TRACEOFF' then Result := atkTraceOff;
    592: if tokStr = 'ENDWHILE' then Result := atkEndWhile;
    594: if tokStr = 'PUSHAUX$' then Result := atkPushAuxS;
    598: if tokStr = 'ONCALLEX' then Result := atkOnCallFar;
    599: if tokStr = 'FORCYCLE' then Result := atkForCycle;
    601: if tokStr = 'POPNCALL' then Result := atkPopnCall;
    608: if tokStr = 'INITFUNC' then Result := atkInitFunc;
    613: if tokStr = 'CONTINUE' then Result := atkContinue;
    614: if tokStr = 'FUNCTION' then Result := atkFunction;
    619: if tokStr = 'DO_WHILE' then Result := atkDoWhile;
    624: if tokStr = 'LOOP_END' then Result := atkLoopEnd;
    633: if tokStr = 'POPNJUMP' then Result := atkPopNJump;
    636: if tokStr = 'POPSTORE' then Result := atkPopStore;
    638: if tokStr = 'DO_UNTIL' then Result := atkDoUntil;
    640: if tokStr = 'DO_START' then Result := atkDoStart;
    670: if tokStr = 'PUSH#_TAG' then Result := atkPushPtrTag;
    671: if tokStr = 'POPSTORE#' then Result := atkPopStorePtr;
    672: if tokStr = 'POPSTORE$' then Result := atkPopStoreS;
    682: if tokStr = 'CASESTART' then Result := atkCaseStart;
    742: if tokStr = 'ELSEIFBODY' then Result := atkElseIfBody;
    751: if tokStr = 'BREAKPOINT' then Result := atkBreakpoint;
    760: if tokStr = 'ELSEIFTEST' then Result := atkElseIfTest;
    786: if tokStr = 'LOOP_WHILE' then Result := atkLoopWhile;
    804: if tokStr = 'PUSHAUXTOS' then Result := atkPushAuxTOS;
    805: if tokStr = 'LOOP_UNTIL' then Result := atkLoopUntil;
    827: if tokStr = 'REFRESHRATE' then Result := atkRefreshRate;
    829: if tokStr = 'ENDFUNCTION' then Result := atkEndfunction;
    849: if tokStr = 'RETFUNCTION' then Result := atkRetFunction;
    1023: if tokStr = 'POPNJUMP_CRLF' then Result := atkPopNJump_CRLF;
    1086: if tokStr = 'POPNJUMP_ENDIF' then Result := atkPopNJump_EndIf;
  end;
end;

constructor TAsmLexer.Create();
begin
  inherited Create();
end;

destructor TAsmLexer.Destroy();
begin
  inherited Destroy();
end;

procedure TAsmLexer.LoadLine(p: PChar);
begin
  pSource := p;
  idx := 0;
end;

function TAsmLexer.NextString(): String;
var
  p: Integer;
  tk: TAsmToken;
begin
  Result := '';
  Advance(Result, p, tk);
end;

function TAsmLexer.SecondArg(s: String): String;
var
  p: Integer;
  tk: TAsmToken;
begin
  LoadLine(PChar(s));
  Advance(result, p, tk);
  Advance(result, p, tk);
end;

{ TExec }

procedure TExec.Clear();
var
  i: Integer;
begin
  // FIX #6: Changed MAXVARS-1 to MAXVARS to clear ALL elements.
  // HeapMem is array[0..MAXVARS] (indices 0..515). The loop previously
  // skipped index 515. A program with 513+ globals would see stale data
  // in the last variable slot after re-running.
  for i := 0 to MAXVARS do
  begin
    HeapMem[i].n := 0; // Classic BASIC: uninitialized numbers default to 0
    HeapMem[i].p := nil;
    HeapMem[i].s := '';
  end;
  FErrorMessage := '';
  STKP := 0;
  PRG_IP := 0;
  BASEP := 0; // HIGH PRIORITY FIX: Initialize base pointer
  AuxStackIdx := 0; // HIGH PRIORITY FIX: Initialize auxiliary stack index
  FArgDepth := 0; //no native call is in flight at the start of a program
  ended := false;
end;

constructor TExec.Create();
begin
  TagObject := nil;
  sourceAlloc := false;
  FTraceLevel := 0; //Debug trace mode disabled by default
  FCurrentFunction := ''; //No function being executed
  FWatchList := TStringList.Create; //Create watch list for debug
  FWatchList.Duplicates := dupIgnore; //Ignore duplicate variable names
  //This dictionary contains the BASIC program available functions. Those
  //imported from Delphi and those declared by the user in the BASIC program
  //source code.
  //This information is sent to the stack machine by the parser and by the
  //preprocessor.
  ProgramFunctions := TFunctionsDictionary.Create();
  //Holds the position and type for each compiled DATA statement.
  DataStmts := TDataItems.Create;
  //Holds the index for the READ statements
  ReadIdx := 0;
  //Stack machine execution timeout
  FTimeOut := DEFAULT_TIMEOUT;
  //UI refresh throttling
  FUIRefreshInterval := DEFAULT_UI_REFRESH_INTERVAL;
  FLastUIRefresh := 0;
  asmLexer := TAsmLexer.Create();
  try
    SetLength(asmProg, INITASMSIZE + 1);
  except
    on E:Exception do
    begin
      FErrorMessage := 'ERROR. Unable to allocate memory for program execution: '+E.Message;
      ended := true;
    end;
  end;
  Self.Clear();
end;

destructor TExec.Destroy();
begin
  if Assigned(FWatchList) then FreeAndNil(FWatchList);
  if Assigned(asmLexer) then FreeAndNil(asmLexer);
  if Assigned(DataStmts) then FreeAndNil(DataStmts);
  if Assigned(ProgramFunctions) then FreeAndNil(ProgramFunctions);

  inherited Destroy();
end;

//Executes a user defined function (called directly only for callbacks)
//Normal function calls within the main program use fCallNear instead.
//CRITICAL: This method MUST run callbacks in a completely isolated stack
//environment to prevent corrupting the main program's stack state.
procedure TExec.ExecuteFunction(Entry, ParamCount: Integer; ParamType: array of TExprKind; Params: array of TAsmData; RetType: TExprKind; out RetValue: TAsmData);
var
  deltaTicks: Int64;
  Timer: TStopWatch;
  innerProc, i, TmpIP, TmpSTKP, TmpBASEP, TmpAuxStackIdx: Integer;
  TmpArgDepth: Integer;
  instructionCount, drainCount: Integer;
  dt: TAsmData;
  WasEnded, HadError: Boolean;
begin
  //Starts with 1, because the execution point in the assembly code will always
  //start in a function
  innerProc := 1;
  HadError := false;

  //CRITICAL FIX: ALWAYS save the COMPLETE VM state before callback execution.
  //This method is called directly only for callbacks (via ExecuteUserFunction).
  //Normal function calls go through fCallNear within ExecuteProgram.
  //Without saving state, callbacks fired during main program execution
  //(e.g., from property setters like switch_ischecked#) would corrupt the stack.
  WasEnded := ended;
  TmpIP := PRG_IP;
  TmpSTKP := STKP;
  TmpBASEP := BASEP;
  // FIX: Save AuxStackIdx to prevent SELECT/CASE corruption during callbacks.
  // If a callback fires while the main program is inside a SELECT/CASE block,
  // and the callback also uses SELECT/CASE, the auxiliary stack would be corrupted.
  TmpAuxStackIdx := AuxStackIdx;
  //And the native-call nesting, for the same reason as the four above. Every
  //CALLEX gives its level back from a finally, so this should already be where
  //it was -- but Clear runs only from Create and from the top of
  //ExecuteProgram, never from here, so a level that did leak inside a callback
  //would stay leaked for the rest of the run and push every later call towards
  //the allocating path. Restoring it bounds that to one callback.
  TmpArgDepth := FArgDepth;

  //Use try/finally to GUARANTEE state restoration even if exceptions occur
  try
    //CRITICAL FIX: Do NOT reset STKP to 0!
    //Callbacks can fire during main program execution (e.g., OnSelChanged triggers
    //while PopulateData sets cell values). If we reset STKP to 0, the callback
    //writes its parameters and locals over positions 1..N, DESTROYING the main
    //program's live stack data. After restoring STKP, the main program finds
    //corrupted TypeStack entries => "Stack type mismatch".
    //
    //Instead, build the callback's stack frame ON TOP of the existing stack.
    //After the callback completes, we restore STKP/BASEP to discard the
    //callback's frame, leaving the main program's stack memory untouched.
    if ended then
      ended := false;
    PRG_IP := 0;
    //STKP stays at current value - callback builds on top of existing stack
    //BASEP stays at current value - will be saved/restored by fInitFunc/fRetFunction

    for i := 0 to ParamCount-1 do //Push parameters
      PushAsmData(Params[i], ParamType[i]);
    dt.n := ParamCount;
    PushAsmData(dt, ekNumber); //Push total of passed parameters.
    // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
    dt.p := Pointer(NativeInt(PRG_IP)); //Record the entry point.
    PushAsmData(dt, ekPointer); //Push function entry point.
    PRG_IP := Entry; //Move index to the function's entry point.
    //It must be an "atkInitFunc" instruction
    if (asmProg[PRG_IP].token <> atkInitFunc) then
    begin
      RTError(rteUserMessage, atkNull, 'Entry point is not a function address in function call by address.');
      Exit(); //finally will still run and restore state
    end;
    deltaTicks := FTimeOut * 1000; //Timeout in milliseconds
    Timer := TStopWatch.StartNew; //Create watch
    instructionCount := 0;
    drainCount := 0;
    try
      //The guard ExecuteProgram carries as FIX #12, and for the same reason:
      //without it a library exception leaves this loop with the error text
      //naming nothing, and the four collection libraries raise fatally in 121
      //places, so a callback reaching one of them is not a remote case.
      //
      //One frame around the whole loop, where ExecuteProgram puts one around
      //each instruction. The message is identical either way: the raise happens
      //before Inc(PRG_IP), so PRG_IP still names the failing instruction when
      //the exception arrives here. Both re-raise, so the loop ends the same
      //way. Only the cost differs, and here it is not free -- measured per
      //instruction it took 2.6% off every callback, which is 2.6% off every
      //frame of a game to gain a prefix on a message.
      try
        repeat //run function's body
          if (asmProg[PRG_IP].token = atkCallNear) then Inc(innerProc);
          if (asmProg[PRG_IP].token = atkRetFunction) then Dec(innerProc);
          asmProg[PRG_IP].proc(); //call proc linked to the instruction
          Inc(PRG_IP); //move to next instruction
          //If there is a callback, run it.
          if (callBackObj <> nil) then CallBackProc(callBackObj);
          //Anything another thread queued while this callback was running. Until
          //this was here a computing callback answered nothing, so a click that
          //arrived during a frame waited out the whole script timeout and came
          //back as "the VM did not reach a yield point in time" -- the failure
          //the drain exists to prevent, in the one loop that did not have it.
          if Assigned(FDrainProc) then
          begin
            Inc(drainCount);
            if drainCount >= DRAIN_CHECK_INTERVAL then
            begin
              drainCount := 0;
              Drain();
            end;
          end;
          //Check for the script timeout.
          //
          //This used to Stop and Start the watch on every instruction: two
          //QueryPerformanceCounter calls to answer a question that cannot change
          //meaningfully between one instruction and the next. Measured at about
          //34 ns per instruction, which is 1.7x of the frame time of a game whose
          //steps arrive here as OnTimer callbacks. ElapsedMilliseconds reads a
          //running watch -- ExecuteProgram has relied on that since its own fix,
          //and stopping the watch was never what made the reading correct.
          if FTimeOut > 0 then //0 = no timeout (be careful)
          begin
            Inc(instructionCount);
            if instructionCount >= TIMEOUT_CHECK_INTERVAL then
            begin
              instructionCount := 0;
              if Timer.ElapsedMilliseconds > deltaTicks then //Check for timeout
              begin
                HadError := true;
                Break; //Exit loop instead of raising exception
              end;
            end;
          end;
        until (ended or (innerProc = 0));
      except
        on E: Exception do
        begin
          if not ended then
          begin
            FErrorMessage := 'Unexpected error at ASM[' + IntToStr(PRG_IP) +
              '] Source[' + IntToStr(srcLine) + ']: ' + E.Message;
            ended := true;
          end;
          raise;
        end;
      end;
    finally
      Timer.Stop(); //Stop watch
    end;
    //Track if an error occurred during callback execution
    if ended then HadError := true;
    // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
    PRG_IP := NativeInt(dt.p);
    //After running, pop function result from stack (only if no error occurred)
    if not HadError then
    begin
      case RetType of
        ekNumber: RetValue.n := PopAsmData(ekNumber).n;
        ekPointer: RetValue.p := PopAsmData(ekPointer).p;
        ekString: RetValue.s := PopAsmData(ekString).s;
      end;
    end;
  finally
    //ALWAYS restore VM state after callback completes - this is CRITICAL
    //Restoring STKP effectively discards the callback's entire stack frame,
    //leaving the main program's stack data intact below.
    ended := WasEnded;
    PRG_IP := TmpIP;
    STKP := TmpSTKP;
    BASEP := TmpBASEP;
    AuxStackIdx := TmpAuxStackIdx; // Restore auxiliary stack (SELECT/CASE)
    FArgDepth := TmpArgDepth;
  end;
end;

//Execute the entire program
//Both intervals this loop uses are declared at the top of the implementation
//section, because ExecuteFunction uses them too and the two loops disagreeing
//about them is the defect that put them there.
procedure TExec.ExecuteProgram();
var
  deltaTicks: Int64;
  Timer: TStopWatch;
  instructionCount: Integer;
  drainCount: Integer;
begin
  ExecStatus := TExecStatus.esRun; //Change status to 'running'
  Self.Clear(); //Reset the stack machine
  deltaTicks := FTimeOut * 1000; //Timeout in milliseconds
  Timer := TStopWatch.StartNew(); //Create watch
  instructionCount := 0; // HIGH PRIORITY FIX: Counter for optimized timeout checking
  drainCount := 0;

  repeat //for each instruction...
    if ExecStatus <> TExecStatus.esRun then
    begin
      if Assigned(FYieldProc) then
        FYieldProc();
      //Parked is where draining matters most, and where it was missing. Idle
      //means the VM is waiting for the host to answer -- a BREAKPOINT, an
      //INPUT -- and answering is exactly when a host runs BASIC again. Without
      //this a caller waits out the whole script timeout, which on a device is
      //a window that has stopped responding.
      //
      //A console host can reach this through YieldProc instead, and the first
      //version of this only worked that way. An FMX host cannot: its YieldProc
      //pumps the message loop, which from a worker is wrong, so it has none.
      Drain();
      // Two reasons, and the second arrived later than the first.
      //
      // Without a sleep this loop burns a core while the VM waits for the host
      // to answer, which on a device drains the battery and can trip the
      // Android ANR or the iOS watchdog. 16 ms is about one frame.
      //
      // It is also the interval at which a parked VM answers what another
      // thread has queued, because DrainProc above runs here and nowhere else
      // while execution is stopped. Replacing this with a blocking wait would
      // stop that draining, which is the deadlock in ANALYSIS 20.
      TThread.Sleep(16);
      continue;
    end;
    // FIX #12: Wrap instruction execution in try/except to catch unexpected
    // exceptions from library functions. Without this, an unhandled exception
    // propagates with PRG_IP/STKP/BASEP in potentially inconsistent state,
    // causing incorrect error line reporting. We catch it here and set the
    // error state cleanly before re-raising.
    try
      asmProg[PRG_IP].proc(); //Exec instr.
    except
      on E: Exception do
      begin
        // If ended is already set (e.g. by fErr or RTError), the error
        // was expected and handled — just re-raise to exit the loop.
        if not ended then
        begin
          FErrorMessage := 'Unexpected error at ASM[' + IntToStr(PRG_IP) +
            '] Source[' + IntToStr(srcLine) + ']: ' + E.Message;
          ended := true;
        end;
        raise;
      end;
    end;
    Inc(PRG_IP); //Increment instruction pointer
    //Check for callback object, If assigned process it.
    if (callBackObj <> nil) then CallBackProc(callBackObj);
    //Anything another thread queued for the VM runs here, between two
    //instructions, which is the only place it can: the stack machine holds one
    //caller at a time and this is where it holds none.
    if Assigned(FDrainProc) then
    begin
      Inc(drainCount);
      if drainCount >= DRAIN_CHECK_INTERVAL then
      begin
        drainCount := 0;
        Drain();
      end;
    end;
    // HIGH PRIORITY FIX: Optimized timeout checking - only check every N instructions
    if FTimeOut > 0 then //0 = no timeout (be careful)
    begin
      Inc(instructionCount);
      if instructionCount >= TIMEOUT_CHECK_INTERVAL then
      begin
        instructionCount := 0;
        if Timer.ElapsedMilliseconds > deltaTicks then //Check for timeout
        begin
          ended := true;
          Timer.Stop();
          raise Exception.Create('Script timeout');
        end;
      end;
    end;
  until ended;
  Timer.Stop(); //Stop watch
end;

procedure TExec.fAdd();
begin
  Pop();
  StackMem[STKP].n := StackMem[STKP].n + StackMem[STKP + 1].n;
end;

procedure TExec.fAddCRLFS();
begin
  Pop();
  StackMem[STKP].s := StackMem[STKP].s + System.sLineBreak + StackMem[STKP + 1].s;
end;

procedure TExec.fAddS();
begin
  Pop();
  StackMem[STKP].s := StackMem[STKP].s + StackMem[STKP + 1].s;
end;

//Append the string on top of the stack to a variable, in place.
//
//`s$ = s$ + x$` compiled to PUSH$ s / <x> / ADD$ / POPSTORE$ s, and that
//sequence is quadratic. PUSH$ hands the stack the variable's own buffer, so the
//variable and the stack slot hold it at reference count two, and Delphi's
//_UStrCat can only extend a buffer in place at reference count one. At two it
//allocates a fresh buffer and copies everything built so far. Every iteration.
//Measured before this existed: 10k appends 3.03 ms, 40k 31.69, 160k 2200.32 --
//eighteen times the time for twice the work.
//
//This never puts the destination on the stack, so its buffer stays at one
//reference and grows in place. TCompiler.AssignAppend is what rewrites the
//sequence into it, and only for the exact four-instruction shape where the
//variable read and the variable written are the same one.
procedure TExec.fAppendS();
var
  i: Integer;
begin
  if STKP = 0 then
  begin
    RTError(rteStackUnderflow, atkNull);
    Exit;
  end;
  if TypeStack[STKP] <> ekString then
  begin
    RTError(rteStackTypeMismatch, atkNull);
    Exit;
  end;
  i := asmProg[PRG_IP].i;
  //`s$ = s$ + s$` reaches here with the source and the destination sharing one
  //buffer, so the append below finds reference count two and allocates, exactly
  //as the old sequence always did. Correct, and no slower than before.
  if i < 0 then
    StackMem[BASEP + i + MAXLOCALS].s :=
      StackMem[BASEP + i + MAXLOCALS].s + StackMem[STKP].s //local
  else if GlobalIndexValid(i) then
    HeapMem[i].s := HeapMem[i].s + StackMem[STKP].s; //global
  //Release the slot rather than leaving it to Pop, which deliberately does not.
  //Nothing reads this cell again -- the value has been consumed -- and a stack
  //slot holding the last fragment of a string built in a loop keeps a buffer
  //alive for no reason.
  StackMem[STKP].s := '';
  Dec(STKP);
end;

//Debug: ASSERT condition, "message"
procedure TExec.fAssert();
var
  assertMsg: String;
  condition: Extended;
begin
  //Pop the message first (was pushed last)
  assertMsg := PopAsmData(ekString).s;

  //Pop the condition result
  condition := PopAsmData(ekNumber).n;

  //Only execute assertion check if trace is enabled
  if FTraceLevel > 0 then
  begin
    if condition = 0 then
    begin
      //Assertion failed
      if Assigned(FPrintProc) then
        FPrintProc(PChar('[ASSERT FAILED] Line ' + IntToStr(srcLine) + ': ' + assertMsg + System.sLineBreak));

      //Stop execution
      ended := true;
    end;
  end;
end;

//Numerical far call
procedure TExec.fCallFar();
var
  n,i,t,lvl: Integer;
  numF: TLinkFunction;
  Args: Array of TAsmData;
  dt: TAsmData;
begin
  //The signature was resolved once, when the program was loaded, so the
  //instruction now carries a row in FFarTable instead of an offset into the
  //string pool. What used to happen here on every execution -- build a heap
  //String, hash it for ContainsKey, hash it again for the lookup -- happens
  //once per call site in ResolveFarCalls.
  t := asmProg[PRG_IP].i;
  if (t < 0) or (t > High(FFarTable)) or (not FFarTable[t].Known) then
  begin
    RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
    Exit();
  end;
  //The whole record: the entry point and the flags that travel with it.
  //Copying only Entry left NeedsUIThread reading stack garbage, which is
  //why the marshalling seam never fired.
  numF := FFarTable[t].Fn; //entry point and flags
  n := Trunc(PopAsmData(ekNumber).n);
  lvl := AcquireArgs(n);
  if lvl >= 0 then
  begin
    //The ordinary path: a buffer that already exists.
    try
      for i := n - 1 downto 0 do //for each parameter...
        TakeArg(FArgBuf[lvl][i]);
      //Sliced, because the buffer is wider than this call and the callee reads
      //Length(Args) to know how many arguments it was given.
      try
        dt := CallNative(numF, Slice(FArgBuf[lvl], n));
      except
        on E: Exception do
        begin
          RTError(rteUserMessage, atkNull, 'Far call error (' + FFarTable[t].Name + '): ' + E.Message);
          Exit;
        end;
      end;
    finally
      //Whatever happened above -- an error, an Exit out of the except branch --
      //the level goes back, or every later call in this run starts one deeper.
      Dec(FArgDepth);
    end;
  end
  else
  begin
    //Too many arguments, or too deeply nested. Allocate, as this always did.
    try
      SetLength(Args, n); //allocate parameters
    except
      RTError(rteUserMessage, atkNull, 'Out of memory');
      Exit();
    end;
    for i := n - 1 downto 0 do
      TakeArg(Args[i]);
    try
      dt := CallNative(numF, Args);
    except
      on E: Exception do
      begin
        RTError(rteUserMessage, atkNull, 'Far call error (' + FFarTable[t].Name + '): ' + E.Message);
        Exit;
      end;
    end;
  end;
  PushAsmData(dt, ekNumber);
end;

//Pointer far call
procedure TExec.fCallFarP();
var
  n,i,t,lvl: Integer;
  ptrF: TLinkFunction;
  Args: Array of TAsmData;
  dt: TAsmData;
begin
  //The signature was resolved once, when the program was loaded, so the
  //instruction now carries a row in FFarTable instead of an offset into the
  //string pool. What used to happen here on every execution -- build a heap
  //String, hash it for ContainsKey, hash it again for the lookup -- happens
  //once per call site in ResolveFarCalls.
  t := asmProg[PRG_IP].i;
  if (t < 0) or (t > High(FFarTable)) or (not FFarTable[t].Known) then
  begin
    RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
    Exit();
  end;
  //The whole record: the entry point and the flags that travel with it.
  //Copying only Entry left NeedsUIThread reading stack garbage, which is
  //why the marshalling seam never fired.
  ptrF := FFarTable[t].Fn; //entry point and flags
  n := Trunc(PopAsmData(ekNumber).n);
  lvl := AcquireArgs(n);
  if lvl >= 0 then
  begin
    //The ordinary path: a buffer that already exists.
    try
      for i := n - 1 downto 0 do //for each parameter...
        TakeArg(FArgBuf[lvl][i]);
      //Sliced, because the buffer is wider than this call and the callee reads
      //Length(Args) to know how many arguments it was given.
      try
        dt := CallNative(ptrF, Slice(FArgBuf[lvl], n));
      except
        on E: Exception do
        begin
          RTError(rteUserMessage, atkNull, 'Far call error (' + FFarTable[t].Name + '): ' + E.Message);
          Exit;
        end;
      end;
    finally
      //Whatever happened above -- an error, an Exit out of the except branch --
      //the level goes back, or every later call in this run starts one deeper.
      Dec(FArgDepth);
    end;
  end
  else
  begin
    //Too many arguments, or too deeply nested. Allocate, as this always did.
    try
      SetLength(Args, n); //allocate parameters
    except
      RTError(rteUserMessage, atkNull, 'Out of memory');
      Exit();
    end;
    for i := n - 1 downto 0 do
      TakeArg(Args[i]);
    try
      dt := CallNative(ptrF, Args);
    except
      on E: Exception do
      begin
        RTError(rteUserMessage, atkNull, 'Far call error (' + FFarTable[t].Name + '): ' + E.Message);
        Exit;
      end;
    end;
  end;
  PushAsmData(dt, ekPointer);
end;

//String far call
procedure TExec.fCallFarS();
var
  n,i,t,lvl: Integer;
  strF: TLinkFunction;
  Args: Array of TAsmData;
  dt: TAsmData;
begin
  //The signature was resolved once, when the program was loaded, so the
  //instruction now carries a row in FFarTable instead of an offset into the
  //string pool. What used to happen here on every execution -- build a heap
  //String, hash it for ContainsKey, hash it again for the lookup -- happens
  //once per call site in ResolveFarCalls.
  t := asmProg[PRG_IP].i;
  if (t < 0) or (t > High(FFarTable)) or (not FFarTable[t].Known) then
  begin
    RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
    Exit();
  end;
  //The whole record: the entry point and the flags that travel with it.
  //Copying only Entry left NeedsUIThread reading stack garbage, which is
  //why the marshalling seam never fired.
  strF := FFarTable[t].Fn; //entry point and flags
  n := Trunc(PopAsmData(ekNumber).n);
  lvl := AcquireArgs(n);
  if lvl >= 0 then
  begin
    //The ordinary path: a buffer that already exists.
    try
      for i := n - 1 downto 0 do //for each parameter...
        TakeArg(FArgBuf[lvl][i]);
      //Sliced, because the buffer is wider than this call and the callee reads
      //Length(Args) to know how many arguments it was given.
      try
        dt := CallNative(strF, Slice(FArgBuf[lvl], n));
      except
        on E: Exception do
        begin
          RTError(rteUserMessage, atkNull, 'Far call error (' + FFarTable[t].Name + '): ' + E.Message);
          Exit;
        end;
      end;
    finally
      //Whatever happened above -- an error, an Exit out of the except branch --
      //the level goes back, or every later call in this run starts one deeper.
      Dec(FArgDepth);
    end;
  end
  else
  begin
    //Too many arguments, or too deeply nested. Allocate, as this always did.
    try
      SetLength(Args, n); //allocate parameters
    except
      RTError(rteUserMessage, atkNull, 'Out of memory');
      Exit();
    end;
    for i := n - 1 downto 0 do
      TakeArg(Args[i]);
    try
      dt := CallNative(strF, Args);
    except
      on E: Exception do
      begin
        RTError(rteUserMessage, atkNull, 'Far call error (' + FFarTable[t].Name + '): ' + E.Message);
        Exit;
      end;
    end;
  end;
  PushAsmData(dt, ekString);
end;

//User Defined Function (near) call
procedure TExec.fCallNear();
var
  dt: TAsmData;
begin
  // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
  dt.p := Pointer(NativeInt(PRG_IP + 1));
  PushAsmData(dt, ekPointer);
  PRG_IP := asmProg[PRG_IP].i - 1;
end;

procedure TExec.fCls();
begin
  FPrintProc(nil);
end;

procedure TExec.fComma();
begin
  srcLine := asmProg[PRG_IP].i;
  //Output trace info when trace mode is enabled
  //
  //The trace itself lives in TraceComma below because it declares a String, and
  //a managed local makes the compiler wrap the entire handler in an implicit
  //try/finally to finalise it. This handler is one instruction in five or six
  //of everything the VM executes -- it is how the line number gets set -- and
  //with tracing off, which is almost always, its whole job is the field store
  //above. It should not be paying for a string it never builds.
  if (FTraceLevel > 0) and Assigned(FPrintProc) then
    TraceComma();
end;

//The trace text, byte for byte as fComma produced it.
procedure TExec.TraceComma();
var
  traceMsg: String;
begin
  case FTraceLevel of
    1: //Basic: Line number only
      traceMsg := '[TRACE] Line ' + IntToStr(srcLine);
    2: //Standard: Line + function name
      begin
        traceMsg := '[TRACE] Line ' + IntToStr(srcLine);
        if FCurrentFunction <> '' then
          traceMsg := traceMsg + ' | Function: ' + FCurrentFunction;
      end;
    3: //Verbose: Line + function + watched variables
      begin
        traceMsg := '[TRACE] Line ' + IntToStr(srcLine);
        if FCurrentFunction <> '' then
          traceMsg := traceMsg + ' | Function: ' + FCurrentFunction;
        if FWatchList.Count > 0 then
          traceMsg := traceMsg + GetWatchedVariablesInfo();
      end;
  else
    traceMsg := '[TRACE] Line ' + IntToStr(srcLine);
  end;
  traceMsg := traceMsg + System.sLineBreak;
  FPrintProc(PChar(traceMsg));
end;

procedure TExec.fDiv();
begin
  Pop();
  if StackMem[STKP + 1].n = 0 then
  begin
    RTError(rteDivisionByZero, atkNull);
    Exit;
  end;
  StackMem[STKP].n := StackMem[STKP].n / StackMem[STKP + 1].n;
end;

//Debug: DUMP ["label"] - show all global variables with actual values
procedure TExec.fDump();
var
  dumpLabel: String;
  i: Integer;
  varName, varValue, varLine, displayName: String;
begin
  //Pop the label (empty string if not provided)
  dumpLabel := PopAsmData(ekString).s;

  //Only execute if trace is enabled
  if FTraceLevel > 0 then
  begin
    if Assigned(FPrintProc) then
    begin
      if dumpLabel <> '' then
        FPrintProc(PChar('[DUMP] ' + dumpLabel + ' (Line ' + IntToStr(srcLine) + ')' + System.sLineBreak))
      else
        FPrintProc(PChar('[DUMP] Line ' + IntToStr(srcLine) + System.sLineBreak));

      //Show all global variables if GlobalVarNames is available
      if Assigned(FGlobalVarNames) then
      begin
        for i := 3 to FGlobalVarNames.Count - 1 do  //Skip registers @0, @1, @2
        begin
          varName := FGlobalVarNames[i];

          //Skip only the internal registers @0, @1, @2 (already skipped by starting at 3)
          //But also skip if somehow they appear
          if (varName = '@0') or (varName = '@1') or (varName = '@2') then
            Continue;

          //Remove @ prefix for display
          if varName.StartsWith('@') then
            displayName := Copy(varName, 2, Length(varName) - 1)
          else
            displayName := varName;

          //Get value based on type (check the displayName for suffix)
          if displayName.EndsWith('$') then
            varValue := '"' + HeapMem[i].s + '"'
          else if displayName.EndsWith('#') then
          begin
            if HeapMem[i].p = nil then
              varValue := 'nil'
            else
              varValue := '$' + IntToHex(NativeInt(HeapMem[i].p), 8);
          end
          else
            varValue := FloatToStr(HeapMem[i].n);

          varLine := '  ' + displayName + ' = ' + varValue;
          FPrintProc(PChar(varLine + System.sLineBreak));
        end;
      end
      else
        FPrintProc(PChar('  (GlobalVarNames not available)' + System.sLineBreak));
    end;
  end;
end;

procedure TExec.fEnd();
begin
  srcLine := 0;
  ended := true;
end;

//Debug: Enable trace mode (legacy - same as TRACE 1)
procedure TExec.fTraceOn();
begin
  FTraceLevel := 1;
  if Assigned(FPrintProc) then
    FPrintProc(PChar('[TRACE] Trace mode enabled (level 1)' + System.sLineBreak));
end;

//Debug: Set trace level
procedure TExec.fTrace();
var
  level: Integer;
begin
  level := Round(asmProg[PRG_IP].n);
  FTraceLevel := level;
  if Assigned(FPrintProc) then
  begin
    case level of
      0: FPrintProc(PChar('[TRACE] Trace disabled' + System.sLineBreak));
      1: FPrintProc(PChar('[TRACE] Trace level 1 (basic)' + System.sLineBreak));
      2: FPrintProc(PChar('[TRACE] Trace level 2 (standard)' + System.sLineBreak));
      3: FPrintProc(PChar('[TRACE] Trace level 3 (verbose)' + System.sLineBreak));
    end;
  end;
end;

//Debug: UNWATCH [var1, var2, ...] - remove variables from watch list
procedure TExec.fUnwatch();
var
  varCount, i, idx: Integer;
  varName: String;
begin
  varCount := Round(asmProg[PRG_IP].n);

  if varCount = 0 then
  begin
    //Clear all watches
    FWatchList.Clear;
    if (FTraceLevel > 0) and Assigned(FPrintProc) then
      FPrintProc(PChar('[UNWATCH] Cleared all watched variables' + System.sLineBreak));
  end
  else
  begin
    //Remove specific variables
    for i := varCount - 1 downto 0 do
    begin
      varName := PopAsmData(ekString).s;
      idx := FWatchList.IndexOf(varName);
      if idx >= 0 then
        FWatchList.Delete(idx);
    end;
    if (FTraceLevel > 0) and Assigned(FPrintProc) then
      FPrintProc(PChar('[UNWATCH] Removed ' + IntToStr(varCount) + ' variable(s) from watch list' + System.sLineBreak));
  end;
end;

//Debug: WATCH var1, var2, ... - add variables to watch list
procedure TExec.fWatch();
var
  varCount, i: Integer;
  varName: String;
begin
  varCount := Round(asmProg[PRG_IP].n);

  //Pop variable names in reverse order, but insert at beginning to preserve order
  for i := varCount - 1 downto 0 do
  begin
    varName := PopAsmData(ekString).s;
    FWatchList.Insert(0, varName);  // Insert at beginning to preserve original order
  end;

  if (FTraceLevel > 0) and Assigned(FPrintProc) then
    FPrintProc(PChar('[WATCH] Added ' + IntToStr(varCount) + ' variable(s) to watch list' + System.sLineBreak));
end;

//Debug: Disable trace mode (legacy - same as TRACE 0)
procedure TExec.fTraceOff();
begin
  FTraceLevel := 0;
  if Assigned(FPrintProc) then
    FPrintProc(PChar('[TRACE] Trace mode disabled' + System.sLineBreak));
end;

//Debug: Breakpoint (only executes when trace is enabled)
procedure TExec.fBreakpoint();
var
  varCount, i: Integer;
  bkptMsg, varInfo, dialogMsg: String;
  varValue: TAsmData;
  varType: TExprKind;
  varNames: array of String;
  varValues: array of String;
begin
  //Only execute if trace mode is enabled
  if FTraceLevel = 0 then
  begin
    //Still need to clean the stack even when not tracing
    varCount := Round(asmProg[PRG_IP].n);
    //Pop all variable values and names
    for i := 0 to varCount - 1 do
    begin
      Pop(); //value
      Pop(); //name
    end;
    Pop(); //message
    Exit();
  end;

  //Get the variable count from the instruction
  varCount := Round(asmProg[PRG_IP].n);

  //Allocate arrays for variable info
  SetLength(varNames, varCount);
  SetLength(varValues, varCount);

  //Pop variables in reverse order (LIFO)
  for i := varCount - 1 downto 0 do
  begin
    //Pop variable value first (was pushed last for this var)
    varType := TypeStack[STKP];
    case varType of
      ekNumber:
      begin
        varValue := PopAsmData(ekNumber);
        varValues[i] := FloatToStr(varValue.n);
      end;
      ekString:
      begin
        varValue := PopAsmData(ekString);
        varValues[i] := '"' + varValue.s + '"';
      end;
      ekPointer:
      begin
        varValue := PopAsmData(ekPointer);
        if varValue.p = nil then
          varValues[i] := 'nil'
        else
          varValues[i] := '$' + IntToHex(NativeInt(varValue.p), 8);
      end;
    end;
    //Pop variable name
    varNames[i] := PopAsmData(ekString).s;
  end;

  //Now pop the breakpoint message (was pushed first)
  bkptMsg := PopAsmData(ekString).s;

  //Build variable info string
  varInfo := '';
  for i := 0 to varCount - 1 do
    varInfo := varInfo + '  ' + varNames[i] + ' = ' + varValues[i] + System.sLineBreak;

  //Build dialog message
  dialogMsg := 'BREAKPOINT at Line ' + IntToStr(srcLine) + System.sLineBreak;
  if bkptMsg <> '' then
    dialogMsg := dialogMsg + System.sLineBreak + 'Message: ' + bkptMsg + System.sLineBreak;
  if varInfo <> '' then
    dialogMsg := dialogMsg + System.sLineBreak + 'Variables:' + System.sLineBreak + varInfo;
  dialogMsg := dialogMsg + System.sLineBreak + 'Press YES to continue, NO to stop execution.';

  //Report the whole frame to the trace, variables included, whether or not a
  //dialog follows. Doing it here rather than inside the branch below keeps the
  //record identical on every platform: a trace log that loses its values as
  //soon as someone closes a window is half a log, and the desktop was the half
  //losing them.
  if Assigned(FPrintProc) then
  begin
    FPrintProc(PChar('[BREAKPOINT] ' + bkptMsg + ' (Line ' + IntToStr(srcLine) + ')' + System.sLineBreak));
    for i := 0 to varCount - 1 do
      FPrintProc(PChar('             ' + varNames[i] + ' = ' +
                       varValues[i] + System.sLineBreak));
  end;

  //Two things must hold before the VM may park: someone to ask, and a platform
  //that can answer a thread this very call has already blocked. The engine
  //checks both itself rather than trusting the host to have checked, so a host
  //that assigns ConfirmProc unconditionally cannot hang on Android or iOS. It
  //gets the report above and carries on instead.
  if not (Assigned(FConfirmProc) and CanPauseForHostDialog) then
    Exit();

  //Pause execution until the host answers
  ExecStatus := TExecStatus.esIdle;

  //Suspending whatever the host has running -- timers, animations -- is the
  //host's business, inside its own handler. The engine does not know they exist.
  FConfirmProc(dialogMsg,
    procedure(Confirmed: Boolean)
    begin
      if not Confirmed then
      begin
        //User chose to stop execution
        ended := true;
        if Assigned(FPrintProc) then
          FPrintProc(PChar('[BREAKPOINT] Execution stopped by user' + System.sLineBreak));
      end
      else
      begin
        if Assigned(FPrintProc) then
          FPrintProc(PChar('[BREAKPOINT] Execution resumed' + System.sLineBreak));
      end;
      //Resume execution
      ExecStatus := TExecStatus.esRun;
    end
  );
end;

procedure TExec.fEQ();
begin
  Pop();
  //if StackMem[STKP].n = StackMem[STKP + 1].n then
  if CompareValue(StackMem[STKP].n, StackMem[STKP + 1].n) = 0 then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fEQS();
begin
  Pop();
  if StackMem[STKP].s = StackMem[STKP + 1].s then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
  TypeStack[STKP] := ekNumber;
end;

//Assembly instruction 'ERR'
procedure TExec.fErr();
begin
  FErrorMessage := 'RUNTIME ERROR: '+StrPas(PChar(strConst)+asmProg[PRG_IP].i);
  // FIX #4: Set ended BEFORE raise. The raise transfers control immediately,
  // making any code after it unreachable. Setting ended first ensures the VM
  // stops even if the exception is caught by a callback's try/except block.
  ended := true;
  raise Exception.Create(FErrorMessage);
end;

procedure TExec.fForCycle();
var
  i: Integer;
begin
  i := asmProg[PRG_IP].i;
  if i < 0 then
  begin
    i := i + MAXLOCALS + BASEP;
    StackMem[i].n := StackMem[i].n + StackMem[STKP].n;
    StackMem[STKP].n := StackMem[i].n
  end
  else if GlobalIndexValid(i) then
  begin
    HeapMem[i].n := HeapMem[i].n + StackMem[STKP].n;
    StackMem[STKP].n := HeapMem[i].n;
  end;
end;

procedure TExec.fGE();
begin
  Pop();
  if StackMem[STKP].n >= StackMem[STKP + 1].n then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fGES();
begin
  Pop();
  if StackMem[STKP].s >= StackMem[STKP + 1].s then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
  TypeStack[STKP] := ekNumber;
end;

procedure TExec.fGT();
begin
  Pop();
  if StackMem[STKP].n > StackMem[STKP + 1].n then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fGTS();
begin
  Pop();
  if StackMem[STKP].s > StackMem[STKP + 1].s then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
  TypeStack[STKP] := ekNumber;
end;

//Call a function (near or far) using its signature
procedure TExec.fIndirectCall();
var
  dt: TAsmData;
  FnSignt, FnParams: String;
  n,i: Integer;
  farF: TLinkFunction;
  Args, Params: Array of TAsmData;
begin
  n := Trunc(PopAsmData(ekNumber).n); //Get total of parameters
  if (STKP < n) or (n = 0) then //Stack pointer must be compatible with the total of parameters
  begin
    RTError(rteStackUnderflow, atkNull);
    Exit();
  end;

  try
    SetLength(Params, n-1); //allocate parameters array
  except
    RTError(rteUserMessage, atkNull, 'Out of memory');
    Exit();
  end;

  if n-1 > 0 then
    for i := n - 1 downto 1 do //set the type for each parameter
    begin
      Pop;
      case TypeStack[STKP+1] of
        ekNumber:
        begin
          Params[i-1].n := StackMem[STKP+1].n;
          Params[i-1].p := nil;
          Params[i-1].s := '';
        end;
        ekPointer:
        begin
          Params[i-1].n := 0;
          Params[i-1].p := Pointer(StackMem[STKP+1].p);
          Params[i-1].s := '';
        end;
        ekString:
        begin
          Params[i-1].n := 0;
          Params[i-1].p := nil;
          Params[i-1].s := StackMem[STKP+1].s;
        end;
      end;
    end;
  FnSignt := PopAsmData(ekString).s; //Get the function's signature
  if programFunctions.ContainsKey(FnSignt) then //Check if function exists at the dictionary
  begin
    FnParams := ICallGetParams(FnSignt); //Get the parameters part of the signature
    for i := 0 to FnParams.Length-1 do //For each char...
    begin
      case FnParams.Chars[i] of
        'n': //number
        begin
          dt.n := Params[i].n;
          PushAsmData(dt, ekNumber);
        end;
        '#': //pointer
        begin
          dt.p := Params[i].p;
          PushAsmData(dt, ekPointer);
        end;
        '$': //string
        begin
          dt.s := Params[i].s;
          PushAsmData(dt, ekString);
        end;
      end;
    end;
    dt.n := FnParams.Length; //get the total of parameters pushed
    if Trunc(dt.n) <> n-1 then //validate
    begin
      RTError(rteUserMessage, atkNull, 'Total of arguments mismatch in ICALL instruction');
      Exit();
    end;
    PushAsmData(dt, ekNumber); //Push the total of parameters

    if not programFunctions[FnSignt].FarCall then //"near" function
    begin
      // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
      dt.p := Pointer(NativeInt(PRG_IP + 1)); //Get the next instruction pointer
      PushAsmData(dt, ekPointer); //Push next instruction pointer into the stack (function return)
      PRG_IP := NativeInt(@programFunctions[FnSignt].Entry); //Move PRG_IP to the function entry point
      Exit();
    end;

    //If we reach this point, that's because the function signature points to a
    //"FAR" function.
    farF := programFunctions[FnSignt]; //entry point and flags
    //Value pushed during "FnParams" formation (few lines above)
    n := Trunc(PopAsmData(ekNumber).n);
    try
      SetLength(Args, n); //allocate parameters
    except
      RTError(rteUserMessage, atkNull, 'Out of memory');
      Exit;
    end;
    if (n > 0) then
      for i := n-1 downto 0 do
      begin
        Pop;
        case TypeStack[STKP+1] of
          ekNumber: Args[i].n := StackMem[STKP+1].n;
          ekPointer: Args[i].p := StackMem[STKP+1].p;
          ekString: Args[i].s := StackMem[STKP+1].s;
       end;
      end;
    //Call the FAR function, store result in "dt"
    try
      dt := CallNative(farF, Args);
    except
      on E: Exception do
      begin
        RTError(rteUserMessage, atkNull, 'Far call error (' + FnSignt + '): ' + E.Message);
        Exit;
      end;
    end;
    case ICallReturnType(FnSignt).Chars[0] of
      'n': PushAsmData(dt, ekNumber);
      '#': PushAsmData(dt, ekPointer);
      '$': PushAsmData(dt, ekString);
    end;
    Exit();
  end;
  RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
end;

//procedure TExec.fInitFunc();
//var
//  dt: TAsmData;
//begin
//  dt.p := pointer(BASEP);
//  PushAsmData(dt, ekPointer);
//  BASEP := STKP;
//  Inc(STKP, asmProg[PRG_IP].i);
//end;
procedure TExec.fInitFunc();
var
  dt: TAsmData;
  i, localCount: Integer;
begin
  dt.p := pointer(BASEP);
  PushAsmData(dt, ekPointer);
  BASEP := STKP;
  localCount := asmProg[PRG_IP].i;

  // FIX #3: Bounds check — prevent writing past StackMem/TypeStack arrays.
  // Deep recursion or functions with many locals could overflow MAXSTACK.
  if BASEP + localCount >= MAXSTACK then
  begin
    RTError(rteStackOverflow, atkNull);
    Exit;
  end;

  // Local variables start at BASEP+1 (BASEP holds saved old BASEP).
  // Stack layout: [BASEP] = saved old BASEP, [BASEP+1..] = local variables
  for i := 1 to localCount do
  begin
    StackMem[BASEP + i].n := 0;   // Numbers default to 0
    StackMem[BASEP + i].p := nil; // Pointers default to nil
    StackMem[BASEP + i].s := '';  // Strings default to ""
    TypeStack[BASEP + i] := ekNumber; // FIX #9: Init TypeStack for locals
  end;
  Inc(STKP, localCount);
end;

procedure TExec.fInput();
var
  dt, ret: TAsmData;
  SCaption, FnSignt, stmp: String;
  Value: Extended;
  Args, Params: Array of TAsmData;
  farF: TLinkFunction;
  ALabels, AValues: array of string;
begin
  FnSignt := PopAsmData(ekString).s; //Function signature
  Value := PopAsmData(ekNumber).n; //Numeric default value
  SetLength(AValues, 1); AValues[0] := FloatToStr(Value);
  SetLength(ALabels, 1); ALabels[0] := PopAsmData(ekString).s; //Popup filed label
  sCaption := PopAsmData(ekString).s; //Popup caption

  if programFunctions.ContainsKey(FnSignt) then //Check if function exists at the dictionary
  begin
    try
      try
        //No host to ask: keep the default the program supplied and go on,
        //rather than failing. A console host installs InputProc and reads stdin.
        if not Assigned(FInputProc) then
          Exit();

        FInputProc(sCaption, ALabels, AValues,
          procedure(Confirmed: Boolean; const AValues: array of String)
          begin
            if Confirmed then
            begin
              if not TryStrToFloat(AValues[0], Value) then
                Value := 0.0;

              if not programFunctions[FnSignt].FarCall then //"near" function
              begin
                try
                  SetLength(Params, 1); //allocate parameters array (INPUT command numerical value)
                except
                  RTError(rteUserMessage, atkNull, 'Out of memory');
                  Exit();
                end;
                Params[0].n := Value;
                Params[0].p := nil;
                Params[0].s := '';

                try
                  // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
                  ExecuteFunction(NativeInt(@programFunctions[FnSignt].Entry)+1, 1, [TExprKind.ekNumber], Params, TExprKind.ekNumber, ret);
                  //Push function return value back into the stack
                  PushAsmData(ret, ekNumber);
                except
                  On E: Exception do
                  begin
                    stmp := '*** Exception catched ***'+System.sLineBreak;
                    stmp := stmp + 'Instruction Pointer: [' + IntToStr(PRG_IP) + ']'+System.sLineBreak;
                    stmp := stmp + 'Function entry: [' + IntToStr(NativeInt(@programFunctions[FnSignt].Entry)) + ']'+System.sLineBreak;
                    stmp := stmp + 'Line: ' + IntToStr(SourceLine)+System.sLineBreak;
                    stmp := stmp + 'Exception: "' + E.Message + '"';
                    if Assigned(FPrintProc) then
                      FPrintProc(PChar(stmp));
                  end;
                end;

                Exit(); //End this function
              end;

              //If we reach this point, that's because the function signature points to a
              //"FAR" function.
              farF := programFunctions[FnSignt]; //entry point and flags
              try
                SetLength(Args, 1); //allocate parameters
              except
                RTError(rteUserMessage, atkNull, 'Out of memory');
                Exit();
              end;
              Args[0].n := Value;
              //Call the FAR function, store result in "dt"
              dt := CallNative(farF, Args);
              //Push function return value into the stack
              PushAsmData(dt, ekNumber);
            end;
          end);
      except
        //Unreachable as written before: Exception is the ancestor, so the
        //EInvalidFmxHandle clause that used to follow never fired.
        on E:Exception do
          RTError(rteUserMessage, atkNull, E.Message);
      end;
    finally
      SetLength(AValues, 0);
      SetLength(ALabels, 0);
    end;

    Exit();
  end;
  RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
end;

procedure TExec.fInputS();
var
  dt, ret: TAsmData;
  SCaption, FnSignt, stmp: String;
  Args, Params: Array of TAsmData;
  farF: TLinkFunction;
  ALabels, AValues: array of string;
begin
  FnSignt := PopAsmData(ekString).s;
  SetLength(AValues, 1); AValues[0] := PopAsmData(ekString).s;
  SetLength(ALabels, 1); ALabels[0] := PopAsmData(ekString).s;
  sCaption := PopAsmData(ekString).s;

  if programFunctions.ContainsKey(FnSignt) then //Check if function exists at the dictionary
  begin
    try
      try
        //No host to ask: keep the default the program supplied and go on,
        //rather than failing. A console host installs InputProc and reads stdin.
        if not Assigned(FInputProc) then
          Exit();

        FInputProc(sCaption, ALabels, AValues,
          procedure(Confirmed: Boolean; const AValues: array of String)
          begin
            if Confirmed then
            begin
              if not programFunctions[FnSignt].FarCall then //"near" function
              begin
                try
                  SetLength(Params, 1); //allocate parameters array (INPUT command numerical value)
                except
                  RTError(rteUserMessage, atkNull, 'Out of memory');
                  Exit();
                end;
                Params[0].n := 0;
                Params[0].p := nil;
                Params[0].s := AValues[0];

                try
                  // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
                  ExecuteFunction(NativeInt(@programFunctions[FnSignt].Entry)+1, 1, [TExprKind.ekString], Params, TExprKind.ekString, ret);
                  //Push function return value back into the stack
                  PushAsmData(ret, ekString);
                except
                  on E: Exception do
                  begin
                    stmp := '*** Exception catched ***'+System.sLineBreak;
                    stmp := stmp + 'Instruction Pointer: [' + IntToStr(PRG_IP) + ']'+System.sLineBreak;
                    stmp := stmp + 'Function entry: [' + IntToStr(NativeInt(@programFunctions[FnSignt].Entry)) + ']'+System.sLineBreak;
                    stmp := stmp + 'Line: ' + IntToStr(SourceLine)+System.sLineBreak;
                    stmp := stmp + 'Exception: "' + E.Message + '"';
                    if Assigned(FPrintProc) then
                      FPrintProc(PChar(stmp));
                  end;
                end;

                Exit(); //End this function
              end;

              //If we reach this point, that's because the function signature points to a
              //"FAR" function.
              farF := programFunctions[FnSignt]; //entry point and flags
              try
                SetLength(Args, 1); //allocate parameters
              except
                RTError(rteUserMessage, atkNull, 'Out of memory');
                Exit();
              end;
              Args[0].s := AValues[0];
              //Call the FAR function, store result in "dt"
              dt := CallNative(farF, Args);
              //Push function return value into the stack
              PushAsmData(dt, ekString);
            end;
          end);
      except
        //Unreachable as written before: Exception is the ancestor, so the
        //EInvalidFmxHandle clause that used to follow never fired.
        on E:Exception do
          RTError(rteUserMessage, atkNull, E.Message);
      end;
    finally
      SetLength(AValues, 0);
      SetLength(ALabels, 0);
    end;

    Exit();
  end;
  RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
end;

procedure TExec.fInv();
begin
  StackMem[STKP].n := -StackMem[STKP].n;
end;

procedure TExec.fJump();
begin
  PRG_IP := asmProg[PRG_IP].i - 1;
end;

procedure TExec.fLE();
begin
  Pop();
  if StackMem[STKP].n <= StackMem[STKP + 1].n then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fLES();
begin
  Pop();
  if StackMem[STKP].s <= StackMem[STKP + 1].s then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
  TypeStack[STKP] := ekNumber;
end;

procedure TExec.fLT();
begin
  Pop();
  if StackMem[STKP].n < StackMem[STKP + 1].n then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fLTS();
begin
  Pop();
  if StackMem[STKP].s < StackMem[STKP + 1].s then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
  TypeStack[STKP] := ekNumber;
end;

procedure TExec.fMax();
begin
  Pop();
  if StackMem[STKP + 1].n > StackMem[STKP].n then
    StackMem[STKP].n := StackMem[STKP + 1].n;
end;

procedure TExec.fMin();
begin
  Pop();
  if StackMem[STKP + 1].n < StackMem[STKP].n then
    StackMem[STKP].n := StackMem[STKP + 1].n;
end;

procedure TExec.fMod();
begin
  Pop();
  // CRITICAL FIX: Check for division by zero
  if StackMem[STKP + 1].n = 0 then
  begin
    RTError(rteDivisionByZero, atkNull);
    Exit;
  end;
  StackMem[STKP].n := Frac(StackMem[STKP].n / StackMem[STKP + 1].n) * StackMem[STKP + 1].n;
end;

procedure TExec.fMul();
begin
  Pop();
  StackMem[STKP].n := StackMem[STKP].n * StackMem[STKP + 1].n;
end;

procedure TExec.fNE();
begin
  Pop();
  //if StackMem[STKP].n <> StackMem[STKP + 1].n then
  if CompareValue(StackMem[STKP].n, StackMem[STKP + 1].n) <> 0 then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fNES();
begin
  Pop();
  if StackMem[STKP].s <> StackMem[STKP + 1].s then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
  TypeStack[STKP] := ekNumber;
end;

procedure TExec.fNOp();
begin
  // 'N'ot 'OP'erational
end;

procedure TExec.fNot();
begin
  if StackMem[STKP].n = 0 then
    StackMem[STKP].n := 1
  else
    StackMem[STKP].n := 0;
end;

procedure TExec.fOnCallFar();
var
  dt: TAsmData;
  FnSignt, FnParams: String;
  Args, Params: Array of TAsmData;
  farF: TLinkFunction;
  i, n: Integer;
  Test: Boolean;
begin
  n := Trunc(PopAsmData(ekNumber).n); //Get total of parameters
  FnSignt := PopAsmData(ekString).s; //Get the function signature

  if (STKP < n) or (n = 0) then //Stack pointer must be compatible with the total of parameters
  begin
    RTError(rteStackUnderflow, atkNull);
    Exit();
  end;

  try
    SetLength(Params, n-1); //allocate parameters array
  except
    RTError(rteUserMessage, atkNull, 'Out of memory');
    Exit();
  end;

  if n-1 > 0 then
    for i := n - 1 downto 1 do //set the type for each parameter
    begin
      Pop;
      case TypeStack[STKP+1] of
        ekNumber:
        begin
          Params[i-1].n := StackMem[STKP+1].n;
          Params[i-1].p := nil;
          Params[i-1].s := '';
        end;
        ekPointer:
        begin
          Params[i-1].n := 0;
          Params[i-1].p := Pointer(StackMem[STKP+1].p);
          Params[i-1].s := '';
        end;
        ekString:
        begin
          Params[i-1].n := 0;
          Params[i-1].p := nil;
          Params[i-1].s := StackMem[STKP+1].s;
        end;
      end;
    end;

  Test := PopAsmData(ekNumber).n = 0; //ON..CALL test result

  if programFunctions.ContainsKey(FnSignt) then //Check if function exists at the dictionary
  begin
    FnParams := ICallGetParams(FnSignt); //Get the parameters part of the signature
    for i := 0 to FnParams.Length-1 do //For each char...
    begin
      case FnParams.Chars[i] of
        'n': //number
        begin
          dt.n := Params[i].n;
          PushAsmData(dt, ekNumber);
        end;
        '#': //pointer
        begin
          dt.p := Params[i].p;
          PushAsmData(dt, ekPointer);
        end;
        '$': //string
        begin
          dt.s := Params[i].s;
          PushAsmData(dt, ekString);
        end;
      end;
    end;
    dt.n := FnParams.Length; //get the total of parameters pushed
    if Trunc(dt.n) <> n-1 then //validate
    begin
      RTError(rteUserMessage, atkNull, 'Total of arguments mismatch in ICALL instruction');
      Exit();
    end;

    PushAsmData(dt, ekNumber); //Push the total of parameters

    if not programFunctions[FnSignt].FarCall then //"near" function
    begin
      if Test then
      begin
        // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
        dt.p := Pointer(NativeInt(PRG_IP + 1)); //Get the next instruction pointer
        PushAsmData(dt, ekPointer); //Push next instruction pointer into the stack (function return)
        PRG_IP := NativeInt(@programFunctions[FnSignt].Entry); //Move PRG_IP to the function entry point
      end;
      Exit();
    end;

    //If we reach this point, that's because the function signature points to a
    //"FAR" function.
    farF := programFunctions[FnSignt]; //entry point and flags
    //Value pushed during "FnParams" formation (few lines above)
    n := Trunc(PopAsmData(ekNumber).n);
    try
      SetLength(Args, n); //allocate parameters
    except
      RTError(rteUserMessage, atkNull, 'Out of memory');
      Exit;
    end;
    if (n > 0) then
      for i := n-1 downto 0 do
      begin
        Pop;
        case TypeStack[STKP+1] of
          ekNumber: Args[i].n := StackMem[STKP+1].n;
          ekPointer: Args[i].p := StackMem[STKP+1].p;
          ekString: Args[i].s := StackMem[STKP+1].s;
       end;
      end;

    if Test then
    begin
      //Call the FAR function, store result in "dt"
      try
        dt := CallNative(farF, Args);
      except
        on E: Exception do
        begin
          RTError(rteUserMessage, atkNull, 'Far call error (' + FnSignt + '): ' + E.Message);
          Exit;
        end;
      end;
      case ICallReturnType(FnSignt).Chars[0] of
        'n': PushAsmData(dt, ekNumber);
        '#': PushAsmData(dt, ekPointer);
        '$': PushAsmData(dt, ekString);
      end;
    end;
    Exit();
  end;
  RTError(rteUserMessage, atkNull, 'There is no function with such arguments.');
end;

// FIX #5: Replaced empty stubs with explicit error messages.
// Previously these were silent no-ops — if ever triggered, they would
// silently discard the ON..CALL without any feedback. The parser
// currently only generates ONCALLEX (numeric), but these prevent
// silent data loss if the language is later extended.
procedure TExec.fOnCallFarP();
begin
  RTError(rteUserMessage, atkNull,
    'ON..CALL for pointer-returning functions is not yet implemented');
end;

procedure TExec.fOnCallFarS();
begin
  RTError(rteUserMessage, atkNull,
    'ON..CALL for string-returning functions is not yet implemented');
end;

procedure TExec.fPop();
begin
  if STKP = 0 then
  begin
    RTError(rteStackUnderflow, atkNull);
    Exit;
  end;
  Dec(STKP);
end;

//Pop SELECT aux stack
procedure TExec.fPopAuxStack();
begin
  if AuxStackIdx = 0 then
  begin
    RTError(rteAuxStackUnderflow, atkNull);
    Exit;
  end;
  Dec(AuxStackIdx);
end;

procedure TExec.fPopNCall();
var
  dt: TAsmData;
begin
  if PopAsmData(ekNumber).n = 0 then
  begin
    // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
    dt.p := Pointer(NativeInt(PRG_IP + 1));
    PushAsmData(dt, ekPointer);
    PRG_IP := asmProg[PRG_IP].i - 1;
  end;
end;

procedure TExec.fPopNJump();
begin
  if PopAsmData(ekNumber).n = 0 then
    PRG_IP := asmProg[PRG_IP].i - 1;
end;

//Guards a global variable index before it reaches HeapMem, which is a fixed
//array [0..MAXVARS]. The compiler refuses programs with too many globals
//(see TCompiler.EnumVarsFuncs), so reaching here means the assembly code was
//not produced by that path — hand written or corrupted intermediate code.
//Failing loudly beats corrupting adjacent memory in a Release build.
function TExec.GlobalIndexValid(Index: Integer): Boolean;
begin
  Result := (Index >= 0) and (Index <= MAXVARS);
  if not Result then
    RTError(rteUserMessage, atkNull,
      'Global variable index out of range: ' + IntToStr(Index));
end;

procedure TExec.fPopStore();
var
  i: Integer;
  v: Extended;
begin
  v := PopNum();
  i := asmProg[PRG_IP].i;
  if i < 0 then
    StackMem[BASEP + i + MAXLOCALS].n := v //local
  else if GlobalIndexValid(i) then
    HeapMem[i].n := v; //global
end;

procedure TExec.fPopStorePtr();
var
  i: Integer;
  dt: TAsmData;
begin
  dt := PopAsmData(ekPointer);
  i := asmProg[PRG_IP].i;
  if i < 0 then
    StackMem[BASEP + i + MAXLOCALS].p := dt.p //local
  else if GlobalIndexValid(i) then
    HeapMem[i].p := dt.p; //global
end;

procedure TExec.fPopStoreS();
var
  i: Integer;
  dt: TAsmData;
begin
  dt := PopAsmData(ekString);
  i := asmProg[PRG_IP].i;
  if i < 0 then
    StackMem[BASEP + i + MAXLOCALS].s := dt.s //local
  else if GlobalIndexValid(i) then
    HeapMem[i].s := dt.s; //global
end;

// FIX #8: Added domain validation for power operations.
// Power(negative, fractional) → NaN, Power(0, negative) → Infinity.
// Without this, special values silently propagate through all
// subsequent arithmetic, causing confusing behavior.
procedure TExec.fPow();
var
  base, exponent, r: Extended;
begin
  Pop;
  base := StackMem[STKP].n;
  exponent := StackMem[STKP + 1].n;
  try
    r := Power(base, exponent);
    if IsNan(r) or IsInfinite(r) then
    begin
      RTError(rteUserMessage, atkNull, 'Invalid power operation');
      Exit;
    end;
  except
    on E: Exception do
    begin
      RTError(rteUserMessage, atkNull, 'Invalid power operation: ' + E.Message);
      Exit;
    end;
  end;
  StackMem[STKP].n := r;
end;

procedure TExec.fPrint();
var
  n, i, l: Integer;
  s, sr, st: String;
begin
  n := Round(PopAsmData(ekNumber).n);
  if n = 0 then
  begin
    FPrintProc(PChar(''));
    Exit();
  end;
  if STKP < n then
  begin
    RTError(rtePrintStackOverflow, atkNull);
    Exit();
  end;
  Dec(STKP, n);
  sr := '';
  i := 1;
  repeat
    if i > n then //todos os valores impressos, termina
      break;
    if TypeStack[STKP + i] = ekString then
      st := StackMem[STKP + i].s
    else
      //st := ' ' + FloatToStrF(StackMem[STKP + i].n, ffgeneral, 13, 0) + ' ';
      st := FloatToStrF(StackMem[STKP + i].n, ffgeneral, 13, 0);
    sr := sr + st;
    Inc(i);
    if i > n then
      break;
    //A separator is always pushed as a string, so anything else in this slot is
    //a malformed PRINT. Four lines above, the value read consults TypeStack
    //before choosing which field to read; this one did not, and worked only
    //because every numeric push leaves an empty string behind it in the slot.
    //That was the compiler's doing until PushNum started writing the fields by
    //hand, so it is now an invariant three handlers maintain deliberately --
    //and an invariant maintained by hand is one to stop depending on.
    if TypeStack[STKP + i] <> ekString then
    begin
      RTError(rtePrintSyntaxMismatch, atkNull);
      Exit;
    end;
    s := StackMem[STKP + i].s;
    if (s <> ',') and (s <> ';') then
    begin
      RTError(rtePrintSyntaxMismatch, atkNull);
      Exit;
    end;
    Inc(i);
    if s = ';' then
      Continue;
    //l := 14 - Length(st);
    l := 5 - Length(st);
    while (l < 0) do
      //Inc(l, 14);
      Inc(l, 5);
    sr := sr + format('%-*s', [l, '']);
  until false;

  //Output text first
  FPrintProc(PChar(sr));

  //Throttled UI refresh for better performance in loops with many PRINTs
  //Only refresh if enough time has passed since last refresh
  if not unitGC.SkipProcessMessages then
  begin
    if (FUIRefreshInterval = 0) or
       (TThread.GetTickCount - FLastUIRefresh >= Cardinal(FUIRefreshInterval)) then
    begin
      if Assigned(FYieldProc) then
        FYieldProc();
      FLastUIRefresh := TThread.GetTickCount;
    end;
  end;
end;

//Push numerical var (local or global)
procedure TExec.fPush();
var
  i: Integer;
begin
  i := asmProg[PRG_IP].i;
  if i < 0 then
    PushAsmData(StackMem[BASEP + i + MAXLOCALS], ekNumber) //local var
  else if GlobalIndexValid(i) then
    PushAsmData(HeapMem[i], ekNumber); //global var
end;

//Push numeric value into SELECT aux stack
procedure TExec.fPushAuxStack();
begin
  // CRITICAL FIX: Check BEFORE incrementing to prevent buffer overrun
  if AuxStackIdx >= MAXSTACK - 1 then
  begin
    RTError(rteAuxStackOverflow, atkNull);
    Exit;
  end;
  Inc(AuxStackIdx);
  if TypeStack[STKP]<> ekNumber then
  begin
    RTError(rteAuxStackTypeMismatch, atkNull);
    Dec(AuxStackIdx); // Rollback increment on type mismatch
    Exit();
  end;
  AuxStack[AuxStackIdx].n := StackMem[STKP].n;
  Pop();
  AuxStackTypes[AuxStackIdx] := TExprKind.ekNumber;
end;

//Push string value into SELECT aux stack
procedure TExec.fPushAuxStackS();
begin
  // CRITICAL FIX: Check BEFORE incrementing to prevent buffer overrun
  if AuxStackIdx >= MAXSTACK - 1 then
  begin
    RTError(rteAuxStackOverflow, atkNull);
    Exit;
  end;
  Inc(AuxStackIdx);
  if TypeStack[STKP] <> ekString then
  begin
    RTError(rteAuxStackTypeMismatch, atkNull);
    Dec(AuxStackIdx); // Rollback increment on type mismatch
    Exit();
  end;
  AuxStack[AuxStackIdx].s := StackMem[STKP].s;
  Pop();
  AuxStackTypes[AuxStackIdx] := TExprKind.ekString;
end;

//Push the SELECT aux stack TOS into the data stack. This method **DO NOT** pop
//the SELECT aux stack TOS
procedure TExec.fPushAuxTOS();
var
  dt: TAsmData;
begin
  if AuxStackTypes[AuxStackIdx] = TExprKind.ekNumber then
  begin
    dt.n := AuxStack[AuxStackIdx].n;
    PushAsmData(dt, ekNumber);
  end
  else
  begin
    dt.s := AuxStack[AuxStackIdx].s;
    PushAsmData(dt, ekString);
  end;
end;

//Push numerical constant
procedure TExec.fPushC();
begin
  PushNum(asmProg[PRG_IP].n);
end;

//Push pointer var (local or global)
procedure TExec.fPushPtr();
var
  i: Integer;
begin
  i := asmProg[PRG_IP].i;
  if i < 0 then
    PushAsmData(StackMem[BASEP + i + MAXLOCALS], ekPointer) //local var
  else if GlobalIndexValid(i) then
    PushAsmData(HeapMem[i], ekPointer); //global var
end;

//Push "THIS" object pointer
procedure TExec.fPushPtrTag();
var
  dt: TAsmData;
begin
  dt.p := TagObject;
  PushAsmData(dt, ekPointer);
end;

//Push string var (local or global)
procedure TExec.fPushS();
var
  i: Integer;
begin
  i := asmProg[PRG_IP].i;
  if i < 0 then
    PushAsmData(StackMem[BASEP + i + MAXLOCALS], ekString)
  else if GlobalIndexValid(i) then
    PushAsmData(HeapMem[i], ekString);
end;

//Push string constant
procedure TExec.fPushSC();
var
  dt: TAsmData;
begin
  dt.s := StrPas(PChar(strConst) + asmProg[PRG_IP].i);
  PushAsmData(dt, ekString);
end;

procedure TExec.fRead();
var
  i: Integer;
begin
  if ReadIdx >= DataStmts.Count then
  begin
    RTError(rteUserMessage, atkNull, 'READ past DATA');
    Exit();
  end;

  if DataStmts[ReadIdx].DataType <> 'n' then
  begin
    RTError(rteUserMessage, atkNull, 'Invalid data type for READ instruction');
    Exit();
  end;

  i := asmProg[PRG_IP].i;
  if i < 0 then
    StackMem[BASEP + i + MAXLOCALS].n := asmProg[DataStmts[ReadIdx].DataPos].n //local
  else if GlobalIndexValid(i) then
    HeapMem[i].n := asmProg[DataStmts[ReadIdx].DataPos].n; //global
  Inc(ReadIdx);
end;

procedure TExec.fReadS();
var
  i: Integer;
begin
  if ReadIdx >= DataStmts.Count then
  begin
    RTError(rteUserMessage, atkNull, 'READ past DATA');
    Exit;
  end;

  if DataStmts[ReadIdx].DataType <> '$' then
  begin
    RTError(rteUserMessage, atkNull, 'Invalid data type for READ instruction');
    Exit;
  end;

  i := asmProg[PRG_IP].i;
  if i < 0 then
    StackMem[BASEP + i + MAXLOCALS].s := StrPas(PChar(strConst) + asmProg[DataStmts[ReadIdx].DataPos].i) //local
  else if GlobalIndexValid(i) then
    HeapMem[i].s := StrPas(PChar(strConst) + asmProg[DataStmts[ReadIdx].DataPos].i); //global

  Inc(ReadIdx);
end;

//-----------------------------------------------------------------------------
// REFRESHRATE n - Set UI refresh interval in milliseconds
//-----------------------------------------------------------------------------
procedure TExec.fRefreshRate();
begin
  FUIRefreshInterval := asmProg[PRG_IP].i;
  FLastUIRefresh := 0; //Reset the timer to apply new setting immediately
end;

procedure TExec.fRestore();
begin
  ReadIdx := 0; //Restore READ index
end;

procedure TExec.fRetFunction();
var
  SP, n: Integer;
begin
  SP := STKP;
  STKP := BASEP;
  // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
  //DEFENSIVE FIX: Check for errors after each critical pop to prevent cascading failures
  BASEP := NativeInt(PopAsmData(ekPointer).p);
  if ended then Exit; //Stop if error occurred during pop
  PRG_IP := NativeInt(PopAsmData(ekPointer).p) - 1;
  if ended then Exit; //Stop if error occurred during pop
  n := Round(PopAsmData(ekNumber).n);
  if ended then Exit; //Stop if error occurred during pop
  Dec(STKP, n);
  Inc(STKP);
  TypeStack[STKP] := TypeStack[SP];
  //Field by field; see PopAsmData. Safe when STKP and SP are the same slot,
  //which they can be: three self-assignments are what the whole-record form
  //did too.
  StackMem[STKP].n := StackMem[SP].n;
  StackMem[STKP].p := StackMem[SP].p;
  StackMem[STKP].s := StackMem[SP].s;
end;

procedure TExec.fReturn();
begin
  // HIGH PRIORITY FIX: Use NativeInt for 64-bit compatibility
  PRG_IP := NativeInt(PopAsmData(ekPointer).p) - 1;
end;

procedure TExec.fSub();
begin
  Pop();
  StackMem[STKP].n := StackMem[STKP].n - StackMem[STKP + 1].n;
end;

procedure TExec.fSubS();
var
  i, l: Integer;
begin
  Pop();
  i := Round(StackMem[STKP + 1].n);
  l := Length(StackMem[STKP].s);
  if i > l then
    i := l;
  Delete(StackMem[STKP].s, 1 + l - i, i);
end;

//The three accessors below are called by the host with an index it looked up
//in GlobalVarNames. A stale or wrong index must not read outside HeapMem.
function TExec.GetGlobalNum(const Index: Integer): Extended;
begin
  if (Index < 0) or (Index > MAXVARS) then
    Exit(0);
  Result := HeapMem[Index].n;
end;

function TExec.GetGlobalPtr(const Index: Integer): Pointer;
begin
  if (Index < 0) or (Index > MAXVARS) then
    Exit(nil);
  Result := HeapMem[Index].p;
end;

function TExec.GetGlobalStr(const Index: Integer): String;
begin
  if (Index < 0) or (Index > MAXVARS) then
    Exit('');
  Result := HeapMem[Index].s;
end;

//Debug: Get trace enabled (for legacy compatibility)
function TExec.GetTraceEnabled(): Boolean;
begin
  Result := FTraceLevel > 0;
end;

//Debug: Get variable value as string (actual value, not just type)
function TExec.GetVariableValue(const varName: String): String;
var
  varIndex: Integer;
  lowerName{, displayName}: String;
begin
  Result := '?';

  //Need GlobalVarNames to be set
  if not Assigned(FGlobalVarNames) then
    Exit;

  //Variable names are stored in lowercase with @ prefix
  lowerName := '@' + LowerCase(varName);  // Add @ prefix for lookup

  //Find variable index in GlobalVarNames
  varIndex := FGlobalVarNames.IndexOf(lowerName);

  if varIndex < 0 then
  begin
    Result := '(not found)';
    Exit;
  end;

  //Get value based on variable type (determined by suffix)
  if varName.EndsWith('$') then
  begin
    //String variable
    Result := '"' + HeapMem[varIndex].s + '"';
  end
  else if varName.EndsWith('#') then
  begin
    //Pointer variable
    if HeapMem[varIndex].p = nil then
      Result := 'nil'
    else
      Result := '$' + IntToHex(NativeInt(HeapMem[varIndex].p), 8);
  end
  else
  begin
    //Numeric variable
    Result := FloatToStr(HeapMem[varIndex].n);
  end;
end;

//Debug: Get watched variables info string
function TExec.GetWatchedVariablesInfo(): String;
var
  i: Integer;
  varName, varValue: String;
begin
  Result := '';
  if FWatchList.Count = 0 then
    Exit;

  Result := ' | ';
  for i := 0 to FWatchList.Count - 1 do
  begin
    if i > 0 then
      Result := Result + ', ';
    varName := FWatchList[i];
    varValue := GetVariableValue(varName);
    Result := Result + varName + '=' + varValue;
  end;
end;

//Auxiliary method. Return function arguments types
function TExec.ICallGetParams(signature: String): String;
var
  sepPos: Integer;
begin
  sepPos := signature.IndexOf('@');
  if sepPos < 1 then Exit('');
  Exit(signature.Substring(sepPos+1).ToLower());
end;

//Auxiliary method. Get function return type based on signature
function TExec.ICallReturnType(signature: String): String;
var
  sepPos: Integer;
begin
  sepPos := signature.IndexOf('@'); //find position of '@'
  if sepPos < 1 then Exit('');
  case signature.Chars[sepPos-1] of
    '#':
    begin
      Result := '#';
      if (sepPos < 2) then Result := '';
    end;
    '$':
    begin
      Result := '$';
      if (sepPos < 2) then Result := '';
    end;
    else Result := 'n';
  end;
end;

procedure TExec.LoadSource(ls: TStringTokens);
var
  ok: Boolean;
  p: Integer;
  s: String;
  atk: TAsmToken;
  i, n: Integer;
begin
  strConst := ''; s := '';
  n := ls.count;
  FTotInsts := n; //used by property 'TotalASMInst'

  // PHASE 4: Always allocate to exact size needed (n+1 for END instruction)
  // This replaces the conditional allocation and ensures no wasted memory
  try
    SetLength(asmProg, n + 1);
  except
    on E:Exception do
    begin
      FErrorMessage := 'ERROR. Not enough memory for program execution: '+E.Message;
      ended := true;
      Exit;
    end;
  end;

  asmProg[n].token := atkEnd;
  asmProg[n].proc := fEnd;
  if n = 0 then Exit;
  for i := 0 to n - 1 do
  begin
    asmLexer.LoadLine(PChar(ls[i].Str));
    asmLexer.Advance(s, p, atk);
    asmProg[i].token := atk;
    asmProg[i].proc := TokenToFunc(atk);
    asmLexer.Advance(s, p, atk);
    if atk in [atkInteger, atkFloat] then
      asmProg[i].n := TUtils.StrToFloat2(s, ok)
    else
      asmProg[i].n := 0;

    if atk = atkInteger then
      asmProg[i].i := StrToInt(s)
    else
      asmProg[i].i := 0;

    if atk = atkString then
    begin
      asmProg[i].i := Length(strConst);
      strConst := strConst + s + #0;
    end;
  end;
  ResolveFarCalls();
end;

//Turn every native call site's signature into an index into FFarTable, once.
//
//The dictionary is complete and frozen before this runs: the parser fills
//exec.ProgramFunctions inside Compile, which returns before basic.pas calls
//LoadSource. So the lookup that each CALLEX was repeating on every execution
//can be done here instead, and asmProg[i].i stops being an offset into the
//string pool and becomes a row in this table.
//
//A signature that is not registered is RECORDED, not reported. LoadIntermediate
//is public and bypasses the parser's compile-time check, so a program can
//arrive here naming a function that does not exist -- and an error raised now
//would be discarded anyway, because ExecuteProgram calls Clear and Clear resets
//`ended` to false. It has to fire when the call is reached, which is also where
//it always fired.
procedure TExec.ResolveFarCalls();
var
  i, n: Integer;
  sign: String;
begin
  n := 0;
  for i := 0 to High(asmProg) do
    if asmProg[i].token in [atkCallFar, atkCallFarP, atkCallFarS] then
      Inc(n);
  SetLength(FFarTable, n);
  if n = 0 then
    Exit();
  n := 0;
  for i := 0 to High(asmProg) do
    if asmProg[i].token in [atkCallFar, atkCallFarP, atkCallFarS] then
    begin
      sign := StrPas(PChar(strConst) + asmProg[i].i);
      FFarTable[n].Name := sign;
      FFarTable[n].Known := ProgramFunctions.TryGetValue(sign, FFarTable[n].Fn);
      asmProg[i].i := n;
      Inc(n);
    end;
end;

//Claim the next argument buffer for a call taking n arguments, and return its
//level. The caller must Dec(FArgDepth) when the call is done, from a finally.
//
//Returns -1 for a call that does not fit -- too many arguments, or too deeply
//nested -- and the caller then allocates, exactly as every call used to.
function TExec.AcquireArgs(n: Integer): Integer;
begin
  if (n > ARGBUF_WIDTH) or (FArgDepth >= ARGBUF_DEPTH) then
    Exit(-1);
  Result := FArgDepth;
  Inc(FArgDepth);
end;

//Move one argument off the stack into a cell.
//
//Shared by both paths above so that the buffered call and the allocated one
//cannot drift apart: two copies of this would be two places to fix the day a
//fourth kind of value exists.
procedure TExec.TakeArg(var cell: TAsmData);
begin
  Pop;
  case TypeStack[STKP + 1] of
    ekNumber:
    begin
      cell.n := StackMem[STKP + 1].n;
      cell.p := nil;
      cell.s := '';
    end;
    ekPointer:
    begin
      cell.n := 0;
      cell.p := Pointer(StackMem[STKP + 1].p);
      cell.s := '';
    end;
    ekString:
    begin
      cell.n := 0;
      cell.p := nil;
      cell.s := StackMem[STKP + 1].s;
    end;
  end;
end;

//Pop and discard
procedure TExec.Pop();
begin
  if STKP = 0 then
  begin
    RTError(rteStackUnderflow, atkNull);
    Exit;
  end;
  // NOTE: Do NOT clear StackMem[STKP] here! Many instructions (fAddS, fEQS,
  // fGES, fSubS, etc.) call Pop() to combine two stack values and then read
  // the old top-of-stack at StackMem[STKP+1] immediately after. Clearing
  // the string field here would destroy the operand before it can be used.
  Dec(STKP);
end;

//Pop a data cell (TAsmData) from stack. Uses "TypeStack" to validate the type
//of the popped information.
function TExec.PopAsmData(checkType: TExprKind): TAsmData;
begin
  //DEFENSIVE FIX: Check for underflow BEFORE reading the stack
  //This prevents returning garbage data and helps identify stack issues
  if STKP = 0 then
  begin
    Result.n := 0;
    Result.p := nil;
    Result.s := '';
    RTError(rteStackUnderflow, atkNull);
    Exit;
  end;
  //Field by field rather than `Result := StackMem[STKP]`. A record holding a
  //managed field turns a whole-record assignment into a call to
  //System.@CopyRecord, which walks the record's RTTI field table at run time:
  //7.85 ns measured, against 2.45 ns for these same three writes. It is the
  //RTTI walk being paid for and not the reference count -- a record whose only
  //field is the String still costs 5.85 ns, more than three separate writes.
  Result.n := StackMem[STKP].n;
  Result.p := StackMem[STKP].p;
  Result.s := StackMem[STKP].s;
  if TypeStack[STKP] <> checkType then
  begin
    RTError(rteStackTypeMismatch, atkNull);
    Exit;
  end;
  Dec(STKP);
end;

//Pop a number, with the same type check, without moving a record to do it.
//
//PopAsmData returns a TAsmData by value: the caller gets a hidden local that
//must be finalised, and the assignment inside is the RTTI walk described above,
//all to carry one Extended. The two early exits below are PopAsmData's, in the
//same order and with the same behaviour -- and in particular NEITHER of them
//decrements STKP, which callers depend on.
function TExec.PopNum(): Extended;
begin
  if STKP = 0 then
  begin
    Result := 0;
    RTError(rteStackUnderflow, atkNull);
    Exit;
  end;
  Result := StackMem[STKP].n;
  if TypeStack[STKP] <> ekNumber then
  begin
    RTError(rteStackTypeMismatch, atkNull);
    Exit;
  end;
  Dec(STKP);
end;

//Push a number without building a TAsmData to hold it.
//
//A `dt: TAsmData` local in a handler is a managed local: the compiler zeroes it
//on entry and wraps the whole routine in an implicit try/finally to finalise it
//on the way out. Three of the hottest handlers were paying that to carry one
//Extended into PushAsmData, which then copied three fields back out again.
procedure TExec.PushNum(const v: Extended);
begin
  if STKP >= MAXSTACK - 1 then
  begin
    RTError(rteStackOverflow, atkNull);
    Exit;
  end;
  Inc(STKP);
  StackMem[STKP].n := v;
  //Both of the next two lines were the compiler's work until now: the managed
  //local arrived zeroed and PushAsmData copied all three fields over the slot.
  //Writing fields directly means writing all of them.
  //
  //The string is load-bearing here and not obviously so. fPrint reads
  //StackMem[..].s for a separator without consulting TypeStack, and works today
  //only because a numeric push copies an empty string over whatever the slot
  //held. Leaving a stale string would put the previous value's text into a
  //PRINT, which is a wrong answer rather than a crash.
  StackMem[STKP].s := '';
  //Nothing reads .p from a numeric cell, so this is not load-bearing -- it is
  //here so the cell means one thing. A slot that says "number" while carrying
  //the previous occupant's pointer is the kind of state that makes the next
  //defect take a week.
  StackMem[STKP].p := nil;
  TypeStack[STKP] := ekNumber;
end;

//Push a data cell (TAsmdata) into the stack
procedure TExec.PushAsmData(const dt: TAsmData; st: TExprKind);
begin
  // CRITICAL FIX: Check BEFORE incrementing to prevent buffer overrun
  if STKP >= MAXSTACK - 1 then
  begin
    RTError(rteStackOverflow, atkNull);
    Exit;
  end;
  Inc(STKP);
  //Field by field, for the reason spelled out in PopAsmData above: the
  //whole-record form is a run-time RTTI walk, and this is the single hottest
  //line in the engine.
  StackMem[STKP].n := dt.n;
  StackMem[STKP].p := dt.p;
  StackMem[STKP].s := dt.s;
  TypeStack[STKP] := st;
end;

procedure TExec.RTError(msg: TRTErrors; unkInstr: TAsmToken; auxMsg: String);
var
  ErrMsg: array[TRTErrors] of String;
  ErrLine: String;
begin
  ErrMsg[rteStackOverflow] := 'Stack overflow';
  ErrMsg[rteStackUnderflow] := 'Stack underflow';
  ErrMsg[rteStackTypeMismatch] := 'Stack type mismatch';
  ErrMsg[rteInvalidParams] := 'Invalid parameters during instruction call';
  ErrMsg[rteDimIndexBound] := 'Index out of bounds';
  ErrMsg[rtePrintStackOverflow] := 'Print stack overflow';
  ErrMsg[rtePrintSyntaxMismatch] := 'PRINT syntax mismatch';
  ErrMsg[rteAuxStackTypeMismatch] := 'Type mismatch in auxiliary stack';
  ErrMsg[rteAuxStackOverflow] := 'Auxiliary stack overflow';
  ErrMsg[rteAuxStackUnderflow] := 'Auxiliary stack underflow';
  ErrMsg[rteDivisionByZero] := 'Division by zero';
  ErrMsg[rteUnknownInstr] := 'Unknown instruction';
  ErrMsg[rteStringSize] := 'Invalid string size';
  ErrMsg[rteUserMessage] := auxMsg;
  ErrLine := '*** RUNTIME ERROR ***' + System.SlineBreak + 'ASM[' + IntToStr(PRG_IP) + '] BP['+IntToStr(BASEP)+'] ' + 'Source[' + IntToStr(srcLine) + ']' +' - "' + ErrMsg[msg]+'"';

  if msg = rteUnknownInstr then
    ErrLine := ErrLine+' : unknown instruction:['+IntToStr(Integer(unkInstr))+']';
  FErrorMessage := ErrLine;
  ended := true;

  if Assigned(FPrintProc) then
    FPrintProc(PChar(ErrLine));
end;

procedure TExec.Stop();
begin
  ended := true;
end;

function TExec.TokenToFunc(tk: TAsmToken): TExeFunc;
begin
  Result := fNOp;
  case tk of
    atkPush: Result := fPush;
    atkInitFunc: Result := fInitFunc;
    atkPushC: Result := fPushC;
    atkPushS: Result := fPushS;
    atkPushCS: Result := fPushSC;
    atkPushPtr: Result := fPushPtr;
    atkPushPtrTag: Result := fPushPtrTag;
    atkPop: Result := fPop;
    atkAdd: Result := fAdd;
    atkSub: Result := fSub;
    atkMul: Result := fMul;
    atkDiv: Result := fDiv;
    atkMin: Result := fMin;
    atkMax: Result := fMax;
    atkPow: Result := fPow;
    atkInv: Result := fInv;
    atkMod: Result := fMod;
    atkGe: Result := fGE;
    atkGt: Result := fGT;
    atkLe: Result := fLE;
    atkLt: Result := fLT;
    atkNe: Result := fNE;
    atkEq: Result := fEQ;
    atkNot: Result := fNot;
    atkOr: Result := fAdd;
    atkAnd: Result := fMul;
    atkGes: Result := fGES;
    atkGts: Result := fGTS;
    atkLes: Result := fLES;
    atkLts: Result := fLTS;
    atkNes: Result := fNES;
    atkEqs: Result := fEQS;
    atkAdds: Result := fAddS;
    atkAppendS: Result := fAppendS;
    atkSubs: Result := fSubS;
    atkAddcrlfs: Result := fAddCRLFS;
    atkRead: Result := fRead;
    atkReadS: Result := fReadS;
    atkRefreshRate: Result := fRefreshRate;
    atkRestore: Result := fRestore;
    atkPopStore: Result := fPopStore;
    atkPopstoreS: Result := fPopStoreS;
    atkPopStorePtr: Result := fPopStorePtr;
    atkRetFunction: Result := fRetFunction;
    atkForcycle: Result := fForCycle;
    atkCallNear: Result := fCallNear;
    atkCallFar: Result := fCallFar;
    atkCallFarP: Result := fCallFarP;
    atkCallFarS: Result := fCallFarS;
    atkOnCallFar: Result := fOnCallFar;
    atkOnCallFarP: Result := fOnCallFarP;
    atkOnCallFarS: Result := fOnCallFarS;
    atkReturn: Result := fReturn;
    atkJump: Result := fJump;
    atkPopnCall: Result := fPopNCall;
    atkPopnjump: Result := fPopNJump;
    atkPrint: Result := fPrint;
    atkErr: Result := fErr;
    atkComma: Result := fComma;
    // FIX #15: Added atkPause to NOP list. Token was defined and recognized
    // by the asm lexer but unmapped, causing rteUnknownInstr if triggered.
    atkComment, atkNop, atkPause, atkInteger, atkEndIf, atkRepeat, atkEndFunction: Result := fNop;
    atkEnd: Result := fEnd;
    atkCls: Result := fCls;
    //atkFnAddress: Result := fFnAddr;
    atkIndirectCall: Result := fIndirectCall;
    atkPushAux: Result := fPushAuxStack;
    atkPushAuxS: Result := fPushAuxStackS;
    atkPopAux: Result := fPopAuxStack;
    atkPushAuxTOS: Result := fPushAuxTOS;
    atkInput: Result := fInput;
    atkInputS: Result := fInputS;
    //Debug instructions
    atkAssert: Result := fAssert;
    atkBreakpoint: Result := fBreakpoint;
    atkDump: Result := fDump;
    atkTrace: Result := fTrace;
    atkTraceOn: Result := fTraceOn;
    atkTraceOff: Result := fTraceOff;
    atkWatch: Result := fWatch;
    atkUnwatch: Result := fUnwatch;
  else
    RTError(rteUnknownInstr, tk);
  end;
end;

end.

