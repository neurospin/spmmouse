function spmmouse(varargin)
%SPMMouse - toolbox for SPM for animal brains
%Stephen Sawiak - http://www.wbic.cam.ac.uk/~sjs80/spmmouse.html


global defaults
global spmmouseset

    if isempty(defaults)
        spm('PET');
        return;
    end
    
    if isempty(spmmouseset)
        spm_defaults;
        initspmmouseset;
    end;

    % what should we do
    if nargin == 0 
        showinfo;
        return;
    end

    str = varargin(1);

    if strcmp(str, 'setup')
        % show buttons to configure spmmouse
        setup;
        return;
    end

    if strcmp(str,'load')
        if(nargin < 2)
            warning('No preset file specified for SPMMouse!');
            return;
        end
        loadpres(varargin(2));
        return;
    end
    if strcmp(str, 'loadpreset')
        loadpreset;
        return;
    end
    
    if strcmp(str, 'unload')
        unload;
        return;
    end
    
    if strcmp(str, 'createpreset')
        createpreset;
        return;
    end
    
    if strcmp(str, 'loadimage')
        loadimage;
        return;
    end
    
    if strcmp(str,'autochk')
        autochk;
        return;
    end

    if strcmp(str,'slideru')
        slideru;
        return;
    end
    
    if strcmp(str,'sliderl')
        sliderl;
        return;
    end
    
    if strcmp(str,'slidert')
        slidert;
        return;
    end
    
    if strcmp(str,'createmip')
        createmip;
        return;
    end
    
    if strcmp(str,'priors')
        priors;
        return;
    end
    
    if strcmp(str,'savepreset')
        savepreset;
        return;
    end
    
    if strcmp(str,'applypreset')
        applypreset;
        return;
    end


%------------------------------
function setup
    try
        gfig = findobj('Tag','Graphics');
        figure(gfig);
    catch
        fprintf(1,'Could not find SPM graphics window! Is SPM loaded ? ');
        return;
    end

    
function initspmmouseset
global spmmouseset
        mypath = which('spmmouse');
        spmmouseset.oldpath = path;
        spmmouseset.path = fileparts(mypath);
        spmmouseset.title = 'SPMMouse v1.0';
        spmmouseset.margin = 15;
        spmmouseset.size = [400 364];

%------------------------------
function showinfo
global spmmouseset;
    try
        gfig = findobj('Tag','Graphics');
        figure(gfig);
    catch
        fprintf(1,'Could not find SPM graphics window ! Is SPM loaded ?\n');
        return;
    end
    
    % clear everything visible from graphics window
	delete(findobj(get(gfig,'Children'),'flat','HandleVisibility','on'));
    % clear callbacks
	set(gfig,'KeyPressFcn','','WindowButtonDownFcn','','WindowButtonMotionFcn','','WindowButtonUpFcn','');
    winscale = spm('WinScale');
    tTitle = uicontrol(gfig,'Style','Text','Position',[20 800 560 40].*winscale,'String',spmmouseset.title,'FontSize',24,'BackgroundColor','w');
    tInfo = uicontrol(gfig,'Style','Edit','Position',[20 180 560 560].*winscale,...
             'FontSize',14,'FontWeight','normal','BackgroundColor',[1 1 0.5],'Min',0,'Max',2,'Enable','on','Value',0,'Enable','inactive');

     newl = sprintf('\n');   
     set(tInfo,'String', ...
         {'SPMMouse is a series of modifications to SPM making it easy to use non-human brains. It includes templates for the mouse brain but is generally applicable, and an interface is provided to make a ''glass brain'' from any brain-extracted image.',newl,...
         'Modifications to default settings allow realign, coregister, normalise, segment, etc to work with non-human images. A new option appears in Display allowing an overlay to be displayed on the image, easing initial manual registration.',newl,...
         'Use of VBM in the mouse brain is described in',...
         'S.J. Sawiak et al. "Voxel-based Morphometry Reveals Changes Not Seen with Manual 2D Volumetry in the R6/2 Huntingdon''s disease mouse brain. Neurobiol. Dis. (2009) 33(1) p20-27',newl,...
         'Please cite this paper if you use this toolbox. Sample data, updates and tutorials are available from',...
         '      http://www.wbic.cam.ac.uk/~sjs80/spmmouse.html','',...
         'Bug reports and suggestions should be sent to','','Stephen Sawiak','sjs80@cam.ac.uk'});
     set(tInfo,'Listboxtop',1)
     
     
      uicontrol('Position',[20 760 148 30].*winscale,'String','Load Animal Preset',...
          'Callback','spmmouse(''loadpreset'');');
      uicontrol('Position',[180 760 148 30].*winscale,'String','Create Animal Preset',...
          'Callback','spmmouse(''createpreset'');');
      uicontrol('Position',[340 760 148 30].*winscale,'String','Unload SPMMouse',...
          'Callback','spmmouse(''unload'');');
      
      try 
          im=imread('mouse.jpg');
          axes('Position',[0.8 0.01 0.2 0.2]);
          imagesc(im);axis image off;
      catch
          % it doesn't matter if the mouse can't be displayed ;)
      end

