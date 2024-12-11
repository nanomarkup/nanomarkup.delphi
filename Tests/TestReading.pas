unit TestReading;

interface

uses
  DUnitX.TestFramework;

const
  CTab = #9;
  CLineBreak = sLineBreak;

type
  [TestFixture]
  TTestReading = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    { Test Values }
    [Test]
    [TestCase('TestInt', '-1,-1')]
    [TestCase('TestInt', '0,0')]
    [TestCase('TestInt', '1,1')]
    [TestCase('TestFloat', '-1.0,-1.0')]
    [TestCase('TestFloat', '0.0,0.0')]
    [TestCase('TestFloat', '1.0,1.0')]
    [TestCase('TestString', 'Name,Name')]
    [TestCase('TestString', 'D20.12.2024,D20.12.2024')]
    [TestCase('TestString', 'Hello world!,Hello world!')]
    [TestCase('TestString', 'Hello world..,Hello world..')]
    [TestCase('TestMultiLineString', 'Hello '+CLineBreak+CTab+'world!,Hello '+CLineBreak+'world!')]
    [TestCase('TestMultiLineString', 'Hello'+CLineBreak+CTab+' world!,Hello'+CLineBreak+' world!')]
    [TestCase('TestMultiLineString', '642552'+CLineBreak+CTab+'712,642552'+CLineBreak+'712')]
    [TestCase('TestMultiLineString', 'John Smith'+CLineBreak+CTab+CTab+'Hi,John Smith'+CLineBreak+CTab+'Hi')]
    procedure TestValues(const AData: string; const AExpected: string);
    { Test 2 Values }
    [Test]
    [TestCase('Test2Ints', '1'+CLineBreak+'-1,1,-1')]
    [TestCase('Test2Floats', '1.0'+CLineBreak+'-1.0,1.0,-1.0')]
    [TestCase('Test2Strings', 'D20.12.2024'+CLineBreak+'Hello world!,D20.12.2024,Hello world!')]
    procedure Test2Values(const AData: string; const AExp1, AExp2: string);
    { Test Sections }
    [Test]
    [TestCase('TestEmptySection', '..,0')]
    [TestCase('TestEmptySection', '..'+CLineBreak+'name John'+CLineBreak+'age 20,0')]
    [TestCase('TestEmptySection', 'student..,0')]
    [TestCase('TestEmptySection', 'student..'+CLineBreak+'name John'+CLineBreak+'age 20,0')]
    procedure TestEmptySection(const AData: string; const AExpItemsCount: Integer);
    [Test]
    [TestCase('TestSection', '..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'age 20,John,20')]
    procedure TestSection(const AData: string; const AExp1, AExp2: string);
    [Test]
    [TestCase('Test2Sections', '..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'age 20'+CLineBreak+'..'+CLineBreak+CTab+'name Jack'+CLineBreak+CTab+'age 21,John,Jack')]
    procedure Test2Sections(const AData: string; const AExp1, AExp2: string);
    [Test]
    [TestCase('Test2LevelSection', '..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'contacts..'+CLineBreak+CTab+CTab+'city New York,John,New York')]
    procedure Test2LevelSection(const AData: string; const AExp1, AExp2: string);
    { Test Lists }
    [Test]
    [TestCase('TestEmptyList', ':,0')]
    [TestCase('TestEmptyList', ':'+CLineBreak+'apple'+CLineBreak+'banana,0')]
    [TestCase('TestEmptyList', ':'+CLineBreak+'John Smith'+CLineBreak+'Jack Daniels,0')]
    [TestCase('TestEmptyList', 'actors:,0')]
    [TestCase('TestEmptyList', 'actors:'+CLineBreak+'John Smith'+CLineBreak+'Jack Daniels,0')]
    procedure TestEmptyList(const AData: string; const AExpItemsCount: Integer);
    [Test]
    [TestCase('TestList', ':'+CLineBreak+CTab+'apple'+CLineBreak+CTab+'banana,apple,banana')]
    [TestCase('TestList', ':'+CLineBreak+CTab+'John Smith'+CLineBreak+CTab+'Jack Daniels,John Smith,Jack Daniels')]
    procedure TestList(const AData: string; const AExp1, AExp2: string);
    [Test]
    [TestCase('Test2Lists', ':'+CLineBreak+CTab+'apple'+CLineBreak+':'+CLineBreak+CTab+'John,apple,John')]
    procedure Test2Lists(const AData: string; const AExp1, AExp2: string);
    [Test]
    [TestCase('Test2LevelList', ':'+CLineBreak+CTab+'apple'+CLineBreak+CTab+':'+CLineBreak+CTab+CTab+'John,apple,John')]
    procedure Test2LevelList(const AData: string; const AExp1, AExp2: string);
    { Test Comments }
    [Test]
    [TestCase('TestComment', '#Hello world!,#Hello world!')]
    [TestCase('TestComment', '# Hello world..,# Hello world..')]
    [TestCase('TestComment', '#Hello '+CLineBreak+CTab+'world!,#Hello '+CLineBreak+'world!')]
    [TestCase('TestComment', '# Hello'+CLineBreak+CTab+' world!,# Hello'+CLineBreak+' world!')]
    [TestCase('TestComment', '#642552'+CLineBreak+CTab+'712,#642552'+CLineBreak+'712')]
    [TestCase('TestComment', '# John Smith'+CLineBreak+CTab+CTab+'Hi,# John Smith'+CLineBreak+CTab+'Hi')]
    procedure TestComment(const AData: string; const AExpected: string);
  end;

implementation

uses
  System.Classes, System.SysUtils, System.Generics.Collections, NanoMarkup;

procedure TTestReading.Setup;
begin
end;

procedure TTestReading.TearDown;
begin
end;

procedure TTestReading.Test2Sections(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 2);
    Assert.IsTrue(LValue[0].NanoType = ntSection);
    Assert.IsTrue(LValue[1].NanoType = ntSection);
    Assert.AreEqual(AExp1, TNanoSection(LValue[0])[0].Value);
    Assert.AreEqual(AExp2, TNanoSection(LValue[1])[0].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.Test2LevelSection(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 1);
    Assert.IsTrue(LValue[0].NanoType = ntSection);
    Assert.AreEqual(TNanoSection(LValue[0]).Count, 2);
    Assert.IsTrue(TNanoSection(LValue[0])[1].NanoType = ntSection);
    Assert.AreEqual(AExp1, TNanoSection(LValue[0])[0].Value);
    Assert.AreEqual(AExp2, TNanoSection(TNanoSection(LValue[0])[1])[0].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.Test2LevelList(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 1);
    Assert.IsTrue(LValue[0].NanoType = ntList);
    Assert.AreEqual(TNanoList(LValue[0]).Count, 2);
    Assert.IsTrue(TNanoList(TNanoList(LValue[0])[1]).NanoType = ntList);
    Assert.AreEqual(TNanoList(TNanoList(LValue[0])[1]).Count, 1);
    Assert.AreEqual(AExp1, TNanoList(LValue[0])[0].Value);
    Assert.AreEqual(AExp2, TNanoList(TNanoList(LValue[0])[1])[0].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.Test2Lists(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 2);
    Assert.IsTrue(LValue[0].NanoType = ntList);
    Assert.IsTrue(LValue[1].NanoType = ntList);
    Assert.AreEqual(AExp1, TNanoList(LValue[0])[0].Value);
    Assert.AreEqual(AExp2, TNanoList(LValue[1])[0].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.Test2Values(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 2);
    Assert.IsTrue(LValue[0].NanoType = ntValue);
    Assert.IsTrue(LValue[1].NanoType = ntValue);
    Assert.AreEqual(AExp1, LValue[0].Value);
    Assert.AreEqual(AExp2, LValue[1].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.TestComment(const AData, AExpected: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 1);
    Assert.IsTrue(LValue[0].NanoType = ntComment);
    Assert.AreEqual(AExpected, LValue[0].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.TestEmptySection(const AData: string; const AExpItemsCount: Integer);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.IsTrue(LValue.Count > 0);
    Assert.IsTrue(LValue[0].NanoType = ntSection);
    Assert.AreEqual(AExpItemsCount, TNanoSection(LValue[0]).Count);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.TestEmptyList(const AData: string; const AExpItemsCount: Integer);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.IsTrue(LValue.Count > 0);
    Assert.IsTrue(LValue[0].NanoType = ntList);
    Assert.AreEqual(AExpItemsCount, TNanoSection(LValue[0]).Count);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.TestSection(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 1);
    Assert.IsTrue(LValue[0].NanoType = ntSection);
    Assert.AreEqual(AExp1, TNanoSection(LValue[0])[0].Value);
    Assert.AreEqual(AExp2, TNanoSection(LValue[0])[1].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.TestList(const AData, AExp1, AExp2: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 1);
    Assert.IsTrue(LValue[0].NanoType = ntList);
    Assert.AreEqual(AExp1, TNanoList(LValue[0])[0].Value);
    Assert.AreEqual(AExp2, TNanoList(LValue[0])[1].Value);
  finally
    LValue.Free;
  end;
end;

procedure TTestReading.TestValues(const AData, AExpected: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.IsNotNull(LValue);
    Assert.AreEqual(LValue.Count, 1);
    Assert.IsTrue(LValue[0].NanoType = ntValue);
    Assert.AreEqual(AExpected, LValue[0].Value);
  finally
    LValue.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestReading);

end.
