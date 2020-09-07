function SessionOut=Analyze(Master,Cycle,Session,SStrings,SFrets,SpAnPar)
%function SessionOut=Analyze(Session,SStrings,SFrets,SpAnPar)
%Sessions=load('datos.mat')
%Sessions=Sessions.Sessions;
 SessionPathBase=[Master.WavPath Cycle.WavPath];
% SessionDataBase=Master.DataPath;
% SesF=[SessionDataBase,cell2mat(Cycle.Sessions(SessionIndex))];
% aux=load(SesF);
% Session=aux.SessionData;
if ~isfield(Session,'Analyzed')
Session=CreateSessionStruct(Session);
end
for str=1:6;
if ~isfield(Session.Strings(str).Fret(1),'SupLim')
    Session.Strings(str).Fret(1).SupLim=[];
    Session.Strings(str).Fret(1).InfLim=[];
end
end
%Sessions=OutS;
%SessionPathBase='C:\Users\Antonio\Clases\TFGs\Guitarra\Sesiones';
%fs=48000;
%f=figure;
%Para inicializar
d = figure('Units','normalized','Position',[0.3 0.3 0.2 0.5],'MenuBar','none',...
    'Name','Analysis output','NumberTitle','off');
%d = dialog('Position',[300 300 250 150],'Name','Analizing Session');
txt=[{'Starting.......................'}];
txtw = uicontrol('Parent',d,...
    'Style','edit',...
    'Max',20,...
    'Enable','inactive',...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',[0 0 1 1],...
    'String','Starting................');
drawnow;

