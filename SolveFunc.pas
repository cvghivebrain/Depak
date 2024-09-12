unit SolveFunc;

//{$DEFINE GUI_APP} // Remove this line for command line programs.

interface
uses StrUtils,
  SysUtils,
  {$IFDEF GUI_APP}
  Dialogs,
  {$ENDIF}
  Math,
  Windows;

function DoSum(s: string): int64;
function DoSum2(s: string): int64;
function DoSum3(num1, num2: string; op: char): string;
function BinToInt(s: string): int64;
function Solve(s: string): int64;
function Solve2(s: string): int64;
function SolveStr(s: string): string;
function SolveHex(s: string): string;

function Explode(str, delimiter: string; n: integer): string;
function ExplodeFull(str, delimiter: string; n: integer): string;
function FirstChar(s: string): string;

function CRCString(s: string): string;
function CRCFile(fi: string): string;
function CRCData(): string;
function SHA1String(s: string): string;
function SHA1File(fi: string): string;
function SHA1Data(): string;
function MD5String(s: string): string;
function MD5File(fi: string): string;
function MD5Data(): string;
function rol(l: longword; i: integer): longword;
function swapendian(l: longword): longword;
function swapendian64(i: uint64): uint64;

procedure LoadFile(openthis: string; fnum: integer = 0);
procedure UnloadFile(fnum: integer = 0);
procedure SaveFile(savethis: string; fnum: integer = 0);
procedure ClipFile(a, len: integer; clipthisfile: string; fnum: integer = 0);
procedure NewFile(filelen: integer; fnum: integer = 0);
procedure AppendFile(a: integer; addthisfile: string; fnum: integer = 0);
procedure EvenFile(fnum: integer = 0);
function GetByte(a: int64; fnum: integer = 0): byte;
function GetBit(a: int64; b: integer; fnum: integer = 0): byte;
function Bit(i, b: integer): byte;
function GetWord(a: int64; fnum: integer = 0): word;
function GetDword(a: int64; fnum: integer = 0): longword;
function GetWordRev(a: int64; fnum: integer = 0): word;
function GetDwordRev(a: int64; fnum: integer = 0): longword;
function GetString(a, maxlength: int64; fnum: integer = 0): string;
function GetStringWide(a, maxlength, charw: int64; fnum: integer = 0): string;
function GetStrInt(a, maxlength: int64; fnum: integer = 0): string;
procedure WriteByte(a: int64; b: byte; fnum: integer = 0);
procedure WriteWord(a: int64; w: word; fnum: integer = 0);
procedure WriteWordRev(a: int64; w: word; fnum: integer = 0);
procedure WriteDword(a: int64; d: longword; fnum: integer = 0);
procedure WriteDwordRev(a: int64; d: longword; fnum: integer = 0);
procedure RunCommand(command: string);
function FileInUse(f: string): boolean;
procedure ListFolders(dir: string; subfolders: boolean);
procedure ListFiles(dir: string; subfolders: boolean);
procedure GetBase64(a, a2: int64; fnum, fnum2: integer);
function ByteToBase64(c: byte): byte;
procedure MakeFolder(f: string);

var
  val: int64;
  myfile: file;
  hasharray: array of byte;
  fs, fpos: integer;
  folderlist, filelist: array of string;
  filearrays: array of array of byte;

const
  md5table: array[0..63] of longword = ($d76aa478, $e8c7b756, $242070db, $c1bdceee,
    $f57c0faf, $4787c62a, $a8304613, $fd469501, $698098d8, $8b44f7af, $ffff5bb1, $895cd7be,
    $6b901122, $fd987193, $a679438e, $49b40821, $f61e2562, $c040b340, $265e5a51, $e9b6c7aa,
    $d62f105d, $02441453, $d8a1e681, $e7d3fbc8, $21e1cde6, $c33707d6, $f4d50d87, $455a14ed,
    $a9e3e905, $fcefa3f8, $676f02d9, $8d2a4c8a, $fffa3942, $8771f681, $6d9d6122, $fde5380c,
    $a4beea44, $4bdecfa9, $f6bb4b60, $bebfbc70, $289b7ec6, $eaa127fa, $d4ef3085, $04881d05,
    $d9d4d039, $e6db99e5, $1fa27cf8, $c4ac5665, $f4292244, $432aff97, $ab9423a7, $fc93a039,
    $655b59c3, $8f0ccc92, $ffeff47d, $85845dd1, $6fa87e4f, $fe2ce6e0, $a3014314, $4e0811a1,
    $f7537e82, $bd3af235, $2ad7d2bb, $eb86d391);
  crctable: array[0..255] of longword = ($00000000, $77073096, $EE0E612C, $990951BA,
    $076DC419, $706AF48F, $E963A535, $9E6495A3, $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91, $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
    $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B, $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
    $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59, $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
    $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433, $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
    $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01, $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457, $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
    $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65, $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB, $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010, $C90C2086,
    $5768B525, $206F85B3, $B966D409, $CE61E49F, $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
    $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD, $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683, $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
    $F762575D, $806567CB, $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5, $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
    $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B, $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
    $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79, $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
    $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D, $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
    $9C0906A9, $EB0E363F, $72076785, $05005713, $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
    $81BE16CD, $F6B9265B, $6FB077E1, $18B74777, $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
    $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9, $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
    $BAD03605, $CDD70693, $54DE5729, $23D967BF, $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);
  md5shift: array[0..63] of integer = (7,12,17,22,7,12,17,22,7,12,17,22,7,12,17,22,
    5,9,14,20,5,9,14,20,5,9,14,20,5,9,14,20,
    4,11,16,23,4,11,16,23,4,11,16,23,4,11,16,23,
    6,10,15,21,6,10,15,21,6,10,15,21,6,10,15,21);

