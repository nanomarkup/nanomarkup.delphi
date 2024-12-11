unit NanoMarkup;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TNanoType = (ntValue, ntPair, ntList, ntSection, ntComment);

  TNanoValue = class
  private
    FType: TNanoType;
    FValue: string;  
  public
    constructor Create(const AType: TNanoType; const AValue: string); virtual;
    property NanoType: TNanoType read FType;
    property Value: string read FValue write FValue;
  end;

  TNanoPair = class(TNanoValue)
  private
    FKey: string;
  protected
    constructor Create(const AKey, AValue: string); reintroduce; virtual;
    property Key: string read FKey write FKey;
  end;

  TNanoList = class(TNanoValue)
  private
    FItems: TObjectList<TNanoValue>;
    FParent: TNanoList;
    FLevel: Integer;
  protected
    constructor Create(const AType: TNanoType; const AName: string; AParent: TNanoList); reintroduce; overload; virtual;
    function GetItem(const AIndex: Integer): TNanoValue; virtual;
  public
    constructor Create(const AName: string; AParent: TNanoList); reintroduce; overload; virtual;
    destructor Destroy; override;
    function Count: Integer;

    property Item[const Index: Integer]: TNanoValue read GetItem; default;
    property Items: TObjectList<TNanoValue> read FItems;
    property Parent: TNanoList read FParent;
    property Level: Integer read FLevel;
  end;

  TNanoSection = class(TNanoList)
  public
    constructor Create(const AName: string; AParent: TNanoList); override;
  end;

  TNanoMarkup = class
  private
    class procedure ToString(ASrc: TNanoList; ADst: TStrings); reintroduce; overload;
  public const
    CTab = #9;
    CLineBreak = sLineBreak;
    CTokenList = ':';
    CTokenSection = '..';
    CTokenComment = '#';
  public
    class function Read(const AData: TStrings): TNanoList; overload;
    class function Read(const AData: string): TNanoList; overload;
    class function ToString(AList: TNanoList): string; reintroduce; overload;
    class function ToStrings(AList: TNanoList): TStrings;
  end;

implementation

uses
  System.SysUtils;

{ TNanoValue }

constructor TNanoValue.Create(const AType: TNanoType; const AValue: string);
begin
  FType := AType;
  FValue := AValue;
end;

{ TNanoPair }

constructor TNanoPair.Create(const AKey, AValue: string);
begin
  inherited Create(ntPair, AValue);
  FKey := AKey;
end;

{ TNanoList }

function TNanoList.Count: Integer;
begin
  Result := FItems.Count;
end;

constructor TNanoList.Create(const AName: string; AParent: TNanoList);
begin
  Create(ntList, AName, AParent);
end;

constructor TNanoList.Create(const AType: TNanoType; const AName: string; AParent: TNanoList);
begin
  inherited Create(AType, AName);
  FItems := TObjectList<TNanoValue>.Create;
  FParent := AParent;
  if FParent <> nil then
    FLevel := AParent.Level + 1;
end;

destructor TNanoList.Destroy;
begin
  FItems.Free;
  FParent := nil;
  inherited;
end;

function TNanoList.GetItem(const AIndex: Integer): TNanoValue;
begin
  Result := FItems[AIndex];
end;

{ TNanoSection }

constructor TNanoSection.Create(const AName: string; AParent: TNanoList);
begin
  inherited Create(ntSection, AName, AParent);
end;

{ TNanoMarkup }

class function TNanoMarkup.Read(const AData: TStrings): TNanoList;

  function LGetParent(AParent: TNanoList; const ALevel: Integer): TNanoList;
  begin
    Result := nil;
    if AParent.Level + 1 < ALevel then
      raise EParserError.Create('Incorrect indentation');

    var LParent := AParent;
    while LParent <> nil do
    begin
      if LParent.Level < ALevel then
      begin
        Result := LParent;
        Exit;
      end;
      LParent := LParent.Parent;
    end;
  end;

  function LParseLevel(const ALine: string; out ALevel: Integer): string;
  var
    I: Integer;
  begin
    ALevel := 0;
    var LLength := Length(ALine);
    for I := 1 to LLength do
    begin
      if ALine[I] = CTab then
        Inc(ALevel)
      else
        Break;
    end;
    Result := Copy(ALine, I, LLength);
  end;

