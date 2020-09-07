function f=ProcessSession(Sessions,session_index,PathBase)
%StringName={'E','A','D','G','B','e'};
%cur_data=[];
t1=[];%uitable
tSeg=[];%uitable
hsel=[];
hsel1=[];
ht=[];hp=[];
[GNoteFreq GNoteName]=GeneraNotasGuitarra();
saved=1;
Session=Sessions(session_index);
Session.Edited=1;
Session.EditDate=datenum(now);
hMarks=[];
config.defaultPath='./';
config.WinL=30;
config.Overlap=80;
config.Window=@hamming;
config.decimate=4;
selected_wav=[];
selected_wav_data=[];
selected_wav_fs=[];
selected_wav_content=[];
selected_segments=[];
SessionData=[];
selected_wav_index=-1;
f = figure('Units','normalized','Position',[0.1 0.1 0.7 0.7],'MenuBar','none',...
    'Name','Process Session','NumberTitle','off');
hspectrum = axes('Units','normalized','Position',[0.05,0.5,0.9,0.45]);
hp5 = uipanel('FontSize',12,...
    'Title','Session Info',...
    'Units','normalized',...
    'BackgroundColor','white',...
    'Position',[0 0 0.3 0.45]);
txt1 = uicontrol('Parent',hp5,'Style','text',...
            'Units','normalized',...
            'Position',[0.05,0.8,0.45,0.2],...
            'FontSize',10,...
            'String','No Session loaded');
        btVal = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Validate',...
    'Parent',hp5,...
    'Position', [0.5,0.8,0.15,0.15],...
    'Callback', @Validate);
hp6 = uipanel('FontSize',12,...
    'Title','Wav Info',...
    'Units','normalized',...
    'BackgroundColor','white',...
    'Position',[0.3 0 0.7 0.45]);
txt2 = uicontrol('Parent',hp6,'Style','text',...
            'Units','normalized',...
            'Position',[0,0.7,0.3,0.3],...
            'FontSize',8,...
            'String','No Wav Selected');
        btSegment = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Segment',...
    'Parent',hp6,...
    'Position', [0 0 0.15 0.15],...
    'Callback', @SegmentWav);
    btDetect = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Detect Notes',...
    'Parent',hp6,...
    'Position', [0 0.15 0.15 0.15],...
    'Callback', @DetectNotes);
    btEditSeg = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Edit Segment',...
    'Parent',hp6,...
    'Position', [0 0.3 0.15 0.15],...
    'Callback', @EditSegment);
btPlay = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Play',...
    'Parent',hp6,...
    'Position', [0 0.45 0.15 0.15],...
    'Callback', @PlaySegment);
btSave = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Save',...
    'Parent',hp6,...
    'Position', [0.15 0 0.15 0.15],...
    'Callback', @Save);
btExit = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Exit',...
    'Parent',hp6,...
    'Position', [0.15 0.15 0.15 0.15],...
    'Callback', @Exit);
btDel = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Del. Seg.',...
    'Parent',hp6,...
    'Position', [0.15 0.30 0.15 0.15],...
    'Callback', @DeleteSegment);
btDup = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Dup. Seg.',...
    'Parent',hp6,...
    'Position', [0.15 0.45 0.15 0.15],...
    'Callback', @DuplicateSeg);
   tSeg = uitable('Units','normalized','Parent', hp6, 'Position', [0.3 0 0.55 1]);

 set(tSeg,'ColumnName',{'Start','End','Freq','Note','Ref Freq',...
     'String','Select'});
 set(tSeg, 'ColumnEditable', [false false false false false true true]);
 set(tSeg, 'ColumnFormat', {'char' ,'numeric','numeric',...
     'char','numeric',{'UNK','E','A','D','G','B','e'},...
     'logical'});
 set(tSeg, 'CellEditCallback', @SelectSegment);
%set(tSeg,'units','characters');
%set(tSeg,'ColumnWidth',{});
btSA = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Select All',...
    'Parent',hp6,...
    'Position', [0.85 0 0.15 0.15],...
    'Callback', @SelectAll);
btUSA = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Unselect All',...
    'Parent',hp6,...
    'Position', [0.85 0.15 0.15 0.15],...
    'Callback', @USelectAll);
