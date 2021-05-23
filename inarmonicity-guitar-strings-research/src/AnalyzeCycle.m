function f=AnalyzeCycle(Master,Cycle_index)

SpecAnPar.Fs=48000;
SpecAnPar.WinLen=250;
SpecAnPar.Overlap=90;

SpecAnPar.WinLenS=round(SpecAnPar.Fs*SpecAnPar.WinLen*1e-3);
SpecAnPar.OverlapS=round(0.9*SpecAnPar.WinLenS);
%SpecAnPar.WinDespS=240;
%SpecAnPar.WinDesp=2.5;
SpecAnPar.WinDespS=SpecAnPar.WinLenS-SpecAnPar.OverlapS;
SpecAnPar.WinDesp=1000*SpecAnPar.WinDespS/SpecAnPar.Fs;
SpecAnPar.FreqMarg=30;
SpecAnPar.OverSamp=2;
SpecAnPar.Interp=10;
SpecAnPar.NFFT=SpecAnPar.OverSamp*2^(ceil(log2(SpecAnPar.WinLenS)+1));
SpecAnPar.WindowFun=@hamming;
SpecAnPar.WindowIndex=1;
SpecAnPar.Window=...
SpecAnPar.WindowFun(SpecAnPar.WinLenS);
SpecAnPar.Precision=SpecAnPar.Fs/(SpecAnPar.NFFT*SpecAnPar.Interp)/2;
SpecAnPar.NormF=2/(sum(abs(SpecAnPar.Window)));
PathCycle=Master.Cycles{Cycle_index};
Cycle=load([Master.DataPath,cell2mat(PathCycle)]);
Cycle=Cycle.Cycle;
SessionPathBase=[Master.WavPath Cycle.WavPath];
%'C:\Users\Antonio\Clases\TFGs\Guitarra\Sesiones'
SessionDataBase=Master.DataPath; 
btsaveSess=[];
%aux=load('datos2.mat');
StrRef=GenerateStringData();
SessionIndex=-1;
Session=[];
SessionSaved=1;
%Sessions=aux.Sessions;
savecol=[];
f = figure('Units','normalized','Position',[0 0 0.8 0.6],'MenuBar','none',...
    'Name','Analysis window','NumberTitle','off');
%File selection Panel%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hp1 = uipanel('Units','normalized','FontSize',12,...
    'Title','Cycle Info',...
    'BackgroundColor','white',...
    'Position',[0 0.1 0.3 0.5],'Parent',f);
% bta = uicontrol('Units','normalized','Style', 'pushbutton',...
%     'String', 'Load File',...
%     'Position', [0 0 0.3 0.2],...
%     'Callback', @GetFile,'Parent',hp1);
tboxhp1 = uicontrol('Units','normalized','Style','text','String','No File loaded',...
    'position',[0 0.3 1 0.7],'Parent',hp1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hp2 = uipanel('Units','normalized','FontSize',12,...
    'Title','Session Info',...
    'BackgroundColor','white',...
    'Position',[0.3 0.1 0.3 0.5],'Parent',f);
tbox = uicontrol('Units','normalized','Style','text','String','No session loaded ',...
    'position',[0 0.3 1 0.7],'Parent',hp2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hp3 = uipanel('Units','normalized','FontSize',12,...
    'Title','Fret Info',...
    'BackgroundColor','white',...
    'Position',[0.6 0.1 0.3 0.5],'Parent',f);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
menu=uimenu(f,'Label','Display');
m1=uimenu(menu,'Label','Reference Frequency','CallBack',@PrintRefFreq);
m1=uimenu(menu,'Label','Reference Frequency From Open String','CallBack',@PrintRefFreqFromOpStr);
m2=uimenu(menu,'Label','Detected Frequency','CallBack',@PrintDetFreq);
m3=uimenu(menu,'Label','Error from reference','CallBack',@PrintErrorFromRef);
m4=uimenu(menu,'Label','Error from Open string (Hz)','CallBack',@PrintErrorFromOpHz);
m4=uimenu(menu,'Label','Error from Open string (%)','CallBack',@PrintErrorFromOpPer);
 bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Inharmonicity analisys',...
    'Position', [0 0 0.1 0.05],...
    'Callback', @InharmAnal,'Parent',f);
 btb = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Extract B',...
    'Position', [0.1 0 0.1 0.05],...
    'Callback', @Extract_B,'Parent',f);

