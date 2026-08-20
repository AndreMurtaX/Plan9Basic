{******************************************************************************
  LoopbackServer - the HTTP server the verb tests talk to.

  HttpLib's verbs, transfers and response accessors cannot be tested without
  something to answer them. Until now that something was httpbin.org: a third
  party, reachable only with a network, slow enough to matter, and able to make
  the build red by being down. The five HTTP applets in Examples/ have used it
  since they were written, which is why a full verification contacts four
  outside hosts and takes minutes.

  This answers the same shapes on 127.0.0.1, so the HTTP verbs stop being a step
  that gets skipped and become one that always runs.

  The endpoints mirror httpbin's, because that is the contract the tests and the
  applets were already written against:

    /get /post /put /patch /delete   echo the method, the body and the headers
    /status/N                        answer N and nothing else
    /redirect/N                      302 to /get, N hops
    /response-headers?k=v            set every query pair as a response header
    /cookies/set?k=v                 set every query pair as a cookie
    /bytes/N                         N bytes of binary
    /quit                            stop the server

  Started and stopped by tools/verify.ps1. It binds to the loopback address
  only, so nothing outside this machine can reach it.
******************************************************************************}
program LoopbackServer;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.StrUtils,
  IdHTTPServer,
  IdCustomHTTPServer,
  IdContext,
  IdGlobal;

type
  TLoopback = class
  private
    FServer: TIdHTTPServer;
    FDone: Boolean;
    procedure Command(AContext: TIdContext;
                      ARequest: TIdHTTPRequestInfo;
                      AResponse: TIdHTTPResponseInfo);
  public
    constructor Create(APort: Integer);
    destructor Destroy(); override;
    procedure Run();
  end;

//A JSON rendering of what arrived, in the shape httpbin uses -- the tests read
//"url" out of it, and the mirrored body has to appear somewhere findable.
function Mirror(ARequest: TIdHTTPRequestInfo): String;
var
  Body: String;
  i: Integer;
  Headers: String;
