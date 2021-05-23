function selected=SelectStrings()
StringName={'E','A','D','G','B','e'};
cur_data=[];
f = figure('Units','normalized','Position', [0.2 0.2 0.2 0.4]);
t = uitable('Units','normalized','Parent', f, 'Position', [0 0 1 0.9]);
bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
    'Go',...
    'Position', [0 0 0.2 0.1],...
    'Callback', @Exit);
bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
    'Abort',...
    'Position', [0.2 0 0.2 0.1],...
    'Callback', @Abort);
bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
    'SelectAll',...
    'Position', [0.4 0 0.2 0.1],...
    'Callback', @SelectAll);
set(t,'ColumnName',{'Name','Select'});
set(t, 'ColumnEditable', [false true]);
set(t, 'ColumnFormat', {'char', 'logical'});
selected(1:6)={false};
set(t,'Data',[StringName',selected']);
set(t, 'CellEditCallback', @EditTable);
uiwait(f);
function EditTable(src,eventdata);
%     cur_data=get(src,'Data');
%     changed=eventdata.Indices;
%     cur_data(changed(1),2)={true};
%     set(t,'Data',cur_data);
end
function SelectAll(src,eventdata);
    cur_data=get(t,'Data');
    cur_data(:,2)={true};
   set(t,'Data',cur_data);
end

    function Exit(source,eventdata)
         cur_data=get(t,'Data');
        selected=cell2mat(cur_data(:,2));
       
        close(f);
    end
  function Abort(source,eventdata)
        
        selected=0;
       
        close(f);
    end

end