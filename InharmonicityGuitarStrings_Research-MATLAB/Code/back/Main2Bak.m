function Main2()

MasterFile='datosv.mat';
SessionPathBase='C:\Users\Antonio\Clases\TFGs\Guitarra\Sesiones';
gldata=[];
gldata.Selected_session=-1;
Selected_Session=-1;
f = figure('Units','normalized','Position',[0 0 0.6 0.6],'MenuBar','none',...
    'Name','Test Window','NumberTitle','off');
Sessions=[];
% bta = uicontrol('Units','normalized','Style', 'pushbutton',...
%     'String', 'Load new session',...
%     'Position', [0.1 0 0.1 0.1],...
%     'Callback', @LoadSessionsFile);
bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Add New Session',...
    'Position', [0.1 0 0.1 0.1],...
    'Callback', @AddNewSession);
bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Save List',...
    'Position', [0.2 0 0.1 0.1],...
    'Callback', @SaveList);
bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Change Path Base',...
    'Position', [0.3 0 0.1 0.1],...
    'Callback', @ChangeSessionPath);
bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Reload List',...
    'Position', [0 0 0.1 0.1],...
    'Callback', @Reload);

txt1 = uicontrol('Style','text',...
            'Units','normalized',...
            'Position',[0.05,0.8,0.9,0.2],...
            'FontSize',13,...
            'String','No Sessions');
        
 bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Delete Selected',...
    'Position', [0.7 0.6 0.1 0.1],...
    'Callback', @DeleteSelected);
 bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Duplicate Selected',...
    'Position', [0.8 0.6 0.1 0.1],...
    'Callback', @DuplicateSelected);
bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Edit Selected',...
    'Position', [0.7 0.5 0.1 0.1],...
    'Callback', @EditSelected);
bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Process Selected',...
    'Position', [0.7 0.4 0.1 0.1],...
    'Callback', @ProcessSelected);

%%%%%%%%%%%%%%%%%%%%%%%%%
if (~exist(MasterFile))
    Sessions=[];
else
    Sessions=load(MasterFile);
    Sessions=Sessions.Sessions;
    PrintSessionsTable(Sessions);
    
    set(txt1,'String',[{[num2str(length(Sessions)) ' sessions']};...
        {['Session Path: ' SessionPathBase]}]);
    PrintSessionsTable(Sessions);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function salida=PrintSessionsTable(Sessions)
         tSeg = uitable('Units','normalized'...
             , 'Position', [0 0.1 0.7 0.6]);
% bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
%     'Terminar',...
%     'Position', [0 0 0.1 0.1],...
%     'Callback', @Exit);
% 
 set(tSeg,'ColumnName',{'Recording Date','Number of Wav Files',...
     'Editing Date','Edited','Completed','Select'});
 set(tSeg, 'ColumnEditable', [false false false false false true]);
 set(tSeg, 'ColumnFormat', {'char' ,'numeric','char','numeric','char','logical'});
 set(tSeg, 'CellEditCallback', @SelectSession);
 aux=struct2cell(Sessions);
 %RecDate=[];
 for i=1:length(Sessions)
  aux2=datestr(squeeze(cell2mat(aux(1,:,i))))
  RecDate(i)={aux2};
  NumFiles(i)={num2str(squeeze(cell2mat(aux(11,:,i))))};
  EdDate(i)={datestr(squeeze(cell2mat(aux(3,:,i))))};
  Ed(i)={num2str(squeeze(cell2mat(aux(2,:,i))))};
  Comp(i)={num2str(squeeze(cell2mat(aux(4,:,i))))};
  Sel(i)={0};
 end
 set(tSeg,'Data',...
  [RecDate', NumFiles', EdDate',Ed',Comp',...
  Sel']);
  gldata.tSeg=tSeg;
  gldata.Selected_Session=-1;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=SelectSession(src,eventdata)
    cur_data=get(src,'Data');
    changed=eventdata.Indices
    Selected_Session=changed(1);
    cur_data(:,6)={false};
    cur_data(changed(1),6)={true};
    set(gldata.tSeg,'Data',cur_data);
    gldata.Selected_Session=Selected_Session;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function salida=AddNewSession(source,eventdata)
        SessionPath= uigetdir(SessionPathBase,'Select directory');
         if isequal(SessionPath,0)
            return;
         end
         %display(SessionPath)
         %SessionPath=SessionPath(length(SessionPathBase)+1:end);
         SessionRecordings=dir([SessionPath '\*.wav']);
         SessionData=EditSession(SessionRecordings);
         SessionData.SessionPath=...
             SessionPath(length(SessionPathBase)+1:end);;
         SessionData.CurrentSessionSaved=0;
         for i=1:length(SessionData.Wavs)
               SessionData.WavAnalisys(i).Segmented=0;
                SessionData.WavAnalisys(i).DetectedNotes=0;
         end
         index=length(Sessions);
         if (index==0)
                      Sessions=SessionData;
         else
                    Sessions(index+1)=SessionData;
         end
         %PrintSessionsTable(Sessions)
         
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=ChangeSessionPath(source,eventdata)
        aux= uigetdir('../','Select directory');
         if isequal(aux,0)
            return;
         end
         SessionPathBase=aux;
         set(txt1,'String',[{[num2str(length(Sessions)) ' sessions']};...
        {['Session Path: ' SessionPathBase]}]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=DuplicateSelected(source,eventdata)
    if (length(Sessions)==0)
        errordlg('Error. No sessions');
        return;
    end 
    if( gldata.Selected_Session < 1)
        errordlg('Error. No session selected');
        return;
    end
    Sessions(length(Sessions)+1)=Sessions(gldata.Selected_Session);
             PrintSessionsTable(Sessions)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=DeleteSelected(source,eventdata)
    SS=gldata.Selected_Session;
    if (length(Sessions)==0)
        errordlg('Error. No sessions');
        return;
    end 
    if( SS < 1)
        errordlg('Error. No session selected');
        return;
    end
    Old=Sessions;
    if (SS==1)
        Sessions=[];
        Sessions=Old(2:end);
    elseif (SS==length(Old))
        Sessions=[];
        Sessions=Old(1:end-1);
    else
       Sessions=[]
       Sessions=Old([1:SS-1,SS+1:end])
    end
             PrintSessionsTable(Sessions)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=SaveList(source,eventdata)
     save('datos.mat','Sessions')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=EditSelected(source,eventdata)
     Sessions(gldata.Selected_Session)=...
         EditSelectedSession(Sessions(gldata.Selected_Session));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function salida=Reload(source,eventdata)
     if (~exist(MasterFile))
    Sessions=[];
else
    Sessions=load(MasterFile);
    Sessions=Sessions.Sessions;
    PrintSessionsTable(Sessions);
    
    set(txt1,'String',[{[num2str(length(Sessions)) ' sessions']};...
        {['Session Path: ' SessionPathBase]}]);
    PrintSessionsTable(Sessions);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function salida=ProcessSelected(source,eventdata)
     
         if (Selected_Session < 0)
             errordlg('No session selected')
             return
         end
          fig=ProcessSession(Sessions,gldata.Selected_Session,SessionPathBase);
%          uiwait(fig);
% %          waitfor(fig);
%          Sessions=load(MasterFile);
%     Sessions=Sessions.Sessions;
%     PrintSessionsTable(Sessions);
%     
%     set(txt1,'String',[num2str(length(Sessions)) ' sessions']);
%     PrintSessionsTable(Sessions);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estructura principal
%Sessions - Array de estructuras, una sesion por posición del array
%
%Sessions(1) 
%           Date
%           Edited
%           Editdate
%           Completed
