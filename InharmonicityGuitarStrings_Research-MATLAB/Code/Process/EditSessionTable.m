function f=EditSessionTable(Master,Cycle_index)

PathCycle=Master.Cycles{Cycle_index};
Cycle=load([Master.DataPath,cell2mat(PathCycle)]);
Cycle=Cycle.Cycle;
 gldata.Selected_Session=-1;
 
 f = figure('Units','normalized','Position',[0.1 0.1 0.5 0.5],'MenuBar','none',...
    'Name',['Editing table session of cycle',cell2mat(Cycle.Name)],'NumberTitle','off');

txthp71 = uicontrol('Parent',f,'Style','text',...
    'Units','normalized',...
    'Position',[0,0.8,1,0.2],...
    'FontSize',8,...
    'String','No sessions ');
btAddSess = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Add',...
    'Parent',f,...
    'Position', [0 0 0.15 0.15],...
    'Callback', @AddSes);
btDelSes = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Del',...
    'Parent',f,...
    'Position', [0.15 0 0.15 0.15],...
    'Callback', @DelSes);
btSaveCycle = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Save',...
    'Parent',f,...
    'Position', [0.30 0 0.15 0.15],...
    'Callback', @SaveCycle);
savedcolor=get(btSaveCycle,'BackgroundColor');
btEdit = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Edit',...
    'Parent',f,...
    'Position', [0.6 0 0.15 0.15],...
    'Callback', @EditSel);

btImport = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Import',...
    'Parent',f,...
    'Position', [0.45 0 0.15 0.15],...
    'Callback', @ImportSession);
PrintCycleInfo(Cycle)

    function salida=PrintCycleInfo(Cycle)
        if (Cycle.NSessions ==0)
            set(txthp71,'String',['No sessions in cycle Cycle ',...
                cell2mat(Cycle.Name),...
                ' Please use Add or import button']);
        else
        set(txthp71,'String',[num2str(Cycle.NSessions),' ','sessions in Cylce']);
        end
        PrintSessionsTable(Cycle)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function salida=AddSes(source,eventdata)
        SessionPath= uigetdir([Master.WavPath,Cycle.WavPath],'Select session directory');
         if isequal(SessionPath,0)
            return;
         end
         %display(SessionPath)
         %SessionPath=SessionPath(length(SessionPathBase)+1:end);
         SessionRecordings=dir([SessionPath '\*.wav']);
         SessionData=EditSession(SessionRecordings);
         %SessionData.SessionPath=...
             %SessionPath(length(SessionPathBase)+1:end);;
         aux=SessionPath(length(Cycle.WavPath)+1+length(Master.WavPath):end);
         SessionData.SessionPath=aux;
         SessionData.CurrentSessionSaved=0;
         for i=1:length(SessionData.Wavs)
               SessionData.WavAnalisys(i).Segmented=0;
                SessionData.WavAnalisys(i).DetectedNotes=0;
         end
%          index=length(Sessions);
%          if (index==0)
%                       Sessions=SessionData;
%          else
%                     Sessions(index+1)=SessionData;
%          end
         PathSessionData=strcat(Master.DataPath,'\',Cycle.Name,'_',...
             SessionData.Name,'.mat');
         if (Cycle.NSessions==0)
             Cycle.Sessions=strcat('\',Cycle.Name,'_',...
             SessionData.Name,'.mat');
         else
             Cycle.Sessions(Cycle.NSessions+1)=strcat('\',Cycle.Name,'_',...
             SessionData.Name,'.mat');
         end
         Cycle.NSessions=Cycle.NSessions+1;
         save(cell2mat(PathSessionData),'SessionData');
         PrintSessionsTable(Cycle)
         set(btSaveCycle,'BackgroundColor','red');
          
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=SaveCycle(source,eventdata)
    
    save([Master.DataPath,cell2mat(PathCycle)],'Cycle');
     set(btSaveCycle,'BackgroundColor',savedcolor);
     
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   function salida=PrintSessionsTable(Cycle)
        if (Cycle.NSessions ==0)
            set(txthp71,'String','No sessions in actual Cycle. Please use Add button');
            return
        end
        set(txthp71,'String',[num2str(Cycle.NSessions),' ','sessions in Cylce']);
         tSeg = uitable('Parent',f,'Units','normalized'...
             , 'Position', [0 0.3 1 0.6]);
% bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
%     'Terminar',...
%     'Position', [0 0 0.1 0.1],...
%     'Callback', @Exit);
% 
 set(tSeg,'ColumnName',{'Select','Name','Recording Date','Number of Wav Files',...
     'Editing Date','Edited','Completed'});
 set(tSeg, 'ColumnEditable', [true false false false false false]);
 set(tSeg, 'ColumnFormat', {'logical','char','char' ,'numeric','char','numeric','char'});
 set(tSeg, 'CellEditCallback', @SelectSession);