tSeg = uitable('Units','normalized',...
    'Position', [0 0.75 1 0.25]);
tboxG = uicontrol('Units','normalized','Style','text','String',...
    'Canonic frequency of each string/fret',...
    'position',[0 0.74 1 0.03],'Parent',f);
% bta = uicontrol('Units','normalized','Style', 'pushbutton', 'String',...
%     'Terminar',...
%     'Position', [0 0 0.1 0.1],...
%     'Callback', @Exit);
%

%for string=1:6
%PrintTextBox(Sessions,session);
SFret=-1;
SString=-1;
for fret=1:13
    columname(fret)={['Fret ',num2str(fret-1)]};
    
end
columnformat(1:13)={'char'};
columnwidth(1:13)={90};
%end
set(tSeg,'ColumnWidth',columnwidth);

set(tSeg,'ColumnName',columname);
%set(tSeg, 'ColumnEditable', [false false false false false true]);
set(tSeg, 'ColumnFormat', columnformat);
set(tSeg, 'CellSelectionCallback', @SelectFret);
for string=1:6
    for fret=1:13
        aux=StrRef(string).fret(fret);
        %tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
        %   num2str(aux.Freq,5),'||',...
        %  num2str(Sessions(session).Strings(string).Fret(fret).Freq,5)]};
        tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
            num2str(aux.Freq,'%4.2f')]};
        %tableData(string,fret)={num2str(aux.Freq,5)};
        tSeg.ColumnWidth
    end
end
%RecDate=[];
tableRefData=tableData;
set(tSeg,'Data',tableData);
PrintCycleInfo()
return
    function SelectFret(source,eventdata)
        if isempty(eventdata.Indices)
            return
        end
        if ~isfield(Session,'Analyzed')
                errordlg('Session not Analyzed');
                return;
            elseif ~Session.Analyzed
                errordlg('Session not Analyzed');
                return;
        end
        tbox3 = uicontrol('Units','normalized','Style','text','String','Fret Info ',...
            'position',[0 0.3 1 0.7],'Parent',hp3);
        fret=eventdata.Indices(2);
        string=eventdata.Indices(1);
        LFret=Session.Strings(string).Fret(fret);
        Text=char(['String: ',num2str(string),' Fret:', num2str(fret-1)]);
        Text=char(Text,['Note Name ',cell2mat(LFret.NoteName)]);
        Text=char(Text,[' Note Ref freq: ',num2str(LFret.NoteRefFreq,'%4.2f')]);
        Text=char(Text,['Freq from open str ', num2str(LFret.FreqFromOpenStNote,'%4.2f')]);
        Text=char(Text,['Detected Freq ', num2str(LFret.Freq,'%4.2f')]);
        Text=char(Text,['Out of tune (Hz) ',num2str(LFret.RelOutOfTuneHz,'%2.2f')]);
        %Text=char(Text,['Precision :',num2str(prec),' Hz']);
        set(tbox3,'String',Text);
        bta = uicontrol('Units','normalized','Style', 'pushbutton',...
            'String', 'Inspect',...
            'Position', [0.3 0.2 0.2 0.1],...
            'Callback', @InspectFret,'Parent',hp3);
         bta = uicontrol('Units','normalized','Style', 'pushbutton',...
            'String', 'Inharmonicity',...
            'Position', [0.6 0.2 0.2 0.1],...
            'Callback', @Inharm,'Parent',hp3);
        
        SFret=fret;
        SString=string;
        PrintCycleInfo()
        
    end
    function PrintRefFreq(source,eventdata)
