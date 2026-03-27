function powerfilter2
% UI Figure to filter power output from Gen-1 pump controller
% new version for 2026
N=80;	% initial length of running average
fs=40;	% initial (assumed) sample rate.  This is only used approximately,
			% to set the number of lines to read in one second and then
			% update the display

figh=figure('name','Power Filter 2.0','numbertitle','off', ...
	'SizeChangedFcn',@resizeFcn,'DeleteFcn',@figDeleteFcn);
	% 'units','normalized','position',[0.23 0.15 0.6 0.7], ...
poph=uicontrol(figh,'style','popupmenu', ...
	'string',{'Choose Port'},'fontsize',14, 'Callback',@selectSerial);
Ntexth=uicontrol(figh,'style','text','String','N','fontsize',14);
editNh=uicontrol(figh,'style','edit', ...
	'String',num2str(N),'fontsize',14, 'Callback',@changeN);
fsTexth=uicontrol(figh,'style','text','String','fs','fontsize',14);
editfsh=uicontrol(figh,'style','edit', ...
	'String',num2str(fs),'fontsize',14,'Callback',@changefs);
durh=uicontrol(figh,'style','text','String','2.00 sec','fontsize',14);
runh=uicontrol(figh,'style','togglebutton','String','Run','fontsize',14, ...
	'Enable','off','Callback',@runButton,'interruptible','on');
saveh=uicontrol(figh,'style','checkbox','String','Save','fontsize',14, ...
	'Value',1);
alarmsLabelh=uicontrol(figh,'style','text','String','Alarms','fontsize',14);
powLabelh=uicontrol(figh,'style','text','String','Power Alarm','fontsize',14);
editPowh=uicontrol(figh,'style','edit', ...
	'String','5.00','fontsize',14, 'Callback',@changePowAlarm);
curLabelh=uicontrol(figh,'style','text', ...
	'String','Current Alarm','fontsize',14);
editCurh=uicontrol(figh,'style','edit', ...
	'String','2.000','fontsize',14, 'Callback',@changeCurAlarm);
powerh=uicontrol(figh,'style','text','position',[200 330 600 280], ...
	'String','0.00','backgroundcolor',[1 0.85 0.85], ...
	'tooltip','Filtered Power (Watts)');
currenth=uicontrol(figh,'style','text','position',[200 20 600 280], ...
	'String','0.000','backgroundcolor',[0.8 1 1], ...
	'tooltip','Filtered Current (Amps)');

set(figh,'UserData',struct('poph',poph,'fsTexth',fsTexth,'editfsh',editfsh, ...
	'Ntexth',Ntexth,'editNh',editNh,'durh',durh,'runh',runh, ...
	'saveh',saveh,'alarmsLabelh',alarmsLabelh,'powLabelh',powLabelh, ...
	'editPowh',editPowh,'curLabelh',curLabelh,'editCurh',editCurh, ...
	'powerh',powerh,'currenth',currenth, ...
	'N',N,'fs',fs,'PowData',zeros(N,1),'PowSum',0,'phIData',zeros(N,1), ...
	'phISum',0,'idx',1,'port',0,'PowLim',5,'CurrLim',2,'fp',0));

strs=serialportlist('available');
len=length(strs);
lines=cell(len+1,1);
lines{1}='Choose Port';
for k=1:len
	lines{k+1}=strs(k);
end
poph.String=lines;
resizeFcn(figh,0);
end

function resizeFcn(src,~) 
	size=src.Position;
	winw=size(3);	winh=size(4);
	pos=[20 winh-40 100 22];	% select port popup
	src.UserData.poph.Position=pos;
	y=65+0.84*(winh-105);
	pos=[20 y+27 100 22];		% fs label
	src.UserData.fsTexth.Position=pos;
	pos=[20 y 100 20];			% fs edit box
	src.UserData.editfsh.Position=pos;
	y=65+0.69*(winh-105);
	pos=[20 y+27 100 22];		% N label
	src.UserData.Ntexth.Position=pos;
	pos=[20 y 100 20];			% N edit box
	src.UserData.editNh.Position=pos;
	pos=[20 y-27 100 22];			% dur label
	src.UserData.durh.Position=pos;
	y=65+0.460*(winh-105);
	pos=[20 y 100 40];			% Run button
	src.UserData.runh.Position=pos;
	pos=[20 y-27 100 22];			% Save checkbox
	src.UserData.saveh.Position=pos;
	y=65+0.27*(winh-105);
	pos=[20 y 100 25];		% alarms label
	src.UserData.alarmsLabelh.Position=pos;
	y=65+0.143*(winh-105);
	pos=[20 y+27 100 22];		% power alarm label
	src.UserData.powLabelh.Position=pos;
	pos=[20 y 100 20];		% power alarm edit box
	src.UserData.editPowh.Position=pos;
	pos=[20 47 100 22];		% current alarm label
	src.UserData.curLabelh.Position=pos;
	pos=[20 20 100 20];		% current alarm edit box
	src.UserData.editCurh.Position=pos;
	w=winw-210;	h=(winh-70)/2;
	fontsize=min([0.29*w 0.625*h]);
	pos=[150, h+50, w, h];	% Power display
	src.UserData.powerh.Position=pos;
	src.UserData.powerh.FontSize=fontsize;
	pos=[150, 20, w, h];	% current display
	src.UserData.currenth.Position=pos;
	src.UserData.currenth.FontSize=fontsize;