% aux=struct2cell(Sessions);
 %RecDate=[];
 for i=1:Cycle.NSessions
   session=load([Master.DataPath,cell2mat(Cycle.Sessions(i))]);
   
   sdata=session.SessionData;
  Names(i)=sdata.Name;
  RecDate(i)={datestr(sdata.date)};
  NumFiles(i)={num2str(sdata.NumWavs)};
  EdDate(i)={datestr(sdata.EditDate)};
  Ed(i)={num2str(sdata.Edited)};
  Comp(i)={num2str(sdata.Completed)};
  Sel(i)={0};
 end
 set(tSeg,'Data',...
  [Sel' Names' RecDate', NumFiles', EdDate',Ed',Comp',...
  ]);
  gldata.tSeg=tSeg;
  gldata.Selected_Session=-1;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=SelectSession(src,eventdata)
    cur_data=get(src,'Data');
    changed=eventdata.Indices;
    Selected_Session=changed(1);
    cur_data(:,1)={false};
    cur_data(changed(1),1)={true};
    set(gldata.tSeg,'Data',cur_data);
    gldata.Selected_Session=Selected_Session;
end

function salida=DelSes(src,eventdata)
     SS=gldata.Selected_Session;
    if (length(Cycle.Sessions)==0)
        errordlg('Error. No sessions');
        return;
    end 
    
    if( SS < 1)
        errordlg('Error. No session selected');
        return;
    end
    Old=Cycle.Sessions;
    if (SS==1)
        Cycle.Sessions=[];
        Cycle.Sessions=Old(2:end);
    elseif (SS==length(Old))
        Cycle.Sessions=[];
        Cycle.Sessions=Old(1:end-1);
    else
       Cycle.Sessions=[]
       Cycle.Sessions=Old([1:SS-1,SS+1:end])
    end
    Cycle.NSessions=Cycle.NSessions-1;
    PrintSessionsTable(Cycle)
         set(btSaveCycle,'BackgroundColor','red');

end
function salida=EditSel(src,eventdata)
     SS=gldata.Selected_Session;
    if (Cycle.NSessions==0)
        errordlg('Error. No sessions');
        return;
    end 
    if( SS < 1)
        errordlg('Error. No session selected');
        return;
    end
    SessionData=load([Master.DataPath,cell2mat(Cycle.Sessions(gldata.Selected_Session))]);
    SessionData=SessionData.SessionData;
    SessionData=EditSelectedSession(SessionData);
    save(cell2mat([Master.DataPath,Cycle.Sessions(gldata.Selected_Session)]),'SessionData');
end

function salida=ImportSession(src,eventdata)
      [file,path] = uigetfile('*.mat','Select a File to import');
        if ~file
            return;
        end
        data=load([path,'/',file]);
        if ~(isfield(data,'Sessions'))
            errordlg('Not Sessions struct in data');
            return
        end
        for i=1:length(data.Sessions)
            %answer=inputdlg('Session Name','Input Session Name',[1 35],{'Session1'});
            SessionData=data.Sessions(i);
            if ~(isfield(SessionData,'EditDate'))
                SessionData.EditDate=now;
            end
            answer=questdlg({'Import session with following data?',...
                        ['Session ',num2str(i),' of ',num2str(length(data.Sessions))],...
                        ['Path: ',SessionData.SessionPath],...
                        ['Num wavs: ',num2str(SessionData.NumWavs)]},...                                    
             'Import Session','Yes','No','Yes');
         SessionData.Name=inputdlg('Session Name','Input Session Name',[1 35],{'Session1'});
         
            switch answer,
            case 'Yes'
               % session.Name=inputdlg('Session Name','Input Session Name',[1 35],{'Session1'});
                PathSessionData=strcat(Master.DataPath,'\',Cycle.Name,'_',...
                SessionData.Name,'.mat');
                SessionName=strcat('\',Cycle.Name,'_',SessionData.Name,'.mat');
                SessionData.SessionPath=...
                    SessionData.SessionPath(length(Cycle.WavPath)+1:end);
                if (Cycle.NSessions==0)
                     Cycle.Sessions=SessionName;
                else
                    Cycle.Sessions(Cycle.NSessions+1)=SessionName;
                end
                Cycle.NSessions=Cycle.NSessions+1;
                SessionData.WavContent=SessionData.WavContent;
                save(cell2mat(PathSessionData),'SessionData');
                PrintSessionsTable(Cycle)
                set(btSaveCycle,'BackgroundColor','red');
            end
        end
   
end
end