%         for string=1:6
%            % mystring=Session.Strings(string);
%             for fret=1:13
%                 aux=StrRef(string).fret(fret);
% %                 if (isempty(mystring.Fret(fret).WavName))
% %                     tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
% %                    'UNK']};)]};
%               %  end
%                 set(tSeg,'Data',tableData);
%                 
%             end
%         end
 set(tSeg,'Data',tableRefData);
         set(tboxG,'String','Canonic frequency for each string/fret');
    end
 function PrintDetFreq(source,eventdata)
        for string=1:6
            mystring=Session.Strings(string);
            for fret=1:13
               aux=StrRef(string).fret(fret);
                 if ((fret > length(mystring.Fret))|| ...
                         ~isfield(mystring.Fret(fret),'FreqFromOpenStNote') ||...
                         (isempty(mystring.Fret(fret).FreqFromOpenStNote)))
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                   'UNK']};
                 else
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                    num2str(Session.Strings(string).Fret(fret).Freq(1),'%4.2f')]};
                
                end
            end
        end
         set(tSeg,'Data',tableData);
         set(tboxG,'String','Canonic frequency for each string/fret');
    end
    function PrintRefFreqFromOpStr(source,eventdata)
        if (isempty(Session))
            errordlg('Please, select a session first');
            return;
        end
        for string=1:6
            mystring=Session.Strings(string);
            for fret=1:13
                aux=StrRef(string).fret(fret);
               % tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                %    num2str(Session.Strings(string).Fret(fret).FreqFromOpenStNote,5)]};
                %tableData(string,fret)={num2str(aux.Freq,5)};
                 if ((fret > length(mystring.Fret))|| ...
                         ~isfield(mystring.Fret(fret),'FreqFromOpenStNote') ||...
                         (isempty(mystring.Fret(fret).FreqFromOpenStNote)))
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                   'UNK']};
                 else
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                    num2str(Session.Strings(string).Fret(fret).FreqFromOpenStNote,'%4.2f')]};
                
                end
               
                
            end
        end
         set(tSeg,'Data',tableData);
        set(tboxG,'String','Reference from open string detected frequency: Intonation accuracy for each fret');
    end
    function PrintErrorFromOpHz(source,eventdata)
        if (isempty(Session))
            errordlg('Please, select a session first');
            
            return;
        end
        for string=1:6
            mystring=Session.Strings(string);
            for fret=1:13
                aux=StrRef(string).fret(fret);
                if ((fret > length(mystring.Fret))||...
                        ~isfield(mystring.Fret(fret),'RelOutOfTuneHz') ||...
                         (isempty(mystring.Fret(fret).RelOutOfTuneHz)))
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                   'UNK']};
                 else
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                    num2str(Session.Strings(string).Fret(fret).RelOutOfTuneHz,'%4.2f')]};
                
                end
                %tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                 %   num2str(Session.Strings(string).Fret(fret).RelOutOfTuneHz,5)]};
                %tableData(string,fret)={num2str(aux.Freq,5)};
                set(tSeg,'Data',tableData);
                
            end
        end
        set(tboxG,'String',...
        'Relative string/fret intonation accuracy: error in Hz from open string detected frequency');
    end
    function PrintErrorFromOpPer(source,eventdata)
        if (isempty(Session))
            errordlg('Please, select a session first');
            return;
        end
        for string=1:6
            mystring=Session.Strings(string);
            for fret=1:13
                aux=StrRef(string).fret(fret);
                if ((fret > length(mystring.Fret))||~isfield(mystring.Fret(fret),'RelOutOfTunePer') ||...
                         (isempty(mystring.Fret(fret).RelOutOfTunePer)))
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                   'UNK']};
                 else
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                    num2str(Session.Strings(string).Fret(fret).RelOutOfTunePer,'%2.2f')]};
                
                end
                
                %tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                  %  num2str(Session.Strings(string).Fret(fret).RelOutOfTunePer,5)]};
                %tableData(string,fret)={num2str(aux.Freq,5)};
                set(tSeg,'Data',tableData);
                
            end
        end
        set(tboxG,'String',...
            'Relative string/fret intonation accuracy: error in % from open string detected frequency');
    end
    function PrintErrorFromRef(source,eventdata)
        if (isempty(Session))
            errordlg('Please, select a session first');
            return;
        end
        for string=1:6
            mystring=Session.Strings(string);
            for fret=1:13
                aux=StrRef(string).fret(fret);
               if ((fret > length(mystring.Fret))||...
                        ~isfield(mystring.Fret(fret),'WavName') ||...
                         (isempty(mystring.Fret(fret).WavName)))
                    tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                   'UNK']};
                else
                    aux2=mystring.Fret(fret).NoteRefFreq-...
                      mystring.Fret(fret).Freq(1);
                tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                    num2str(aux2,5)]};
                %tableData(string,fret)={[cell2mat(aux.NoteName),' ',...
                   % num2str(mystring.Fret(fret).Freq,5)]};
                end
               
                %tableData(string,fret)={num2str(aux.Freq,5)};
                set(tSeg,'Data',tableData);
                
            end
        end
         set(tboxG,'String',...
        'Absolute string/fret intonation accuracy: error in Hz from canonic frequency');
    end
    function PrintSessionInfo(Session)
        
        %set(tbox,'String',String);
     
            %String=char(['General Info']);