implementation

{ Convert an expression (e.g. '1+1') to integer. }

function DoSum(s: string): int64;
begin
  s := ReplaceStr(s,' ',''); // Strip spaces.
  s := ReplaceStr(s,'0x','$'); // Convert C++ hex prefix to Delphi/assembly.
  s := ReplaceStr(s,'<<','L'); // Replace << (shift left) to avoid clash with <.
  s := ReplaceStr(s,'>>','l'); // Replace >> (shift right) to avoid clash with >.
  s := ReplaceStr(s,'**','P'); // Replace ** (exponent) to avoid clash with *.
  if (AnsiPos('=',s) > 0) or (AnsiPos('<',s) > 0) or (AnsiPos('>',s) > 0) then // Check for conditional.
    begin
    result := 1; // Assume condition is satisfied.
    if AnsiPos('>=',s) > 0 then
      begin
      if DoSum2(Explode(s,'>=',0)) >= DoSum2(Explode(s,'>=',1)) then exit; // 1 for greater than or equal.
      end
    else if AnsiPos('<=',s) > 0 then
      begin
      if DoSum2(Explode(s,'<=',0)) <= DoSum2(Explode(s,'<=',1)) then exit; // 1 for less than or equal.
      end
    else if AnsiPos('=',s) > 0 then
      begin
      if DoSum2(Explode(s,'=',0)) = DoSum2(Explode(s,'=',1)) then exit; // 1 for equal.
      end
    else if AnsiPos('<>',s) > 0 then
      begin
      if DoSum2(Explode(s,'<>',0)) <> DoSum2(Explode(s,'<>',1)) then exit; // 1 for inequal.
      end
    else if AnsiPos('>',s) > 0 then
      begin
      if DoSum2(Explode(s,'>',0)) > DoSum2(Explode(s,'>',1)) then exit; // 1 for greater than.
      end
    else if AnsiPos('<',s) > 0 then
      begin
      if DoSum2(Explode(s,'<',0)) < DoSum2(Explode(s,'<',1)) then exit; // 1 for less than.
      end;
    result := 0; // Condition was not satisfied.
    end
  else result := DoSum2(s);
end;

function DoSum2(s: string): int64;
var i: integer;
  num1, num2, op: string;
begin
  num1 := '';
  num2 := '';
  op := '';
  for i := 1 to Length(s) do
    begin
    if AnsiPos(s[i],'0123456789ABCDEFabcdef$') > 0 then // Check if character is digit or operator.
      begin
      if op = '' then num1 := num1+s[i] // Add to first number.
      else num2 := num2+s[i]; // Add to second number if operator is set.
      end
    else if (AnsiPos(s[i],'-%') > 0) and (num1 = '') then num1 := s[i] // Check for number prefix.
    else if (AnsiPos(s[i],'-%') > 0) and (op <> '') and (num2 = '') then num2 := s[i]
    else
      begin
      if op <> '' then
        begin
        num1 := DoSum3(num1,num2,op[1]); // Perform operation and put result in num1.
        num2 := ''; // Clear second number.
        end;
      op := s[i]; // Next operator.
      end;
    end;
  if op <> '' then result := StrToInt64(DoSum3(num1,num2,op[1]))
  else
    begin
    if num1[1] = '%' then result := BinToInt(num1)
    else result := StrToInt64(num1); // Return single number if no operator is present.
    end;
end;

