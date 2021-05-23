function DisplayFret(SessionPathBase,Session,istring,ifret,SPP,Master,Cycle)

f = figure('Units','normalized','Position',[0 0 0.6 0.6],'MenuBar','none',...
    'Name','Display Fret','NumberTitle','off');
hspectrum = axes('Units','normalized','Position',[0.05,0.4,0.9,0.55])

%%%%%%%%%%%%%%%%%Panel de activación de las distintas gráficas
hp = uipanel('Units','normalized','FontSize',12,...
    'Title','Session Info',...
    'BackgroundColor','white',...
    'Position',[0 0 0.3 0.3],'Parent',f);
xrb=1;
yrb=1/6;
ycount=0;
c1 = uicontrol('Parent',hp,...
    'Units','normalized',...
    'Style','radiobutton',...
    'String','Trace',...
    'ToolTip','Detected frequency per frame',...
    'Value',1,...
    'Position', [0 ycount xrb yrb],...
    'Callback', @DispTrace);
ycount=ycount+yrb;
c2 = uicontrol('Parent',hp,...
    'Units','normalized',...
    'Style','radiobutton',...
    'String','Freq',...
     'ToolTip','Global computed frequency for each harmonic',...
        'Value',1,...
    'Position', [0 ycount xrb yrb],...
    'Callback', @DispFreq);
ycount=ycount+yrb;
c3 = uicontrol('Parent',hp,...
    'Units','normalized',...
    'Style','radiobutton',...
    'String','Freq from open string',...
        'Value',1,...
        'ToolTip','Reference frequency from open string. Intonation',...
    'Position', [0 ycount xrb yrb],...
    'Callback', @DispFreqFromOpString);
ycount=ycount+yrb;
c4 = uicontrol('Parent',hp,...
    'Units','normalized',...
    'Style','radiobutton',...
    'String','Reference Freq',...
     'ToolTip','Reference frequency of harmonics from first harmonic',...
        'Value',1,...
    'Position', [0 ycount xrb yrb],...
    'Callback', @DisplayRefFreq);
ycount=ycount+yrb;
c5 = uicontrol('Parent',hp,...
    'Units','normalized',...
    'Style','radiobutton',...
    'String','Precision Marg',...
     'ToolTip','Margins of detection given by precision (NFFT).',...
        'Value',1,...
    'Position', [0 ycount xrb yrb],...
    'Callback', @Margins);
ycount=ycount+yrb;
c6 = uicontrol('Parent',hp,...
    'Units','normalized',...
    'Style','radiobutton',...
    'String','Detection Margins',...
    'ToolTip','Margins of each harmonic given by precision of fundamental multiplied by the harmonic number.',...
        'Value',1,...
    'Position', [0 ycount xrb yrb],...
    'Callback', @DetectMargins);
%%%%%%%%%%%%%%%%%%%%%%%Panel zoom y pan
hp1 = uipanel('Units','normalized','FontSize',12,...
    'Title','Session Info',...
    'BackgroundColor','white',...
    'Position',[0.3 0 0.2 0.3],'Parent',f);
bg=uibuttongroup('Visible','off',...
                    'Units','normalized',...
                    'Parent',hp1,...
                  'Position',[0 0 1 1],...
                  'SelectionChangedFcn',@bselection);
