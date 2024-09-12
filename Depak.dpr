program PDepak;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  SolveFunc in 'SolveFunc.pas';

var
  outname, mode: string;

{ Alone in the Dark 2 PAK }
procedure PAK;
var i: integer;
  subhead: int64;
  subname: string;
begin
  WriteLn('Alone in the Dark 2 PAK');
  i := 4;
  while GetDword(i) > 0 do
    begin
    subhead := GetDword(i); // Get address of subfile header.
    subname := outname+'\'+GetString(subhead+$12,GetDword(subhead+$C)); // Get subfile name.
    ClipFile(subhead+$10+GetDword(subhead+$C),GetDword(subhead+4),subname); // Export file.
    i := i+4; // Next subfile.
    end;
end;

{ Sonic the Hedgehog level }
procedure S1LVL;
var w, h, i, j: integer;
begin
  WriteLn('Sonic the Hedgehog level');
  NewFile($80*8,1); // Create blank level file ($80 wide, 8 high).
  w := GetByte(0)+1;
  h := GetByte(1)+1;
  for i := 0 to h-1 do
    for j := 0 to w-1 do
      WriteByte((i*$80)+j,GetByte(2+j+(i*w)),1);
  SaveFile(outname,1); // Export file.
end;

begin
  { Program start }
  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: depak file.pak [outputfolder|outputfile]');
    exit;
    end;
  if not FileExists(ParamStr(1)) then
    begin
    WriteLn(ParamStr(1)+' not found.');
    exit;
    end;
  outname := ParamStr(2);
  if FirstChar(outname) = '-' then
    begin
    mode := outname;
    outname := '';
    end;
  if ParamStr(3) <> '' then mode := ParamStr(3);
  if (outname <> '') and (ExtractFileExt(outname) = '') then
    begin
    if not DirectoryExists(outname) then CreateDir(outname); // Create output folder if needed.
    end;
  if outname = '' then outname := ParamStr(1)+'.out'; // Use input file name with suffix if output was blank.

  LoadFile(ParamStr(1)); // Load file to memory.

  if mode = '-pak' then PAK
  else if mode = '-s1lvl' then S1LVL
  else // mode not set, so check file contents.
    begin
    if (GetDword(0) = 0) and (GetDword(GetDword(4)) = 0) and (GetByte(GetDword(4)+$10) = $49) then PAK
    else if (GetByte(0)+1)*(GetByte(1)+1) = fs-2 then S1LVL;
    end;
end.