function DoSum3(num1, num2: string; op: char): string;
var n1, n2: int64;
begin
  if num1[1] = '%' then n1 := BinToInt(num1) // Convert from binary.
  else n1 := StrToInt64(num1);
  if num2[1] = '%' then n2 := BinToInt(num2)
  else n2 := StrToInt64(num2);
  case Ord(op) of
  Ord('+'): result := IntToStr(n1+n2);
  Ord('-'): result := IntToStr(n1-n2);
  Ord('*'): result := IntToStr(n1*n2);
  Ord('/'): result := IntToStr(n1 div n2);
  Ord('\'): result := IntToStr(Ceil(n1/n2)); // Division rounding up.
  Ord('R'): result := IntToStr(Ceil(n1/n2)*n2); // Round up to multiple of n2.
  Ord('r'): result := IntToStr((n1 div n2)*n2); // Round down to multiple of n2.
  Ord('&'): result := IntToStr(n1 and n2);
  Ord('|'): result := IntToStr(n1 or n2);
  Ord('^'): result := IntToStr(n1 xor n2);
  Ord('%'): result := IntToStr(n1 mod n2);
  Ord('L'): result := IntToStr(n1 shl n2);
  Ord('l'): result := IntToStr(n1 shr n2);
  Ord('P'): result := IntToStr(Floor(Power(n1,n2)));
  end;
end;

{ Convert binary number with % prefix to integer. }

function BinToInt(s: string): int64;
var i: integer;
begin
  result := 0;
  for i := 2 to Length(s) do
    result := (result shl 1)+Ord(s[i])-48;
end;

{ Convert sum with brackets to integer. }

function Solve(s: string): int64;
var sub, scopy: string;
begin
  scopy := s;
  s := ReplaceStr(s,'{val}',IntToStr(val)); // Insert predefined value.
  try
    while AnsiPos('}',s) <> 0 do
      begin
      sub := ExplodeFull(Explode(s,'}',0),'{',-1); // Get contents of curly brackets.
      s := ReplaceStr(s,'{'+sub+'}',InttoStr(Solve2(sub))); // Solve & remove brackets.
      end;
    while AnsiPos('"',s) <> 0 do
      begin
      sub := Explode(s,'"',1); // Get contents of quotes.
      s := ReplaceStr(s,'"'+sub+'"','$'+CRCString(sub)); // Replace string with CRC32.
      end;
    while AnsiPos(')',s) <> 0 do
      begin
      sub := ExplodeFull(Explode(s,')',0),'(',-1); // Get contents of brackets.
      s := ReplaceStr(s,'('+sub+')',InttoStr(DoSum(sub))); // Solve & remove brackets.
      end;
    result := DoSum(s); // Final sum after brackets are gone.
  except
    {$IFDEF GUI_APP}
    ShowMessage(scopy+' is not a valid expression.');
    {$ELSE}
    WriteLn(scopy+' is not a valid expression.');
    {$ENDIF}
    result := 0;
  end;
end;

function Solve2(s: string): int64; // Get data from file array.
var t, str, p1, p2, chrw: string;
  a, a2, len: int64;
  i, fnum: integer;
begin
  t := Explode(s,':',0); // Get type (e.g. "b" for byte).
  p1 := Explode(s,':',1);
  p2 := Explode(s,':',2);
  if AnsiPos('"',p2) > 0 then p2 := Explode(s,'":',1); // Adjust if string contains colon.
  if p2 = '' then fnum := 0
  else fnum := Solve(p2);
  if t = 'b' then result := GetByte(Solve(p1),fnum) // Return byte from file array.
  else if t = 'w' then result := GetWord(Solve(p1),fnum) // Return word.
  else if t = '_w' then result := GetWordRev(Solve(p1),fnum) // Return word (byteswapped).
  else if t = 't' then result := (GetWord(Solve(p1),fnum) shl 8)+GetByte(Solve(p1)+2,fnum) // Return 3 bytes.
  else if t = '_t' then result := GetWordRev(Solve(p1),fnum)+(GetByte(Solve(p1)+2,fnum) shl 16) // Return 3 bytes (byteswapped).
  else if t = 'd' then result := GetDWord(Solve(p1),fnum) // Return longword.
  else if t = '_d' then result := GetDWordRev(Solve(p1),fnum) // Return longword (byteswapped).
  else if t = 's' then
    begin
    a := Solve(Explode(p1,',',0)); // Get string address.
    len := Solve(Explode(p1,',',1)); // Get max length.
    chrw := Explode(p1,',',2); // Get character width if set.
    if chrw = '' then result := StrtoInt64('$'+CRCString(GetString(a,len,fnum))) // Return CRC32 of string.
    else result := StrtoInt64('$'+CRCString(GetStringWide(a,len,Solve(chrw),fnum))); // Return CRC32 of string.
    end
  else if t = 'i' then
    begin
    a := Solve(Explode(p1,',',0)); // Get string address.
    len := Solve(Explode(p1,',',1)); // Get max length.
    result := StrtoInt64(GetStrInt(a,len,fnum)); // Return string as integer.
    end
  else if t = 'find' then
    begin
    a := Solve(Explode(p1,',',0)); // Get start address.
    a2 := Solve(Explode(p1,',',1)); // Get end address.
    str := Explode(s,'"',1); // Get string to search for.
    for i := a to a2-Length(str) do
      if GetString(i,Length(str)) = str then
        begin
        result := i; // Return address where string was found.
        exit; // Stop searching.
        end;
    result := -1; // String was not found.
    end
  else if t = 'filesize' then
    begin
    if p1 = '' then fnum := 0 // {filesize} only has 1 parameter.
    else fnum := Solve(p1);
    if fnum < Length(filearrays) then result := Length(filearrays[fnum]) // Get file size.
    else result := 0; // 0 if file isn't loaded.
    end
  else result := 0; // Return nothing.
end;

function SolveStr(s: string): string; // Solve with output as string.
begin
  result := IntToStr(Solve(s));
end;

function SolveHex(s: string): string; // Solve with output as (hex) string.
begin
  result := '$'+IntToHex(Solve(s),1);
end;

{ ====== String functions. ====== }

{ Replicate MediaWiki's "explode" string function. }

function Explode(str, delimiter: string; n: integer): string; // Get substring from string using delimiter.
begin
  if (AnsiPos(delimiter,str) = 0) and ((n = 0) or (n = -1)) then result := str // Output full string if delimiter not found.
  else if AnsiPos(delimiter,str) = 0 then result := ''
  else
    begin
    str := str+delimiter;
    while n > 0 do
      begin
      Delete(str,1,AnsiPos(delimiter,str)+Length(delimiter)-1); // Trim earlier substrings and delimiters.
      Dec(n);
      end;
    Delete(str,AnsiPos(delimiter,str),Length(str)-AnsiPos(delimiter,str)+1); // Trim later substrings and delimiters.
    result := str;
    end;
end;

{ Full "explode" function, with negative substrings (i.e. reading from the right). }

function ExplodeFull(str, delimiter: string; n: integer): string;
var n2: integer;
begin
  if (AnsiPos(delimiter,str) = 0) and ((n = 0) or (n = -1)) then result := str // Output full string if delimiter not found.
  else if AnsiPos(delimiter,str) = 0 then result := ''
  else
    begin
    if n > -1 then // Check for negative substring.
      begin
      str := str+delimiter;
      n2 := n;
      end
    else
      begin
      delimiter := AnsiReverseString(delimiter);
      str := AnsiReverseString(str)+delimiter; // Reverse string for negative.
      n2 := Abs(n)-1;
      end;
    while n2 > 0 do
      begin
      Delete(str,1,AnsiPos(delimiter,str)+Length(delimiter)-1); // Trim earlier substrings and delimiters.
      Dec(n2);
      end;
    Delete(str,AnsiPos(delimiter,str),Length(str)-AnsiPos(delimiter,str)+1); // Trim later substrings and delimiters.
    if n < 0 then str := AnsiReverseString(str); // Un-reverse string if negative.
    result := str;
    end;
end;

{ Get first character from a string. }

function FirstChar(s: string): string;
begin
  if Length(s) = 0 then result := ''
  else result := s[1];
end;

{ ====== CRC functions. ====== }

{ Left rotate bits in longword. }

function rol(l: longword; i: integer): longword;
begin
  result := (l shl i)+(l shr (32-i));
end;

{ Change endianness. }

function swapendian(l: longword): longword;
begin
  result := (l shl 24)+(l shr 24)+((l shl 8) and $ff0000)+((l shr 8) and $ff00);
end;

function swapendian64(i: uint64): uint64;
var h, l: longword;
begin
  l := swapendian(i and $ffffffff); // Low longword.
  h := swapendian(i shr 32); // High longword.
  result := h + (l*$100000000); // Recombine as uint64.
end;

{ Get CRC32 of string. }

function CRCString(s: string): string;
var i: integer;
begin
  SetLength(hasharray,Length(s));
  for i := 0 to (Length(s)-1) do
    hasharray[i] := Ord(s[i+1]); // Copy string to array.
  result := CRCData();
end;

{ Get CRC32 of file. }

function CRCFile(fi: string): string;
begin
  { Open file and copy to array. }
  AssignFile(myfile,fi); // Get file.
  FileMode := fmOpenRead; // Read only.
  Reset(myfile,1);
  SetLength(hasharray,FileSize(myfile));
  BlockRead(myfile,hasharray[0],FileSize(myfile)); // Copy file to memory.
  CloseFile(myfile); // Close file.
  result := CRCData();
end;

{ Get CRC of data in array (from string or file). }

function CRCData: string;
var i, x: integer;
  r: longword;
begin
  r := $FFFFFFFF;
  for i := 0 to Length(hasharray)-1 do
    begin
    x := (hasharray[i] xor r) and $FF;
    r := (r shr 8) xor crctable[x];
    end;
  result := LowerCase(InttoHex(not r,8));
end;

{ Get SHA-1 of string. }

function SHA1String(s: string): string;
var i: integer;
  ml: uint64;
begin
  SetLength(hasharray,Length(s)+9+64-((Length(s)+9) mod 64)); // Pad data to multiple of 64.
  for i := 0 to 63 do
    hasharray[Length(hasharray)-1-i] := 0; // Clear last 64 bytes.
  for i := 0 to (Length(s)-1) do
    hasharray[i] := Ord(s[i+1]); // Copy string to array.
  hasharray[Length(s)] := $80; // Append bit.
  ml := Length(s)*8; // String length in bits.
  for i := 0 to 7 do
    hasharray[Length(hasharray)-1-i] := (ml shr (i*8)) and $ff; // Copy ml to end of array.
  result := SHA1Data();
end;

{ Get SHA-1 of file. }

function SHA1File(fi: string): string;
var i: integer;
  ml: uint64;
begin
  { Open file and copy to array. }
  AssignFile(myfile,fi); // Get file.
  FileMode := fmOpenRead; // Read only.
  Reset(myfile,1);
  SetLength(hasharray,FileSize(myfile)+9+64-((FileSize(myfile)+9) mod 64)); // Pad data to multiple of 64.
  for i := 0 to 63 do
    hasharray[Length(hasharray)-1-i] := 0; // Clear last 64 bytes.
  BlockRead(myfile,hasharray[0],FileSize(myfile)); // Copy file to array.
  hasharray[FileSize(myfile)] := $80; // Append bit.
  ml := FileSize(myfile)*8; // File size in bits.
  for i := 0 to 7 do
    hasharray[Length(hasharray)-1-i] := (ml shr (i*8)) and $ff; // Copy ml to end of array.
  CloseFile(myfile); // Close file.
  result := SHA1Data();
end;

{ Get SHA-1 of data in array (from string or file). }

function SHA1Data: string;
var h0,h1,h2,h3,h4,a,b,c,d,e,f,k,t: longword;
  w: array[0..79] of longword;
  i, j: integer;
begin
  h0 := $67452301; // Initialise variables.
  h1 := $EFCDAB89;
  h2 := $98BADCFE;
  h3 := $10325476;
  h4 := $C3D2E1F0;
  for j := 0 to ((Length(hasharray) div 64)-1) do
    begin
    for i := 0 to 15 do // Copy chunk into array.
      w[i] := (hasharray[(j*64)+(i*4)] shl 24)+(hasharray[(j*64)+(i*4)+1] shl 16)+(hasharray[(j*64)+(i*4)+2] shl 8)+hasharray[(j*64)+(i*4)+3];
    for i := 16 to 79 do // Extend chunk data.
      w[i] := rol((w[i-3] xor w[i-8] xor w[i-14] xor w[i-16]),1);
    a := h0;
    b := h1;
    c := h2;
    d := h3;
    e := h4;
    for i := 0 to 79 do
      begin
      if i < 20 then
        begin
        f := (b and c) or ((not b) and d);
        k := $5A827999;
        end
      else if i < 40 then
        begin
        f := b xor c xor d;
        k := $6ED9EBA1;
        end
      else if i < 60 then
        begin
        f := (b and c) or (b and d) or (c and d);
        k := $8F1BBCDC;
        end
      else
        begin
        f := b xor c xor d;
        k := $CA62C1D6;
        end;
      t := rol(a,5) + f + e + k + w[i];
      e := d;
      d := c;
      c := rol(b,30);
      b := a;
      a := t;
      end;
    h0 := h0 + a; // Add chunk result.
    h1 := h1 + b;
    h2 := h2 + c;
    h3 := h3 + d;
    h4 := h4 + e;
    end;
  result := AnsiLowerCase(InttoHex(h0)+InttoHex(h1)+InttoHex(h2)+InttoHex(h3)+InttoHex(h4));
end;

{ Get MD5 of string. }

function MD5String(s: string): string;
var i: integer;
  ml: uint64;
begin
  SetLength(hasharray,Length(s)+9+64-((Length(s)+9) mod 64)); // Pad data to multiple of 64.
  for i := 0 to 63 do
    hasharray[Length(hasharray)-1-i] := 0; // Clear last 64 bytes.
  for i := 0 to (Length(s)-1) do
    hasharray[i] := Ord(s[i+1]); // Copy string to array.
  hasharray[Length(s)] := $80; // Append bit.
  ml := Length(s)*8; // String length in bits.
  ml := swapendian64(ml); // Make it little endian.
  for i := 0 to 7 do
    hasharray[Length(hasharray)-1-i] := (ml shr (i*8)) and $ff; // Copy ml to end of array.
  result := MD5Data();
end;

{ Get MD5 of file. }

function MD5File(fi: string): string;
var i: integer;
  ml: uint64;
begin
  { Open file and copy to array. }
  AssignFile(myfile,fi); // Get file.
  FileMode := fmOpenRead; // Read only.
  Reset(myfile,1);
  SetLength(hasharray,FileSize(myfile)+9+64-((FileSize(myfile)+9) mod 64)); // Pad data to multiple of 64.
  for i := 0 to 63 do
    hasharray[Length(hasharray)-1-i] := 0; // Clear last 64 bytes.
  BlockRead(myfile,hasharray[0],FileSize(myfile)); // Copy file to array.
  hasharray[FileSize(myfile)] := $80; // Append bit.
  ml := FileSize(myfile)*8; // File size in bits.
  ml := swapendian64(ml); // Make it little endian.
  for i := 0 to 7 do
    hasharray[Length(hasharray)-1-i] := (ml shr (i*8)) and $ff; // Copy ml to end of array.
  CloseFile(myfile); // Close file.
  result := MD5Data();
end;

{ Get MD5 of data in array (from string or file). }

function MD5Data: string;
var h0,h1,h2,h3,a,b,c,d,f,g: longword;
  w: array[0..15] of longword;
  i, j: integer;
begin
  h0 := $67452301; // Initialise variables.
  h1 := $EFCDAB89;
  h2 := $98BADCFE;
  h3 := $10325476;
  for j := 0 to ((Length(hasharray) div 64)-1) do
    begin
    for i := 0 to 15 do // Copy chunk into array.
      w[i] := hasharray[(j*64)+(i*4)]+(hasharray[(j*64)+(i*4)+1] shl 8)+(hasharray[(j*64)+(i*4)+2] shl 16)+(hasharray[(j*64)+(i*4)+3] shl 24);
    a := h0;
    b := h1;
    c := h2;
    d := h3;
    for i := 0 to 63 do
      begin
      if i < 16 then
        begin
        f := (b and c) or ((not b) and d);
        g := i;
        end
      else if i < 32 then
        begin
        f := (d and b) or ((not d) and c);
        g := ((5*i) + 1) mod 16;
        end
      else if i < 48 then
        begin
        f := b xor c xor d;
        g := ((3*i) + 5) mod 16;
        end
      else
        begin
        f := c xor (b or (not d));
        g := (7*i) mod 16;
        end;
      f := f + a + md5table[i] + w[g];
      a := d;
      d := c;
      c := b;
      b := b + rol(f,md5shift[i]);
      end;
    h0 := h0 + a; // Add chunk result.
    h1 := h1 + b;
    h2 := h2 + c;
    h3 := h3 + d;
    end;
  result := AnsiLowerCase(InttoHex(swapendian(h0))+InttoHex(swapendian(h1))+InttoHex(swapendian(h2))+InttoHex(swapendian(h3)));
end;

{ ====== File functions. ====== }

{ Copy file to memory. }

procedure LoadFile(openthis: string; fnum: integer = 0);
begin
  if not FileExists(openthis) then exit;
  AssignFile(myfile,openthis); // Get file.
  FileMode := fmOpenRead; // Read only.
  Reset(myfile,1);
  if fnum+1 > Length(filearrays) then SetLength(filearrays,fnum+1);
  SetLength(filearrays[fnum],FileSize(myfile)); // Match array size to file size.
  BlockRead(myfile,filearrays[fnum][0],FileSize(myfile)); // Copy file to memory.
  CloseFile(myfile); // Close file.
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]); // Get file size.
  fpos := 0;
