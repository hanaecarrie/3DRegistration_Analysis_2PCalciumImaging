function WriteTiff(OutputFolder, Matrix, ChunckSize)
% Write Tiff stacks
% OutputFolder: string, output folder to create and where the Tiff file(s)
% will be saved
% Matrix: 3D (x,y,z or t) or 4D matrix, (x,y,z,t) to save as a Tiff

tic;

% creating new folder
mkdir(OutputFolder);
Size = size(Matrix); A = length(Size);
if A == 4
    Matrix = reshape(Matrix, [Size(1), Size(2), Size(3)*Size(4)]);
end
SS = size(Matrix,3);
% default input
if nargin < 3
    ChunckSize = SS;
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
    outputFileName = strcat(OutputFolder, 'chunck_', num2str(chunck),...
        '.tiff');
    begin = (chunck-1)*ChunckSize +1;
    writeTiff(Matrix(:, :,begin:begin+ChunckSize-1),outputFileName);
end

tEnd = toc;
fprintf('Elapsed time is %d minutes and %f seconds\n.', ...
    floor(tEnd/60),rem(tEnd,60));

end