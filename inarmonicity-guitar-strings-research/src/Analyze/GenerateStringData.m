function Strings=GenerateStringData()
[GNoteFreq GNoteName]=GeneraNotasGuitarra();
baseNote=[1,6,11,16,20,25];
name={'E','A','D','G','B','e'};
    for i=1:6
     iNote=baseNote(i);
     Strings(i).Name=name(i);

    for fret=1:16
    Strings(i).fret(fret).Freq=GNoteFreq(iNote);
    Strings(i).fret(fret).NoteName={GNoteName(iNote,:)};
    iNote=iNote+1;
    end
end
end
        