end;

{ Remove file from memory. }

procedure UnloadFile(fnum: integer = 0);
var i: integer;
begin
  if fnum < Length(filearrays)-1 then // Check if file isn't the last one.
    for i := fnum to Length(filearrays)-1 do
      begin
      SetLength(filearrays[i],Length(filearrays[i+1])); // Copy length from next file.
      Move(filearrays[i+1][0],filearrays[i][0],Length(filearrays[i+1])); // Copy next file into this one.
      end;
  SetLength(filearrays,Length(filearrays)-1);
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]); // Get file size.
  fpos := 0;
end;

{ Save file from memory to file. }

procedure SaveFile(savethis: string; fnum: integer = 0);
begin
  MakeFolder(savethis); // Create folder if needed.
  AssignFile(myfile,savethis); // Open file.
  FileMode := fmOpenReadWrite;
  ReWrite(myfile,1);
  BlockWrite(myfile,filearrays[fnum][0],Length(filearrays[fnum])); // Copy contents of array to file.
  CloseFile(myfile); // Close file.
end;

{ Save section of file to another file. }

procedure ClipFile(a, len: integer; clipthisfile: string; fnum: integer = 0);
begin
  if a+len > Length(filearrays[fnum]) then len := Length(filearrays[fnum])-a; // Don't allow clip to extend outside file.
  if a > Length(filearrays[fnum]) then len := 0;
  MakeFolder(clipthisfile); // Create folder if needed.
  AssignFile(myfile,clipthisfile); // Open file.
  FileMode := fmOpenReadWrite;
  ReWrite(myfile,1);
  BlockWrite(myfile,filearrays[fnum][a],len); // Copy contents of array to file.
  CloseFile(myfile); // Close file.
