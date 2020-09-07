files=dir('*.mat');
L=CalculateFretPos(65);
aux=zeros(length(files),6,13);
% mileg=[];
% for i=1:length(files)
%    mileg=[mileg;files(i).name];
% end

for string=1:6
figure;subplot 211;hold on;subplot 212;hold on;

for i=1:length(files)
    name=files(i).name
    load(name);
    subplot 211
    plot(Salida(string,:),'-*');
    title(['String: ',num2str(string)]);
    legend(num2str([1:7]'));
    subplot 212
    plot((Salida(string,:).*L.^2)','-*');
end
%pause;
end