btSN = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Select Next',...
    'Parent',hp6,...
    'Position', [0.85 0.3 0.15 0.15],...
    'Callback', @SelectNext);
   btSpS = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Split',...
    'Parent',hp6,...
    'Position', [0.85 0.45 0.15 0.15],...
    'Callback', @SplitSeg);   
btSpS = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Plot Notes',...
    'Parent',hp6,...
    'Position', [0.85 0.85 0.15 0.15],...
    'Callback', @PlotNotes);  
btEdN = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Edit Notes',...
    'Parent',hp6,...
    'Position', [0.85 0.70 0.15 0.15],...
    'Callback', @EditNotes);     
btEdN = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'X',...
    'Parent',hp6,...
    'Position', [0.85 0.6 0.07 0.11],...
    'Callback', @NotesX2);     
btEdN = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', '/',...
    'Parent',hp6,...
    'Position', [0.93 0.60 0.07 0.1],...
    'Callback', @NotesH2);     
PrintSessionInfo(Session)

    function salida=PrintSessionInfo(SessionData)
        

        %text=['Sesion x'; 'Ficheros: '...
         %   num2str(length(SessionData.SessionData.Wavs))];
        text=['Sesion x ' 'Ficheros: ' num2str(length(SessionData.Wavs))]
        if (saved)
            text=[text,'Saved'];
        else
            text=[text,'Modified'];
        end
        set(txt1,'String',text),
        t1 = uitable('Units','normalized','Parent', hp5, 'Position', [0 0 1 0.8]);
% bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
%     'Terminar',...
%     'Position', [0 0 0.1 0.1],...
%     'Callback', @Exit);
% 
 set(t1,'ColumnName',{'Name','Contents','Processed','Select'});
 set(t1, 'ColumnEditable', [false false false true]);
 set(t1, 'ColumnFormat', {'char', 'char' ,'char','logical'});
 set(t1, 'CellEditCallback', @SelectWav);

 selected=cell2mat(SessionData.SelectedWavs);
 set(t1,'Data',[SessionData.Wavs(selected),...
     SessionData.WavContent(selected),...
    num2cell(zeros(sum(selected),1)),...
     num2cell(false(sum(selected),1))]);
