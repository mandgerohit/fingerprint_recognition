function sMap = som_init(D, varargin)

%SOM_RANDINIT Initialize a Self-Organizing Map with random values.
%
% sMap = som_randinit(D, [[argID,] value, ...])
%
%  sMap = som_randinit(D);
%  sMap = som_randinit(D,sMap);
%  sMap = som_randinit(D,'munits',100,'hexa');
% 
%  Input and output arguments ([]'s are optional): 
%    D                 The training data.
%             (struct) data struct
%             (matrix) data matrix, size dlen x dim
%   [argID,   (string) Parameters affecting the map topology are given 
%    value]   (varies) as argument ID - argument value pairs, listed below.
%
%   sMap      (struct) map struct
%
% Here are the valid argument IDs and corresponding values. The values 
% which are unambiguous (marked with '*') can be given without the
% preceeding argID.
%  'munits'       (scalar) number of map units
%  'msize'        (vector) map size
%  'lattice'     *(string) map lattice: 'hexa' or 'rect'
%  'shape'       *(string) map shape: 'sheet', 'cyl' or 'toroid'
%  'topol'       *(struct) topology struct
%  'som_topol','sTopol'    = 'topol'
%  'map'         *(struct) map struct
%  'som_map','sMap'        = 'map'
%
% For more help, try 'type som_randinit' or check out online documentation.
% See also SOM_MAP_STRUCT, SOM_LININIT, SOM_MAKE.

%%%%%%%%%%%%% DETAILED DESCRIPTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% som_randinit
%
% PURPOSE
%
% Initializes a SOM with random values.
%
% SYNTAX
%
%  sMap = som_randinit(D)
%  sMap = som_randinit(D,sMap);
%  sMap = som_randinit(D,'munits',100,'hexa');
%
% DESCRIPTION
%
% Initializes a SOM with random values. If necessary, a map struct
% is created first. For each component (xi), the values are uniformly
% distributed in the range of [min(xi) max(xi)]. 
%
% REQUIRED INPUT ARGUMENTS
%
%  D                 The training data.
%           (struct) Data struct. If this is given, its '.comp_names' and 
%                    '.comp_norm' fields are copied to the map struct.
%           (matrix) data matrix, size dlen x dim
%  
% OPTIONAL INPUT ARGUMENTS 
%
%  argID (string) Argument identifier string (see below).
%  value (varies) Value for the argument (see below).
%
%  The optional arguments can be given as 'argID',value -pairs. If an
%  argument is given value multiple times, the last one is used. 
%
%  Here are the valid argument IDs and corresponding values. The values 
%  which are unambiguous (marked with '*') can be given without the 
%  preceeding argID.
%  'dlen'         (scalar) length of the training data
%  'data'         (matrix) the training data
%                *(struct) the training data
%  'munits'       (scalar) number of map units
%  'msize'        (vector) map size
%  'lattice'     *(string) map lattice: 'hexa' or 'rect'
%  'shape'       *(string) map shape: 'sheet', 'cyl' or 'toroid'
%  'topol'       *(struct) topology struct
%  'som_topol','sTopol'    = 'topol'
%  'map'         *(struct) map struct
%  'som_map','sMap'        = 'map'
%
% OUTPUT ARGUMENTS
% 
%  sMap     (struct) The initialized map struct.
%
% EXAMPLES
%
%  sMap = som_randinit(D);
%  sMap = som_randinit(D,sMap);
%  sMap = som_randinit(D,sTopol);
%  sMap = som_randinit(D,'msize',[10 10]);
%  sMap = som_randinit(D,'munits',100,'hexa');
%
% SEE ALSO
% 
%  som_map_struct   Create a map struct.
%  som_lininit      Initialize a map using linear initialization algorithm.
%  som_make         Initialize and train self-organizing map.

% Copyright (c) 1997-2000 by the SOM toolbox programming team.
% http://www.cis.hut.fi/projects/somtoolbox/

% Version 1.0beta ecco 100997
% Version 2.0beta juuso 101199

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% check arguments

% data
  data_name = inputname(1); 
  struct_mode = 0; 
  
  [dlen dim] = size(D);

% varargin
sMap = [];
sTopol = som_topol_struct; 
sTopol.msize = 0; 
munits = NaN;
i=1; 

if length(varargin) == 2 
   i=i+1;
   sTopol.msize = varargin{i};
   munits = prod(sTopol.msize); 
end;
                               
if ~isempty(sMap), 
  [munits dim2] = size(sMap.codebook);
  if dim2 ~= dim, error('Map and data must have the same dimension.'); end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create map

% map struct
if ~isempty(sMap), 
  sMap = som_set(sMap,'topol',sTopol);
else  
  if ~prod(sTopol.msize), 
    if isnan(munits), 
      sTopol = som_topol_struct('data',D,sTopol);
    else
      sTopol = som_topol_struct('data',D,'munits',munits,sTopol);
    end
  end  
  sMap = som_map_struct(dim, sTopol); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% initialization

% train struct
sTrain = som_train_struct('algorithm','randinit');
sTrain = som_set(sTrain,'data_name',data_name);

munits = prod(sMap.topol.msize);
sMap.codebook = rand([munits dim]); 

% set interval of each component to correct value
for i = 1:dim,
  inds = find(~isnan(D(:,i)) & ~isinf(D(:,i))); 
  if isempty(inds), mi = 0; ma = 1; 
  else ma = max(D(inds,i)); mi = min(D(inds,i));  
  end
  sMap.codebook(:,i) = (ma - mi) * sMap.codebook(:,i) + mi; 
end

% training struct
sTrain = som_set(sTrain,'time',datestr(now,0));
sMap.trainhist = sTrain;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%