begin
  Result := TNanoList.Create('', nil);
  Result.FLevel := -1;
  var LLevel := 0;
  var LValue := '';
  var LToken := '';
  var LParent := Result;
  var LParentOld: TNanoList;
  var LLatest: TNanoValue := nil;
  for var LLine in AData do
  begin
    LValue := LParseLevel(LLine, LLevel);
    // Handle a multi-line value and comment
    if (LLevel > LParent.Level + 1) and (LLatest <> nil) and
      ((LLatest.NanoType = ntValue) or (LLatest.NanoType = ntComment)) then
    begin
      LToken := LLatest.Value;
      LToken := LToken + sLineBreak;
      for var I := LParent.Level + 3 to LLevel do
        LToken := LToken + CTab;
      LLatest.FValue := LToken + LValue;
      Continue;
    end;

    LLatest := nil;
    LParent := LGetParent(LParent, LLevel);
    if LParent = nil then
      LParent := Result;

    LToken := TrimRight(LValue);
    if LToken = CTokenList then
    begin
      if LParent.NanoType <> ntList then
        raise EParserError.Create('Invalid declaration of anonymous list');
      LParentOld := LParent;
      LParent := TNanoList.Create(LToken, LParentOld);
      LParentOld.Items.Add(LParent);
    end
    else if LToken = CTokenSection then
    begin
      if LParent.NanoType <> ntList then
        raise EParserError.Create('Invalid declaration of anonymous object');
      LParentOld := LParent;
      LParent := TNanoSection.Create(LToken, LParentOld);
      LParentOld.Items.Add(LParent);
    end
    else if (Pos(' ', LToken) = 0) and (Copy(LToken, Length(LToken), 1) = CTokenList) then
    begin
      LParentOld := LParent;
      LParent := TNanoList.Create(LToken, LParentOld);
      LParentOld.Items.Add(LParent);
    end
    else if (Pos(' ', LToken) = 0) and (Copy(LToken, Length(LToken) - 1, 2) = CTokenSection) then
    begin
      LParentOld := LParent;
      LParent := TNanoSection.Create(LToken, LParentOld);
      LParentOld.Items.Add(LParent);
    end
    else
    begin
      if LValue[1] = CTokenComment then
        LLatest := TNanoValue.Create(ntComment, LValue)
      else
      begin
        var LPos := Pos(' ', LValue);
        if (LPos < 2) or (LParent.NanoType <> ntSection) then
          LLatest := TNanoValue.Create(ntValue, LValue)
        else
        begin
          var LKey := Copy(LValue, 1, LPos - 1);
          LLatest := TNanoPair.Create(LKey, Copy(LValue, Length(LKey) + 2, Length(LValue)));
        end;
      end;
      LParent.FItems.Add(LLatest);
    end;
  end;
end;

class function TNanoMarkup.Read(const AData: string): TNanoList;
begin
  var LStrings := TStringList.Create;
  try
    LStrings.Text := AData;
    Result := Read(LStrings);
  finally
    LStrings.Free;
  end;
end;

class function TNanoMarkup.ToString(AList: TNanoList): string;
begin
  var LStrings := ToStrings(AList);
  try
    Result := LStrings.Text;
  finally
    LStrings.Free;
  end;
end;

class procedure TNanoMarkup.ToString(ASrc: TNanoList; ADst: TStrings);
begin
  var LItemIdent := '';
  var LParentIdent := '';
  for var I := 0 to ASrc.Level do
  begin
    if I < ASrc.Level then
      LParentIdent := LParentIdent + CTab
    else
      LItemIdent := LParentIdent + CTab;
  end;

  if (ASrc.Level > -1) and (ASrc.Items.Count > 0) then
    ADst.Add(LParentIdent + ASrc.Value);

  for var LItem in ASrc.Items do
  begin
    case LItem.NanoType of
      ntValue,
      ntComment: ADst.Add(LItemIdent + LItem.Value);
      ntPair: ADst.Add(LItemIdent + TNanoPair(LItem).Key + ' ' + LItem.Value);
      ntList,
      ntSection: ToString(LItem as TNanoList, ADst);
    end;
  end;
end;

class function TNanoMarkup.ToStrings(AList: TNanoList): TStrings;
begin
  Result := TStringList.Create;
  Result.TrailingLineBreak := False;
  ToString(AList, Result);
end;

end.
