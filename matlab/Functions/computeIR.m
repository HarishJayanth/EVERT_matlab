% computeIR.m
% ------------------------------------------------------------------------------
% Project title: EVERT_matlab - MATLAB Wrappers for the EVERT library.
% 			  https://users.aalto.fi/~laines9/publications/laine2009aa_code.zip
% Description: Computes impulse response based on the paths between source and
%               listener.
% Author: Harish Venkatesan
%		  M.A., Music Technology
% 		  McGill University
% ------------------------------------------------------------------------------

function ir = computeIR(p, fs)

numPaths = p.numPaths();

order = zeros(numPaths,1);
path = cell(numPaths,1);
mat = cell(numPaths,1);

for i=1:numPaths
    [order(i) path{i} mat{i}] = p.getPath(i);
end

pathLen = zeros(length(path),1);
for i = 1:length(path)
    pathLen(i) = getPathLength(path{i});
end

c = 343;    % speed of sound = 343 m/s
pathSamp = (pathLen * fs / c) + 1;

delay = zeros(ceil(max(pathSamp))+3,1);
x = [1; zeros(length(delay) - 1, 1)];
ir = zeros(size(delay));
ynm1 = zeros(size(pathSamp));
if pathLen(1)~=0
    g = min(pathLen)./pathLen;
else
    g = min(pathLen(2:end))./pathLen;
    g(1) = 1;
end

load('octFilt_freqDomain.mat');
m = evalin('base', 'matFile');

path_refl_gain = ones(numPaths, 10);
for i = 2:numPaths
    for j = 1:length(mat{i})
        matProps = m.find(char(mat{i}(j,:)));
        path_refl_gain(i,:) = path_refl_gain(i,:).*(1-matProps.Absorption);
    end
end

impLen = size(octBands,1);
ir = zeros(ceil(max(pathSamp)) + impLen + 1,1);
f = [0:impLen/2 - 1]*fs/impLen;
airAbs = -atten(23, 29.92, 35, 1, f); % air aborption per unit length
airAbs = [airAbs airAbs(end) airAbs(end:-1:2)]';

for i = 1:numPaths
    sampBegin = ceil(pathSamp(i));
    pathRefl = sum(octBands .* repmat(path_refl_gain(i,:), impLen, 1),2);
    pathFreqResp = mps(pathRefl .* 10.^(airAbs * pathLen(i) / 20)); 
    pathImp = g(i)*ifft(pathFreqResp, 'symmetric');
%     pathImp = ifft(pathFreqResp, 'symmetric');
    pathImp(find(isnan(pathImp))) = zeros(size(pathImp(find(isnan(pathImp)))));
    ir(sampBegin:sampBegin + impLen - 1) = ir(sampBegin:sampBegin + impLen - 1) + ...
       sig_interp(pathImp, 1 - mod(pathSamp(i),1));
end

end
