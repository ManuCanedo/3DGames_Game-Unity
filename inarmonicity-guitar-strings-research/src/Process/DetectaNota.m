function frecuencia=DetectaNota(fs,data,string)
%[GNoteFreq GNoteName]=GeneraNotasGuitarra();
%frecuencia=rand(1,1)*(880-82)+82;
switch cell2mat(string)
    case 'E'
        minfreq=70;
        maxfreq=220;
    case 'A'
         minfreq=100;
        maxfreq=300;
    case 'D'
         minfreq=130;
        maxfreq=370;
    case 'G'
         minfreq=180;
        maxfreq=500;
    case 'B'
         minfreq=230;
        maxfreq=600;
    case 'e'
         minfreq=300;
        maxfreq=830;
    otherwise
       minfreq=70;
       maxfreq=900;
end
frecuencia=HPS(data,fs,minfreq,maxfreq);
% f=figure;
% FileData.FsOr =fs;
%         Fs=fs;
%         Samples=decimate(data,config.decimate);
%         FileData.Fs=FileData.FsOr/config.decimate;
%         config.WinLs=config.WinL*Fs*1e-3;
%         config.Overlaps=floor(config.WinLs*config.Overlap/100);
%         [y f t p]=spectrogram(Samples,config.Window(config.WinLs),...
%             config.Overlaps,...
%             2^(ceil(log2(config.WinLs))+1),...
%             FileData.Fs ,'yaxis');
%         h=imagesc(t,f,10*log10(abs(p)))
%         axis xy; axis tight; colormap(jet); view(0,90);zoom on;
% 
%         pause
%         close(f);
end