end;

{ Create new blank file. }

procedure NewFile(filelen: integer; fnum: integer = 0);
begin
  if fnum+1 > Length(filearrays) then SetLength(filearrays,fnum+1);
  if Length(filearrays[fnum]) > 0 then FillChar(filearrays[fnum][0],Length(filearrays[fnum]),0); // Fill existing file with 0.
  SetLength(filearrays[fnum],filelen);
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := filelen;
  fpos := 0;
end;

{ Add file to existing file array. }

procedure AppendFile(a: integer; addthisfile: string; fnum: integer = 0);
begin
  if not FileExists(addthisfile) then exit;
  AssignFile(myfile,addthisfile); // Get file.
  FileMode := fmOpenRead; // Read only.
  Reset(myfile,1);
  if Length(filearrays[fnum]) < a+FileSize(myfile) then SetLength(filearrays[fnum],a+FileSize(myfile)); // Enlarge file if needed.
  BlockRead(myfile,filearrays[fnum][a],FileSize(myfile)); // Copy file to array.
  CloseFile(myfile); // Close file.
  if fnum > 0 then exit; // Only update fs for primary file.
  fs := Length(filearrays[fnum]);
end;

{ Make filesize even. }

procedure EvenFile(fnum: integer = 0);
begin
  if not Odd(Length(filearrays[fnum])) then exit;
  SetLength(filearrays[fnum],Length(filearrays[fnum])+1); // Add 1 byte to end if odd.
  if fnum > 0 then exit; // Only update fs for primary file.
  Inc(fs);
