{******************************************************************************
  Plan9Basic Interpreter Engine

  MIT License
  Copyright (c) 2026 André Murta

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
{******************************************************************************
  HandleRegistry - validation of BASIC object handles

  The BASIC language hands objects to programs as raw pointers, and lets a
  program fabricate one with pointer#(n). The libraries used to validate such a
  pointer with

      if not (TObject(P) is TBasButton) then ...

  wrapped in try/except. That dereferences whatever address the program
  supplied. On Windows the resulting access violation is catchable, so the
  damage is contained; on Android and Linux a SIGSEGV is normally NOT converted
  into a Delphi exception and the process dies outright.

  This registry removes the dereference. Every object handed out as a handle
  registers itself on construction, together with its class, and unregisters on
  destruction. Validation is then a dictionary lookup on the pointer VALUE, and
  the class comparison uses the class recorded at registration time, so an
  unknown pointer is never followed.

  Objects must unregister from their destructor rather than from the library
  that created them: FMX frees child controls through parent ownership, and the
  library never sees those frees.

  Usage:

    constructor TBasButton.Create(AOwner: TComponent);
    begin
      inherited Create(AOwner);
      RegisterHandle(Self);
      ...
    end;

    destructor TBasButton.Destroy();
    begin
      UnregisterHandle(Self);
      ...
      inherited Destroy();
    end;

    function ValidateButton(P: Pointer; const FuncName: String): Boolean;
    begin
      Result := IsHandleOf(P, TBasButton);
      ...
    end;
******************************************************************************}
unit HandleRegistry;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs;

type
  THandleRegistry = class;

  //Receives the notification TComponent sends when it is about to be destroyed.
  //Objects that the libraries create but do not own -- FMX effects, and any
  //control freed through its parent -- never pass through a destructor this
  //code controls, so this is how their handles get revoked.
  THandleWatcher = class(TComponent)
  private
    FRegistry: THandleRegistry;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  end;

  THandleRegistry = class(TObject)
  private
    //Maps the pointer VALUE to the class it had when registered. Keeping the
    //class here is what makes validation possible without dereferencing.
    FItems: TDictionary<Pointer, TClass>;
    FLock: TCriticalSection;
    FWatcher: THandleWatcher;
  public
    constructor Create();
    destructor Destroy(); override;

    procedure Add(Obj: TObject);
    procedure Remove(Obj: TObject);

    //True when P is a live registered object.
    function IsValid(P: Pointer): Boolean;
    //True when P is a live registered object of AClass or a descendant.
    function IsValidAs(P: Pointer; AClass: TClass): Boolean;
    //Class recorded for P, or nil when P is not registered.
    function ClassOf(P: Pointer): TClass;

    function Count(): Integer;
  end;

var
  Handles: THandleRegistry = nil;

//Thin wrappers so call sites stay short and tolerate a nil registry during
//unit finalization.
procedure RegisterHandle(Obj: TObject); inline;
procedure UnregisterHandle(Obj: TObject); inline;
function IsHandle(P: Pointer): Boolean; inline;
function IsHandleOf(P: Pointer; AClass: TClass): Boolean; inline;

implementation

{ THandleWatcher }

procedure THandleWatcher.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and Assigned(FRegistry) then
    FRegistry.Remove(AComponent);
  inherited Notification(AComponent, Operation);
end;

{ THandleRegistry }

constructor THandleRegistry.Create();
begin
  inherited Create();
  FItems := TDictionary<Pointer, TClass>.Create();
  FLock := TCriticalSection.Create();
  FWatcher := THandleWatcher.Create(nil);
  FWatcher.FRegistry := Self;
end;

destructor THandleRegistry.Destroy();
begin
  FLock.Enter();
  try
    FItems.Free();
    FItems := nil;
  finally
    FLock.Leave();
  end;
  FLock.Free();
  //Detached first: from here on a late notification must not reach a freed
  //registry.
  FWatcher.FRegistry := nil;
  FWatcher.Free();
  inherited Destroy();
end;

procedure THandleRegistry.Add(Obj: TObject);
begin
  if (Obj = nil) or (FItems = nil) then
    Exit();
  FLock.Enter();
  try
    //AddOrSetValue, not Add: a previous object may have lived at this address
    //and failed to unregister. Overwriting keeps the registry truthful.
    FItems.AddOrSetValue(Pointer(Obj), Obj.ClassType);
  finally
    FLock.Leave();
  end;
  //Outside the lock: FreeNotification touches the component's own list, and
  //holding this lock across it buys nothing.
  if Assigned(FWatcher) and (Obj is TComponent) then
    TComponent(Obj).FreeNotification(FWatcher);
end;

procedure THandleRegistry.Remove(Obj: TObject);
begin
  if (Obj = nil) or (FItems = nil) then
    Exit();
  FLock.Enter();
  try
    FItems.Remove(Pointer(Obj));
  finally
    FLock.Leave();
  end;
end;

function THandleRegistry.IsValid(P: Pointer): Boolean;
begin
  Result := False;
  if (P = nil) or (FItems = nil) then
    Exit();
  FLock.Enter();
  try
    Result := FItems.ContainsKey(P);
  finally
    FLock.Leave();
  end;
end;

function THandleRegistry.IsValidAs(P: Pointer; AClass: TClass): Boolean;
var
  Stored: TClass;
begin
  Result := False;
  if (P = nil) or (AClass = nil) or (FItems = nil) then
    Exit();
  FLock.Enter();
  try
    if FItems.TryGetValue(P, Stored) then
      //Stored comes from the registry, never from the caller's pointer, so no
      //dereference of P happens anywhere in this path.
      Result := (Stored <> nil) and Stored.InheritsFrom(AClass);
  finally
    FLock.Leave();
  end;
end;

function THandleRegistry.ClassOf(P: Pointer): TClass;
begin
  Result := nil;
  if (P = nil) or (FItems = nil) then
    Exit();
  FLock.Enter();
  try
    FItems.TryGetValue(P, Result);
  finally
    FLock.Leave();
  end;
end;

function THandleRegistry.Count(): Integer;
begin
  Result := 0;
  if FItems = nil then
    Exit();
  FLock.Enter();
  try
    Result := FItems.Count;
  finally
    FLock.Leave();
  end;
end;

{ wrappers }

procedure RegisterHandle(Obj: TObject);
begin
  if Assigned(Handles) then
    Handles.Add(Obj);
end;

procedure UnregisterHandle(Obj: TObject);
begin
  if Assigned(Handles) then
    Handles.Remove(Obj);
end;

function IsHandle(P: Pointer): Boolean;
begin
  Result := Assigned(Handles) and Handles.IsValid(P);
end;

function IsHandleOf(P: Pointer; AClass: TClass): Boolean;
begin
  Result := Assigned(Handles) and Handles.IsValidAs(P, AClass);
end;

initialization
  Handles := THandleRegistry.Create();

finalization
  //Objects still alive at this point can no longer unregister; the nil guards
  //in the wrappers make that harmless.
  FreeAndNil(Handles);

end.