%             String=char(['Session ',num2str(SessionIndex),...
%                 ' Name: ',Session.Name]);
%             String=char(String,['Wavs: ',num2str(Session.NumWavs)]);
            String= ['Session ',num2str(SessionIndex),...
                ' Name: ',cell2mat(Session.Name),' Wavs: ',num2str(Session.NumWavs)];
            if ~isfield(Session,'Analyzed')
                String=char(String,['Not Analyzed']);
               % String={String,['Not Analyzed']};
            elseif ~Session.Analyzed
                String=char(String,['Not Analyzed']);
                %String={String,['Analyzed']};
            else
            for string=1:6
                String=char(String,['String ',char(Session.Strings(string).StringID),...
                    ' Canonic Freq: ',num2str(Session.Strings(string).Fret(1).NoteRefFreq,'%4.2f'),'Hz']);
                 String=char(String,...
                 [' Detected ',num2str(Session.Strings(string).OpenFreq,'%4.2f'),...
                  ' Tuning error: ',num2str(Session.Strings(string).OutOfTuneHz,'%2.2f'),'Hz']);
                   % ' Intonation (Hz) ',num2str(Ses.Strings(string).OutOfTuneHz),...
                    %' Intonation (%) ',num2str(Ses.Strings(string).OutOfTunePer)]);
            end
            end
            % String=char(String,['String ',char(Ses.Strings(2).StringID)]);
      
        
        set(tbox,'String',String);
        bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Analyze All',...
    'Position', [0 0 0.2 0.2],...
    'Callback', @AnalyzeCB,'Parent',hp2);
      bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Analyze String',...
    'Position', [0.2 0 0.2 0.2],...
    'Callback', @AnalyzeString,'Parent',hp2);
      bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Analyze Fret',...
    'Position', [0.4 0 0.2 0.2],...
    'Callback', @AnalyzeFret,'Parent',hp2);
 bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Configure Analisis',...
    'Position', [0.6 0 0.2 0.2],...
    'Callback', @SpectralAnalysisConf,'Parent',hp2);
        
    end
    function InspectFret(source,eventdata)
        
        if ((SFret<0) || (SString <0))
            return;
        end
        DisplayFret(SessionPathBase,Session,SString,SFret,SpecAnPar,Master,Cycle);
        
    end
      function Inharm(source,eventdata)
        
        if ((SFret<0) || (SString <0))
            return;

        end
        beta=CalculateInharmonicity(Session.Strings(SString).Fret(SFret));
        
    end
    function   PrintCycleInfo()
        %[Filename Pathname]=uigetfile('*.mat');
        %set(tboxhp1,'String',[Pathname,Filename]);
        %aux=load([Pathname,Filename]);
        %Sessions=aux.Sessions;
        mystring=[cell2mat(Cycle.Name)];
        mystring=char(mystring,['Musician: ',cell2mat(Cycle.Musician)]);
        NumSessions=Cycle.NSessions
        mystring=char(mystring,['Sessions: ',num2str(NumSessions)]);
        popstring=[];
        for i=1:NumSessions
            SesF=[SessionDataBase,cell2mat(Cycle.Sessions(i))];
            aux=load(SesF);
            SData=aux.SessionData;
            mystring=char(mystring,['Session ',num2str(i),' ',...
               cell2mat(SData.Name),' ',datestr(SData.date)]);
            %popstring={popstring,num2str(i)};
        end
        set(tboxhp1,'String',mystring);
        
        txt=uicontrol('Units','normalized','Style', 'text',...
            'String', 'Select Session',...
            'Position', [0.3 0.1 0.3 0.1],...
            'Parent',hp1);
        Pop1 = uicontrol('Units','normalized','Style', 'popupmenu',...
            'String', 1:NumSessions,...
            'Position', [0.3 0 0.3 0.1],...
            'Callback', @GetSession,'Parent',hp1);
        
        
        
    end
    function   GetSession(source,eventdata)
        % Pop1.Value
        if (~SessionSaved)
            resp=questdlg('Session not saved. Save, Continue or cancel?',...                      
                'Save','Continue','Cancel','Cancel');
         
        switch resp,
            case 'Cancel'
                    return;
            case 'Save'
                SaveSession();
        end
        end
        session=get(source,'Value');
        SesF=[SessionDataBase,cell2mat(Cycle.Sessions(session))];
            aux=load(SesF);
            Session=aux.SessionData;
            SessionIndex=session;
           
        PrintSessionInfo(Session);
    end