r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','zoom',...
                  'Units','normalized',...
                  'Tag','1',...
                  'Position',[0 0 1 0.5],...
                  'HandleVisibility','off');              
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','Pan',...
                  'Tag','2',...
                  'Units','normalized',...
                  'Position',[0 0.5 1 0.5],...
                  'HandleVisibility','off');
              bg.Visible = 'on';
              
              
               bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Analyze Fret',...
    'Position', [0.6 0 0.1 0.1],...
    'Callback', @AnalyzeFret,'Parent',f);
      bta = uicontrol('Units','normalized','Style', 'pushbutton',...
    'String', 'Configure Analisis',...
    'Position', [0.7 0 0.1 0.1],...
    'Callback', @SpectralAnalysisConf,'Parent',f);

 String=Session.Strings(istring);
        Fret=String.Fret(ifret);
        aux= strcat(SessionPathBase,Session.SessionPath);
        aux=strcat(aux,'\');
        aux=strcat(aux,cell2mat(Fret.WavName));
        [data fs]=audioread(aux,[Fret.Start Fret.End]);
        
        window=@blackmann; %Ventana de análisis
winlen=300; %miliseconds 100 200 300 500
winlenS=fs*winlen*1e-3;
if (winlenS > length(data))
    winlenS=length(data);
end
NFFT=16*2^(ceil(log2(winlenS)+1));
precision=fs/NFFT/2;
overlap=0.9; %90%
overlapS=round(winlenS*overlap);
windesp=winlenS-overlapS;
NHarm=length(String.Fret(ifret).Freq);
MaxFreq=2*Fret.NoteRefFreq*(NHarm+3);
DecFac=ceil(fs/MaxFreq); 
%if ~exist
p1=[];p2=[];p3=[];p4=[];p5=[];p6=[];
PlotAll();
return
        
        






    function PlotAll()

[y f t p]=spectrogram(decimate(data,DecFac),round(winlenS/DecFac),...
            round(overlapS/DecFac),...
            64*2^(ceil(log2(winlenS/DecFac))+1),...
            fs/DecFac ,'yaxis');
        imagesc(hspectrum,t,f,10*log10(abs(p)));
        axis xy; axis tight; colormap(jet); view(0,90);
        zoom on;
        hold on;
        Axis=axis;
        
        %Frequency detection per frame and harmonic (Trace)
        p1=plot(Fret.LHarm,Fret.HarmFreq,'g.')
       
       %Global frequency computed for each harmonic (Freq)
       p2=plot(repmat(Axis(1:2)',1,NHarm),repmat(Fret.Freq,2,1),'k');
        title(['String ',num2str(istring), 'Fret ', num2str(ifret)]);
         p3=plot(repmat(Axis(1:2)',1,NHarm),repmat(Fret.Freq(1)*(1:NHarm),2,1),'b');
         margins=zeros(1,2*NHarm);
         margins(1:2:end)=Fret.Freq+Fret.Prec;
         margins(2:2:end)=Fret.Freq-Fret.Prec;
         p4=plot(repmat(Axis(1:2)',1,2*NHarm),repmat(margins,2,1),'b');
         %((0:numwin-1)*windesp+(winlen/2))/fs
         for h=1:NHarm
         Inf=(Fret.InfLim(h)*SPP.WinDesp+SPP.WinLen)/fs;
         Sup=(Fret.SupLim(h)*SPP.WinDesp+SPP.WinLen)/fs;
         p5(h)=plot([Inf Inf],[Fret.Freq(h)-20 Fret.Freq(h)+20],'k');
         p6(h)=plot([Sup Sup],[Fret.Freq(h)-20 Fret.Freq(h)+20],'k');
         end
         
        %title(['String ',num2str(istring), 'Fret ', num2str(ifret)]);
         %for i=1:NHarm
          %     L=inf(i):sup(i);
           %   plot(LHarm(L),HarmFreq(L,i),'c.');
         %end
         hold off;
    end
         
        %LHarm=(0:numwin-1)*windesp/fs;
        
%         figure;
%         plot(Fret.HarmAmp);legend('1','2','3','4','5');hold on;
%          title(['String ',num2str(istring), 'Fret ', num2str(ifret)]);
        %plot(sal,sal2,'*r');
       
        
        %hold off;
%     function PlotFreq()
%         p1=plot(Fret.LHarm,Fret.HarmFreq,'g.')
%         %Usar aquí repmat para pintar todos los armónicos
%        % plot(Axis(1:2),Fret.Freq(1).*ones(1,2),'k');
%        plot(repmat(Axis(1:2)',1,10),repmat(Fret.Freq,2,1),'k');
%         title(['String ',num2str(istring), 'Fret ', num2str(ifret)]);
%          plot(repmat(Axis(1:2)',1,10),repmat(Fret.Freq(1)*(1:10),2,1),'b');
%     end
        function salida=DispTrace(src,eventdata)
            if src.Value
                for i=1:length(p1)
                p1(i).Visible='on'
                end
            else
                for i=1:length(p1)
                p1(i).Visible='off'
                end
            end
        end
     function salida=DisplayRefFreq(src,eventdata)
            if src.Value
                for i=1:length(p3)
                p3(i).Visible='on'
                end
            else
                for i=1:length(p3)
                p3(i).Visible='off'
                end
            end
     end
    function salida=DispFreq(src,eventdata)
            if src.Value
                for i=1:length(p2)
                p2(i).Visible='on'
                end
            else
                for i=1:length(p2)
                p2(i).Visible='off'
                end
            end
    end
    function salida=Margins(src,eventdata)
            if src.Value
                for i=1:length(p4)
                p4(i).Visible='on'
                end
            else
                for i=1:length(p4)
                p4(i).Visible='off'
                end
            end
    end
 function salida=DetectMargins(src,eventdata)
            if src.Value
                for i=1:length(p5)
                    set(p5(i),'Visible','on')
                    set(p6(i),'Visible','on')
                %p5(i).Visible='on'
                 %p6(i).Visible='on'
                end
            else
                for i=1:length(p5)
                    set(p5(i),'Visible','off')
                    set(p6(i),'Visible','off')
                 %p5(i).Visible='off'
                 %p6(i).Visible='off'
                
                end
            end
    end
    function bselection(source,event)
    if str2num(event.NewValue.Tag)==1
        zoom ;pan on;
                zoom on;pan off;

    else
               zoom off ;pan on;

    end
    end
      function AnalyzeFret(source,eventdata)
        strings=false(6,1);strings(istring)=true;
        frets=false(13,1);frets(ifret)=true;
         SessionOut=Analyze(Master,Cycle,Session,strings,frets,SPP);
          
        Session=SessionOut;
        %delete(hspectrum);
        %hspectrum = axes('Units','normalized','Position',[0.05,0.4,0.9,0.55])
   PlotAll();
    end
    function SpectralAnalysisConf(source,eventdata)
            SPP=GetSpecAnPar(SPP);
    end
    
        
end
     