end

% callback for selecting serial port
function selectSerial(src,~)
	N=src.Value;
	if (N>1)
		portname=src.String{N};
		port=serialport(portname,38400);
		src.Parent.UserData.port=port;
		src.Parent.UserData.runh.Enable='on';
	end
end

% callback for editing value of fs in edit box
function changefs(src,~)
	[x,tf]=str2num(src.String);
	if (tf)		% limit fs to integers in range
		x=max([2,x]);
		x=min([x,100]);
		fs=round(x);
		src.Parent.UserData.fs=fs;
		src.String=num2str(fs);
		dur=src.Parent.UserData.N/fs;
		src.Parent.UserData.durh.String=sprintf('%4.2f sec',dur);
	else	% numeric conversion failed
		fs=src.Parent.UserData.fs;
		src.String=num2str(fs);	% restore previous value
		beep
	end

end

% callback for editing value of N in edit box
function changeN(src,~)
	[x,tf]=str2num(src.String);
	if (tf)		% limit N to integers and reset running averages
		meanPow=src.Parent.UserData.PowSum/src.Parent.UserData.N;
		meanphI=src.Parent.UserData.phISum/src.Parent.UserData.N;
		x=max([2,x]);
		x=min([x,6000]);
		N=round(x);
		src.Parent.UserData.N=N;
		src.String=num2str(N);
		src.Parent.UserData.PowData=ones(N,1)*meanPow;
		src.Parent.UserData.PowSum=N*meanPow;
		src.Parent.UserData.phIData=ones(N,1)*meanphI;
		src.Parent.UserData.phISum=N*meanphI;
		src.Parent.UserData.idx=1;
		dur=N/src.Parent.UserData.fs;
		src.Parent.UserData.durh.String=sprintf('%4.2f sec',dur);
	else	% numeric conversion failed
		N=src.Parent.UserData.N;
		src.String=num2str(N);	% restore previous value
		beep
	end
end

% callback for pushing "Run" button
% this runs continuously until it interrupts itself with a 2nd push
function runButton(src,~)
if (~src.Value)
	% this is the only part that will run during an interrupt
	src.String='Run';
	src.Parent.UserData.editfsh.Enable='on';
	src.Parent.UserData.editNh.Enable='on';
	src.Parent.UserData.saveh.Enable='on';
