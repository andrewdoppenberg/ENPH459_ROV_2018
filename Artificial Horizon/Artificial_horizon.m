%% Artificial horizon
%  Author  : E. Ogier
%  Version : 1.01
%  Release : 23th mar. 2016
%
%  VERSIONS
%  - v1.0  (20 mar. 2016) : initial version
%  - v1.01 (23 mar. 2016) : modification of heading gauge to indicate horizon line direction
%                           (brackets on the modulo 10° pitch lines) 
%
%  OBJECT METHODS :
%  - AH = Artificial_horizon(PROPERTY1,VALUE1,PROPERTY2,VALUE2,...) 
%  - AH.set(PROPERTY1,VALUE1,PROPERTY2,VALUE2,...)
%  - AH.get(PROPERTY)
%  - AH.update(HEADING,PITCH,ROLL) (aeronautical convention [rad])
%  - AH.delete()
%
%  OBJECT PROPERTIES <default>
%  - AXES         : parent axes of artificial horizon  : <gca>
%  - POSITION     : position of parent axes in figure  : <[0 0 1 1]>
%  - RETICLETYPE  : reticle type                       : <'w'> | '-o-' | '-.-' 
%  - RETICLECOLOR : reticle elements color (ColorSpec) : <'y'>
%  - RETICLEWIDTH : reticle elements width             : <2>
%  - SKYCOLOR     : horizon sky color (ColorSpec)      : <[220 230 242]/255>
%  - GROUNDCOLOR  : horizon ground color (ColorSpec)   : <[216 228 190]/255>
%  - COLORTYPE    : horizon color type                 : <'Gradient'> | 'Uniform'
%  - EDGECOLOR    : horizon elements edge color        : <'w'> 
%  - LINEWIDTH    : horizon elements width             : <1>
%  - FONTSIZE     : horizon fonts size                 : <8>
%  - FONTWEIGHT   : horizon fonts weight               : 'Light' | <'Demi'> | 'Bold'
%
%% EXAMPLE 1 
% 
%  % Figure
%  S = get(0,'ScreenSize');
%  d = 500;
%  P = [(S(3)-d)/2 (S(4)-d)/2 d d];
%  Figure = ...
%      figure('Color',   'w',...
%             'Position', P);
% 
%  % Pause duration
%  dt = 0.5;
% 
%  % Default artificial horizon in current axes
%  AH = Artificial_horizon('Axes',gca); pause(dt);
% 
%  % Reticle type : '-o-'
%  set(AH,'ReticleType','-o-'); pause(dt);
%  
%  % Reticle type : 'w'
%  set(AH,'ReticleType','w'); pause(dt);
% 
%  % Reticle color : green
%  set(AH,'ReticleColor','g'); pause(dt);
% 
%  % Edge color : black
%  set(AH,'EdgeColor','k'); pause(dt);
% 
%  % Font size and weight
%  set(AH,...
%      'LineWidth',    2,...
%      'Fontsize',     10,...
%      'FontWeight',  'Bold'); pause(dt);
% 
%  % Horizon color type : 'Uniform'
%  set(AH,'ColorType','Uniform'); pause(dt);
% 
%  % Horizon color type : 'Gradient'
%  set(AH,...
%      'ColorType',   'Gradient',...   
%      'GroundColor', [252 200 80]/255); pause(dt);
% 
%  % Horizon color type : 'Uniform'
%  set(AH,'ColorType','Uniform'); pause(dt);
% 
%  % Reset
%  delete(AH);
%  AH = Artificial_horizon('Axes',gca);
% 
%  % Full screen figure
%  drawnow;
%  warning('off','all');
%  jFrame = get(Figure,'JavaFrame');
%  jFrame.setMaximized(true);
%  warning('on','all');
% 
%  % Smaller artificial horizon
%  S = get(0,'ScreenSize');
%  d = 300;
%  Position = [1-d/S(3) 0 d/S(3) d/S(4)];
%  set(AH,'Position',Position,'Fontsize',6);
%
%% EXAMPLE 2
% 
%  % Figure
%  S = get(0,'ScreenSize');
%  d = 500;
%  P = [(S(3)-d)/2 (S(4)-d)/2 d d];
%  figure('Color',   'w',...
%         'Position', P);
% 
%  % Pause duration
%  dt = 0.01;
% 
%  % Angle conversion function [0,2*pi[ -> ]-pi,+pi]
%  AngleWrapper = @(a) mod(a,2*pi)-pi*(1-(-1).^floor(a/pi));
% 
%  % Pitch conversion function [0,2*pi[ -> ]-pi/2,+pi/2]
%  PitchWrapper = @(a) (mod(a,pi/2)-pi/4*(1-(-1).^floor(2*a/pi))).*(-1).^floor(1/2+a/pi);
% 
%  % Creation of an artificial horizon  
%  AH = Artificial_horizon('Axes',gca,'ReticleType','-.-','Reticlecolor','y','EdgeColor','w'); 
%  AH.update(0,0,0);
% 
%  % Heading test
%  r0 = -pi/4;
%  R = linspace(0,r0,20);
%  for r = R
%      AH.update(0,0,r);
%      pause(dt);
%  end
%  H = AngleWrapper(linspace(0,2*pi,200));
%  for h = H
%      AH.update(h,0,r0);
%      pause(dt);
%  end
%  R = linspace(r0,0,20);
%  for r = R
%      AH.update(0,0,r);
%      pause(dt);
%  end
% 
%  % Pitch test
%  P = PitchWrapper(linspace(0,2*pi,200));
%  I = lt([1 diff(P)],0); % P: 0 ->  +90 ->  -90 -> 0
%  H = pi*I;              % H: 0 -> +180 -> +180 -> 0
%  R = pi*I;              % R: 0 -> +180 -> +180 -> 0
%  for n = 1:numel(P)
%      AH.update(R(n),P(n),R(n));
%      pause(dt);
%  end
% 
%  % Roll test
%  R = AngleWrapper(linspace(0,2*pi,50));
%  for n = 1:numel(R)
%      AH.update(0,0,R(n));
%      pause(dt);
%  end

