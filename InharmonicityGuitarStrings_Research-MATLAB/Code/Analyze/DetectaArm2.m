function [salida]=DetectaArm2(datain,NHarm,SpAnPar,Freq)

Num=load('filter.mat');
Num=Num.Num;
midebug=0;
%[fsal] = HPS(datain,fsin,minfreq,maxfreq)
% minfreq=70;
% maxfreq=900;
%data=decimate(datain,16);
%fs=fsin/16;
fs=SpAnPar.Fs;
%data=datain;
window=SpAnPar.Window;
winlen=SpAnPar.WinLen;
winlenS=SpAnPar.WinLenS;
NFFT=SpAnPar.NFFT;
overlapS=SpAnPar.OverlapS;
windesp=SpAnPar.WinDesp;
% window=@rectwin; %Ventana de análisis
% winlen=200; %miliseconds 100 200 300 500
% winlenS=fs*winlen*1e-3;
% if (winlenS > length(data))
%     winlenS=length(data);
% end
% NFFT=16*2^(ceil(log2(winlenS)+1));
precision=fs/NFFT/2/SpAnPar.Interp;

% overlap=0.9; %90%
% overlapS=round(winlenS*overlap);
% windesp=winlenS-overlapS;

%Longitud en ventanas para la estimación de la nota base
LNoteEstimation=fs/windesp;
MarginHz=SpAnPar.FreqMarg;
MarginK=MarginHz*NFFT/fs;
numwin=floor((length(datain)-winlenS)/windesp)+1;
HarmFreq=zeros(numwin,NHarm);
HarmAmp=zeros(numwin,NHarm);
for harm=1:NHarm
 ini=1;   
Coeff=Num.*cos(2*pi*(0:length(Num)-1)*Freq(harm)/fs)
data=filter(Coeff,1,datain);

%Kharminf=floor(Kharm-(Kfreq/2)
Kfreq=Freq(harm)*NFFT/fs;

Kharminf=floor(Kfreq-MarginK);
Kharmsup=ceil(Kfreq+MarginK);
if (max(Kharmsup) > NFFT/2)
    errordlg('Aqui');
end

Freq(1)
for w=1:numwin-1
    actual=data(ini:ini+winlenS-1);
    %size(actual)
    %size(window(winlenS))
   spec=(fft(actual.*window,NFFT));
   %figure;plot(abs(spec));pause;
    %aux=[actual.*window; zeros(NFFT-winlenS,1)];
    
   %logspec=20*log10(spec(1:end/2));
    %for harm=1:NHarm
        %Kharminf(harm)
        %Kharmsup(harm)
        spec1=abs(spec(Kharminf:Kharmsup));
        [amp k]=max(spec1);
        DetF=(k+Kharminf-2)*fs/NFFT;
        if SpAnPar.Interp > 1
            margin=3;
            preci=1/SpAnPar.Interp;
            k1=k+Kharminf-1;
           
         spec1=abs(spec(k1-margin:k1+margin));
         aux=interp1(1:length(spec1),spec1,1:preci:length(spec1),'spline');
         [val k2]=max(aux);
         amp=val;
        DetF=(k1-margin+(k2-1)*preci-1)*fs/NFFT;
        %DetF
        end
        
        
        %[amp k]=max(abs(goertzel(aux,Kharminf(harm):Kharmsup(harm))));
        %%%%%%
        % k-2 -> menos uno por find y menos uno por indices matlab
        HarmFreq(w,harm)=DetF;%en Hz
        HarmAmp(w,harm)=amp*SpAnPar.NormF;
        
        ini=ini+windesp; 
    end
   
end

HarmAmp=HarmAmp./winlenS;
%%%%%%%%%%%Extracción de margenes de analisis
[vmaxH wmaxH]=max(HarmAmp);%Tenemos los índices y valores de los máximos
 umbral=0.9*vmaxH;
 umbral2=0.1*vmaxH;
 sal=[];
 Freq=[];
 inf=[];sup=[];
 for i=1:NHarm
     aux=find(HarmAmp(:,i) > umbral(i));
       aux2=find(HarmAmp(aux(1):end,i) < umbral2(i));
       aux3=find(HarmAmp(aux(1):end,i) < umbral(i));
     inf(i)=aux(1)+aux3(1)-1;
     sup(i)=aux(1)+aux2(1)-1;
     sal(i)=aux(1);
     sal2(i)=HarmAmp(aux(1),i);
     %Freq(i)=mean(HarmFreq(sal(i):sal(i)+LNoteEstimation,i));
          %Freq(i)=mean(HarmFreq(sal(i):sal(i)+LNoteEstimation,i));
         % size(HarmFreq)
          %i
          %inf(i)
          %sup(i)
  Freq(i)=mean(HarmFreq(inf(i):sup(i),i));
 end
 
 %Freq=mean(HarmFreq(100:150,1));
 LHarm=((0:numwin-1)*windesp+(winlen/2))/fs;

 if (midebug)
figure(1)
[y f t p]=spectrogram(decimate(data,16),winlenS/16,...
            overlapS/16,...
            2^(ceil(log2(winlenS/16))+1),...
            fs/16 ,'yaxis');
        imagesc(t,f,10*log10(abs(p)))
        axis xy; axis tight; colormap(jet); view(0,90);zoom on;
        hold on;
                
        plot(LHarm,HarmFreq,'g.')
         for i=1:NHarm
               L=inf(i):sup(i);
              plot(LHarm(L),HarmFreq(L,i),'c.');
         end
          ejes=axis;
          %size(Freq)
          TFreq=Freq(1)*(1:NHarm);
          size([Freq' Freq']')
          size(repmat([ejes(1) ejes(2)],NHarm,1)')
        plot(repmat([ejes(1) ejes(2)],NHarm,1)',[Freq' Freq']','k')
        plot(repmat([ejes(1) ejes(2)],NHarm,1)',[TFreq' TFreq']','b')

         hold off;
        %LHarm=(0:numwin-1)*windesp/fs;
       
        figure(2)
        plot(HarmAmp);legend('1','2','3','4','5');hold on;
        plot(sal,sal2,'*r');
        hold off;
        pause
 end
 salida.LHarm=LHarm;
 salida.HarmFreq=HarmFreq 
 salida.HarmAmp=HarmAmp 
 salida.Freq=Freq 
 salida.precision=precision
 salida.SupLim=sup;
 salida.InfLim=inf;
end
