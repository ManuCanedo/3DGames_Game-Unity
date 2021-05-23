function [BridgeToFret]=CalculateFretPos(ScaleLength)

NutToFret(1)=0;
BridgeToFret(1)=ScaleLength
%NutToFret(1)=ScaleLength / 17.817;

for i=2:13
    %BridgeToFret(i-1)=ScaleLength-NutToFret(i-1);
    NutToFret(i)=(BridgeToFret(i-1)/17.817)+NutToFret(i-1);
    BridgeToFret(i)=ScaleLength-NutToFret(i);
end
%BridgeToFret(i)==ScaleLength-NutToFret(i);

