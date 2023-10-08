program PDepak;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  FileFunc in 'FileFunc.pas';

var
  i, p: int64;
  outfolder, outfile: string;

begin
  { Program start }

  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: depak file.pak [outputfolder]');
    exit;
    end;
  outfolder := ParamStr(2);
  if outfolder <> '' then
    begin
    if not DirectoryExists(outfolder) then CreateDir(outfolder); // Create output folder if needed.
    outfolder := outfolder+'\'; // Append backslash.
    end;

  LoadFile(ParamStr(1)); // Load file to memory.

  if (GetDword(0) = 0) and (GetDword(GetDword(4)) = 0) and (GetByte(GetDword(4)+$10) = $49) then
    begin
    i := 4;
    while GetDword(i) > 0 do
      begin
      p := GetDword(i); // Get address of subfile header.
      outfile := outfolder+GetString(p+$12,GetDword(p+$C)); // Get subfile name.
      ClipFile(p+$10+GetDword(p+$C),GetDword(p+4),outfile); // Export file.
      i := i+4; // Next subfile.
      end;
    end;
end.