end;

{ Get byte from file array. }

function GetByte(a: int64; fnum: integer = 0): byte;
begin
  if (a < Length(filearrays[fnum])) and (fnum < Length(filearrays)) then result := filearrays[fnum][a]
  else result := 0;
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a+1;
end;

{ Get bit from file array. }

function GetBit(a: int64; b: integer; fnum: integer = 0): byte;
begin
  result := Bit(GetByte(a,fnum),b);
end;

{ Get bit from integer. }

function Bit(i, b: integer): byte;
begin
  result := (i and (1 shl b)) shr b;
end;

{ Get word from file array. }

function GetWord(a: int64; fnum: integer = 0): word;
begin
  result := (GetByte(a,fnum)*$100)+GetByte(a+1,fnum);
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a+2;
end;

{ Get longword from file array. }

function GetDword(a: int64; fnum: integer = 0): longword;
begin
  result := (GetWord(a,fnum)*$10000)+GetWord(a+2,fnum);
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a+4;
end;

{ Get word (little endian) from file array. }

function GetWordRev(a: int64; fnum: integer = 0): word;
begin
  result := (GetByte(a+1,fnum)*$100)+GetByte(a,fnum);
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a+2;
end;

{ Get longword (little endian) from file array. }

function GetDwordRev(a: int64; fnum: integer = 0): longword;
begin
  result := (GetWordRev(a+2,fnum)*$10000)+GetWordRev(a,fnum);
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a+4;
end;