function AnalyzeCB(source,eventdata)
    
    SessionOut=Analyze(Master,Cycle,Session,true(6,1),true(13,1),SpecAnPar);
    %SessionOut=Analyze(Session,true(6,1),true(13,1),SpecAnPar);
     Session=SessionOut;
     Session.Analyzed=1;
        btsaveSess = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Save',...
    'Position', [0.8 0 0.2 0.2],...
    'Callback', @SaveSession,'Parent',hp2);
       savecol=get(btsaveSess,'BackgroundColor');
   set(btsaveSess,'BackgroundColor','red');
   SessionSaved=0;
   PrintSessionInfo(Session);
    
end
    function SaveSession(source,eventdata)
         SesF=[SessionDataBase,cell2mat(Cycle.Sessions(SessionIndex))];
         SessionData=Session;
         save(SesF,'SessionData');
          set(btsaveSess,'BackgroundColor',savecol);
         msgbox('Current session saved');
         
         
        
    end
    function AnalyzeString(source,eventdata)
        selected=SelectStrings();
         if ~selected
             return
         end
         SessionOut=Analyze(Master,Cycle,Session,selected,true(13,1),SpecAnPar);
          Session.Analyzed=1;
         Session=SessionOut;
         btsaveSess = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Save',...
    'Position', [0.75 0 0.25 0.2],...
    'Callback', @SaveSession,'Parent',hp2);
       savecol=get(btsaveSess,'BackgroundColor');
   set(btsaveSess,'BackgroundColor','red');
   SessionSaved=0;
   Session=SessionOut;
   PrintSessionInfo(Session);
    end
function AnalyzeFret(source,eventdata)
        [strings frets]=SelectStringsFrets();
        if ~strings
             return
         end
         SessionOut=Analyze(Master,Cycle,Session,strings,frets,SpecAnPar);
          Session.Analyzed=1;
         Session=SessionOut;
         btsaveSess = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Save',...
    'Position', [0.75 0 0.25 0.2],...
    'Callback', @SaveSession,'Parent',hp2);
       savecol=get(btsaveSess,'BackgroundColor');
   set(btsaveSess,'BackgroundColor','red');
   SessionSaved=0;
   Session=SessionOut;
   PrintSessionInfo(Session);
    end
    function SpectralAnalysisConf(source,eventdata)
            SpecAnPar=GetSpecAnPar(SpecAnPar);
    end
    function InharmAnal(source,eventdata)
            Salida=InharmonicityAnalysis(Session);
    end
 function Extract_B(source,eventdata)
            Salida=ExtractB(Session);
            name=['Cycle',num2str(Cycle_index),'.',Session.Name,'.B.mat'];
             save(cell2mat(name),'Salida')
    end

end
