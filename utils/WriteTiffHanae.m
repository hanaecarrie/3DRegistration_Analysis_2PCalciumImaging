function [] = WriteTiffHanae(OutputFolder, Matrix, Title, ChunckSize)

%    WRITETIFFHANAE: write matlab 3D or 4D matrix as a tiff multipage 
% 
%    Inputs:
%       OutputFolder -- string, output folder to create and
%           where the Tiff file(s) will be saved
%       Matrix -- 3D (x,y,z or t) or 4D matrix, (x,y,z,t) to save
%       Title -- string, title
%       Chuncksize -- int, size of the chuncks, number of volumes to add
%    Outputs:
%       none

tStartWTH = tic;

% creating new folder
mkdir(OutputFolder);
Size = size(Matrix); A = length(Size);
if A == 4
    Matrix = reshape(Matrix, [Size(1), Size(2), Size(3)*Size(4)]);
end
SS = size(Matrix,3);
% default input
if nargin <= 3
    ChunckSize = SS;
elseif nargin < 3
    Title = 'Movie';
end
NbChunck = ceil(SS/ChunckSize);

% Raising possible erros
if Size(1)*Size(2)*ChunckSize > ((5*(10^9)))
    % ensure Matrix size isn't too big 
    error('Matrix size too big. Please choose a smaller ChunckSize')
elseif mod(SS, ChunckSize) ~= 0 % ensure chunck size well chosen
    error(strcat('ChunckSize does not divide the number of frames. ',...
        'Please choose an appropriate chunck size'));
end

% Writing Tiff
for chunck = 1:NbChunck
    if NbChunck == 1
        extension = '';
    else
        extension =  strcat('_chunck_', num2str(chunck));
    end
    outputFileName = strcat(OutputFolder, Title, ...
           extension, '.tiff');
    begin = (chunck-1)*ChunckSize +1;
    writeTiff(Matrix(:, :,begin:begin+ChunckSize-1),outputFileName);
end

tEndWTH = toc(tStartWTH);
fprintf('WriteTiffHanae in %d minutes and %f seconds\n.', ...
    floor(tEndWTH/60),rem(tEndWTH,60));

end