classdef Artificial_horizon < hgsetget
   
    % Public properties (display options)
    properties (Access = 'public')
        Axes         = [];
        Position     = [0 0 1 1];
        ReticleType  = '-.-';
        ReticleColor = 'y';
        ReticleWidth = 2;
        SkyColor     = [220 230 242]/255;
        GroundColor  = [216 228 190]/255;
        ColorType    = 'Gradient'
        EdgeColor    = 'w';        
        LineWidth    = 1;
        FontSize     = 8;
        FontWeight   = 'Demi';
    end
    
    % Private properties (graphical objects and constants)
    properties (Access = 'private')
        PitchIndicatorGraduation = 0.3;
        IndicatorGraduation      = 0.05;
        PitchIndicatorHeight     = 0.6;    
        HeadingIndicatorLength   = 0.9;
        RollIndicatorRadius      = 0.8;
        PitchRange               = 40;
        RollRange                = 60;
        RollLimits               = 0;
        HeadingRange             = 60;
        Horizon                  = struct('Sky',  [],'Ground',    []);
        PitchIndicator           = struct('Lines',[],'Labels',    []);
        RollIndicator            = struct('Lines',[],'Labels',    []);                            
        HeadingIndicator         = struct('Lines',[],'Labels',    []);
        Reticle                  = struct('Lines',[],'Rectangles',[]);
        Conversion               = @(h) mod(h,360)-180*(1-(-1).^floor(h/180));
    end
    
    methods
        
        % Constructor
        function Object = Artificial_horizon(varargin)
            
            Properties = varargin(1:2:end);
            Values = varargin(2:2:end);
            
            for n = 1:length(Properties)
                
                [is, Property] = isproperty(Object,Properties{n});  
                
                if is                    
                    Object.(Property) = Values{n};   
                else
                    error('Property "%s" not supported !',Properties{n});
                end 
                
            end
            
            Object = create(Object);
            
        end
        
        % Function 'set'
        function Object = set(Object,varargin)
            
            Properties = varargin(1:2:end);
            Values = varargin(2:2:end);
            
            for n = 1:length(Properties)
                
                [is, Property] = isproperty(Object,Properties{n});    
                
                if is                    
                    Object.(Property) = Values{n};          
                    Object = modify(Object,Property);
                else
                    error('Property "%s" not supported !',Properties{n});
                end
                
            end
            
        end
        
        % Function 'get'
        function Value = get(varargin)
            
            switch nargin
                
                case 1
                    
                    Value = varargin{1};
                    
                otherwise
                    
                    Object = varargin{1};
                    [is, Property] = isproperty(Object,varargin{2});
                    if is                        
                        Value = Object.(Property);
                    else
                        error('Property "%s" not supported !',varargin{2});
                    end
                    
            end
            
        end
        
        % Function 'isproperty'
        function [is, Property] = isproperty(Object,Property)
            
            Properties = fieldnames(Object); 
            [is, b] = ismember(lower(Property),lower(Properties));
            Property = Properties{b};
            
        end
   
        % Artificial horizon update
        function update(Object,Heading,Pitch,Roll) 
            
            % Potential warning
            Warning(Heading,Pitch,Roll);
                        
            % Attitude update            
            update_pitch(Pitch,Roll);                      
            update_roll(Roll);
            update_heading(Heading);
            drawnow();
            
            % Picth update
            function update_pitch(Pitch,Roll)
                
                % Half length (rotation margin included)
                d = 1+sqrt(2);
                
                % Sky and ground faces height
                H = 180/Object.PitchRange;
                
                % Vertices transposed vector
                Vertices1 = [-d  0; +d  0; -d +d+H; d +1+H];
                Vertices2 = [-d  0; +d  0; -d -d-H; d -d-H];
                
                % Transposed rotation matrix
                M = [+cos(-Roll) -sin(-Roll);...
                     +sin(-Roll) +cos(-Roll)];
                
                % Transposed translation vector
                h = -2*Pitch/pi*H;             
                Delta = repmat([0 h*Object.PitchIndicatorHeight],4,1);
                
                % Horizon update
                set(Object.Horizon.Sky,   'Vertices',(Vertices1+Delta)*M);
                set(Object.Horizon.Ground,'Vertices',(Vertices2+Delta)*M);
                
                % Pitch range
                pr = Object.PitchRange;
                
                % First line angle
                pmin = 2.5;
                p0 = Pitch*180/pi;
                p0 = pmin*round(p0/pmin);
                
                % Angles (10, 5, 2.5°)
                P = p0-pr/2:2.5:p0+pr/2;
                
                g0 = Object.PitchIndicatorGraduation;
                dx = 0.1;
                n2 = 0;
                
                for n = 1:numel(P)
                    
                    % Current angle
                    p = P(n);
                    if p < -90,      p2 = -180-p;
                    elseif p <= +90, p2 = p;
                    else             p2 = +180-p;
                    end
                    
                    % Height
                    dh = 2*p/pr;
                    
                    % Axes limitations
                    XLim = get(Object.Axes,'Xlim')+[+1 -1]*0.1;
                    YLim = get(Object.Axes,'Ylim')+[+1 -1]*0.1;
                    YLim = YLim * Object.PitchIndicatorHeight;
                    
                    % Line [10°]
                    if mod(p,10) == 0
                        
                        n2 = n2+1;
                        
                        % Graduating length
                        Graduating = g0;
                        
                        % Label rotation angle
                        r = Roll*180/pi;
                        
                        % Left or right labels of current angle
                        Pl = [-Graduating-dx (dh+h)*Object.PitchIndicatorHeight]*M;                        
                        Pr = [+Graduating+dx (dh+h)*Object.PitchIndicatorHeight]*M;
                        
                        if XLim(1) <= Pl(1) && Pl(1) <= XLim(2) &&...
                           YLim(1) <= Pl(2) && Pl(2) <= YLim(2) &&...
                           XLim(1) <= Pr(1) && Pr(1) <= XLim(2) &&...
                           YLim(1) <= Pr(2) && Pr(2) <= YLim(2)
                       
                            set(Object.PitchIndicator.Labels(n2,1),...
                                'String',            sprintf('%+.0f',p2),...
                                'Position',          Pl,...
                                'Rotation',          r,...
                                'Visible',           'on');
                            
                            set(Object.PitchIndicator.Labels(n2,2),...
                                'String',            sprintf('%+.0f',p2),...
                                'Position',          Pr,...
                                'Rotation',          r,...
                                'Visible',           'on');
                            
                        else
                            set(Object.PitchIndicator.Labels(n2,1),'Visible','off');
                            set(Object.PitchIndicator.Labels(n2,2),'Visible','off');
                        end
                        
                        % Lines coordinates
                        X = [-1; -1; +1; +1]*Graduating;
                        switch sign(p)
                            case +1, dh2 = -g0/10;
                            case 0,  dh2 =  0;
                            case -1, dh2 = +g0/10;
                        end
                        Y = h+dh+[1; 0; 0; 1]*dh2;
                        
                    % Line length (5°)
                    elseif mod(p,5) == 0,
                        
                        % Graduating length
                        Graduating = g0/2;
                        
                        % Lines coordinates
                        X = [-1; -1; +1; +1]*Graduating;
                        Y = [+1; +1; +1; +1]*dh+h;
                                                
                    % Line length (2.5°)
                    else
                        
                        % Graduating length
                        Graduating = g0/4;
                        
                        % Lines coordinates
                        X = [-1; -1; +1; +1]*Graduating;
                        Y = [+1; +1; +1; +1]*dh+h;
                                                                        
                    end                    
                    
                    % Line coordinates                    
                    Pos = [X Y*Object.PitchIndicatorHeight]*M;
                                        
                    % Pitch indicator update
                    set(Object.PitchIndicator.Lines(n), ...
                        'XData', Pos(:,1),...
                        'YData', Pos(:,2));
                    
                end
                
            end
            
            % Roll update
            function update_roll(Roll)
                               
                % Arc radius
                Radius = 0.8;
                
                % Arc interval [°]
                r = Object.RollRange;
                                
                % First line angle
                rmin = 2.5;
                r0 = -180/pi*Roll;
                r1 = rmin*round(r0/rmin);
                
                % Gradution angles             
                n2 = 0;
                R = r1-90-r/2:rmin:r1+r/2-90;
                
                % Graduations and labels deletions
                set(Object.RollIndicator.Labels,'Visible','off');
                set(Object.RollIndicator.Lines, 'Visible','off');
                
                for n = 1:numel(R)
                    
                    r = R(n);                    
                    r2 = pi/180*(r-r0);  
                    
                    % Line [10°]
                    if mod(r,10) == 0
                        
                        Graduating = Object.IndicatorGraduation;
                        rdr = Radius+Graduating+0.06;
                        n2 = n2+1;
                        r3 = r+90;
                        
                        r4 = -Object.Conversion(r3);
                        
                        switch r4
                            case 0
                                String = '0';
                                StringEdgeColor = Object.EdgeColor;
                            case -180                                
                                String = '+180';
                                StringEdgeColor = 'none';
                            otherwise
                                String = sprintf('%+.0f',r4);
                                StringEdgeColor = 'none';
                        end
                        
                        if Object.RollLimits(1) <= r2 && r2 <= Object.RollLimits(2)
                            set(Object.RollIndicator.Labels(n2),...
                                'Position',  [rdr*cos(r2),rdr*sin(r2)],...
                                'String',    String,...                                
                                'Rotation',  r3-r1,...
                                'EdgeColor', StringEdgeColor,...
                                'LineWidth', Object.LineWidth,...
                                'Visible',   'on');                                             
                        end
                        
                    % Line [5°]    
                    elseif mod(r,5) == 0, Graduating = 2*Object.IndicatorGraduation/3;
                        
                    % Line [2.5°]
                    else Graduating = Object.IndicatorGraduation/3;
                        
                    end
                    
                    if Object.RollLimits(1) <= r2 && r2 <= Object.RollLimits(2)
                        r = Radius+Graduating;
                        X =[Radius r]*cos(r2);
                        Y =[Radius r]*sin(r2);
                        set(Object.RollIndicator.Lines(n),...
                            'Xdata',   X,...
                            'Ydata',   Y,...
                            'Visible', 'on');
                    end
                    
                end                           
                                   
            end
            
            % Heading update
            function update_heading(Heading)
                  
                hr = Object.HeadingRange;                
                d = Object.RollIndicatorRadius;                 
                
                n2 = 0;
                dh = 0.2;
                k = Object.HeadingIndicatorLength;
                                
                % First line heading angle
                hmin = 2.5;
                h0 = 180/pi*Heading;
                h1 = hmin*round(h0/hmin);
                
                % Gradution angles
                H = h1-hr/2:2.5:h1+hr/2;
                
                % Graduations and labels deletions
                set(Object.HeadingIndicator.Labels,'Visible','off');
                set(Object.HeadingIndicator.Lines, 'Visible','off');
                                
                for n = 1:numel(H)
                    
                    h = H(n);                    
                    h2 = h-h0;
                                            
                    x = 2*k*h2/hr;
                        
                    % Line [10°]
                    if mod(h,10) == 0
                        
                        Graduating = Object.IndicatorGraduation;
                        n2 = n2+1;
                        
                        h = Object.Conversion(h);
                        
                        StringEdgeColor = 'none';
                        switch h
                            case 0
                                String = 'N'; 
                                StringEdgeColor = Object.EdgeColor;                               
                            case 90
                                String = 'E'; 
                                StringEdgeColor = Object.EdgeColor; 
                            case {-180,180}
                                String = 'S';
                                StringEdgeColor = Object.EdgeColor; 
                            case -90,
                                String = 'W';
                                StringEdgeColor = Object.EdgeColor; 
                            otherwise,
                                String = sprintf('%+.0f',h);                                       
                        end
                        
                        if -Object.HeadingIndicatorLength <= x && x <= +Object.HeadingIndicatorLength
                            set(Object.HeadingIndicator.Labels(n2),...
                                'Position',  [x,d+Graduating+0.02],...
                                'EdgeColor', StringEdgeColor,...
                                'LineWidth', Object.LineWidth,...
                                'String',    String,...
                                'Visible',   'on');
                        end
                       
                    % Line [5°]
                    elseif mod(h,5) == 0, Graduating = 2/3*Object.IndicatorGraduation;                        
                        
                    % Line [2.5°]
                    else Graduating = Object.IndicatorGraduation/3;
                        
                    end
                    
                    % Line coordinates
                    X = 2*k*h2/hr*[1 1];
                    Y = (Object.PitchIndicatorHeight+dh)*[1 1]+[0 Graduating];
                    
                    % Heading indicator update
                    if -Object.HeadingIndicatorLength <= x && x <= +Object.HeadingIndicatorLength
                        Object.HeadingIndicator.Lines(n) = ...
                            line('XData',     X,...
                                 'YData',     Y,...
                                 'Color',     Object.EdgeColor,...
                                 'LineWidth', Object.LineWidth);
                    end
                    
                end
                                
            end
            
            % Potential warning
            function Warning(Heading,Pitch,Roll)
                
                % Angles control (tolerance for interval boundaries)
                if Heading < -pi || +pi < Heading
                    warning('Artificial horizon, heading must belong to ]-pi,+pi].');
                end
                if Pitch < -pi/2 || +pi/2 < Pitch
                    warning('Artificial horizon, pitch must belong to [-pi/2,+pi/2].');
                end
                if Roll < -pi || +pi < Roll
                    warning('Artificial horizon, roll must belong to ]-pi,+pi].');
                end
                
            end
            
        end
       
        % Artificial horizon deletion
        function Object = delete(Object)
        
            delete(Object.Axes);
            Object = [];
            
        end
        
    end
    
