unit rle;

interface
type
	TRun = record
		count: byte;
		value: byte;
	end;
	TRuns = record 
		dat : array of TRun;
		siz : size_t;
		old_siz : size_t;
	end;
	bytearr = array of byte;

var 
	oddCounter: boolean = true;
	
function newRun(count, val: byte): TRun;
function getRuns(raw_data : array of byte): TRuns;
function runsToByteArr(runs : TRuns): bytearr;
function decodeBin(raw : bytearr) : TRuns;

implementation

function newRun(count, val: byte): TRun;
begin
	newRun.count := count;
	newRun.value := val;
end;

function getRuns(raw_data : array of byte): TRuns;
var
	count: byte;
	val: byte;
	indx, runindx: size_t;
	ret: TRuns;
begin
	count := 1;
	val := raw_data[0];
	runindx := 0;
	setLength(ret.dat, high(raw_data));
	for indx := 0 to high(raw_data)-1 do
	begin
		if raw_data[indx] <> raw_data[indx+1] then
		begin
			ret.dat[runindx] := newRun(count, val);
			count := 1;
			val := raw_data[indx+1];
			runindx := runindx + 1;
		end
		else count := count + 1;
	end;
	ret.dat[runindx] := newRun(count, val);
	runindx := runindx + 1;
	ret.siz := runindx;
	ret.old_siz := high(raw_data);
	setLength(ret.dat, ret.siz+1);
	getRuns := ret;
end;

function runsToByteArr(runs : TRuns): bytearr;
var
	i, outindx : size_t;
	ret : bytearr;
begin
	outindx := 0;
	setLength(ret, runs.old_siz);
	for i := 0 to runs.siz do
	begin
		if oddCounter then
		begin
			ret[outindx] := runs.dat[i].count;
			ret[outindx+1] := runs.dat[i].value;
		end
		else
		begin
			ret[outindx] := runs.dat[i].value;
			ret[outindx+1] := runs.dat[i].count;
		end;
		outindx := outindx + 2;
	end;
	setLength(ret, outindx+1);
	runsToByteArr := ret;
end;

function decodeBin(raw : bytearr) : TRuns;
var
	bindx, indx : size_t;
	ret : TRuns;
begin
	setLength(ret.dat, high(raw));
	bindx := 0;
	indx := 0;
	while indx <> high(raw)-1 do
	begin
		if oddCounter then
		begin
			ret.dat[bindx] := newRun(raw[indx], raw[indx+1]);
		end
		else
		begin
			ret.dat[bindx] := newRun(raw[indx+1],raw[indx]);
		end;
		bindx := bindx + 1;
		indx := indx + 2;
	end;
	decodeBin := ret;
end;

initialization

finalization
	
end.
