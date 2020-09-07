function [Starts Ends]=SegmentWavFile(selected_wav_data,fs)
data=selected_wav_data(:,1);
umbral=10 ;
% segmentLen=length(data)/17;
% samples=0:segmentLen:length(data);
% samples(end+1)=length(data);
% time=samples/fs;

winlen=300 %miliseconds
winlenS=fs*winlen*1e-3;
overlap=0.8;
overlapS=round(winlenS*overlap);
windesp=winlenS-overlapS;
numwin=floor((length(data)-winlenS)/windesp);
ini=1;
energias=[];
for w=1:numwin
    actual=data(ini:ini+winlenS);
    %energias=[energias 10*log10(mean(actual.^2))];
    energias=[energias mean(actual.^2)];
    
    ini=ini+windesp;
end
% f=figure;
% subplot(211)
% plot(energias);
% subplot(212)
% aux=energias;
% aux(aux > umbral*min(aux))=1;
% aux(aux<1)=0;
% der1=energias(2:end)-energias(1:end-1);
% der2=der1(2:end)-der1(1:end-1);
% 
% %der1(der1<0)=0;
% der1(der1<0.1*max(der1))=0;
% %plot(energias(2:end)-energias(1:end-1));
% plot(aux(2:end)-aux(1:end-1));
aux=energias;
aux(aux > umbral*min(aux))=1;
aux(aux<1)=0;
der=aux(2:end)-aux(1:end-1);
state=0;
St=[];
En=[];
for i=1:length(der)
    if ((state==0)&& (der(i) >0))
        state=1;
        St=[St i];
    elseif ((state==1) && (der(i) <0 ))
        state=0;
        En=[En i]
    end
end
if (length(En) > length(St))
    En=En(1:length(St));
end
if (length(St) > length(En))
    St=St(1:length(En));
end

dur=En-St;
borrables=find(dur<0.5*fs/windesp);
St(borrables)=-1;
En(borrables)=-1;
St=St(St>0);
En=En(En>0);
% subplot(211)
% hold on;
% plot(St,zeros(1,length(St)),'<r');
% plot(En,zeros(1,length(En)),'>g');
% hold off;
%         
% pause
% close(f)
% segmentLen=length(data)/17;
% samples=0:segmentLen:length(data);
% samples(end+1)=length(data);
% time=samples/fs;
Starts=(St+1)*windesp;
Ends=En*windesp;
Ends(1:end-1)=(St(2:end)-1)*windesp;
end