{ Get string from file array. }

function GetString(a, maxlength: int64; fnum: integer = 0): string;
begin
  result := '';
  while maxlength > 0 do
    begin
    Dec(maxlength);
    if GetByte(a,fnum) in [32..126] then result := result+Chr(GetByte(a,fnum)) // Add character to string if valid.
    else maxlength := 0; // Otherwise end the string.
    Inc(a); // Next character.
    end;
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a;
end;

{ As above, but allows for spaces between each letter. }

function GetStringWide(a, maxlength, charw: int64; fnum: integer = 0): string;
begin
  result := '';
  while maxlength > 0 do
    begin
    Dec(maxlength);
    if GetByte(a,fnum) in [32..126] then result := result+Chr(GetByte(a,fnum)) // Add character to string if valid.
    else maxlength := 0; // Otherwise end the string.
    a := a+charw; // Next character.
    end;
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a;
end;

{ Get string integer from file array. }

function GetStrInt(a, maxlength: int64; fnum: integer = 0): string;
var b: byte;
begin
  result := '';
  while maxlength > 0 do
    begin
    Dec(maxlength);
    b := GetByte(a,fnum);
    if b in [48..57] then result := result+Chr(b) // Add character to string if valid.
    else if (b = 32) and (result = '') then result := result // Ignore leading spaces.
    else maxlength := 0; // Otherwise end the string.
    Inc(a); // Next character.
    end;
  if result = '' then result := '0'; // Return 0 if no string is found.
  if fnum > 0 then exit; // Only update fpos for primary file.
  fpos := a;
end;

{ Write single byte to file array. }

procedure WriteByte(a: int64; b: byte; fnum: integer = 0);
begin
  if fnum >= Length(filearrays) then exit;
  if Length(filearrays[fnum]) < a+1 then SetLength(filearrays[fnum],a+1); // Enlarge file if needed.
  filearrays[fnum][a] := b;
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]);
  fpos := a+1;
end;

{ Write word to file array. }

procedure WriteWord(a: int64; w: word; fnum: integer = 0);
begin
  if fnum >= Length(filearrays) then exit;
  if Length(filearrays[fnum]) < a+2 then SetLength(filearrays[fnum],a+2); // Enlarge file if needed.
  filearrays[fnum][a] := w shr 8;
  filearrays[fnum][a+1] := w and $FF;
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]);
  fpos := a+2;
end;

{ Write word (little endian) to file array. }

procedure WriteWordRev(a: int64; w: word; fnum: integer = 0);
begin
  if fnum >= Length(filearrays) then exit;
  if Length(filearrays[fnum]) < a+2 then SetLength(filearrays[fnum],a+2); // Enlarge file if needed.
  filearrays[fnum][a+1] := w shr 8;
  filearrays[fnum][a] := w and $FF;
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]);
  fpos := a+2;
end;

{ Write longword to file array. }

procedure WriteDword(a: int64; d: longword; fnum: integer = 0);
begin
  if fnum >= Length(filearrays) then exit;
  if Length(filearrays[fnum]) < a+4 then SetLength(filearrays[fnum],a+4); // Enlarge file if needed.
  WriteWord(a,d shr 16);
  WriteWord(a+2,d and $FFFF);
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]);
  fpos := a+4;
end;

{ Write longword (little endian) to file array. }

procedure WriteDwordRev(a: int64; d: longword; fnum: integer = 0);
begin
  if fnum >= Length(filearrays) then exit;
  if Length(filearrays[fnum]) < a+4 then SetLength(filearrays[fnum],a+4); // Enlarge file if needed.
  WriteWordRev(a+2,d shr 16);
  WriteWordRev(a,d and $FFFF);
  if fnum > 0 then exit; // Only update fs/fpos for primary file.
  fs := Length(filearrays[fnum]);
  fpos := a+4;
end;

{ Run an external program. }

