function [Strings Frets]=SelectStringsFrets()
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
selected(1:6)={false},
set(t,'Data',[StringName',selected']);
set(t, 'CellEditCallback', @EditTable);
% pop = uicontrol('Style','popupmenu',...
%     'String',{'A','B','C'},...
%     'Position',[0 0 1 1],...
%     'Callback',{@GetFret});
txt12 = uicontrol('Style','text',...
    'Units','normalized',...
    'Position',[0 0.2 0.2 0.1],...
    'String','Fret');

HFret = uicontrol('Units','normalized','Parent',f,'Style',  'popupmenu',...
    'String',num2str((0:12)'),...
    'Position', [0.2 0.2 0.2 0.1],...
    'Callback',{@GetFret});
SelFret=1;


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
function salida=GetFret(source,eventdata)
        SelFret=get(source,'Value');
        
           
    end

    function Exit(source,eventdata)
         cur_data=get(t,'Data');
        Strings=cell2mat(cur_data(:,2));
        Frets=false(13,1);
        Frets(SelFret)=true;
       
        close(f);
    end
 function Abort(source,eventdata)
        
        Strings=0;
        Frets=0;
       
        close(f);
    end

end