%--------------------------
function unload
global defaults
global spmmouseset
    if numel(defaults)>0
       try
           path(spmmouseset.oldpath);
       catch
       end
       
       defaults=[];
       spmmouseset=[];
       spm_defaults;
    end
    
    
%--------------------------
function loadpreset
global spmmouseset;

    if isempty(spmmouseset)
        spm_defaults;
        initspmmouseset;
    end;

    % 
    % ask user for a preset file
    filename = spm_select(1,'mat','Select preset...',[],spmmouseset.path);
    
    try 
        preset = load(filename);
    catch
        fprintf(1,'Couldn''t open file, or file is corrupt / not preset file! Aborting.\n');
        return;
    end
     
    
        %load things about the glass brain and scaling factors
    try
        spmmouseset.animal.DX = preset.DX;
        spmmouseset.animal.DY = preset.DY;
        spmmouseset.animal.DZ = preset.DZ;
        spmmouseset.animal.CX = preset.CX;
        spmmouseset.animal.CY = preset.CY;
        spmmouseset.animal.CZ = preset.CZ;
        spmmouseset.animal.mip = preset.mip;
        spmmouseset.animal.scale = preset.scale;
        spmmouseset.animal.name = preset.name;
    catch
        fprintf(1,'Critical fields missing from preset file - aborting\n.');
        returnl
    end
    
        
        if(isfield(preset,'isig')) % does the file have any priors in it?
            spmmouseset.animal.isig = preset.isig;
            spmmouseset.animal.mu = preset.mu(:);
        end
        
        if(isfield(preset,'grey'))
            % can we open the file?
            if exist(preset.grey,'file') ~=2
                % no - is it in the spmmouse tpm directory?
                [pth,nm,ext] = fileparts(preset.grey);
                
                teststr=strfind(ext,',');
                if(~isempty(teststr))
                    ext = ext(1:teststr(1));
                end
                
                if exist(strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext),'file')==2
                    % yes - let's just update it
                    preset.grey = strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext);
                    
                    % white and csf files probably in same place, let's
                    % take a chance ... 
                    [pth,nm] = fileparts(preset.white);
                    preset.white = strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext);
                    
                    [pth,nm] = fileparts(preset.csf);
                    preset.csf = strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext);
                    
                    
                spmmouseset.animal.tpm = char(...
                    preset.grey,...
                    preset.white,...
                    preset.csf);
                else
                    % no - ask the user
                    switch questdlg(sprintf('Couldn''t find \n"%s"\n\nWould you like to locate tissue probability maps now?', preset.grey), preset.name, 'Yes', 'No', 'Yes')
                        case 'Yes'
                            [files,sts] = spm_select(3,'image','Select grey, white, csf TPMs');
                            if sts
                                preset.grey = ridcomma(files(1,:));
                                preset.white = ridcomma(files(2,:));
                                preset.csf = ridcomma(files(3,:));
                                preset.tpm = char(...
                                    preset.grey,...
                                    preset.white,...
                                    preset.csf);
                                % user will probably want to save this,
                                % let's just do it 
                                try
                                    save(filename, '-v6', '-struct', 'preset');
                                catch
                                    warning('Couldn''t save amended preset file');
                                end
                                
                                spmmouseset.animal.tpm = char(...
                                    preset.grey,...
                                    preset.white,...
                                    preset.csf); % Prior probability maps
                            else
                                
                                rmfield(preset,'grey')
                                rmfield(preset,'white')
                                rmfield(preset,'csf'); 
                            end
                            
                        case 'No'
                            rmfield(preset,'grey')
                            rmfield(preset,'white')
                            rmfield(preset,'csf');
                            %best just pretend we have nothing
                    end
                end
            else
                % it did exist, hurrah
                spmmouseset.animal.tpm = char(...
                    preset.grey,...
                    preset.white,...
                    preset.csf); % Prior probability maps
            end
        end

        adjustdefaults;
        
    try
        gfig = findobj('Tag','Graphics');
        figure(gfig);
    catch
        fprintf(1,'Could not find SPM graphics window ! Is SPM loaded ?\n');
        return;
    end

    % clear everything visible from graphics window
	delete(findobj(get(gfig,'Children'),'flat','HandleVisibility','on'));
    % clear callbacks
	set(gfig,'KeyPressFcn','','WindowButtonDownFcn','','WindowButtonMotionFcn','','WindowButtonUpFcn','');
    winscale = spm('WinScale');
    tTitle = uicontrol(gfig,'Style','Text','Position',[20 800 560 40].*winscale,'String',spmmouseset.title,'FontSize',24,'BackgroundColor','w');
    tName = uicontrol(gfig,'Style','Text','Position',[20 700 560 40].*winscale,'String',spmmouseset.animal.name,'FontSize',14,'BackgroundColor','w','FontWeight','bold','ForegroundColor','b');
    uicontrol('Position',[20 760 148 30].*winscale,'String','Show Welcome Screen',...
          'Callback','spmmouse;');
    %uicontrol('Position',[180 760 148 30].*winscale,'String','Edit Preset',...
    %  'Callback','spmmouse(''editpreset'');');
  
    % display details of the loaded preset
    axmip = axes('Position',[0.1 0.4 0.4 0.4]);
    imagesc(rot90(spmmouseset.animal.mip)); axis image off; colormap gray;
    title('Preview of MIP template');
    
    if(isfield(preset,'grey'))
        strtpms = sprintf('TPMs:\n%s\n%s\n%s\n',preset.grey,preset.white,preset.csf);
    else
        strtpms = sprintf('No TPMs specified in preset.\n');
    end
    
    tInfo = uicontrol(gfig,'Style','Text','Position',[20 50 560 250].*winscale,'String','','FontSize',12,'BackgroundColor','w','FontWeight','bold');
    set(tInfo, 'String', ...
        {sprintf('CX %i CY %i CZ %i DX %i DY %i DZ %i scale %f', ....
            spmmouseset.animal.CX, spmmouseset.animal.CY, spmmouseset.animal.CZ, ...
            spmmouseset.animal.DX, spmmouseset.animal.DY, spmmouseset.animal.DZ, ...
            spmmouseset.animal.scale), ...
        '',strtpms,'','preset file:',filename,'','Ready to go, use SPM as normal.',''});
    
        