end

% Creation of an artificial horizon
function Object = create(Object)

if isempty(Object.Axes)    
    Object.Axes = gca;
    S = get(0,'ScreenSize');
    d = 300;
    P = [(S(3)-d)/2 (S(4)-d)/2 d d];
    set(get(Object.Axes,'Parent'),...
        'Color',    'w',...
        'MenuBar',  'none',...
        'Position', P);
    set(gca,'Position',[0 0 1 1]);
end

set(Object.Axes,...
    'Position', Object.Position,...
    'Xlim',     [-1 +1],...
    'Ylim',     [-1 +1],...
    'Xtick',    [],...
    'Ytick',    [],...
    'Box',      'on',...
    'Visible',  'on');

Creation_horizon(Object.Axes);
Creation_heading_indicator(Object.Axes);
Creation_pitch_indicator(Object.Axes);
Creation_roll_indicator(Object.Axes);
Object.Reticle = Creation_reticle(Object);

    % Creation of an horizon (sky and ground)
    function Creation_horizon(Axes)
        
        % Half length (rotation margin included)
        d = 1+sqrt(2);
        
        % Sky and ground faces height
        H = 180/Object.PitchRange;
        
        % Vertices transposed vector
        Vertices1 = [-d  0; +d  0; -d +d+H; d +1+H];
        Vertices2 = [-d  0; +d  0; -d -d-H; d -d-H];
        
        % Sky and ground faces
        Faces = [1 2 4 3];
        
        % Sky face        
        Object.Horizon.Sky = ...
            patch('Parent',    Axes,...
                  'Vertices',  Vertices1,...
                  'Faces',     Faces,...
                  'Edgecolor', 'none',...
                  'LineWidth', 0.01);
        
        % Ground face
        Object.Horizon.Ground = ...
            patch('Parent',    Axes,...
                  'Vertices',  Vertices2,...
                  'Faces',     Faces,...
                  'Edgecolor', 'none',...
                  'LineWidth', 0.01);
              
        % Sky and ground colors    
        switch lower(Object.ColorType)
            
            case 'uniform'
                set(Object.Horizon.Sky,...
                    'FaceVertexCData', Object.SkyColor,...
                    'FaceColor',       'interp');
                
                set(Object.Horizon.Ground,...
                    'FaceVertexCData', Object.GroundColor,...
                    'FaceColor',       'interp');
                
            case 'gradient'
                                
                ColorSky    = ColorSpec2RGB(Object.SkyColor);
                ColorGround = ColorSpec2RGB(Object.GroundColor);
                
                k = 0.4;
                c = max(Object.SkyColor)/0.9;
                ColorSky = repmat(ColorSky,4,1).*repmat([1;1;k;k],1,3)/c;
                c = max(Object.GroundColor)/0.9;
                ColorGround = repmat(ColorGround,4,1).*repmat([1;1;k;k],1,3)/c;
                
                set(Object.Horizon.Sky,...
                    'FaceVertexCData', ColorSky,...
                    'FaceColor',       'interp');
                    
                set(Object.Horizon.Ground,...
                    'FaceVertexCData', ColorGround,...
                    'FaceColor',       'interp');
                
        end
                
    end

    % Creation of a pitch indicator
    function Creation_pitch_indicator(Axes)
        
        pr = Object.PitchRange;
        
        P = -pr/2:2.5:+pr/2;
        
        g0 = Object.PitchIndicatorGraduation;
        dx = 0.1;
        n2 = 0;
        
        for n = 1:numel(P)
            
            p = P(n);
            dh = 2*p/pr*Object.PitchIndicatorHeight;
            
            % Line length (10°)
            if mod(p,10) == 0
                
                % Line length
                Graduating = g0;
                
                % Label index
                n2 = n2+1;
                
                Object.PitchIndicator.Labels(n2,1) = ...
                    text(-Graduating-dx,dh,     sprintf('%+.0f',p),...
                         'Color',               Object.EdgeColor,...
                         'Parent',              Axes,...
                         'FontSize',            Object.FontSize,...
                         'FontWeight',          Object.FontWeight,...
                         'HorizontalAlignment', 'Center',...
                         'VerticalAlignment',   'Middle');
                
                Object.PitchIndicator.Labels(n2,2) = ...
                    text(+Graduating+dx,dh,     sprintf('%+.0f',p),...
                         'Color',               Object.EdgeColor,...
                         'Parent',              Axes,...
                         'FontSize',            Object.FontSize,...
                         'FontWeight',          Object.FontWeight,...
                         'HorizontalAlignment', 'Center',...
                         'VerticalAlignment',   'Middle');
                     
                X = [-1; -1; +1; +1]*Graduating;
                switch sign(p)
                    case +1, dh2 = -g0/10;
                    case 0,  dh2 =  0;
                    case -1, dh2 = +g0/10;
                end
                Y = [1; 1; 1; 1]*dh + [1; 0; 0; 1]*dh2;
                
            % Line length (5°)
            elseif mod(p,5) == 0,
                
                Graduating = g0/2;                
                X = [-1; -1; +1; +1]*Graduating;
                Y = [+1; +1; +1; +1]*dh;
                
            % Line length (2.5°)
            else
                
                Graduating = g0/4;            
                X = [-1; -1; +1; +1]*Graduating;
                Y = [+1; +1; +1; +1]*dh;
            
            end
            
            % Pitch indicator
            Object.PitchIndicator.Lines(n) = ...
                line('XData',     X,...
                     'YData',     Y,...
                     'Parent',    Axes,...
                     'Color',     Object.EdgeColor,...
                     'LineWidth', Object.LineWidth);
            
        end
        
    end

    % Creation of a roll indicator
    function Creation_roll_indicator(Axes)
        
        % Arc radius
        r0 = Object.RollIndicatorRadius;
        
        % Roll range [°]
        r = Object.RollRange;
        Object.RollLimits = pi/180*[-90-r/2,r/2-90];
        
        % Gradution angles
        R = pi/180*linspace(-90-r/2,r/2-90,50);
        
        % Arc
        Object.RollIndicator.Arc = ...
            line(r0*cos(R),r0*sin(R),...
                 'Parent',    Axes,...
                 'LineWidth', Object.LineWidth,...
                 'Color',     Object.EdgeColor);
        
        % Triangle
        c = 0.05;
        Object.RollIndicator.Triangle = ...
            patch('Vertices',  [-c/2 c-r0; 0 -r0+0.01; +c/2 c-r0],...
              'Faces',     [1 2 3],...
              'EdgeColor', 'none',...
              'FaceColor', Object.EdgeColor);
        
        n2 = 0;
        dr0 = Object.IndicatorGraduation;
        R = -90-r/2:2.5:r/2-90;
        
        for n = 1:numel(R)
            
            r = R(n);
            a2 = pi/180*r;
            
            % Line [10°]
            if mod(r,10) == 0
                
                dr = dr0;
                rdr = r0+dr+0.06;
                n2 = n2+1;
                r3 = -r-90;
                
                if r3 == 0,
                    String = '0';
                    StringEdgeColor = Object.EdgeColor;
                else
                    String = sprintf('%+.0f',r3);
                    StringEdgeColor = 'none';
                end
                
                Object.RollIndicator.Labels(n2) = ...
                    text(rdr*cos(a2),rdr*sin(a2), String,...
                         'Parent',                Axes,...
                         'Color',                 Object.EdgeColor,...
                         'EdgeColor',             StringEdgeColor,...
                         'FontSize',              Object.FontSize,...
                         'FontWeight',            Object.FontWeight,...
                         'Rotation',              -r3,...
                         'HorizontalAlignment',   'Center');
                
            % Line [5°]
            elseif mod(r,5) == 0, dr = 2*dr0/3;
                
            % Line [2.5°]
            else dr = dr0/3;
                
            end
            
            r = r0+dr;
            X =[r0 r]*cos(a2);
            Y =[r0 r]*sin(a2);
            Object.RollIndicator.Lines(n) = ...
                line(X,Y,...
                     'Parent',    Axes,...
                     'LineWidth', Object.LineWidth,...
                     'Color',     Object.EdgeColor);
            
        end
        
    end

    % Creation of a heading indicator
    function Creation_heading_indicator(Axes)
        
        hr = Object.HeadingRange;
        H = -hr/2:2.5:+hr/2;
        
        n2 = 0;
        dh = 0.2;
        k = Object.HeadingIndicatorLength;
        
        % Line
        Object.HeadingIndicator.Axe = ...
            line(k*[-1 +1],(Object.PitchIndicatorHeight+dh)*[1 1],...
                 'Parent',    Axes,...
                 'Color',     Object.EdgeColor,...
                 'LineWidth', Object.LineWidth);
        
        % Triangle
        d = Object.RollIndicatorRadius;
        c = 0.05;
        Object.HeadingIndicator.Triangle = ...
            patch('Vertices',  [-c/2 -c+d; 0 d-0.01; +c/2 -c+d],...
                  'Faces',     [1 2 3],...                  
                  'Parent',    Axes,...
                  'EdgeColor', 'none',...
                  'FaceColor', Object.EdgeColor);
        
        for n = 1:numel(H)
            
            h = H(n);
            
            % Line [10°]
            if mod(h,10) == 0
                
                Graduating = Object.IndicatorGraduation;
                n2 = n2+1;
                
                if h == 0,
                    String = 'N';
                    StringEdgeColor = Object.EdgeColor;
                else
                    String = sprintf('%+.0f',h);
                    StringEdgeColor = 'none';
                end
                
                Object.HeadingIndicator.Labels(n2) = ...
                    text(2*k*h/hr,d+Graduating+0.02, String,...
                         'Parent',              Axes,...
                         'Color',               Object.EdgeColor,...
                         'EdgeColor',           StringEdgeColor,...
                         'FontSize',            Object.FontSize,...
                         'FontWeight',          Object.FontWeight,...
                         'HorizontalAlignment', 'Center',...
                         'VerticalAlignment',   'Bottom');
                
            % Line [5°]
            elseif mod(h,5) == 0, Graduating = 2/3*Object.IndicatorGraduation;
                
            % Line [2.5°]
            else Graduating = Object.IndicatorGraduation/3;
                
            end
            
            % Line coordinates
            X = 2*k*h/hr*[1 1];
            Y = (Object.PitchIndicatorHeight+dh)*[1 1]+[0 Graduating];
            
            % Heading indicator update
            Object.HeadingIndicator.Lines(n) = ...
                line('XData',     X,...
                     'YData',     Y,...
                     'Parent',    Axes,...
                     'Color',     Object.EdgeColor,...
                     'LineWidth', Object.LineWidth);
            
        end
        
    end

