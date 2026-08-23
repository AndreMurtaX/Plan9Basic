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
unit GuiUtils;

{******************************************************************************
  GuiUtils - helpers that need FireMonkey

  This exists so that UnitUtils does not. Everything else in UnitUtils works on
  strings, numbers, dates and RTTI; only this one helper needed an FMX TBitmap,
  and carrying it forced the whole engine to link FireMonkey.

  Anything added here must genuinely require FMX. If it does not, it belongs in
  UnitUtils, which the engine can use from a console or a service.
******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClientComponent,
  FMX.Graphics;

type
  TGuiUtils = class(TObject)
  public
    //Downloads an image and loads it into Bitmap. False on any failure.
    class function LoadImageFromWeb(url: String; Bitmap: TBitmap): Boolean;
  end;

implementation

class function TGuiUtils.LoadImageFromWeb(url: String; Bitmap: TBitmap): Boolean;
var
  ms: TMemoryStream;
  httpCli: TNetHTTPClient;
begin
  Result := true;

  httpCli := TNetHTTPClient.Create(nil);
  ms := TMemoryStream.Create();
  try
    try
      httpCli.Get(url, ms);
      ms.Position := 0;
      Bitmap.LoadFromStream(ms);
    except
      Result := false;
    end;
  finally
    ms.Free();
    httpCli.Free();
  end;
end;

end.