function loadpres(fname)
global spmmouseset;
% with fname - no gui

    try 
        preset = load(fname);
    catch
        fprintf(1,'Couldn''t open file, or file is corrupt / not preset file! Aborting.\n');
        return;
    end
     
    
        %load things about the glass brain and scaling factors
    try
        spmmouseset.animal.DX = preset.DX;
        spmmouseset.animal.DY = preset.DY;
        spmmouseset.animal.DZ = preset.DZ;
        spmmouseset.animal.CX = preset.CX;
        spmmouseset.animal.CY = preset.CY;
        spmmouseset.animal.CZ = preset.CZ;
        spmmouseset.animal.mip = preset.mip;
        spmmouseset.animal.scale = preset.scale;
        spmmouseset.animal.name = preset.name;
    catch
        fprintf(1,'Critical fields missing from preset file - aborting\n.');
        returnl
    end
    
        
        if(isfield(preset,'isig')) % does the file have any priors in it?
            spmmouseset.animal.isig = preset.isig;
            spmmouseset.animal.mu = preset.mu(:);
        end
        
        if(isfield(preset,'grey'))
            % can we open the file?
            if exist(preset.grey,'file') ~=2
                % no - is it in the spmmouse tpm directory?
                [pth,nm,ext] = fileparts(preset.grey);
                
                teststr=strfind(ext,',');
                if(~isempty(teststr))
                    ext = ext(1:teststr(1));
                end
                
                if exist(strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext),'file')==2
                    % yes - let's just update it
                    preset.grey = strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext);
                    
                    % white and csf files probably in same place, let's
                    % take a chance ... 
                    [pth,nm] = fileparts(preset.white);
                    preset.white = strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext);
                    
                    [pth,nm] = fileparts(preset.csf);
                    preset.csf = strcat(spmmouseset.path,strcat(filesep,'tpm',filesep),nm,ext);
                    
                    
                 spmmouseset.animal.tpm = char(...
                    preset.grey,...
                    preset.white,...
                    preset.csf);
                else

                            rmfield(preset,'grey')
                            rmfield(preset,'white')
                            rmfield(preset,'csf');
                            %best just pretend we have nothing

                end
            else
                % it did exist, hurrah
                spmmouseset.animal.tpm = char(...
                    preset.grey,...
                    preset.white,...
                    preset.csf); % Prior probability maps
            end
        end

        adjustdefaults;
    
        

        