% set(hp5,'visible','on');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=SelectWav(src,eventdata)
    cur_data=get(src,'Data');
    changed=eventdata.Indices
    selected_segments=[];
    selected_wav=cur_data(changed(1),1)
    selected_wav_index=changed(1);
    selected_wav_content=cur_data(changed(1),2);
    cur_data(:,4)={false};
    cur_data(changed(1),changed(2))={true};
    set(t1,'Data',cur_data);
    text=strcat('File Selected: ',selected_wav);
    switch strcmp(selected_wav_content,'Open Str'),
        case 1,
            text=[text, ['Contents: Open string reference']];
        case 0,        
           text=[text, cellstr(strcat('Contents: string  ',cellstr(selected_wav_content)))];
    end
           %['Contents:' selected_wav_content]};
     
    wavname=[PathBase Session.SessionPath,'\',cell2mat(selected_wav)];
    if ~exist(wavname,'file')
        errordlg(['Error!!, file ', wavname,' not found']);
        return;
    end
    %[selected_wav_data selected_wav_fs]=wavread(wavname);
    if isempty(strfind(version,'R2011b'))
        [selected_wav_data selected_wav_fs]=audioread(wavname);
    else
        [selected_wav_data selected_wav_fs]=wavread(wavname);
    end
    text=[text,...
        strcat('Length',' ',num2str(length(selected_wav_data)/selected_wav_fs),'sg')];
    text=[text,['Fs ' num2str(selected_wav_fs)]];
       set(hp6,'visible','on');
       set(tSeg,'visible','off');
    set(txt2,'String',text);
    set(btSegment,'visible','on');
    set(btDetect,'visible','on');
    salida=ResetPlot()
   PlotSpectrum(selected_wav_data,selected_wav_fs);
   if Session.WavAnalisys(selected_wav_index).Segmented
   aux=Session.WavAnalisys(selected_wav_index)
    %Selected(1:aux.Nsegments)={false};
    selected_segments=num2cell(false(aux.Nsegments,1));;

%     set(tSeg,'Data',[num2cell(aux.Starts/selected_wav_fs)'...
%     ,num2cell(aux.Ends/selected_wav_fs)',...
%     num2cell(aux.Freq)',
%     num2cell(aux.Note)',
%     num2cell(aux.RefFreq)',Selected']);
    ReplotTableSeg();
    set(tSeg,'Visible','on');
    PlotSegMarks(Session.WavAnalisys(selected_wav_index));
              PlotSelectedSeg()

   end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=SegmentWav(src,eventdata)
    saved=0;
    %Comprobar si no hay selección!
    [Starts Ends]=SegmentWavFile(selected_wav_data,selected_wav_fs)
    %hMarks=plot(hspectrum,SW_time,1e2*(ones(1,length(SW_time))),'*');
%     caxis=axis(hspectrum)
%      if ~isempty(hMarks)
%            delete(hMarks);
%            hMarks=[];
%        end;
%     hMarks=plot(hspectrum,[1;1]*SW_time,...
%         ([0;caxis(4)]*(ones(1,length(SW_time)))),'*-r');
%      tSeg = uitable('Units','normalized','Parent', hp6, 'Position', [0.3 0 0.7 1]);
%  set(tSeg,'ColumnName',{'Start','End','Freq','Note','Ref Freq','Select'});
%  set(tSeg, 'ColumnEditable', [false false false false false true]);
%  set(tSeg, 'ColumnFormat', {'char' ,'char','char','char','char','logical'});
%  set(tSeg, 'CellEditCallback', @SelectSegment);
 Nsegments=length(Starts);
 %Starts=SW_segments(1:end-1);
 %Ends=SW_segments(2:end);
 Note(1:Nsegments)={'UNK'};
 %Freq(1:Nsegments)={'0'};
 %RefFreq(1:Nsegments)={'0'};
 Freq(1:Nsegments)=0;
 RefFreq(1:Nsegments)=0;
 selected_segments=num2cell(false(Nsegments,1));
switch strcmp(selected_wav_content,'Open Str'),
     case '1'
         StringID(1:Nsegments)={'UNK'};
     otherwise
         StringID(1:Nsegments)=selected_wav_content;
 end
             
 Session.WavAnalisys(selected_wav_index).Segmented=1;
 Session.WavAnalisys(selected_wav_index).Starts=Starts;
 Session.WavAnalisys(selected_wav_index).Ends=Ends;
 Session.WavAnalisys(selected_wav_index).Note=Note;
 Session.WavAnalisys(selected_wav_index).Freq=Freq;
 Session.WavAnalisys(selected_wav_index).Nsegments=Nsegments;
 Session.WavAnalisys(selected_wav_index).RefFreq=RefFreq;
  Session.WavAnalisys(selected_wav_index).StringID=StringID;

 
%Session.WavAnalisys(selected_wav_index).StringID=RefFreq;


salida=PlotSegMarks(Session.WavAnalisys(selected_wav_index))
   ReplotTableSeg();


% set(tSeg,'Data',[num2cell(Starts/selected_wav_fs)'...
%     ,num2cell(Ends/selected_wav_fs)',...
%     num2cell(Freq)',Note',num2cell(RefFreq)',Selected']);
    set(tSeg,'Visible','on'); 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function salida=PlotSpectrum(data,fs)
        
%         if ~isempty(hMarks)
%           delete(hMarks);
%           hMarks=[];
%         end
 
        FileData.FsOr =fs;
        Fs=fs;
        Samples=decimate(data(:,1),config.decimate);
        FileData.Fs=FileData.FsOr/config.decimate;
        config.WinLs=config.WinL*Fs*1e-3;
        config.Overlaps=floor(config.WinLs*config.Overlap/100);
        [y f t p]=spectrogram(Samples,config.Window(config.WinLs),...
            config.Overlaps,...
            2^(ceil(log2(config.WinLs))+1),...
            FileData.Fs ,'yaxis');
        imagesc(t,f,10*log10(abs(p)),'Parent',hspectrum)
        axis xy; axis tight; colormap(jet); view(0,90);zoom on;
        hold on;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=ResetPlot()
    axes(hspectrum);
    hold off;
    salida=[];
    if ~isempty(hMarks)
           delete(hMarks);
           hMarks=[];
    end
       if ~(isempty(hsel))
          for i=1:length(hsel)
              delete(hsel(i));
          end
          hsel=[];
       end
       if ~isempty(ht)
             for i=1:length(ht)
                 delete(ht(i));
             end
             ht=[];
         end
         if ~isempty(hp)
             for i=1:length(hp)
                 delete(hp(i));
             end
             hp=[];
         end
end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=Exit(src,eventdata)
if ~saved
    answer = questdlg('Not saved. Sure to exit?')
    switch answer
        case 'Yes'
            close(f);    
    end 
    return;
end
close(f);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=Save(src,eventdata)
   Sessions(session_index)=Session;
    save('datos.mat','Sessions')
    Salida=Session;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=SelectSegment(src,eventdata)
 
    cur_data=get(src,'Data');
    aux=size(cur_data);
    changed=eventdata.Indices;
    
    %if (cur_data(changed(1),changed(2)))
    %cur_data(changed(1),changed(2))={true};
    if (changed(2) == aux(2)) %Cuando se selecciona el segmento
    set(tSeg,'Data',cur_data);
    selected_segments=cur_data(:,end);
    caxis=axis(hspectrum);
    St=cell2mat(cur_data(changed(1),1));
    End=cell2mat(cur_data(changed(1),2));
    PlotSelectedSeg()
    else %Cuando se cambia la cuerda
        Session.WavAnalisys(selected_wav_index).StringID(changed(1))=...
            cur_data(changed(1),changed(2));
    end
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=PlotSegMarks(aux)
  caxis=axis(hspectrum);
   if ~isempty(hMarks)
           delete(hMarks);
           hMarks=[];
       end
    hMarks=plot(hspectrum,[1;1]*aux.Starts/selected_wav_fs,...
        ([0;caxis(4)]*(ones(1,length(aux.Starts)))),'-r',...
        [1;1]*aux.Ends/selected_wav_fs,...
        ([0;caxis(4)]*(ones(1,length(aux.Ends)))),'-b'...
    );
    salida=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=PlaySegment(src,eventdata)
        selected_play=selected_segments;
               aux=Session.WavAnalisys(selected_wav_index);
 caxis=axis(hspectrum);
       if (isempty(selected_play))
            answer = questdlg('No segment selected. Play all?');
            switch answer
                case 'Yes'
                    selected_play=1:length(aux.Starts);
                case 'No'
                    return
            end
       else
           selected_play=cell2mat(selected_play);
       end
    
            
       St=aux.Starts((selected_play));
       End=aux.Ends((selected_play));
       for i=1:length(St)
           if (St(i)>=End(i))
               errordlg('Segmento erróneo');
           else
           %h=rectangle(hspectrum,'Position',[St(i)/selected_wav_fs 0 ...
            %   (End(i)-St(i))/selected_wav_fs caxis(4)], ...
             %  'color',gray);
             x1=St(i)/selected_wav_fs;
             x2=(End(i))/selected_wav_fs;
             y1=0;y2=caxis(4);
             hsel1=fill([x1 x1 x2 x2],...
               [y1 y2 y2 y1],'r');
           set(hsel1,'facealpha',.25)

           round(St(i)+1)
           round(End(i))
       soundsc(selected_wav_data(round(St(i)+1):round(End(i))),selected_wav_fs);
       delete(hsel1);hsel1=[];
           end
       end
       if ~isempty(hsel1)
           delete(hsel1);hsel1=[];
       end
       %selected_segments
    %selected_wav
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=EditSegment(src,eventdata)

       aux=Session.WavAnalisys(selected_wav_index);
       St=aux.Starts(cell2mat(selected_segments))/selected_wav_fs;
       if ~isempty(hMarks)
           delete(hMarks);
           hMarks=[];
       end
       End=aux.Ends(cell2mat(selected_segments))/selected_wav_fs;
       isegments=find(cell2mat(selected_segments));
       for i=1:length(St)
           isegment=isegments(i);
       [Stn Endn]=EditSingleSegment(hspectrum,St(i),End(i));
       Session.WavAnalisys(selected_wav_index).Starts(isegment)=...
           round(Stn*selected_wav_fs);
       Session.WavAnalisys(selected_wav_index).Ends(isegment)=...
           round(Endn*selected_wav_fs);
                 cur_data=get(tSeg,'Data');

              cur_data(isegment,1)=num2cell(Stn);
              cur_data(isegment,2)=num2cell(Endn);
                  set(tSeg,'Data',cur_data);

       end
  
        salida=PlotSegMarks(Session.WavAnalisys(selected_wav_index))
            PlotSelectedSeg()

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=DuplicateSeg(src,eventdata)
    if sum(cell2mat(selected_segments))==0
        errordlg('Error. No segment selected');
        return;
    end
    if sum(cell2mat(selected_segments))>1
        errordlg('Please, select a single segment.');
        return;
    end
    isegment=find(cell2mat(selected_segments));
    aux=Session.WavAnalisys(selected_wav_index);
    Starts=[aux.Starts(1:isegment)...
        aux.Starts(isegment) aux.Starts(isegment+1:end)];
    Ends=[aux.Ends(1:isegment)...
        aux.Ends(isegment) aux.Ends(isegment+1:end)];
    Note=[aux.Note(1:isegment)...
        aux.Note(isegment) aux.Note(isegment+1:end)];
    Freq=[aux.Freq(1:isegment)...
        aux.Freq(isegment) aux.Freq(isegment+1:end)];
     RefFreq=[aux.RefFreq(1:isegment)...
        aux.RefFreq(isegment) aux.RefFreq(isegment+1:end)];
    StringID=[aux.StringID(1:isegment)...
        aux.StringID(isegment) aux.StringID(isegment+1:end)];
    Session.WavAnalisys(selected_wav_index).Nsegments=length(Starts);
        Session.WavAnalisys(selected_wav_index).Starts=Starts;
    Session.WavAnalisys(selected_wav_index).Ends=Ends;
    Session.WavAnalisys(selected_wav_index).Freq=Freq;
    Session.WavAnalisys(selected_wav_index).RefFreq=RefFreq;
        Session.WavAnalisys(selected_wav_index).Note=Note;
                Session.WavAnalisys(selected_wav_index).StringID=StringID;

   selected_segments=num2cell(false(length(Starts),1));

   ReplotTableSeg();
   salida=PlotSegMarks(Session.WavAnalisys(selected_wav_index))
       PlotSelectedSeg()


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=SplitSeg(src,eventdata)
    if sum(cell2mat(selected_segments))==0
        errordlg('Error. No segment selected');
        return;
    end
    if sum(cell2mat(selected_segments))>1
        errordlg('Please, select a single segment.');
        return;
    end
    isegment=find(cell2mat(selected_segments));
    aux=Session.WavAnalisys(selected_wav_index);
    Starts=[aux.Starts(1:isegment)...
        aux.Starts(isegment) aux.Starts(isegment+1:end)];
    Ends=[aux.Ends(1:isegment)...
        aux.Ends(isegment) aux.Ends(isegment+1:end)];
    Note=[aux.Note(1:isegment)...
        aux.Note(isegment) aux.Note(isegment+1:end)];
    Freq=[aux.Freq(1:isegment)...
        aux.Freq(isegment) aux.Freq(isegment+1:end)];
     RefFreq=[aux.RefFreq(1:isegment)...
        aux.RefFreq(isegment) aux.RefFreq(isegment+1:end)];
    StringID=[aux.StringID(1:isegment)...
        aux.StringID(isegment) aux.StringID(isegment+1:end)];
    
    E1=Ends(isegment);
    S1=Starts(isegment);
    medio=round(S1+(E1-S1)/2)
    Ends(isegment)=medio;
    Starts(isegment+1)=medio;
    Session.WavAnalisys(selected_wav_index).Nsegments=length(Starts);
        Session.WavAnalisys(selected_wav_index).Starts=Starts;
    Session.WavAnalisys(selected_wav_index).Ends=Ends;
    Session.WavAnalisys(selected_wav_index).Freq=Freq;
    Session.WavAnalisys(selected_wav_index).RefFreq=RefFreq;
        Session.WavAnalisys(selected_wav_index).Note=Note;
         Session.WavAnalisys(selected_wav_index).StringID=StringID;
   selected_segments=num2cell(false(length(Starts),1));

   ReplotTableSeg();
   salida=PlotSegMarks(Session.WavAnalisys(selected_wav_index))
       PlotSelectedSeg()


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=DeleteSegment(src,eventdata)
     if sum(cell2mat(selected_segments))==0
        errordlg('Error. No segment selected');
        return;
    end
    if sum(cell2mat(selected_segments))>1
        errordlg('Please, select a single segment.');
        return;
    end
    isegment=find(cell2mat(selected_segments));
    aux=Session.WavAnalisys(selected_wav_index);
    Starts=[aux.Starts(1:isegment-1)...
       aux.Starts(isegment+1:end)];
    Ends=[aux.Ends(1:isegment-1)...
       aux.Ends(isegment+1:end)];
    Note=[aux.Note(1:isegment-1)...
        aux.Note(isegment+1:end)];
    Freq=[aux.Freq(1:isegment-1)...
       aux.Freq(isegment+1:end)];
     RefFreq=[aux.RefFreq(1:isegment-1)...
         aux.RefFreq(isegment+1:end)];
     StringID=[aux.StringID(1:isegment-1)...
         aux.StringID(isegment+1:end)];
    Session.WavAnalisys(selected_wav_index).Nsegments=length(Starts);
        Session.WavAnalisys(selected_wav_index).Starts=Starts;
    Session.WavAnalisys(selected_wav_index).Ends=Ends;
    Session.WavAnalisys(selected_wav_index).Freq=Freq;
    Session.WavAnalisys(selected_wav_index).RefFreq=RefFreq;
        Session.WavAnalisys(selected_wav_index).Note=Note;
                Session.WavAnalisys(selected_wav_index).StringID=StringID;

   selected_segments=num2cell(false(length(Starts),1));
   ReplotTableSeg();
   salida=PlotSegMarks(Session.WavAnalisys(selected_wav_index))
       PlotSelectedSeg()

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=ReplotTableSeg()
     aux=Session.WavAnalisys(selected_wav_index)
    set(tSeg,'Data',[num2cell(aux.Starts/selected_wav_fs)'...
    ,num2cell(aux.Ends/selected_wav_fs)',...
    num2cell(aux.Freq)',aux.Note',...
    num2cell(aux.RefFreq)',...
    aux.StringID',...
    selected_segments]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=PlotSelectedSeg()
     aux=Session.WavAnalisys(selected_wav_index)
     
      if ~(isempty(hsel))
          for i=1:length(hsel)
              delete(hsel(i));
          end
          hsel=[];
      end
    
      caxis=axis(hspectrum);

          selected=cell2mat(selected_segments);
       St=aux.Starts((selected));
       End=aux.Ends((selected));
       y1=0;y2=caxis(4);
       for i=1:length(St)
             x1=St(i)/selected_wav_fs;
             x2=(End(i))/selected_wav_fs
             hsel(i)=fill([x1 x1 x2 x2],...
               [y1 y2 y2 y1],'r');
           set(hsel(i),'facealpha',.25)
           
       end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=DetectNotes(src,eventdata)
    
    if (Session.WavAnalisys(selected_wav_index).Segmented==0)
        errordlg('Please. Segment first')
        return;
    end
    saved=0;
     selected=cell2mat(selected_segments);
               aux=Session.WavAnalisys(selected_wav_index);
       if (isempty(selected) || sum(selected)==0)
            answer = questdlg('No segment selected. Detect all?');
            switch answer
                case 'Yes'
                    isegments=1:length(aux.Starts);
                case 'No'
                    return
            end
       else
               isegments=find(cell2mat(selected_segments));

       end
   
    for i=1:length(isegments)
        isegment=isegments(i);
       frecuenciaNota=DetectaNota(selected_wav_fs,...
     selected_wav_data(aux.Starts(isegment):aux.Ends(isegment)),...
     selected_wav_content);
 [m ind]=min(abs(GNoteFreq-frecuenciaNota));
 Session.WavAnalisys(selected_wav_index).Note(isegment)=...
                    {GNoteName(ind,:)};
 Session.WavAnalisys(selected_wav_index).Freq(isegment)=frecuenciaNota;
 Session.WavAnalisys(selected_wav_index).RefFreq(isegment)=GNoteFreq(ind);    
    end
     ReplotTableSeg();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=SelectAll(src,eventdata)
       NSeg=Session.WavAnalisys(selected_wav_index).Nsegments;
        selected_segments=num2cell(true(NSeg,1));
        ReplotTableSeg();
               PlotSelectedSeg();

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=USelectAll(src,eventdata)
     NSeg=Session.WavAnalisys(selected_wav_index).Nsegments;
        selected_segments=num2cell(false(NSeg,1));
        ReplotTableSeg();
               PlotSelectedSeg();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=SelectNext(src,eventdata)
      numsel=sum(cell2mat(selected_segments));
      if ((numsel==0)||(numsel > 1))
          selected_segments(1)=num2cell(true);
           ReplotTableSeg();
               PlotSelectedSeg();
               return;
      end
      selected=find(cell2mat(selected_segments));
      if (selected==length(selected_segments))
            next=1;
      else
          next=selected+1;
      end
          selected_segments(next)=num2cell(true);
          selected_segments(selected)=num2cell(false);
         ReplotTableSeg();
               PlotSelectedSeg();
      
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=PlotNotes(src,eventdata)
         if ~isempty(ht)
             for i=1:length(ht)
                 delete(ht(i));
             end
             ht=[];
         end
         if ~isempty(hp)
             for i=1:length(hp)
                 delete(hp(i));
             end
             hp=[];
         end
         aux=Session.WavAnalisys(selected_wav_index)
         caxis=axis(hspectrum);
         ypos=caxis(4);
          harm=1:5;
         for i=1:length(aux.Note)
             xpos=aux.Starts(i)/selected_wav_fs;
             xpos2=aux.Ends(i)/selected_wav_fs;
             
             ht(i)=text(xpos,ypos,[aux.Note(i),' ',num2str(aux.Freq(i),'%6.1f')]);
             %hp(i)=plot([xpos xpos2],[aux.Freq(i) aux.Freq(i)],'k');
              hp(i,:)=plot([xpos xpos2],([aux.Freq(i) aux.Freq(i)]'*harm)','k');
             set(ht(i),'FontSize',8);
         end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function salida=EditNotes(src,eventdata)
        
        
        if (isempty(selected_segments))
            errordlg('No segment selected.');
            return;
        end
        aux=Session.WavAnalisys(selected_wav_index);        
        
        for seg=find(cell2mat(selected_segments))'
            
            prompt={'Note name'};
            dlg_title = ['Select new note'];
            num_lines = 1;
            answer = inputdlg(prompt,dlg_title,num_lines,...
                aux.Note(seg))
            answer=cell2mat(answer);
            if (length(answer) < 2)
                errordlg('Please indicate note (ABC..),alteration (#), and octave (2-5)');
                return
            end
            Note=answer;
            if (length(answer)==2)
                Note=[answer(1),' ',answer(2)];
            elseif (length(answer) > 4)
                Note=answer(1:4),
            end
            index=-1;
            for i=1:length(GNoteName)
                if strcmp(Note,GNoteName(i,:))
                    index=i;
                end
            end
            if (index<0)
                errordlg('Not found. Please indicate note (ABC..),alteration (#), and octave (2-5)');
                return;
            end
            aux.Note(seg)={GNoteName(index,:)};
            aux.RefFreq(seg)=GNoteFreq(index);
            aux.Freq(seg)=GNoteFreq(index);
            Session.WavAnalisys(selected_wav_index)=aux;
            ReplotTableSeg();
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function salida=NotesX2(src,eventdata)
        
        aux=Session.WavAnalisys(selected_wav_index);
        
        if (isempty(selected_segments))
            errordlg('No segment selected.');
            return;
        end
        aux=Session.WavAnalisys(selected_wav_index);
        %isegments=find(cell2mat(selected_segments));
        
        
        for seg=find(cell2mat(selected_segments))'
            
            aux.Freq(seg)=2*aux.Freq(seg);
            [m ind]=min(abs(GNoteFreq-aux.Freq(seg)));
            aux.Note(seg)=...
                {GNoteName(ind,:)};
            aux.RefFreq(seg)=GNoteFreq(ind);
            Session.WavAnalisys(selected_wav_index)=aux;
            ReplotTableSeg();
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=NotesH2(src,eventdata)
       
        aux=Session.WavAnalisys(selected_wav_index);

       if (isempty(selected_segments))
            errordlg('No segment selected.');
            return;
       end
               aux=Session.WavAnalisys(selected_wav_index);
        %isegments=find(cell2mat(selected_segments));
            
      
       for seg=find(cell2mat(selected_segments))'
   
           aux.Freq(seg)=aux.Freq(seg)/2;
          [m ind]=min(abs(GNoteFreq-aux.Freq(seg)));
          aux.Note(seg)=...
                    {GNoteName(ind,:)};
                aux.RefFreq(seg)=GNoteFreq(ind);
           Session.WavAnalisys(selected_wav_index)=aux;
           ReplotTableSeg();
       end
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function salida=Validate(src,eventdata)
        StrRef=GenerateStringData();
        Wav2StrID=zeros(6,13);
        Wav2StrSeg=zeros(6,13);
        WavContent=Session.WavContent(cell2mat(Session.SelectedWavs));
        WavNames=Session.Wavs(cell2mat(Session.SelectedWavs));
        for string=1:6 %Cuerda en la que buscamos
            StringID=StrRef(string).Name;
            StringID
           % StringSal(string)=[];
            StringSal(string).StringID=StringID;
            for fret=1:13 %Traste que buscamos (1 es cuerda al aire)
                
                NoteId=StrRef(string).fret(fret).NoteName;
                StringSal(string).Fret(fret).NoteName=NoteId;
                StringSal(string).Fret(fret).NoteRefFreq=...
                    StrRef(string).fret(fret).Freq;
                StringSal(string).Fret(fret).HarmFreq=[];
                StringSal(string).Fret(fret).HarmAmp=[];
                StringSal(string).Fret(fret).NHarm=[];
                StringSal(string).Fret(fret).LHarm=[];

                    
                %NoteId
                ires=-1; %Aquí va el índice si es que la encontramos
                for wav=1:sum(cell2mat(Session.SelectedWavs))
                    WavContent(wav)
                    %if ((cel2mat(Session.SelectedWavs(wav))) &&...
                    if ((strcmp(WavContent(wav),'Open Str')&& fret==1) ||...
                    (strcmp(WavContent(wav),StringID)))
                        aux=Session.WavAnalisys(wav);
                        for note=1:aux.Nsegments
                            if strcmp(cell2mat(aux.Note(note)),NoteId)
                                %display('Encontrada!');
                                %display(['Wav: ',Session.Wavs(wav),...
                                   % 'Segment: ',num2str(note)]);
                                   Wav2StrID(string,fret)=wav;
                                   Wav2StrSeg(string,fret)=note;
                                   StringSal(string).Fret(fret).WavName=...
                                       WavNames(wav);
                                   StringSal(string).Fret(fret).Start=...
                                       aux.Starts(note);
                                   StringSal(string).Fret(fret).End=...
                                       aux.Ends(note);
                                   StringSal(string).Fret(fret).Freq=...
                                       aux.Freq(note);
                                   
                                ires=1;
                            end
                        end
                    end
                end
%                 if (ires < 0)
%                     %errordlg(['No encontré ',StringID,' ',NoteId]);
%                     
%                 end
            end
        end
        %txt=[];
        finfo = figure('Units','normalized','Position',[0.1 0.1 0.3 0.3],'MenuBar','none',...
    'Name','Validate Session','NumberTitle','off');
    txt1 = uicontrol('Parent',finfo,'Style','text',...
            'Units','normalized',...
            'Position',[0,0,1,1],...
            'FontSize',10,...
            'HorizontalAlignment','left',...
            'String','Validating');
        allOk=1;
        for string=1:6
            display(['String ',cell2mat(StrRef(string).Name)]);
            get(txt1,'String')
            set(txt1,'String',[get(txt1,'String');...
                strcat('String: ',cellstr(StrRef(string).Name))]);
            if ~(sum(Wav2StrID(string,:)==0))
                display(' Completed');
                set(txt1,'String',[get(txt1,'String');...
                '... correct'])
            else
                for fret=1:13
                  if ~Wav2StrID(string,fret)
                      textinfo=['...Note ',...
                          cell2mat(StrRef(string).fret(fret).NoteName),...
                          ' (fret ',num2str(fret-1),') not found']
                      display([' ',...
                          cell2mat(StrRef(string).fret(fret).NoteName),...
                          ' fret ',num2str(fret-1),' not found']);
                      set(txt1,'String',[get(txt1,'String');textinfo]);
                      allOk=0;
                      
                  end
            end
        end
        end
       if (allOk)
           Session.Strings=StringSal;
           Session.Completed=1;
       end
    end

end