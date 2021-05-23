function [fsal] = HPS(datain,fsin,minfreq,maxfreq)
% minfreq=70;
% maxfreq=900;
data=decimate(datain,16);
fs=fsin/16;
winlen=2500 %miliseconds
winlenS=fs*winlen*1e-3;
if (winlenS > length(data))
    winlenS=length(data);
end
NFFT=2^(ceil(log2(winlenS)+1));
overlap=0.9;
overlapS=round(winlenS*overlap);
windesp=winlenS-overlapS;
numwin=floor((length(data)-winlenS)/windesp)+1;
ini=1;
frest=[];
maxk=ceil(maxfreq*NFFT/fs);
mink=floor(minfreq*NFFT/fs);
iOrder=10;
for w=1:numwin
    actual=data(ini:ini+winlenS-1);
    spec=abs(fft(actual.*hamming(winlenS)',NFFT));
    
   logspec=20*log10(spec(1:end/2));
    afHps   =logspec;
    for (j = 2:iOrder)
        
        %subplot(311)
        %plot(afHps)
        %subplot(312)
        %plot(logspec(1:j:end,:));
       %zeros(size(logspec,1)-size(logspec(1:j:end,:),1), size(logspec,2))])

        auxspec=logspec(1:j:end,:);
        afHps   = afHps(1:length(auxspec))+auxspec;
        %+ ...
       %[logspec(1:j:end,:);...
       %zeros(size(logspec,1)-size(logspec(1:j:end,:),1), size(logspec,2))];
    
    %subplot(313)
     %   plot(afHps)
      %  pause
    end
    [fDummy,f]  = max(afHps(mink:maxk)',[],1);
    %f + minfs -1
    fres           = (f + mink - 1) / NFFT * fs;
    ini=ini+windesp;
    frest=[frest fres];
end
% ff=figure()
% plot(frest,'*-');
% pause;
% close(ff);
fsal=mode(frest);
    %ff=figure();
    %plot(afHps(minfs:end,:))
    %hold on;
    %plot(f-1,fDummy,'*');
     %pause
    %close(ff);
    %Revisión (de artículo)
    % Si el segundo armónico bajo el pitch inicial es cerca de 1/2 el
    % actual
    % Y el ratio de amplitues es superior a un umbral (0.2 para 5
    % armonicos)
    %fDummy
    %afHps(round(f/2))
    %second_harm=10^(afHps(round(f/2))/20)
    %actual=10^(fDummy/20)
    
    
end