%----------------------------------
function adjustdefaults
global defaults;
global spmmouseset;

    spm_defaults; % reset defaults
    
    global c0;
    if ~isempty(c0);
        c0=[];
    end
    
    try
        
    animal = spmmouseset.animal;
    defaults.animal = spmmouseset.animal;
     % now adjust all settings based on scale - all these numbers can be
    % adjusted in the particular interfaces for each function, they are
    % reasonable enough but not really worth adding a further fudge-factor
    % modifying interface...
    
    fixedscale = 0.01 * round(animal.scale * 100);
    
    if(isfield(defaults,'realign'))
        defaults.realign.estimate.sep    = 3*fixedscale;
        defaults.realign.estimate.fwhm   = 4*fixedscale;
    end

    if(isfield(defaults,'unwarp'))
        defaults.unwarp.estimate.fwhm    = 4*fixedscale;
        defaults.unwarp.estimate.basfcn  = [12 12]*fixedscale;
    end

    if(isfield(defaults,'coreg'))
        defaults.coreg.estimate.sep      = fixedscale*[4 2];
        defaults.coreg.estimate.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        defaults.coreg.estimate.fwhm     = 8*fixedscale;
    end

    if(isfield(defaults,'normalise'))
        defaults.normalise.estimate.smosrc  = 8*fixedscale;
        defaults.normalise.estimate.cutoff  = 25*fixedscale; 
        defaults.normalise.write.vox        = fixedscale*[2 2 2];
    end 

    if(isfield(defaults,'segment'))
        defaults.segment.estimate.cutoff = 30*fixedscale;
        defaults.segment.estimate.samp   = 4*fixedscale;
        defaults.segment.estimate.affreg.smosrc = 8*fixedscale;
        defaults.segment.estimate.bb     =  [[-inf -inf -inf];[inf inf inf]];
    end

    if(isfield(defaults,'preproc'))
        
        % for bias correction
        allowedvals = [1,2,5,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,Inf];
        
        defaults.preproc.warpco   = 25*fixedscale;
        defaults.preproc.biasfwhm = allowedvals(find(allowedvals>=(60*fixedscale),1,'first'));
        defaults.preproc.samp     = 3*fixedscale;
        

        defaults.animal.maximadistance = 8*fixedscale; 
        
        if(isfield(animal,'mu'))
            defaults.preproc.regtype = 'animal';
            defaults.preproc.mu = animal.mu(:);
            defaults.preproc.isig = animal.isig;
        end

        
    end

    if(isfield(animal,'tpm'))
        defaults.preproc.tpm = animal.tpm;
    end
    
    catch
        fprintf(1,'Error occured setting defaults in spmmouse :(\n');
        return;
    end

   

    % put replaced versions of spm files at front of path
    addpath(strcat(spmmouseset.path,strcat(filesep,'replaced')),'-begin');


    
