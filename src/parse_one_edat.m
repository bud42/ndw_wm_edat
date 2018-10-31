function [D,edat_basename] = parse_one_edat(edat_file)

% Load the edat data
D = readtable(edat_file,'Delimiter','tab');

% Just keep the ProbeProc rows (these have the needed info) and the columns
% we care about
D = D(strcmp(D.Procedure_Trial_,'ProbeProc'), ...
	{'ProbeDisp_CRESP','ProbeDisp_RESP','ProbeDisp_ACC', ...
	'ProbeDisp_RT','StateName'} );
D.StateName = categorical(D.StateName);

% Label by task condition
D.Task = categorical(D.StateName,{'Probe1','Probe2'},{'WM','CTL'});

% Label hits, misses, etc
D.YesTrial = D.ProbeDisp_CRESP==7;
D.NoTrial = D.ProbeDisp_CRESP==8;
D.YesResponse = D.ProbeDisp_RESP==7;
D.NoResponse = D.ProbeDisp_RESP==8;

D.Hit = D.YesTrial & D.YesResponse;
D.Miss = D.YesTrial & D.NoResponse;
D.CorrectRejection = D.NoTrial & D.NoResponse;
D.FalseAlarm = D.NoTrial & D.YesResponse;

% Responses that are bad for other reason (no response, multiple response,
% etc)
D.BadResponse = ~D.Hit & ~D.CorrectRejection & ~D.Miss & ~D.FalseAlarm;

% Add the edat filename
q = strsplit(edat_file,'/');
edat_basename = q{end};
D.EdatFile = repmat({edat_basename},height(D),1);

