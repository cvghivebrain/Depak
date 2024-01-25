program PDepak;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils,
  FileFunc in 'FileFunc.pas';

var
  i, j, p, w, h: int64;
  outfolder, outfile: string;

begin
  { Program start }

  if ParamCount < 1 then // Check if program was run with parameters.
    begin
    WriteLn('Usage: depak file.pak [outputfolder|outputfile]');
    exit;
    end;
  outfolder := ParamStr(2);
  outfile := ParamStr(2);
  if (outfolder <> '') and (ExtractFileExt(outfile) = '') then
    begin
    if not DirectoryExists(outfolder) then CreateDir(outfolder); // Create output folder if needed.
    outfolder := outfolder+'\'; // Append backslash.
    end;
  if outfile = '' then outfile := ParamStr(1)+'.out';

  LoadFile(ParamStr(1)); // Load file to memory.

  { Alone in the Dark 2 PAK }
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
    end

  { Sonic the Hedgehog level }
  else if (GetByte(0)+1)*(GetByte(1)+1) = fs-2 then
    begin
    NewFileOutput($80*8); // Create blank file.
    w := GetByte(0)+1;
    h := GetByte(1)+1;
    for i := 0 to h-1 do
      for j := 0 to w-1 do
        WriteByteOutput((i*$80)+j,GetByte(2+j+(i*w)));
    SaveFileOutput(outfile); // Export file.
    end;
end.