%-------------------
function createpreset
global spmmouseset;

    if isempty(spmmouseset)
        spm_defaults;
        initspmmouseset;
    end;
    
    if(isfield(spmmouseset,'preset')) rmfield(spmmouseset,'preset');end;
    
    try
        gfig = findobj('Tag','Graphics');
        figure(gfig);
    catch
        fprintf(1,'Could not find SPM graphics window ! Is SPM loaded ?\n');
        return;
    end
    
    % clear everything visible from graphics window
	delete(findobj(get(gfig,'Children'),'flat','HandleVisibility','on'));
    % clear callbacks
	set(gfig,'KeyPressFcn','','WindowButtonDownFcn','','WindowButtonMotionFcn','','WindowButtonUpFcn','');
    winscale = spm('WinScale');
    tTitle = uicontrol(gfig,'Style','Text','Position',[20 800 560 40].*winscale,'String',spmmouseset.title,'FontSize',24,'BackgroundColor','w');

    uicontrol('Position',[20 760 148 30].*winscale,'String','Cancel',...
          'Callback','spmmouse;');
    uicontrol('Position',[180 760 148 30].*winscale,'String','Load Preset',...
      'Callback','spmmouse(''loadpreset'');');
    uicontrol('Position',[340 760 148 30].*winscale,'String','Save Preset',...
      'Callback','spmmouse(''savepreset'');');
  
    % Load image button  
    uicontrol('Position',[20 720 148 30].*winscale,'String','Load Image...',...
        'Callback','spmmouse(''loadimage'');');
    uicontrol('Position',[20 680 148 30].*winscale,'String','Apply Preset...',...
        'Callback','spmmouse(''applypreset'');');
    % Filename box
    spmmouseset.edFilename = uicontrol('Position',[175 710 350 30].*winscale,'String','No image loaded','Tag','filenamebox','Style','Text','BackgroundColor','w');
    

    % text boxes for edge detection 
    spmmouseset.edThresh = uicontrol('Style','Edit','Position',[110 200 50 28].*winscale,'String','0.15','BackgroundColor','w');
    spmmouseset.edCannyU = uicontrol('Style','Edit','Position',[110 170 50 28].*winscale,'BackgroundColor','w','Enable','inactive','String','0.1');
    spmmouseset.edCannyL = uicontrol('Style','Edit','Position',[110 140 50 28].*winscale,'BackgroundColor','w','Enable','inactive','String','0.01');
    uicontrol('Style','Text','Position',[10 195 90 28].*winscale,'BackgroundColor','w','String','Threshold');
    uicontrol('Style','Text','Position',[10 165 90 28].*winscale,'BackgroundColor','w','String','Canny Upper');
    uicontrol('Style','Text','Position',[10 135 90 28].*winscale,'BackgroundColor','w','String','Canny Lower');
    spmmouseset.chkAutoEdge = uicontrol('Style','Checkbox','Position',[420 150 150 28].*winscale,'String','Auto edge limits?','Value',1,'BackgroundColor','w','Callback','spmmouse(''autochk'');');
    
    spmmouseset.sldThresh = uicontrol('Style','slider','Position',[180 210 200 15].*winscale,'Min',0,'Max',1,'Value',0.15,'Callback','spmmouse(''slidert'');');
    spmmouseset.sldCannyU= uicontrol('Style','slider','Position',[180 177 200 15].*winscale,'Min',0,'Max',1,'Value',0.1,'Callback','spmmouse(''slideru'');','Enable','inactive');
    spmmouseset.sldCannyL = uicontrol('Style','slider','Position',[180 152 200 15].*winscale,'Min',0,'Max',1,'Value',0.01,'Callback','spmmouse(''sliderl'');','Enable','inactive');
    
    uicontrol('Position',[450 200 150 30],'String','Regenerate MIP','Callback','spmmouse(''createmip'')');
    uicontrol('Position',[450 240 150 30],'String','TPMs...','Callback','spmmouse(''priors'')');
    
%-----------------------------------
function loadimage % happens when load image button is clicked 
global spmmouseset;

    

    [filename, sts] = spm_select(1,'image','Select brain extracted image..');
    if(~sts) 
        return;
    end
    if(isfield(spmmouseset,'preset')) rmfield(spmmouseset,'preset'); end;
    set(spmmouseset.edFilename,'String',filename);
    
    try
        spmmouseset.volImage = spm_vol(filename);
        img = spm_read_vols(spmmouseset.volImage);
        spmmouseset.img = img(:,:,:,1);
    catch
        fprintf(1,'Couldn''t load image, giving up.');
        return;
    end
    
    createmip;
    
%-----------------------------------    
function fact = GetZoomFactor(nSize, nSizeFit)
% Returns the biggest factor nSize can be increased so the whole thing will
% fit in nSizeFit

    fact = nSizeFit / nSize;
    fact = min(fact);
    
    
    
