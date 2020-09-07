function OutPar=GetSpecAnPar(InPar)

OutPar=InPar;
TestList=...
{'None',... %Ninguno
'Test',...
'FFT',...
'FFT & interp',...
'Analysis by syntesis'
};
WindowList={'Hamm','Rect','Hann','Black'};
f = figure('Units','normalized','Position',[0 0 0.3 0.4],'MenuBar','none',...
    'Name','Spectral Analisys configuration','NumberTitle','off');
hp3 = uipanel('Units','normalized',...
    'FontSize',10,...
    'Title','Test Config',...
    'BackgroundColor','white',...
    'Position',[0 0 1 1]);
TextFs = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0 250 75 25],...
    'String',['Fs  ',num2str(OutPar.Fs')]);
txt = uicontrol('Parent',hp3,'Style','text',...
    'Position',[100,250,75,25],...
    'String','Freq Margin');

HMinFreq = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.FreqMarg)],...
    'Position',[200 250 50 25],...
    'Callback',{@FreqMargin});




txt1 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0,190,100,25],...
    'String','Win. Len, ms');

HWinLen = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.WinLen)],...
    'Position',[110 190 30 25],...
    'Callback',{@WinLen});
txt12 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[170,190,75,25],...
    'String','Samples');
HWinLenS = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.WinLenS)],...
    'Position',[240 190 50 25],...
    'Callback',{@WinLenS});

txt4 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0 160 100 25],...
    'String','Overlap %');
HOverlap = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.Overlap)],...
    'Position',[110 160 50 25],...
    'Callback',{@Overlap});

txt12 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[170,160,75,25],...
    'String','Samples');
HOverlapS = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.OverlapS)],...
    'Position',[240 160 50 25],...
    'Callback',{@OverlapS});

txt4 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0 140 100 25],...
    'String','Win desp ms');
HWindesp = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.WinDesp)],...
    'Position',[110 140 50 25],...
    'Callback',{@WinDesp});

txt12 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[170,140,75,25],...
    'String','Samples');
HWindespS = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.WinDespS)],...
    'Position',[240 140 50 25],...
    'Callback',{@WinDespS});


txt2 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0 100 65 20],...
    'String','FFT Len.');
HNFFT = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.NFFT)],...
    'Position',[70 100 50 20],...
    'Callback',{@FFTSize});


txt3 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[130 100 65 25],...
    'String','window type');

HWindowType = uicontrol('Parent',hp3,'Style',  'popupmenu',...
    'String',WindowList,...
    'Value',OutPar.WindowIndex,...
    'Position',[210,100,65,25],...
    'Callback',{@Window});

txtn = uicontrol('Parent',hp3,'Style','text',...
    'Position',[280 100 80 20],...
    'String','Over Sampling');
HOverS = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.OverSamp)],...
    'Position',[370 100 50 20],...
    'Callback',{@OverSamp});

txt3 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0 66-25 65 25],...
    'String','Method');

HTestType = uicontrol('Parent',hp3,'Style',  'popupmenu',...
    'String',TestList,...
    'Position',[70,65-25,65,25],...
    'Callback',{@TestType});
bta = uicontrol('Style', 'pushbutton',...
    'String', 'Save',...
    'Position', [200 66-50 65 25],...
    'Callback', {@Exit},'Parent',hp3);
bta = uicontrol('Style', 'pushbutton',...
    'String', 'Abort',...
    'Position', [200 66-25 65 25],...
    'Callback', {@Abort},'Parent',hp3);



txt2 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[0 80 65 20],...
    'String','Interpolation');
HInterp = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.Interp)],...
    'Position',[70 80 50 20],...
    'Callback',{@Interpolation});

txt2 = uicontrol('Parent',hp3,'Style','text',...
    'Position',[300,65-25,65,25],...
    'String','Precision');
HPrec = uicontrol('Parent',hp3,'Style','edit',...
    'String',[num2str(OutPar.Precision)],...
    'Position',[370,65-25,65,25],...
    'Callback',{@Precision});