else
	src.String='Stop';
	src.Parent.UserData.editfsh.Enable='off';
	src.Parent.UserData.editNh.Enable='off';
	src.Parent.UserData.saveh.Enable='off';
	N=src.Parent.UserData.N;
	port=src.Parent.UserData.port;
	if (port~=0)
		saveflag=src.Parent.UserData.saveh.Value;
		if (saveflag)
			namestr=['NIH',char(datetime('now','TimeZone','local','Format','yyMMddHHmmss')),'.txt'];
			fp=fopen(namestr,'wt');
		end
		% this loop ends after an interrupt changes src.Value to 0
		% also test for case of figure deletion during the loop
		while (ishghandle(src) && src.Value)	
			flush(port);
			readline(port);
			% read fs serial lines - should be 1 second total
			for k=1:src.Parent.UserData.fs	
				serline=readline(port);
				[token1,remain]=strtok(serline,',');
				[token2,remain]=strtok(remain,',');
				[token3,remain]=strtok(remain,',');
				[token4,remain]=strtok(remain,',');
				[token5,remain]=strtok(remain,',');
				[token6,remain]=strtok(remain,',');	% current
				[token7,remain]=strtok(remain,',');
				[token8,remain]=strtok(remain,',');
				[token9,remain]=strtok(remain,',');	% power
				current=str2num(token6);
				power=str2num(token9);
				% replace latest power and current in the moving averages
				idx=src.Parent.UserData.idx;
				src.Parent.UserData.PowSum=src.Parent.UserData.PowSum ...
					-src.Parent.UserData.PowData(idx)+power;
				src.Parent.UserData.PowData(idx)=power;
				src.Parent.UserData.phISum=src.Parent.UserData.phISum ...
					-src.Parent.UserData.phIData(idx)+current;
				src.Parent.UserData.phIData(idx)=current;
				if (idx==N)
					idx=1;
				else
					idx=idx+1;
				end
				src.Parent.UserData.idx=idx;
			end
			assignin('base','line',serline)
			assignin('base','current',current)
			assignin('base','power',power)
			filtPow=src.Parent.UserData.PowSum/N;
			filtphI=src.Parent.UserData.phISum/N;
			src.Parent.UserData.powerh.String=sprintf('%.2f',filtPow);
			src.Parent.UserData.currenth.String=sprintf('%.3f',filtphI);
			if (saveflag)
				fprintf(fp,'%s, %5.3f, %4.2f\n',strip(serline,char(13)),filtphI,filtPow);
			end
			drawnow		% this is the main time the interrupt can happen
			if  (filtPow>src.Parent.UserData.PowLim || ...
					filtphI>src.Parent.UserData.CurrLim)
				src.Parent.Color='red';
				beep
			end
			% repeat for 2nd second
			flush(port)
			readline(port);
			% read fs serial lines - should be 1 second total
			for k=1:src.Parent.UserData.fs	
				serline=readline(port);
				[token1,remain]=strtok(serline,',');
				[token2,remain]=strtok(remain,',');
				[token3,remain]=strtok(remain,',');
				[token4,remain]=strtok(remain,',');
				[token5,remain]=strtok(remain,',');
				[token6,remain]=strtok(remain,',');	% current
				[token7,remain]=strtok(remain,',');
				[token8,remain]=strtok(remain,',');
				[token9,remain]=strtok(remain,',');	% power
				current=str2num(token6);
				power=str2num(token9);
				% replace latest power and current in the moving averages
				idx=src.Parent.UserData.idx;
				src.Parent.UserData.PowSum=src.Parent.UserData.PowSum ...
					-src.Parent.UserData.PowData(idx)+power;
				src.Parent.UserData.PowData(idx)=power;
				src.Parent.UserData.phISum=src.Parent.UserData.phISum ...
					-src.Parent.UserData.phIData(idx)+current;
				src.Parent.UserData.phIData(idx)=current;
				if (idx==N)
					idx=1;
				else
					idx=idx+1;
				end
				src.Parent.UserData.idx=idx;
			end
			assignin('base','line',serline)
			assignin('base','current',current)
			assignin('base','power',power)
			filtPow=src.Parent.UserData.PowSum/N;
			filtphI=src.Parent.UserData.phISum/N;
			src.Parent.UserData.powerh.String=sprintf('%.2f',filtPow);
			src.Parent.UserData.currenth.String=sprintf('%.3f',filtphI);
			src.Parent.Color=[0.94 0.94 0.94 ];
			if (saveflag)
				fprintf(fp,'%s, %5.3f, %4.2f\n',strip(serline,char(13)),filtphI,filtPow);
			end
			drawnow		% this is the main time the interrupt can happen
		end
		if (saveflag)
			fclose(fp);
		end
	end
end
end

% callback for changing power alarm
function changePowAlarm(src,~)
	[x,tf]=str2num(src.String);
	if (tf)		% limit to positive numbers
		x=max([0,x]);
		src.Parent.UserData.PowLim=x;
		src.String=sprintf('%.2f',x);
	else	% numeric conversion failed
		x=src.Parent.UserData.PowLim;
		src.String=sprintf('%.2f',x);
		beep
	end
end

% callback for changing current alarm
function changeCurAlarm(src,~)
	[x,tf]=str2num(src.String);
	if (tf)		% limit to positive numbers
		x=max([0,x]);
		src.Parent.UserData.CurrLim=x;
		src.String=sprintf('%.3f',x);
	else	% numeric conversion failed
		x=src.Parent.UserData.CurrLim;
		src.String=sprintf('%.3f',x);
		beep
	end
end

% cleanup before closing window
function figDeleteFcn(src,~)
	% shut down serial connection
	port0=src.UserData.port;
	if (port0~=0)
		delete(port0);
	end
end