function [ref] = DefineReference(volume, n)
% DefineReference
% build a moving volume reference from an input sequence of volume
% Inputs:
%   volume - input the volume, 4D matrix of double, dim = x,y,z,t
%   n - number of frames to average together for the moving reference
%       ADVICE: visualise your volume in ImageJ and bin each n frames
%       to find a good n
% Outputs:
%   ref - moving volume reference, 4D matrix of double, dim = x,y,z,t/n


x = size(volume, 1);
y = size(volume, 2);
z = size(volume, 3);
t = size(volume, 4);

if mod(t,n) ~= 0
    error('n does not divide the number of frames')
end

ref = zeros(x, y, z, t/n); % initialize reference

for i = 1:t/n
    for z = 1:size(volume, 3)
        a = volume(:,:,z,(i-1)*n+1:i*n); % chunck of n volumes
        a = squeeze(permute(a, [1, 2, 4, 3]));
        a = mean(a, 3); % take the average
        ref(:,:,z,i) = a;
    end
end
end