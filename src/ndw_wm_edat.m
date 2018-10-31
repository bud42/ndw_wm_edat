function ndw_wm_edat(in_dir,out_dir)

warning('off','MATLAB:table:ModifiedVarnames')

% Get inputs from INPUTS directory
d = dir([in_dir '/*.txt']);
edat_files = strcat(in_dir,'/',{d.name}');

fid = fopen([in_dir '/project'],'rt');
project = fscanf(fid,'%s',[1 1]);
fclose(fid);

fid = fopen([in_dir '/subject'],'rt');
subject = fscanf(fid,'%s',[1 1]);
fclose(fid);

fid = fopen([in_dir '/session'],'rt');
session = fscanf(fid,'%s',[1 1]);
fclose(fid);

% Now parse the files and save trial info
for e = 1:length(edat_files)
	[D,eb] = parse_one_edat(edat_files{e});
	if e==1
		allD = D;
		edat_basenames = {eb};
	else
		allD = [allD;D];
		edat_basenames{e} = eb;
	end
end

writetable(allD,fullfile(out_dir,'trialinfo.csv'));


% Compute some quantities of interest. The denominator is the number of
% RELEVANT trials (yes/no), not ALL trials from the condition. We ignore
% control condition because the specific responses there are not meaningful.
ctl = allD.Task=='CTL';
wm = allD.Task=='WM';
yes = allD.YesTrial;
no = allD.NoTrial;
good = ~allD.BadResponse;

info = struct();

info.NumEdatFiles = length(edat_files);

info.CTL_Trials = sum(ctl&good);
info.CTL_BadResponseTrials = sum(allD.BadResponse(ctl));
info.CTL_BadResponseRate = info.CTL_BadResponseTrials / sum(ctl);

info.WM_YesTrials = sum(wm&yes&good);
info.WM_NoTrials = sum(wm&no&good);
info.WM_BadResponseTrials = sum(allD.BadResponse(wm));

info.WM_Hits = sum(allD.Hit(wm));
info.WM_Misses = sum(allD.Miss(wm));
info.WM_CorrectRejections = sum(allD.CorrectRejection(wm));
info.WM_FalseAlarms = sum(allD.FalseAlarm(wm));

info.WM_HitRate = info.WM_Hits / info.WM_YesTrials;
info.WM_MissRate = info.WM_Misses / info.WM_YesTrials;
info.WM_CorrectRejectionRate = info.WM_CorrectRejections / info.WM_NoTrials;
info.WM_FalseAlarmRate = info.WM_FalseAlarms / info.WM_NoTrials;
info.WM_BadResponseRate = info.WM_BadResponseTrials / sum(wm);

info.WM_DPrime_Raw = info.WM_HitRate - info.WM_FalseAlarmRate;

% Z for d prime has an issue at the extremes:
% https://stats.stackexchange.com/questions/134779/d-prime-with-100-hit-rate-probability-and-0-false-alarm-probability
% We adjust using loglinear approach
H = (info.WM_Hits+0.5) / (info.WM_YesTrials+1);
F = (info.WM_FalseAlarms+0.5) / (info.WM_NoTrials+1);
info.WM_DPrime_Zloglin = norminv(H) - norminv(F);

info.CTL_RT_median = median(allD.ProbeDisp_RT(good & ctl));
info.CTL_RT_mean = mean(allD.ProbeDisp_RT(good & ctl));
info.WM_CorrectRT_median = median( ...
	allD.ProbeDisp_RT((allD.Hit | allD.CorrectRejection) & wm) );
info.WM_CorrectRT_mean = mean( ...
	allD.ProbeDisp_RT((allD.Hit | allD.CorrectRejection) & wm) );
info.WM_ErrorRT_median = median( ...
	allD.ProbeDisp_RT((allD.Miss | allD.FalseAlarm) & wm) );
info.WM_ErrorRT_mean = mean( ...
	allD.ProbeDisp_RT((allD.Miss | allD.FalseAlarm) & wm) );


% Save to file
writetable(struct2table(info),fullfile(out_dir,'summary.csv'));


% Write a text file to convert to PDF
edatfilestr = [];
for e = 1:length(edat_files)
	edatfilestr = [edatfilestr edat_basenames{e} '\n'];
end
summarytext = sprintf( ...
	[ ...
	'Project                       %s \n' ...
	'Subject                       %s \n' ...
	'Session                       %s \n' ...
	'--------------------------------------------- \n' ...
	edatfilestr ...
	'--------------------------------------------- \n' ...
	],project,subject,session);

for f = fields(info)'
	thisstr = sprintf('%30s  %f\n',f{1},info.(f{1}));
	summarytext = [summarytext thisstr];
end
summarytext = [summarytext '---------------------------------------------'];

pdf_figure = openfig('report.fig','new');
figH = guihandles(pdf_figure);
set(figH.summarytext, 'String', summarytext)
print(pdf_figure,'-dpdf',fullfile(out_dir,'report.pdf'))

close(pdf_figure)

end