begin
  Body := '';
  if Assigned(ARequest.PostStream) then
  begin
    ARequest.PostStream.Position := 0;
    Body := ReadStringFromStream(ARequest.PostStream);
  end
  else if ARequest.UnparsedParams <> '' then
    Body := ARequest.UnparsedParams;

  Headers := '';
  for i := 0 to ARequest.RawHeaders.Count - 1 do
  begin
    if Headers <> '' then
      Headers := Headers + ', ';
    Headers := Headers + '"' + IntToStr(i) + '": "' +
               StringReplace(ARequest.RawHeaders[i], '"', '''', [rfReplaceAll]) + '"';
  end;

  Result := '{' +
    '"url": "http://127.0.0.1' + ARequest.URI + '", ' +
    '"method": "' + ARequest.Command + '", ' +
    '"data": "' + StringReplace(Body, '"', '''', [rfReplaceAll]) + '", ' +
    '"form": "' + StringReplace(Body, '"', '''', [rfReplaceAll]) + '", ' +
    '"headers": {' + Headers + '}' +
    '}';
end;

constructor TLoopback.Create(APort: Integer);
begin
  inherited Create();
  FServer := TIdHTTPServer.Create(nil);
  FServer.DefaultPort := APort;
  //Loopback only. A test server that answers the network is a test server
  //somebody else can reach.
  FServer.Bindings.Add.IP := '127.0.0.1';
  FServer.Bindings[0].Port := APort;
  FServer.OnCommandGet := Command;
  FServer.OnCommandOther := Command;
end;

destructor TLoopback.Destroy();
begin
  FServer.Active := False;
  FServer.Free();
  inherited Destroy();
end;

procedure TLoopback.Command(AContext: TIdContext;
                            ARequest: TIdHTTPRequestInfo;
                            AResponse: TIdHTTPResponseInfo);
var
  Path, Rest, Key, Value: String;
  Count, Code, i: Integer;
  Bytes: TIdBytes;
  Pairs: TArray<String>;
  Pair: String;
begin
  Path := LowerCase(ARequest.Document);
  AResponse.ContentType := 'application/json';

  if Path = '/quit' then
  begin
    AResponse.ResponseNo := 200;
    AResponse.ContentText := 'stopping';
    FDone := True;
    Exit();
  end;

  //  /status/N -- the code asked for, and nothing else worth reading.
  if Path.StartsWith('/status/') then
  begin
    Rest := Copy(Path, Length('/status/') + 1, MaxInt);
    if not TryStrToInt(Rest, Code) then
      Code := 400;
    AResponse.ResponseNo := Code;
    AResponse.ContentText := '';
    Exit();
  end;

  //  /redirect/N -- N hops, then /get. Answered as 302 so a client that does
  //  not follow can still report where it was being sent.
  if Path.StartsWith('/redirect/') then
  begin
    Rest := Copy(Path, Length('/redirect/') + 1, MaxInt);
    if not TryStrToInt(Rest, Count) then
      Count := 1;
    AResponse.ResponseNo := 302;
    if Count <= 1 then
      AResponse.CustomHeaders.Values['Location'] := '/get'
    else
      AResponse.CustomHeaders.Values['Location'] :=
        '/redirect/' + IntToStr(Count - 1);
    AResponse.ContentText := '';
    Exit();
  end;

  //  /response-headers?k=v -- every pair becomes a header on the way back.
  if Path = '/response-headers' then
  begin
    Pairs := ARequest.QueryParams.Split(['&']);
    for Pair in Pairs do
    begin
      i := Pos('=', Pair);
      if i > 0 then
      begin
        Key := Copy(Pair, 1, i - 1);
        Value := Copy(Pair, i + 1, MaxInt);
        AResponse.CustomHeaders.Values[Key] := Value;
      end;
    end;
    AResponse.ResponseNo := 200;
    AResponse.ContentText := '{"ok": true}';
    Exit();
  end;

  //  /cookies/set?k=v -- every pair becomes a cookie.
  if Path = '/cookies/set' then
  begin
    Pairs := ARequest.QueryParams.Split(['&']);
    for Pair in Pairs do
    begin
      i := Pos('=', Pair);
      if i > 0 then
        AResponse.Cookies.AddClientCookie(
          Copy(Pair, 1, i - 1) + '=' + Copy(Pair, i + 1, MaxInt) + '; Path=/');
    end;
    AResponse.ResponseNo := 200;
    AResponse.ContentText := '{"ok": true}';
    Exit();
  end;

  //  /bytes/N -- N bytes that are not text, so a base64 body has something to
  //  be base64 of.
  if Path.StartsWith('/bytes/') then
  begin
    Rest := Copy(Path, Length('/bytes/') + 1, MaxInt);
    if not TryStrToInt(Rest, Count) then
      Count := 0;
    SetLength(Bytes, Count);
    for i := 0 to Count - 1 do
      Bytes[i] := Byte(i mod 256);
    AResponse.ContentType := 'application/octet-stream';
    AResponse.ContentStream := TMemoryStream.Create();
    //WriteBuffer, not WriteData: the latter has a single-byte overload that
    //quietly wins here and writes one byte where N were meant.
    if Count > 0 then
      AResponse.ContentStream.WriteBuffer(Bytes[0], Count);
    AResponse.ContentStream.Position := 0;
    AResponse.ResponseNo := 200;
    Exit();
  end;

  //  /get /post /put /patch /delete, and anything else: mirror the request.
  AResponse.ResponseNo := 200;
  AResponse.ContentText := Mirror(ARequest);
end;

procedure TLoopback.Run();
begin
  FServer.Active := True;
  Writeln('loopback listening on 127.0.0.1:', FServer.DefaultPort);
  Flush(Output);
  while not FDone do
    Sleep(50);
  FServer.Active := False;
end;

var
  Port: Integer;
  Srv: TLoopback;
begin
  try
    if (ParamCount < 1) or (not TryStrToInt(ParamStr(1), Port)) then
      Port := 8731;
    Srv := TLoopback.Create(Port);
    try
      Srv.Run();
    finally
      Srv.Free();
    end;
  except
    on E: Exception do
    begin
      Writeln('loopback failed: ', E.Message);
      Flush(Output);
      Halt(1);
    end;
  end;
end.
