unit HostServices;

{******************************************************************************
  Platform services the engine asks for rather than reaches for.

  Three units under engine/ used to import FireMonkey directly: StdLib for
  processmessages() and handlemessage(), StrLib for the clipboard. That is the
  entire reason engine/ could not link without a windowing framework, and it
  cost more than tidiness -- a console host, a service, a test runner or a
  future non-FMX front end had to drag in 58 FMX units to call left$().

  These are not per-engine state. A clipboard is one resource belonging to the
  process, and so is the message loop, so they are set once by the host rather
  than carried on every TExec. That is the distinction worth keeping: this is
  not a return of the per-module globals Phase 2.2 removed, where 35 libraries
  each held their own copy of an engine reference.

  Unassigned means the service does not exist here, which is a real answer and
  not a failure. A headless test runner has no clipboard; asking for one gets
  ERR_CLIPBOARD_ERROR, exactly as it did when the platform service was missing.
******************************************************************************}

interface

type
  //Hands the host a string to place on the system clipboard.
  TClipboardSetProc = procedure(const AText: string) of object;
  //Answers with the system clipboard's text, or '' when it holds none.
  TClipboardGetFunc = function: string of object;
  //Lets the host's event loop run. Whether that returns immediately or waits
  //for one message is the caller's business, hence two of them.
  TPumpProc = procedure of object;

var
  //Set by the host during start-up. Left nil, the corresponding language
  //function reports the service as unavailable.
  SetClipboardText: TClipboardSetProc = nil;
  GetClipboardText: TClipboardGetFunc = nil;
  //processmessages(): drain what is pending and return.
  PumpMessages: TPumpProc = nil;
  //handlemessage(): wait for one message, then return.
  HandleOneMessage: TPumpProc = nil;

implementation

end.
