function SessionData=EditSelectedSession(InputSessionData)
StringName={'E','A','D','G','B','e'};
cur_data=[];
f = figure('Units','normalized','Position', [0.2 0.2 0.2 0.4]);
t = uitable('Units','normalized','Parent', f, 'Position', [0 0 1 0.9]);
bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
    'Terminar',...
    'Position', [0 0 0.2 0.1],...
    'Callback', @Exit);
bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
    'SelectAll',...
    'Position', [0.2 0 0.2 0.1],...
    'Callback', @SelectAll);
set(t,'ColumnName',{'Name','Select','Contents'});
set(t, 'ColumnEditable', [false true true]);
set(t, 'ColumnFormat', {'char', 'logical' , ...
    {'UNK','Open Str','E','A','D','G','B','e'}});
SessionData=InputSessionData;
names=SessionData.Wavs;
select=SessionData.SelectedWavs;
Contents=SessionData.WavContent;
%select=false(length(names),1);
%Contents(1:length(names))={'UNK'};
set(t,'Data',[cellstr(names),select,cellstr(Contents)]);
set(t, 'CellEditCallback', @EditTable);

SessionData=InputSessionData;
% SessionData.date=SessionRecordings(1).datenum;
% SessionData.Edited=0;
% SessionData.EditDate=0;
% SessionData.Completed=0;
% SessionData.Wavs=names;
% SessionData.SelectedWavs=[];
% SessionData.WavContent=[];
% SessionData.Open=[];
% SessionData.Strings=[];
% SessionData.SessionPath=[];
% SessionData.NumWavs=0;

uiwait(f);
function EditTable(src,eventdata);
    cur_data=get(src,'Data');
    changed=eventdata.Indices;
end
function SelectAll(src,eventdata);
    cur_data=get(t,'Data');
    cur_data(:,2)={true};
   set(t,'Data',cur_data);
end

    function Exit(source,eventdata)
        if (isempty(cur_data))|| (sum(cell2mat(cur_data(:,2)))==0)
            response=questdlg('Ningún fichero seleccionado','Terminar',...
                'Continuar', 'Salir','asdf');
            switch response,
                case 'Continuar',
                    return
                case 'Salir'
                    close(f)
                    return
            end
        end
        selected=cur_data(cell2mat(cur_data(:,2)),:);
        SessionData.SelectedWavs=cur_data(:,2);
        SessionData.WavContent=cur_data(:,3);
        SessionData.NumWavs=length(cur_data(:,2));
        SessionData.Open=[];
        SessionData.Open.Wav=...
               selected(strcmp(selected(:,3),'Open Str'),1);
        SessionData.Strings=[];
        for i=1:length(StringName)
         SessionData.Strings(i).Wav=...
             selected(strcmp(selected(:,3),cell2mat(StringName(i))),1);
        end
        error=[];
         for i=1:length(StringName)
         if isempty(SessionData.Strings(i).Wav)
             error=[error,' ',StringName(i)]
         end
         end
        if ~isempty(error)
             response=questdlg(['Cuidado. Cuerdas sin asignar',error],...
                 'Terminar',...
                'Continuar', 'Salir','asdf');
            switch response,
                case 'Continuar',
                    return
                case 'Salir'
                    close(f)
                    return
            end
        end
         %.Strings(2).Wav=...
            % selected(strcmp(selected(:,3),'A'),1);
        close(f);
    end

end