end

% Modification of graphical objects
function Object = modify(Object,Property)

switch lower(Property)
    
    case 'position'        
        set(Object.Axes,'Position',Object.Position);
        
    case 'reticletype'
        delete(Object.Reticle.Lines);        
        delete(Object.Reticle.Rectangles);
        Object.Reticle = Creation_reticle(Object);
        
    case 'reticlecolor'
        set(Object.Reticle.Lines,'Color',Object.ReticleColor);        
        if isfield(Object.Reticle,'Rectangles')
            set(Object.Reticle.Rectangles,'EdgeColor',Object.ReticleColor); 
        end
        
    case 'reticlewidth'
        set(Object.Reticle.Lines,'LineWidth',Object.ReticleWidth); 
        if isfield(Object.Reticle,'Rectangles')
            if ~isempty(Object.Reticle.Rectangles)
                set(Object.Reticle.Rectangles,'LineWidth',Object.ReticleWidth);
            end
        end
    case {'skycolor','groundcolor','colortype'}       
        switch lower(Object.ColorType)            
            case 'uniform'                
                set(Object.Horizon.Sky,   'FaceColor', Object.SkyColor);                
                set(Object.Horizon.Ground,'FaceColor', Object.GroundColor);                
            case 'gradient'              
                ColorSky    = ColorSpec2RGB(Object.SkyColor);
                ColorGround = ColorSpec2RGB(Object.GroundColor);                
                k = 0.4;
                c = max(Object.SkyColor)/0.9;
                ColorSky = repmat(ColorSky,4,1).*repmat([1;1;k;k],1,3)/c;
                c = max(Object.GroundColor)/0.9;
                ColorGround = repmat(ColorGround,4,1).*repmat([1;1;k;k],1,3)/c;         
                set(Object.Horizon.Sky,...
                    'FaceVertexCData', ColorSky,...
                    'FaceColor',       'interp');                    
                set(Object.Horizon.Ground,...
                    'FaceVertexCData', ColorGround,...
                    'FaceColor',       'interp');                
        end
        
    case 'edgecolor'        
        set(Object.PitchIndicator.Lines,      'Color',     Object.EdgeColor);        
        set(Object.PitchIndicator.Labels,     'Color',     Object.EdgeColor);        
        set(Object.RollIndicator.Lines,       'Color',     Object.EdgeColor);         
        set(Object.RollIndicator.Labels,      'Color',     Object.EdgeColor); 
        I = ~strcmp(get(Object.RollIndicator.Labels,'EdgeColor'),'none');
        set(Object.RollIndicator.Labels(I),'EdgeColor',    Object.EdgeColor);        
        
        set(Object.RollIndicator.Arc,         'Color',     Object.EdgeColor);
        set(Object.RollIndicator.Triangle,    'FaceColor', Object.EdgeColor);        
        set(Object.HeadingIndicator.Lines,    'Color',     Object.EdgeColor);                
        set(Object.HeadingIndicator.Labels,   'Color',     Object.EdgeColor);
        I = ~strcmp(get(Object.HeadingIndicator.Labels,'EdgeColor'),'none');
        set(Object.HeadingIndicator.Labels(I),'EdgeColor', Object.EdgeColor); 
        
        set(Object.HeadingIndicator.Axe,      'Color',     Object.EdgeColor);
        set(Object.HeadingIndicator.Triangle, 'FaceColor', Object.EdgeColor);
    
    case 'linewidth'          
        set(Object.PitchIndicator.Lines,   'LineWidth', Object.LineWidth); 
        set(Object.RollIndicator.Lines,    'LineWidth', Object.LineWidth); 
        set(Object.RollIndicator.Labels,   'LineWidth', Object.LineWidth);        
        set(Object.RollIndicator.Arc,      'LineWidth', Object.LineWidth);      
        set(Object.HeadingIndicator.Lines, 'LineWidth', Object.LineWidth); 
        set(Object.HeadingIndicator.Labels,'LineWidth', Object.LineWidth); 
        set(Object.HeadingIndicator.Axe,   'LineWidth', Object.LineWidth);
               
    case 'fontsize'      
        set(Object.PitchIndicator.Labels,   'FontSize', Object.FontSize);
        set(Object.RollIndicator.Labels,    'FontSize', Object.FontSize);
        set(Object.HeadingIndicator.Labels, 'FontSize', Object.FontSize);
      
    case 'fontweight'      
        set(Object.PitchIndicator.Labels,   'FontWeight', Object.FontWeight);
        set(Object.RollIndicator.Labels,    'FontWeight', Object.FontWeight);
        set(Object.HeadingIndicator.Labels, 'FontWeight', Object.FontWeight);
        
