unit TranslationManager;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.IniFiles, System.Generics.Collections,
  FMX.Dialogs;

type
  TTranslationManager = class
  private
    FTranslations: TDictionary<string, string>;
    FIniFile: TIniFile;
    FLanguage: string;
    procedure LoadLanguage(const LangCode: string);
  public
    constructor Create(const FileName: string);
    destructor Destroy(); override;
    function GetText(const Key: string): string;
    property Language: string read FLanguage write LoadLanguage;
  end;

function _(const Key: string): string; // Helper function for simplicity

var
  LanguageManager: TTranslationManager;
//  {$IFDEF ANDROID}
//  AssetPath, DocPath: string;
//  {$ENDIF}

implementation

function _(const Key: string): string;
begin
  if Assigned(LanguageManager) then
    Result := LanguageManager.GetText(Key)
  else
    Result := Key; // Fallback to the key itself
end;

{ TTranslationManager }

constructor TTranslationManager.Create(const FileName: string);
begin
  FTranslations := TDictionary<string, string>.Create;
  FIniFile := TIniFile.Create(FileName);

  // Default language is system language or fallback to English
  FLanguage := 'en';
  LoadLanguage(FLanguage);
end;

destructor TTranslationManager.Destroy();
begin
  FTranslations.Free();
  FIniFile.Free();
  inherited;
end;

procedure TTranslationManager.LoadLanguage(const LangCode: string);
var
  Section: TStringList;
  Line: string;
  Key, Value: string;
  EqualPos: Integer;
begin
  FLanguage := LangCode;
  FTranslations.Clear;

  Section := TStringList.Create;
  try
    FIniFile.ReadSectionValues(LangCode, Section);
    for Line in Section do
    begin
      EqualPos := Line.IndexOf('=');
      if EqualPos > 0 then
      begin
        Key := Line.Substring(0, EqualPos).Trim();
        //Value := Line.Substring(EqualPos + 1).Trim(); //That trailing Trim() is a problem.
        Value := Line.Substring(EqualPos + 1);

        // If the quotes are delimiters, strip them
        if (Value.StartsWith('"')) and (Value.EndsWith('"')) then
          Value := Value.Substring(1, Value.Length - 2);

        // Substituir escapes de CRLS (\r\n)
        Value := StringReplace(Value, '\r\n', System.sLineBreak, [rfReplaceAll]);

        // Substituir escapes de aspas (\")
        Value := StringReplace(Value, '\"', '"', [rfReplaceAll]);

        FTranslations.Add(Key, Value);
      end;
    end;
  finally
    Section.Free;
  end;
end;

function TTranslationManager.GetText(const Key: string): string;
begin
  if not FTranslations.TryGetValue(Key, Result) then
    Result := Key; // Fallback to the key itself
end;

//initialization
//  {$IFDEF ANDROID}
//  // Define os caminhos
//  DocPath := TPath.Combine(TPath.GetDocumentsPath, 'Translations.ini');
//  AssetPath := TPath.Combine(TPath.GetDocumentsPath, 'assets\Translations.ini');
//
//  // Check whether the file already exists in the documents folder
//  if not TFile.Exists(DocPath) then
//  begin
//    try
//      // Create the directory if needed
//      if not TDirectory.Exists(TPath.GetDirectoryName(DocPath)) then
//        TDirectory.CreateDirectory(TPath.GetDirectoryName(DocPath));
//
//      if TFile.Exists(AssetPath) then
//        // Copy the file from assets into documents
//        TFile.Copy(AssetPath, DocPath);
//    except
//      on E: Exception do
//        ShowMessage('Error loading the translations file: ' + E.Message);
//    end;
//  end;
//  LanguageManager := TTranslationManager.Create(DocPath);
//  {$ELSE}
//  LanguageManager := TTranslationManager.Create('..\..\Translations.ini');
//  {$ENDIF}
//
//finalization
//  FreeAndNil(LanguageManager);

end.

