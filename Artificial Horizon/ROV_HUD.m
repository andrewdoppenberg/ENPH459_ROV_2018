%% Create Artifical Horizon from IMU data

S = get(0,'ScreenSize');
d = 600;
P = [(S(3)-d)/2 (S(4)-d)/2 d d];
figure('Color',    'w',...
       'MenuBar',  'none',...
       'Position',  P);
set(gca,'Position',[0 0 1 1]);  

% Creation of an artificial horizon
AH = Artificial_horizon('Axes',gca,'ReticleType','-.-','Reticlecolor','y','EdgeColor','w'); 
set(AH,'EdgeColor','k');

AH.update(0,0,0);

%keep trying serial ports until we find the one we're connected to
if ~exist('MCU','var') || all(MCU.status() == 'closed')
    try
       MCU=serial('COM6','BaudRate',2000000);
       fopen(MCU);
    catch
        try
            MCU=serial('COM5','BaudRate',2000000);
            fopen(MCU); 
        catch
            try
                MCU=serial('COM4','BaudRate',2000000);
                fopen(MCU);
            catch
                try
                    MCU=serial('COM3','BaudRate',2000000);
                    fopen(MCU);
                catch
                    try
                         MCU=serial('COM2','BaudRate',2000000);
                         fopen(MCU); 
                    catch
                        try
                            MCU=serial('COM1','BaudRate',2000000);
                            fopen(MCU); 
                        catch
                            errordlg('Unable to find serial port, please reconnect and try again')
                        end
                    end
                end
            end
        end                
    end
end



flushinput(MCU); %clear the input buffer
while 1 
    A = fscanf(MCU, ['%d' '%d' '%d']);
    A = A.*pi/180;
    if length(A) == 3
        AH.update(A(3),A(1),A(2));
    end
    flushinput(MCU);
end