uiwait(f);

 function FreqMargin(source,eventdata)
        OutPar.FreqMarg=str2num(get(source,'String'))
    end
   
    function salida=WinLen(source,eventdata)
        OutPar.WinLen=str2num(get(source,'String'));
        OutPar.WinLenS=round(OutPar.WinLen*OutPar.Fs*1e-3);
        OutPar.OverlapS=...
            round(OutPar.Overlap*OutPar.WinLenS/100);
        set(HWinLenS,'String',OutPar.WinLenS);
        set(HOverlapS,'String',OutPar.OverlapS);
        %Comprobar y recalcular FFT
        if (OutPar.NFFT < OutPar.WinLenS)
            OutPar.NFFT=2^(ceil(log2(OutPar.WinLenS)));
            set(HNFFT,'String',OutPar.NFFT);
        end
        OutPar.Window=...
            OutPar.WindowFun(OutPar.WinLenS);
        
        OutPar.WinDespS=OutPar.WinLenS-OutPar.OverlapS;
        OutPar.WinDesp=1000*OutPar.WinDespS/OutPar.Fs;
        OutPar.NormF=2/(sum(abs(OutPar.Window)));
        set(HWindespS,'String',OutPar.WinDespS);
        set(HWindesp,'String',OutPar.WinDesp);
    end
    function salida=WinLenS(source,eventdata)
        OutPar.WinLenS=str2num(get(source,'String'));
        OutPar.WinLen=OutPar.WinLen/OutPar.Fs/1000;
        OutPar.OverlapS=...
            round(OutPar.Overlap*OutPar.WinLenS/1000);
        
        set(HWinLen,'String',OutPar.WinLen);
        set(HOverlapS,'String',OutPar.OverlapS);
        
        OutPar.WinDespS=OutPar.WinLenS-OutPar.OverlapS;
        OutPar.WinDesp=1000*OutPar.WinDespS/OutPar.Fs;
        set(HWindespS,'String',OutPar.WindespS);
        set(HWindesp,'String',OutPar.Windesp);
        
        %Comprobar y recalcular FFT
        if (OutPar.NFFT < OutPar.WinLenS)
            OutPar.NFFT=2^(ceil(log2(OutPar.WinLenS)));
            set(HNFFT,'String',OutPar.NFFT);
        end
        OutPar.Window=...
            OutPar.WindowFun(OutPar.WinLenS);
        OutPar.NormF=2/(sum(abs(OutPar.Window)));
    end

    function salida=Window(source,eventdata)
        get(source,'String')
        switch get(source,'Value')
            case 1
                OutPar.WindowFun=@hamming;
            case 2
                OutPar.WindowFun=@rectwin;
            case 3
                OutPar.WindowFun=@hanning;
            case 4
                OutPar.WindowFun=@blackman;
        end
        OutPar.Window=...
            OutPar.WindowFun(OutPar.WinLenS);
        OutPar.NormF=2/(sum(abs(OutPar.Window)));
         OutPar.WindowIndex=get(source,'Value');
    end
    function salida=OverlapS(source,eventdata)
        OutPar.OverlapS=str2num(get(source,'String'));
        OutPar.WinLenS=round(OutPar.WinLen*OutPar.Fs*1e-3);
        OutPar.Overlap=...
            100*OutPar.OverlapS/OutPar.WinLenS;
        %set(HWinLenS,'String',OutPar.WinLenS);
        set(HOverlap,'String',OutPar.Overlap);
        OutPar.WinDespS=OutPar.WinLenS-OutPar.OverlapS;
        OutPar.WinDesp=1000*OutPar.WinDespS/OutPar.Fs;
        set(HWindespS,'String',OutPar.WinDespS);
        set(HWindesp,'String',OutPar.WinDesp);
    end
    function salida=Overlap(source,eventdata)
        OutPar.Overlap=str2num(get(source,'String'));
        OutPar.OverlapS=...
            round(OutPar.Overlap*OutPar.WinLenS/100);
        set(HOverlapS,'String',OutPar.OverlapS);
        OutPar.WinDespS=OutPar.WinLenS-OutPar.OverlapS;
        OutPar.WinDesp=1000*OutPar.WinDespS/OutPar.Fs;
        set(HWindespS,'String',OutPar.WinDespS);
        set(HWindesp,'String',OutPar.WinDesp);
    end
    function salida=WinDesp(source,eventdata)
        OutPar.WinDesp=str2num(get(source,'String'));
        OutPar.WinDespS=round(1e-3*OutPar.WinDesp*OutPar.Fs);
        OutPar.Overlap=100*(OutPar.WinLen-OutPar.WinDesp)...
            /OutPar.WinLen;
        OutPar.OverlapS=...
            round(OutPar.Overlap*OutPar.WinLenS/100);
        set(HOverlapS,'String',OutPar.OverlapS);
        set(HOverlap,'String',OutPar.Overlap);
        
        set(HWindespS,'String',OutPar.WinDespS);
    end
    function salida=WinDespS(source,eventdata)
        OutPar.WinDespS=str2num(get(source,'String'));
        OutPar.WinDesp=1000*OutPar.WinDespS/OutPar.Fs;
        OutPar.Overlap=OutPar.WinLen-OutPar.WinDesp;
        OutPar.OverlapS=...
            round(OutPar.Overlap*OutPar.WinLenS/100);
        set(HOverlapS,'String',OutPar.OverlapS);
        set(HOverlap,'String',OutPar.Overlap);
        
        set(HWindesp,'String',OutPar.WinDesp);
        
        
        
    end


    function salida=FFTSize(source,eventdata)
        OutPar.NFFT=str2num(get(source,'String'));
        if (OutPar.NFFT < OutPar.WinLenS)
            OutPar.NFFT=2^(ceil(log2(OutPar.WinLenS)));
            set(HNFFT,'String',OutPar.NFFT);
        end
        OutPar.Precision=OutPar.Fs/(OutPar.NFFT*OutPar.Interp);
        set(HPrec,'String',OutPar.Precision);
    end
  function salida=OverSamp(source,eventdata)
        OutPar.OverSamp=str2num(get(source,'String'));
                    

            OutPar.NFFT=OutPar.OverSamp*2^(ceil(log2(OutPar.WinLenS)));
             if (OutPar.NFFT < OutPar.WinLenS)
                 OutPar.NFFT=2^(ceil(log2(OutPar.WinLenS)));
                  OutPar.OverSamp=1;
             end
             OutPar.Precision=OutPar.Fs/(OutPar.NFFT*OutPar.Interp);
            set(HOverS,'String',OutPar.OverSamp);
            set(HNFFT,'String',OutPar.NFFT);
            set(HPrec,'String',OutPar.Precision);
    end
function salida=TestType(source,eventdata)
        
         OutPar.MethodIndex=get(source,'Value');
         %salida=Config(OutPar,TestList,2);
          %salida=Config(OutPar,PrepList,1);
          % set(source,'Value',OutPar.TypeIndex);
         %OutPar.MethodConfig=salida;
end
function salida=Interpolation(source,eventdata)
        OutPar.Interp=str2num(get(source,'String'));
        OutPar.Precision=OutPar.Fs/(OutPar.NFFT*OutPar.Interp);
        set(HInterp,'String',OutPar.Interp);
        set(HPrec,'String',OutPar.Precision);

end
function salida=Exit(source,eventdata)
    close(f);
end
function salida=Abort(source,eventdata)
    OutPar=InPar;
    close(f);
end
end


