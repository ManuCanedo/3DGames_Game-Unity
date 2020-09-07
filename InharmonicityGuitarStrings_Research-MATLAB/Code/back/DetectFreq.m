function [LHarm HarmFreq HarmAmp Freq precision]=DetectFreq(datain,fs,InFreq,NHarm)
SessionPathBase=[Master.WavPath Cycle.WavPath];
SessionDataBase=Master.DataPath; 
SesF=[SessionDataBase,cell2mat(Cycle.Sessions(session))];
aux=load(SesF);
Session=aux.SessionData;

midebug=0;
%[fsal] = HPS(datain,fsin,minfreq,maxfreq)
% minfreq=70;
% maxfreq=900;
%data=decimate(datain,16);
%fs=fsin/16;
data=datain;
window=@rectwin; %Ventana de análisis
winlen=200; %miliseconds 100 200 300 500
winlenS=fs*winlen*1e-3;
if (winlenS > length(data))
    winlenS=length(data); 
end
NFFT=16*2^(ceil(log2(winlenS)+1));
precision=fs/NFFT/2;
overlap=0.9; %90%
overlapS=round(winlenS*overlap);
windesp=winlenS-overlapS;
numwin=floor((length(data)-winlenS)/windesp)+1;
%Longitud en ventanas para la estimación de la nota base
LNoteEstimation=fs/windesp;
ini=1;
%frest=[];
%Margenes alrededor del armónico
%Voy a probar un margen fijo. La nota menor es 82.4 Hz, la separación entre
%armónicos 41.2Hz
MarginHz=41.2;
MarginK=MarginHz*NFFT/fs;
Kfreq=InFreq*NFFT/fs;
Kharm=(1:NHarm).*Kfreq;
%Kharminf=floor(Kharm-(Kfreq/2));
%Kharmsup=ceil(Kharm+(Kfreq/2));
%mink=floor(minfreq*NFFT/fs);
%;
Kharminf=floor(Kharm-MarginK);
Kharmsup=ceil(Kharm+MarginK);
HarmFreq=zeros(numwin,NHarm);
HarmAmp=zeros(numwin,NHarm);
for w=1:numwin-1
    actual=data(ini:ini+winlenS-1);
    %size(actual)
    %size(window(winlenS))
   spec=(fft(actual.*window(winlenS),NFFT));
    aux=[actual.*window(winlenS); zeros(NFFT-winlenS,1)];
    
   %logspec=20*log10(spec(1:end/2));
    for harm=1:NHarm
        Kharminf(harm);
        Kharmsup(harm);
        [amp k]=max(abs(spec(Kharminf(harm):Kharmsup(harm))));
        %[amp k]=max(abs(goertzel(aux,Kharminf(harm):Kharmsup(harm))));
        %%%%%%
        % k-2 -> menos uno por find y menos uno por indices matlab
        HarmFreq(w,harm)=(k+Kharminf(harm)-2)*fs/NFFT;%en Hz
        HarmAmp(w,harm)=amp;
        
        
    end
    ini=ini+windesp;
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
          size(Freq)
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
end