end

end

% Creation of a reticle
function Reticle = Creation_reticle(Object)

switch lower(Object.ReticleType)
    
    case 'w'
        
        X = [-4 -2 -1 0 +1 +2 +4]/15/2;
        Y = [ 0  0 -1 0 -1  0  0]/15/2;
        
        Reticle.Lines = ...
            line(X,Y,...
                 'Parent',    Object.Axes,...
                 'Color',     Object.ReticleColor,...
                 'LineWidth', Object.ReticleWidth);
        
    case '-.-'
        
        X = [-10 -3 -3  ]/20;
        Y = [ 0  0 -0.1]/2;
        r = 1e-2;
        
        Reticle.Lines(1) = ...
            line(X,Y,...
                 'Parent',    Object.Axes,...
                 'Color',     Object.ReticleColor,...
                 'LineWidth', Object.ReticleWidth);
        
        Reticle.Rectangles = ...
            rectangle('Position',  [-r -r +2*r +2*r],...
                      'Curvature', [0 0],...
                      'Parent',    Object.Axes,...
                      'EdgeColor', Object.ReticleColor,...
                      'LineWidth', Object.ReticleWidth,...
                      'FaceColor', 'none');
        
        Reticle.Lines(2) = ...
            line(-X,Y,...
                 'Parent',    Object.Axes,...
                 'Color',     Object.ReticleColor,...
                 'LineWidth', Object.ReticleWidth);
        
    case '-o-'
        
        r = 2.5e-2;
        X = [ -0.1 -r];
        Y = [  0    0];
        
        Reticle.Rectangles = ...
            rectangle('Position',  [-r -r +2*r +2*r],...
                      'Curvature', [1,1],...
                      'Parent',    Object.Axes,...
                      'EdgeColor', Object.ReticleColor,...
                      'LineWidth', Object.ReticleWidth,...
                      'FaceColor', 'none');
        
        Reticle.Lines(1) = ...
            line(X,Y,...
                 'Parent',    Object.Axes,...
                 'Color',     Object.ReticleColor,...
                 'LineWidth', Object.ReticleWidth);
        
        Reticle.Lines(2) = ...
            line(-X,Y,...
                 'Parent',    Object.Axes,...
                 'Color',     Object.ReticleColor,...
                 'LineWidth', Object.ReticleWidth);
        
        Reticle.Lines(3) = ...
            line(Y,-X*3/4,...
                 'Parent',    Object.Axes,...
                 'Color',     Object.ReticleColor,...
                 'LineWidth', Object.ReticleWidth);
        
end

end

% Conversion in RGB from a color specification string
function RGB = ColorSpec2RGB(ColorSpec)

if ischar(ColorSpec)
    switch ColorSpec
        case {'y','yellow'},  RGB = [1 1 0];
        case {'m','magenta'}, RGB = [1 0 1];
        case {'c','cyan'},    RGB = [0 1 1];
        case {'r','red'},     RGB = [1 0 0];
        case {'g','green'},   RGB = [0 1 0];
        case {'b','blue'},    RGB = [0 0 1];
        case {'w','white'},   RGB = [1 1 1];
        case {'k','black'},   RGB = [0 0 0];
    end
    RGB = 255*RGB;
else
    RGB = ColorSpec;
end

end