NHarm=10;
%for isession=1:length(Sessions)
%SessionPath=Sessions(isession).SessionPath
Strings=Session.Strings;
StringIndex=1:6;
FretIndex=1:13;
for string=StringIndex(SStrings)
%     Strings(string).OpenFreq=[];
%     Strings(string).OutOfTuneHz=[];
%     Strings(string).OutOfTunePer=[];
    String=Strings(string);
    % display(['String ',cell2mat(String.StringID)]);
    txt=[['----String ',cell2mat(String.StringID),'-----'],txt];
    set(txtw,'String',txt);
    drawnow;
    OpenNote=String.OpenFreq;
    OutOfTuneHz=0;
    
    OutOfTunePer=0;
    for fret=FretIndex(SFrets);
        Fret=String.Fret(fret);
        if (isempty(Fret.WavName))
            display(['!!Fret ',num2str(fret),' empty']);
            txt=[txt,{['!!Fret ',num2str(fret),' empty']}];
            set(txtw,'String',txt);
            drawnow;
        else
            %Fret=String.Fret(fret);
            aux= strcat(SessionPathBase,Session.SessionPath);
            aux=strcat(aux,'\');
            aux=strcat(aux,cell2mat(Fret.WavName));
           
            %set(txtw,'String',txt);
            % drawnow;
            
            %        wavname=cellstr(Fret.WavName);
            if isempty(strfind(version,'R2011b'))
                [data fs]=audioread(aux,[Fret.Start Fret.End]);
            else
                [data fs]=wavread(aux,[Fret.Start Fret.End]);
            end
            
            
            %aux=decimate(data(:,1),16);
            %specgram(aux);
            %title([String.StringID,' ',Fret.NoteName])
            tstart = tic;
            %[LHarm HarmFreq HarmAmp Freq prec]=...
                %DetectaArm(data(:,1),Fret.Freq,NHarm,SpAnPar);
                Salida=...
                DetectaArm(data(:,1),Fret.Freq,NHarm,SpAnPar);
            telapsed = toc(tstart)
            Fret.HarmFreq=Salida.HarmFreq;
            Fret.HarmAmp=Salida.HarmAmp;
            Fret.LHarm=Salida.LHarm;
            Fret.Prec=Salida.precision;
            Fret.SupLim=Salida.SupLim;
            Fret.InfLim=Salida.InfLim;;
            display(['Note Name ',cell2mat(String.Fret(fret).NoteName)]);
            display([' Note Ref freq: ',num2str(String.Fret(fret).NoteRefFreq)]);
            display(['Stored real Freq ', num2str(String.Fret(fret).Freq)]);
            display(['Detected Freq ',num2str(Salida.Freq(1))]);
            display(['Precision :',num2str(Salida.precision),' Hz']);
             txt1=[{['*Fret ',num2str(fret),...
                 ' String ',cell2mat(String.StringID),...
                 ' Note ',cell2mat(String.Fret(fret).NoteName),...
                 ' Canonic Freq ',num2str(String.Fret(fret).NoteRefFreq,'%4.2f')...
                 ]}];
            %txt1=[txt1,['Note Name ',cell2mat(String.Fret(fret).NoteName)]];
            %txt1=[txt1,[' Note Ref freq: ',num2str(String.Fret(fret).NoteRefFreq)]];
            %txt1=[txt1,['Stored real Freq ', num2str(String.Fret(fret).Freq)]];
            txt1=[txt1,['Detected Freq ',num2str(Salida.Freq(1)),...
                '+-',num2str(Salida.precision),' Hz']];
            %set(txtw,'String',txt);
            %drawnow;
            if (fret==1)
                OpenNote=Salida.Freq(1);
                NRF=String.Fret(fret).NoteRefFreq;
                OutOfTuneHz=Salida.Freq(1)-NRF;
                
                OutOfTunePer=100*OutOfTuneHz/NRF;
                
                display(['Out of tune ',num2str(Salida.Freq(1)-NRF),...
                    ' Hz ',num2str(100*(Salida.Freq(1)-NRF)/NRF),'%']);
                txt1=[txt1,['Out of tune ',num2str(Salida.Freq(1)-NRF),...
                    ' Hz ',num2str(100*(Salida.Freq(1)-NRF)/NRF),'%']];
                %set(txtw,'String',txt1);
                % drawnow;
                %Fret.Freq=Freq(1);
            end
            Fret.Freq=Salida.Freq;
            FreqFromOpenStrNote=OpenNote*(2)^(((fret-1)/12));
            display(['Ref from open str note: ',num2str(FreqFromOpenStrNote)]);
            display(['Deviation :',num2str(FreqFromOpenStrNote-Salida.Freq(1)), ' Hz ',...
                num2str(100*(FreqFromOpenStrNote-Salida.Freq(1))/Salida.Freq(1)),' % ']);
            txt1=[txt1,['Relative Canonic Freq: ',num2str(FreqFromOpenStrNote),...
                ' Error Hz :',num2str(FreqFromOpenStrNote-Salida.Freq(1)), ' Hz ',...
                num2str(100*(FreqFromOpenStrNote-Salida.Freq(1))/Salida.Freq(1)),' % ']];
            txt=[txt1,txt];
            set(txtw,'String',txt);
            drawnow;
            
            
            Fret.FreqFromOpenStNote=FreqFromOpenStrNote;
            Fret.RelOutOfTuneHz=FreqFromOpenStrNote-Salida.Freq(1);
            Fret.RelOutOfTunePer=100*(FreqFromOpenStrNote-Salida.Freq(1))/Salida.Freq(1);
            
            
            % pause
            String.Fret(fret)=Fret;
            
        end %not empty
    end %fret
     
    NRF=String.Fret(1).NoteRefFreq;
    String.OpenFreq=String.Fret(1).Freq(1);
    String.OutOfTuneHz=String.Fret(1).Freq(1)-NRF;
    String.OutOfTunePer=100*String.OutOfTuneHz/NRF;
    Session.Strings(string)=String;
end %Strings
%Sessions(isession).Strings=Strings;
txt=[['.................Terminated'],txt];

set(txtw,'String',txt);
drawnow;
%end %Sesiones
SessionOut=Session;
end