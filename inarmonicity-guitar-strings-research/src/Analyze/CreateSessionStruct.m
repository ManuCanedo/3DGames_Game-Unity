function [SessionOut]=CreateSessionStruct(SessionIn)
SessionOut.Name=SessionIn.Name;
    SessionOut.date=SessionIn.date;
    SessionOut.Edited=SessionIn.Edited;
    SessionOut.EditDate=SessionIn.EditDate;
    SessionOut.Completed=SessionIn.Completed;
SessionOut.Wavs=SessionIn.Wavs;
SessionOut.SelectedWavs=SessionIn.SelectedWavs;
SessionOut.WavContent=SessionIn.WavContent;
%SessionOut.Strings=[];
SessionOut.SessionPath=SessionIn.SessionPath;
SessionOut.NumWavs=SessionIn.NumWavs;
SessionOut.CurrentSessionSaved=SessionIn.CurrentSessionSaved;
SessionOut.WavAnalisys=SessionIn.WavAnalisys;
     
    for string=1:6
        String=[];
        StringIn=SessionIn.Strings(string);
        String.StringID=StringIn.StringID;
        String.OpenFreq=[];
        String.OutOfTuneHz=[];
        String.OutOfTunePer=[];
        for fret=1:13
           % display([num2str(string),' ',num2str(fret)])
             FretIn=StringIn.Fret(fret);
            if (isfield(FretIn,'WavName'))
                Fret.WavName=FretIn.WavName;
            else
                Fret.WavName=[];
            end
           
            Fret.NoteName=FretIn.NoteName;
            Fret.NoteRefFreq=FretIn.NoteRefFreq;
             if (isfield(FretIn,'WavName'))
            Fret.Start=FretIn.Start;
            Fret.End=FretIn.End;
            
             else
            Fret.Start=[];
            Fret.End=[];
           
             end
            Fret.FreqFromOpenStNote=[];
             if (isfield(FretIn,'WavName'))
            Fret.Freq=FretIn.Freq;
             else
            Fret.Freq=[];
             end
            Fret.HarmFreq=[];
            Fret.HarmAmp=[];
            Fret.LHarm=[];
            Fret.Prec=[];
            Fret.RelOutOfTuneHz=[];
            Fret.RelOutOfTunePer=[];
            Fret.SupLim=[];
            Fret.InfLim=[];
            String.Fret(fret)=Fret;
        end
        SessionOut.Strings(string)=String;
    end
end