%-----------------------------------  
function [rect,imgCrop] = GetCropRect(img)
% returns the tightest rectangle enclosing the binary image and if desired
% the image itself
    
    if ~any(img)
        rect = [0 0 0 0]
        imgCrop = 0;
        return;
    end
    
    nSize = size(img);
    rect = [1 1 nSize(1) nSize(2)];
    
    for i=1:nSize(1)
        if any(img(i,:)) % if this row is not empty...
            rect(1) = i-2;
            break;
        end
    end
    
    for i=1:nSize(2)
        if any(img(:,i)) % if this row is not empty...
            rect(2) = i-2;
            break;
        end
    end
    
    
    for i=nSize(1):-1:1
        if any(img(i,:)) % if this row is not empty...
            rect(3) = i+2;
            break;
        end
    end        
    
    
    for i=nSize(2):-1:1
        if any(img(:,i)) % if this row is not empty...
            rect(4) = i+2;
            break;
        end
    end        
    
    if(rect(1) < 1) rect(1) = 1;  end
    if(rect(2) < 1) rect(2) = 1;  end
    if(rect(3) > nSize(1)) rect(3) = nSize(1);  end
    if(rect(4) > nSize(2)) rect(4) = nSize(2);  end
    
    if nargout > 1
        imgCrop = img(rect(1):rect(3), rect(2):rect(4));
    end

    
    
%--------------------------------------
function createmip
global spmmouseset

if(~isfield(spmmouseset,'img')) % if no image is loaded, load one
    loadimage;
    return;
end

