% spm project gen

function out = spm_project_gen(v, l, dim, dmipdims)
% this was a mex file but this should be fast enough without, will try it.

% forms maximium intensity projections - a compiled routine
% FORMAT spm_project(X,L,dims)
% X	-	a matrix of voxel values
% L	- 	a matrix of locations in Talairach et Tournoux (1988) space
% dims  -       assorted dimensions.
%               dims(1:3) - the sizes of the projected rectangles.
%               dims(4:5) - the dimensions of the mip image.
%____________________________________________________________________________
%
% spm_project 'fills in' a matrix (SPM) in the workspace to create
% a maximum intensity projection according to a point list of voxel
% values (V) and their locations (L) in the standard space described
% in the atlas of Talairach & Tournoux (1988).
%
% see also spm_mip.m
%
% * updated for generic mip maps - pass the atlas dimensions as a 4th parameter


	n    = numel(v);

    DX = dmipdims(1);
    DY = dmipdims(2);
    DZ = dmipdims(3);
    CX = dmipdims(4);
    CY = dmipdims(5);
    CZ = dmipdims(6);
    dScale = dmipdims(7);
    
	xdim = max(1,floor((abs(dim(1) / dScale) + 0.99)/2));
	ydim = max(1,floor((abs(dim(2) / dScale) + 0.99)/2));
	zdim = max(1,floor((abs(dim(3) / dScale) + 0.99)/2)); 
	m    = floor((dim(4)));
	m1   = floor((dim(5)));

        
    %/** In human and other adaptations, 1mm is good unit, and this is used 
    % * here in this coord space. Need to scale point appropriately.*/
	out = zeros([m m1]);

	if (m == DY+DX && m1 == DZ+DX) 
	
		%/* go though point list */
		for i=1:(n-1);
            
            x = floor(l(1,i)/dScale)+CX;
            y = floor(l(2,i)/dScale)+CY;
            z = floor(l(3,i)/dScale)+CZ;

			if (2*CX-x-xdim>0 && 2*CX-x+xdim<DX && y-ydim>0 && y+ydim<DY)
				q = v(i);
				for j=-ydim:ydim  %(j = -ydim/2; j <= ydim/2; j++)
					for k = -xdim:xdim
						%o = 1+j + y + (k + 2*CX-x)*m;
                        if out(1+y+j,2*CX-x+k)<q
                            out(1+y+j,2*CX-x+k) = q;
                        end
						
                    end
                end		
            end

			if (z-zdim>0 && z+zdim<DZ && y-ydim>0 && y+ydim<DY)
			
				q = v(i);
				for j = -ydim:ydim
					for k = -zdim:zdim
						%o = 1+j + y + (DX + k + z)*m;
                        if out(1+j+y, k+z+DX)<q
                            out(1+j+y, k+z+DX) = q;
                        end
                    end    
                end
             end

			if (x-xdim>0 && x+xdim<DX && z-zdim>0 && z+zdim<DZ) 
			
				q = v(i);
				for j = -xdim:xdim
					for k = -zdim:zdim
						%o = 1+DY + j + x + (DX + k + z)*m;
                        if out(1+j+DY+x, k+z+DX)<q
                            out(1+j+DY+x, k+z+DX) = q;
                        end
                    end
                end
            end
        end
    end