procedure RunCommand(command: string);
var StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
begin
  FillChar(StartInfo,SizeOf(TStartupInfo),#0);
  FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
  StartInfo.cb := SizeOf(TStartupInfo);
  if CreateProcess(nil,PChar(command),nil,nil,false,CREATE_NEW_PROCESS_GROUP+NORMAL_PRIORITY_CLASS+CREATE_NO_WINDOW,nil,nil,StartInfo,ProcInfo) then
    begin
    CloseHandle(ProcInfo.hThread);
    WaitForSingleObject(ProcInfo.hProcess,INFINITE);
    CloseHandle(ProcInfo.hProcess);
    end
  else
    {$IFDEF GUI_APP}
    ShowMessage('Failed to execute command: '+SysErrorMessage(GetLastError));
    {$ELSE}
    WriteLn('Failed to execute command: '+SysErrorMessage(GetLastError));
    {$ENDIF}
end;

{ Check if a file is in use by another program. }

function FileInUse(f: string): boolean;
var FileHandle: THandle;
begin
  Result := false;
  try
    FileHandle := FileOpen(f, fmOpenWrite or fmShareExclusive);  // Attempt to open the file in exclusive mode.
    if FileHandle <> THandle(-1) then FileClose(FileHandle) // File is not in use, close the handle.
    else Result := True; // File is in use by another program.
  except
    Result := True; // An exception occurred while opening the file.
  end;
end;

{ List subfolders in a specified folder; the results are stored in folderlist array. }

procedure ListFolders(dir: string; subfolders: boolean);
var rec: TSearchRec;
  i: integer;
begin
  SetLength(folderlist,1);
  folderlist[0] := '\'; // First folder is current one.
  i := 0;
  while i < Length(folderlist) do
    begin
    if FindFirst(dir+'\'+folderlist[i]+'*.*',faDirectory,rec) = 0 then
      begin
      repeat
      if (rec.Name<>'.') and (rec.Name<>'..') and ((rec.attr and faDirectory)=faDirectory) then
        begin
        SetLength(folderlist,Length(folderlist)+1); // Add 1 slot for folder name.
        folderlist[Length(folderlist)-1] := folderlist[i]+rec.Name+'\'; // Add folder name to array.
        end;
      until FindNext(rec) <>0;
      Sysutils.FindClose(rec);
      end;
    Inc(i);
    if not subfolders then exit; // Only run once if subfolders aren't wanted.
    end;
end;

{ List files in a specified folder; the results are stored in filelist array. }

procedure ListFiles(dir: string; subfolders: boolean);
var rec: TSearchRec;
  i: integer;
begin
  SetLength(filelist,0); // Assume no files.
  if subfolders then ListFolders(dir,true) // Create list of folders.
  else
    begin
    SetLength(folderlist,1);
    folderlist[0] := '\'; // Only folder is current one.
    end;
  for i := 0 to Length(folderlist)-1 do
    begin
    if FindFirst(dir+folderlist[i]+'*.*',faAnyFile-faDirectory,rec) = 0 then
      begin
      repeat
        begin
        SetLength(filelist,Length(filelist)+1); // Add slot to filelist.
        filelist[Length(filelist)-1] := folderlist[i]+rec.Name; // Add file name to array.
        end;
      until FindNext(rec) <> 0;
      Sysutils.FindClose(rec);
      end;
    end;
end;

{ Read base64 from file and convert to binary in file array. }

procedure GetBase64(a, a2: int64; fnum, fnum2: integer);
var b: byte;
  pos: integer;
label loop;
begin
  pos := a2*8; // Set initial position in bits.

loop:
  b := ByteToBase64(GetByte(a,fnum));
  if b = 64 then // Stop at invalid or terminator character (=), or end of file.
    begin
    SetLength(filearrays[fnum2],pos div 8); // Trim excess byte.
    exit;
    end;
  a2 := pos div 8; // Get current output byte.
  case pos mod 8 of
    0:
      begin
      WriteByte(a2,b shl 2,fnum2);
      end;
    6:
      begin
      WriteByte(a2,(GetByte(a2,fnum2) and $FC)+(b shr 4),fnum2);
      WriteByte(a2+1,(b shl 4) and $F0,fnum2);
      end;
    4:
      begin
      WriteByte(a2,(GetByte(a2,fnum2) and $F0)+(b shr 2),fnum2);
      WriteByte(a2+1,(b shl 6) and $C0,fnum2);
      end;
    2:
      begin
      WriteByte(a2,(GetByte(a2,fnum2) and $C0)+b,fnum2);
      end;
  end;
  Inc(a); // Next byte.
  fpos := a;
  pos := pos+6; // Next 6 bits.
  goto loop; // Repeat.
end;

{ Convert a character (as byte) to its base64 value. }

function ByteToBase64(c: byte): byte;
begin
  if (c >= Byte('A')) and (c <= Byte('Z')) then result := c-Byte('A')
  else if (c >= Byte('a')) and (c <= Byte('z')) then result := c-Byte('a')+26
  else if (c >= Byte('0')) and (c <= Byte('9')) then result := c-Byte('0')+52
  else if c = Byte('+') then result := 62
  else if c = Byte('/') then result := 63
  else result := 64;
end;

{ Create folder if one doesn't exist. }

procedure MakeFolder(f: string);
begin
  if DirectoryExists(ExtractFileDir(f)) then exit; // Do nothing if folder exists.
  if AnsiPos(':',f) = 0 then // Check if path is relative or absolute.
    ForceDirectories(GetCurrentDir+'\'+ExtractFileDir(f)) // Create folder.
  else
    ForceDirectories(ExtractFileDir(f));
end;

end.