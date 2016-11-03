%Assignment 1: SOM implementation and Test
%Title: Simple function approximation by SOM
%By Wu zhili 99050056
%20 Feb 2002

% Utilize the built-in functions provided by SOM Toolbox 2.0
% related information for SOM Toolbox can be found at 
% http://www.cis.hut.fi/projects/somtoolbox/

clf reset;
figure(gcf)
echo on

clc
%    ==========================================================
%               SOM_RUN - IMPLEMENT AND TEST SOM
%    ==========================================================
%    called built-in functions:		
%    som_randinit   - Create and initialize a SOM.
%    som_lininit    - Create and initialize a SOM.
%    som_seqtrain   - Train a SOM.
%    som_batchtrain - Train a SOM.
%    som_bmus        - Find best-matching units (BMUs).
%    som_quality     - Measure quality of SOM.
%    som_cplane      - draw the gridwise SOM neron

%    SELF-ORGANIZING MAP (SOM):

%    A self-organized map (SOM) is a "map" of the training data, 
%    dense where there is a lot of data and thin where the data 
%    is sparse. 

%    The map constitutes of neurons located on a regular map grid. 
%    The lattice of the grid can be either hexagonal or rectangular.

subplot(1,2,1)
som_cplane('hexa',[10 15],'none')
title('Hexagonal SOM grid')

subplot(1,2,2)
som_cplane('rect',[10 15],'none')
title('Rectangular SOM grid')

%    Each neuron (hexagon on the left, rectangle on the right) has an
%    associated prototype vector. After training, neighboring neurons
%    have similar prototype vectors.

%    The SOM can be used for data visualization, clustering (or 
%    classification), estimation and a variety of other purposes.

pause % Strike any key to continue...

clf
clc
%    INITIALIZE AND TRAIN THE SELF-ORGANIZING MAP
%    ============================================

%    Here are 100 data points obtained from the simple function:
%    y = 3x -2   (x in the domain of [0,1]):

x = (0:0.01:1)*pi;
y = sin(x);
D = [x',y'];

%    The map will be a 2-dimensional grid of size 10 x 10.

msize = [10 10];

%    SOM_RANDINIT can be used to initialize the
%    prototype vectors in the map. The map size is actually an
%    optional argument. If omitted, it is determined automatically
%    based on the amount of data vectors and the principal
%    eigenvectors of the data set. Below, the random initialization
%    algorithm is used.

sMap  = som_randinit(D, 'msize', msize);
[q,t] = som_quality(sMap,D)

%    Actually, each map unit can be thought as having two sets
%    of coordinates: 
%      (1) in the input space:  the prototype vectors
%      (2) in the output space: the position on the map
%    In the two spaces, the map looks like this: 

subplot(1,3,1) 
som_grid(sMap)
axis([0 11 0 11]), view(0,-90), title('Map in output space')

subplot(1,3,2) 
plot(D(:,1),D(:,2),'+r'), hold on
som_grid(sMap,'Coord',sMap.codebook)
title('Map in input space')

%    The black dots show positions of map units, and the gray lines
%    show connections between neighboring map units.  Since the map
%    was initialized randomly, the positions in in the input space are
%    completely disorganized. The red crosses are training data.

pause % Strike any key to train the SOM...

%    During training, the map organizes and folds to the training
%    data. Here, the sequential training algorithm is used:

sMap  = som_seqtrain(sMap,D,'radius',[5 1],'trainlen',100);

subplot(1,3,3)
som_grid(sMap,'Coord',sMap.codebook)
hold on, plot(D(:,1),D(:,2),'+r')
title('Trained map')

pause % Strike any key to view more closely the training process...


clf

clc
%    TRAINING THE SELF-ORGANIZING MAP
%    ================================

%    To get a better idea of what happens during training, let's look
%    at how the map gradually unfolds and organizes itself. To make it
%    even more clear, the map is now initialized so that it is away
%    from the data.

sMap = som_randinit(D,'msize',msize);
sMap.codebook = sMap.codebook + 1;

subplot(1,2,1)
som_grid(sMap,'Coord',sMap.codebook)
hold on, plot(D(:,1),D(:,2),'+r'), hold off
title('Data and original map')

%    The training is based on two principles: 
%     
%      Competitive learning: the prototype vector most similar to a
%      data vector is modified so that it it is even more similar to
%      it. This way the map learns the position of the data cloud.
%
%      Cooperative learning: not only the most similar prototype
%      vector, but also its neighbors on the map are moved towards the
%      data vector. This way the map self-organizes.

pause % Strike any key to train the map...

echo off
subplot(1,2,2)
o = ones(5,1);
r = (1-[1:60]/60);
for i=1:60,
  sMap = som_seqtrain(sMap,D,'tracking',0,...
		      'trainlen',5,'samples',...
		      'alpha',0.1*o,'radius',(4*r(i)+1)*o);
  som_grid(sMap,'Coord',sMap.codebook)
  hold on, plot(D(:,1),D(:,2),'+r'), hold off
  title(sprintf('%d/300 training steps',5*i))
  drawnow
end
title('Sequential training after 300 steps')
echo on


pause % Strike any key to evaluate the quality of maps...

clc
%    BEST-MATCHING UNITS (BMU)
%    =========================

%    Before going to the quality, an important concept needs to be
%    introduced: the Best-Matching Unit (BMU). The BMU of a data
%    vector is the unit on the map whose model vector best resembles
%    the data vector. In practise the similarity is measured as the
%    minimum distance between data vector and each model vector on the
%    map. The BMUs can be calculated using function SOM_BMUS. This
%    function gives the index of the unit.

%    Here the BMU is searched for the origin point (from the
%    trained map):

bmu = som_bmus(sMap,[0 0]);
bmu
%    Here the corresponding unit is shown in the figure. You can
%    rotate the figure to see better where the BMU is.

co = sMap.codebook(bmu,:);
co(1)
co(2)
hold on, 
subplot(1,2,2)
text(co(1),co(2),'BMU','Fontsize',20)
plot([0 co(1)],[0 co(2)],'ro-'),hold off

pause % Strike any key to analyze map quality...




clc
%    SELF-ORGANIZING MAP QUALITY
%    ===========================

%    The maps have two primary quality properties:
%      - data representation accuracy
%      - data set topology representation accuracy

%    The former is usually measured using average quantization error
%    between data vectors and their BMUs on the map.  For the latter
%    several measures have been proposed, e.g. the topographic error
%    measure: percentage of data vectors for which the first- and
%    second-BMUs are not adjacent units.

%    Both measures have been implemented in the SOM_QUALITY function.

%    And here for the initial map:
q
t

%    Here are the quality measures for the trained map: 

[q0,t0] = som_quality(sMap,D)

%    As can be seen, by folding the SOM has reduced the average
%    quantization error, For simple functions estimation, the topology representation
%    error also has reduced although in general the topology
%    representation capability is suffered.  By using a larger final
%    neighborhood radius in the training, the map becomes stiffer and
%    preserves the topology of the data set better.


echo off


