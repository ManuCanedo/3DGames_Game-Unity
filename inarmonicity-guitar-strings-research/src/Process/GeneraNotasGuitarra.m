function [GNoteFreq GNoteName]=GeneraNotasGuitarra()
Names=['E ';'F ';'F#';'G ';'G#';'A ';'A#';'B ';'C ';'C#';'D ';'D#';];
Octave=2;
GNoteFreq=notenum2freq(28:28+12*3+5);
GNoteName=[];
for i=1:length(GNoteFreq)
    Nameindex=mod(i-1,12)+1;
    Name=Names(Nameindex,:);
    %display([Name,num2str(Octave),' ',num2str(GNoteFreq(i))]);
    GNoteName=[GNoteName;Name,num2str(Octave)];
    if (mod(i,12)==8)
        Octave=Octave+1;
    end
end
end