try
    thresh = str2num(get(spmmouseset.edThresh,'String'));
    cannyu = str2num(get(spmmouseset.edCannyU,'String'));
    cannyl = str2num(get(spmmouseset.edCannyL,'String'));
    
    if(isempty(cannyu)) cannyu=0.1;end;
    if(isempty(cannyl)) cannyl=0.01;end;
    if(cannyl < 0) cannyl = 0; end;
    if(cannyu > 1) cannyu = 1; end;
    if(cannyu < cannyl) cannyu=cannyl; end;
    if(cannyl > cannyu) cannyl=cannyu; end;

    if(get(spmmouseset.chkAutoEdge,'Value'))
        cannythresh = [];
    else
        cannythresh = [cannyl cannyu];
    end
    
    if(isempty(thresh)) thresh=0.15; end;
    if(~and(thresh>0,thresh<1))
        thresh=0.15;
    end
    img = spmmouseset.img > (thresh*max(spmmouseset.img(:)));
    
    % x-ray beam on...
    imgTrans = fliplr(squeeze(sum(img, 3)>0)');
    imgSag = ((squeeze(sum(img, 1)>0)));
    imgCor = (squeeze(sum(img, 2)>0));
    
    % crop
    [rectTransCrop,imgTransC] = GetCropRect(imgTrans);
    [rectSagCrop,imgSagC] = GetCropRect(imgSag);
    [rectCorCrop,imgCorC] = GetCropRect(imgCor);
    
    % use split between sagittal and coronal to set scale proportionally
    % rectangle format top left height width, typical matlab xy nonsense
    nSagWidth = rectSagCrop(3) - rectSagCrop(1);
    nCorWidth = rectCorCrop(3) - rectCorCrop(1); % remember the mip is rotated...

    spmmouseset.preset.DY = floor(nSagWidth / (nSagWidth+nCorWidth) * (spmmouseset.size(1)));
    spmmouseset.preset.DX = spmmouseset.size(1) - spmmouseset.preset.DY;
    spmmouseset.preset.DZ = spmmouseset.size(2) - spmmouseset.preset.DX;
    
    % resample image to required dimensions + edge detect
    dZoom = GetZoomFactor(size(imgSagC), [spmmouseset.preset.DY-3*spmmouseset.margin spmmouseset.preset.DZ-3*spmmouseset.margin]);
    
    [imgSagC,outthresh] = edge(double(imresize(imgSagC, dZoom, 'bicubic')),'canny',cannythresh);
    imgCorC = edge(double(imresize(imgCorC, dZoom, 'bicubic')),'canny',cannythresh);
    imgTransC= edge(double(imresize(imgTransC, dZoom, 'bicubic')),'canny',cannythresh);
    
    % thicken lines
    strelLine = strel('line',3,0);
    imgSagC=imdilate(imgSagC,strelLine);
    imgCorC=imdilate(imgCorC,strelLine);
    imgTransC=imdilate(imgTransC,strelLine);

    dWorldCentre = -spmmouseset.volImage.mat([13 14 15]);
    dVoxelSize = sqrt(sum(spmmouseset.volImage.mat(1:3,1:3).^2));
    dWorldExtent = dVoxelSize .* spmmouseset.volImage.dim;
    
    dMIPCentre = floor(dZoom* inv(spmmouseset.volImage.mat(1:3,1:3)) * dWorldCentre');
    
    spmmouseset.preset.CX = dMIPCentre(1) - rectTransCrop(1) + spmmouseset.margin;
    spmmouseset.preset.CY = dMIPCentre(2) - rectSagCrop(1) + spmmouseset.margin;
    spmmouseset.preset.CZ = dMIPCentre(3) - rectCorCrop(1) + spmmouseset.margin;  
    
    spmmouseset.preset.scale = dZoom * dVoxelSize(2); % 1 pixel in MIP will be this in world

    %incorporate into matrix
    spmmouseset.preset.mip = zeros(spmmouseset.size);
    spmmouseset.margin = max(spmmouseset.margin,1);
    spmmouseset.preset.mip(spmmouseset.margin:spmmouseset.margin+size(imgTransC,1)-1, spmmouseset.margin:spmmouseset.margin+size(imgTransC,2)-1) = imgTransC;
    spmmouseset.preset.mip(spmmouseset.margin:spmmouseset.margin+size(imgSagC,1)-1, spmmouseset.preset.DX+2*spmmouseset.margin:2*spmmouseset.margin+spmmouseset.preset.DX+size(imgSagC,2)-1) = imgSagC;
    spmmouseset.preset.mip(spmmouseset.margin+spmmouseset.preset.DY:spmmouseset.margin+spmmouseset.preset.DY+size(imgCorC,1)-1, 2*spmmouseset.margin+spmmouseset.preset.DX:+2*spmmouseset.margin+spmmouseset.preset.DX+size(imgCorC,2)-1) = imgCorC;
    
    %draw coordinate lines
    spmmouseset.preset.mip(round(spmmouseset.preset.CY:spmmouseset.preset.CY+1),round(0.5*spmmouseset.margin:2:spmmouseset.preset.DX-spmmouseset.margin)) = 1;
    spmmouseset.preset.mip(round(0.5*spmmouseset.margin:2:spmmouseset.preset.DY+spmmouseset.margin),round(spmmouseset.preset.CX:spmmouseset.preset.CX+1))=1;
    
    spmmouseset.preset.mip(spmmouseset.preset.CY:spmmouseset.preset.CY+1,spmmouseset.preset.DX+spmmouseset.margin:2:spmmouseset.preset.DZ+spmmouseset.preset.DX-2*spmmouseset.margin) = 1;
    spmmouseset.preset.mip(round(0.5*spmmouseset.margin):2:spmmouseset.preset.DY,spmmouseset.preset.DX+spmmouseset.preset.CZ:spmmouseset.preset.DX+spmmouseset.preset.CZ+1)=1;
    
    spmmouseset.preset.mip(spmmouseset.preset.DY+round(0.5*spmmouseset.margin):2:round(-0.5*spmmouseset.margin)+spmmouseset.preset.DY+spmmouseset.preset.DZ,spmmouseset.preset.DX+spmmouseset.preset.CZ:spmmouseset.preset.DX+spmmouseset.preset.CZ)=1;
    spmmouseset.preset.mip(spmmouseset.preset.DY+spmmouseset.preset.CX:spmmouseset.preset.DY+spmmouseset.preset.CX+1,spmmouseset.preset.DX+spmmouseset.margin:2:spmmouseset.preset.DX+spmmouseset.preset.DZ-round(0.5*spmmouseset.margin))=1;
    
    spmmouseset.preset.mip = spmmouseset.preset.mip(1:spmmouseset.size(1), 1:spmmouseset.size(2));
    
    
    % display details of the loaded preset
    axmip = axes('Position',[0.1 0.4 0.4 0.4]);
    imagesc(rot90(spmmouseset.preset.mip)); axis image off; colormap gray;
    title('Preview of MIP template');

    set(spmmouseset.edCannyU,'String',sprintf('%.3f',outthresh(2)));
    set(spmmouseset.edCannyL,'String',sprintf('%.3f',outthresh(1)));
    set(spmmouseset.sldCannyU,'Value',outthresh(2));
    set(spmmouseset.sldCannyL,'Value',outthresh(1));

 catch
     error('An error occured - is your image ok?');
end
 


%--------------------
function autochk %when the tickbox is pressed for auto canny limits
global spmmouseset;

    if(get(spmmouseset.chkAutoEdge,'Value'))
       set([spmmouseset.edCannyU spmmouseset.sldCannyU],'Enable','inactive');
       set([spmmouseset.edCannyL spmmouseset.sldCannyL],'Enable','inactive');
    else
       set([spmmouseset.edCannyU spmmouseset.sldCannyU],'Enable','on');
       set([spmmouseset.edCannyL spmmouseset.sldCannyL],'Enable','on');
    end
    
    
%--------------------
function sliderl %lower canny slider
global spmmouseset

    set(spmmouseset.edCannyL,'String',sprintf('%.2f',get(spmmouseset.sldCannyL,'Value')));
    
    if get(spmmouseset.sldCannyU,'Value')<get(spmmouseset.sldCannyL,'Value')
        set(spmmouseset.sldCannyU,'Value',min(1,get(spmmouseset.sldCannyL,'Value')+0.01));
        set(spmmouseset.edCannyU,'String',sprintf('%.2f',get(spmmouseset.sldCannyU,'Value')));
    end
    
    
function slideru % upper canny slider
global spmmouseset

    set(spmmouseset.edCannyU,'String',sprintf('%.2f',get(spmmouseset.sldCannyU,'Value')));
    
    if get(spmmouseset.sldCannyL,'Value')>get(spmmouseset.sldCannyU,'Value')
        set(spmmouseset.sldCannyL,'Value',max(0,get(spmmouseset.sldCannyU,'Value')-0.01));
        set(spmmouseset.edCannyL,'String',sprintf('%.2f',get(spmmouseset.sldCannyL,'Value')));
    end
    
    
function slidert % threshold slider
global spmmouseset

    set(spmmouseset.edThresh,'String',sprintf('%.2f',get(spmmouseset.sldThresh,'Value')));
    
    
    
    
%--------------------------------------
function priors
global spmmouseset

    if ~isfield(spmmouseset,'preset')
        loadimage;
    end
    
    if ~isfield(spmmouseset.preset,'grey')
        % no TPMs are loaded in the preset file
        answer = questdlg(sprintf('No TPMs are loaded.\n\nWhat would you like to do?'),'Priors...','Use files','Use flat','Use files');
        if(strcmp(answer,'Use none'))
            return;
        end
    else
        % file has TPMs
        answer = questdlg(sprintf('TPMs are specified in this preset file:\n%s\n%s\n%s\n\nDo you want to replace them?',spmmouseset.preset.grey,spmmouseset.preset.white,spmmouseset.preset.csf),'Priors','Yes','No','No');
        
        if(strcmp(answer,'No'))
            return;
        end
        
        answer = questdlg(sprintf('Do you want to specify new files or generate flat priors?'),'Priors','Use files','Use flat','Use files');
    end
    
    switch answer
        case 'Use files'
            [files,sts] = spm_select(3,'image','Select grey, white, csf TPMs');
            if sts
                spmmouseset.preset.grey = ridcomma(files(1,:));
                spmmouseset.preset.white = ridcomma(files(2,:));
                spmmouseset.preset.csf = ridcomma(files(3,:));
                spmmouseset.preset.tpm = files;
            else
                fprintf(1,'Select TPMs cancelled\n');
                return;
            end
            
        case 'Use flat'
            
            
            if(isfield(spmmouseset,'volImage'))
               v = spmmouseset.volImage;
            else
               [file,sts] = spm_select(1,'image','Select typical image');
               if ~sts, return; end; 
               
               v = spm_vol(file);
            end
            
            dat = 0.25 * ones(v.dim);
            v.dt = [spm_type('float32') 0];
            
            [fname,pathname] = uiputfile({'*.nii','Nifti Image'},'Save file as...');
            
            v.fname = fullfile(pathname,fname);
            spm_write_vol(v,dat);
            spmmouseset.preset.grey = fname;
            spmmouseset.preset.white = fname;
            spmmouseset.preset.csf = fname;
            spmmouseset.preset.tpm = repmat(fname, [3 1]);   
    end
    
    
function savepreset
global spmmouseset

    if(~isfield(spmmouseset,'preset'))
        fprintf(1,'No preset to save! Aborting\n.');
        return;
    end
    
    spmmouseset.preset.name = char(inputdlg('Please enter preset name...','Save preset',1,{'unknown'}));
    
    preset = spmmouseset.preset;
    
    [filename,path] = uiputfile({'*.mat'},'Save file as...');
    save(fullfile(path,filename),'-v6','-struct','preset');
    
    % apply it now 
    applypreset;
    
    
    
function applypreset
global spmmouseset

    if(~isfield(spmmouseset,'preset')), return; end;
    
    spmmouseset.animal = spmmouseset.preset;
    adjustdefaults;
    
    
function outstr = ridcomma(instr)
    
    isthere = findstr(instr,',');

    if ~isempty(isthere)
        outstr=instr(1:isthere(1)-1);
    else
        outstr=instr;
    end
    
