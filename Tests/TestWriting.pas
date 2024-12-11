unit TestWriting;

interface

uses
  DUnitX.TestFramework;

const
  CTab = #9;
  CLineBreak = sLineBreak;

type
  [TestFixture]
  TTestWriting = class
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    { Test Strings }
    [Test]
    [TestCase('TestInt', '-1,-1')]
    [TestCase('TestInt', '0,0')]
    [TestCase('TestInt', '1,1')]
    [TestCase('Test2Ints', '1'+CLineBreak+'-1,1'+CLineBreak+'-1')]
    [TestCase('TestFloat', '-1.0,-1.0')]
    [TestCase('TestFloat', '0.0,0.0')]
    [TestCase('TestFloat', '1.0,1.0')]
    [TestCase('Test2Floats', '1.0'+CLineBreak+'-1.0,1.0'+CLineBreak+'-1.0')]
    [TestCase('TestString', 'Name,Name')]
    [TestCase('TestString', 'D20.12.2024,D20.12.2024')]
    [TestCase('TestString', 'Hello world!,Hello world!')]
    [TestCase('TestString', 'Hello world..,Hello world..')]
    [TestCase('TestMultiLineString', 'Hello '+CLineBreak+CTab+'world!,Hello '+CLineBreak+'world!')]
    [TestCase('TestMultiLineString', 'Hello'+CLineBreak+CTab+' world!,Hello'+CLineBreak+' world!')]
    [TestCase('TestMultiLineString', '642552'+CLineBreak+CTab+'712,642552'+CLineBreak+'712')]
    [TestCase('TestMultiLineString', 'John Smith'+CLineBreak+CTab+CTab+'Hi,John Smith'+CLineBreak+CTab+'Hi')]
    [TestCase('Test2Strings', 'D20.12.2024'+CLineBreak+'Hello world!,D20.12.2024'+CLineBreak+'Hello world!')]
    [TestCase('TestEmptySection', '..,')]
    [TestCase('TestEmptySection', '..'+CLineBreak+'name John'+CLineBreak+'age 20,name John'+CLineBreak+'age 20')]
    [TestCase('TestEmptySection', 'student..,')]
    [TestCase('TestEmptySection', 'student..'+CLineBreak+'name John'+CLineBreak+'age 20,name John'+CLineBreak+'age 20')]
    [TestCase('TestSection', '..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'age 20,..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'age 20')]
    [TestCase('Test2Sections', '..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'age 20'+CLineBreak+'..'+CLineBreak+CTab+'name Jack'+CLineBreak+CTab+'age 21,..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'age 20'+CLineBreak+'..'+CLineBreak+CTab+'name Jack'+CLineBreak+CTab+'age 21')]
    [TestCase('Test2LevelSection', '..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'contacts..'+CLineBreak+CTab+CTab+'city New York,..'+CLineBreak+CTab+'name John'+CLineBreak+CTab+'contacts..'+CLineBreak+CTab+CTab+'city New York')]
    [TestCase('TestEmptyList', ':,')]
    [TestCase('TestEmptyList', ':'+CLineBreak+'apple'+CLineBreak+'banana,apple'+CLineBreak+'banana')]
    [TestCase('TestEmptyList', ':'+CLineBreak+'John Smith'+CLineBreak+'Jack Daniels,John Smith'+CLineBreak+'Jack Daniels')]
    [TestCase('TestEmptyList', 'actors:,')]
    [TestCase('TestEmptyList', 'actors:'+CLineBreak+'John Smith'+CLineBreak+'Jack Daniels,John Smith'+CLineBreak+'Jack Daniels')]
    [TestCase('TestList', ':'+CLineBreak+CTab+'apple'+CLineBreak+CTab+'banana,:'+CLineBreak+CTab+'apple'+CLineBreak+CTab+'banana')]
    [TestCase('TestList', ':'+CLineBreak+CTab+'John Smith'+CLineBreak+CTab+'Jack Daniels,:'+CLineBreak+CTab+'John Smith'+CLineBreak+CTab+'Jack Daniels')]
    [TestCase('Test2Lists', ':'+CLineBreak+CTab+'apple'+CLineBreak+':'+CLineBreak+CTab+'John,:'+CLineBreak+CTab+'apple'+CLineBreak+':'+CLineBreak+CTab+'John')]
    [TestCase('Test2LevelList', ':'+CLineBreak+CTab+'apple'+CLineBreak+CTab+':'+CLineBreak+CTab+CTab+'John,:'+CLineBreak+CTab+'apple'+CLineBreak+CTab+':'+CLineBreak+CTab+CTab+'John')]
    [TestCase('TestComment', '#Hello world!,#Hello world!')]
    [TestCase('TestComment', '# Hello world..,# Hello world..')]
    [TestCase('TestComment', '#Hello '+CLineBreak+CTab+'world!,#Hello '+CLineBreak+'world!')]
    [TestCase('TestComment', '# Hello'+CLineBreak+CTab+' world!,# Hello'+CLineBreak+' world!')]
    [TestCase('TestComment', '#642552'+CLineBreak+CTab+'712,#642552'+CLineBreak+'712')]
    [TestCase('TestComment', '# John Smith'+CLineBreak+CTab+CTab+'Hi,# John Smith'+CLineBreak+CTab+'Hi')]
    procedure TestValues(const AData: string; const AExpected: string);
  end;

implementation

uses
  System.Classes, System.SysUtils, System.Generics.Collections, NanoMarkup;

procedure TTestWriting.Setup;
begin
end;

procedure TTestWriting.TearDown;
begin
end;

procedure TTestWriting.TestValues(const AData, AExpected: string);
begin
  var LValue := TNanoMarkup.Read(AData);
  try
    Assert.AreEqual(AExpected, TNanoMarkup.ToString(LValue));
  finally
    LValue.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestWriting);

end.
