% renderRoom.m
% ------------------------------------------------------------------------------
% Project title: EVERT_matlab - MATLAB Wrappers for the EVERT library.
% 			  https://users.aalto.fi/~laines9/publications/laine2009aa_code.zip
% Description: Renders room surfaces in the room panel of the GUI.
% Author: Harish Venkatesan
%		  M.A., Music Technology
% 		  McGill University
% ------------------------------------------------------------------------------
function plotHandle = renderRoom(roomFile, plotHandle)

if nargin == 1
    plotHandle = figure();
    figure(plotHandle);
else
    axes(plotHandle);
end

f = fopen(roomFile, 'r');
i = 1;
while 1
    line = fgetl(f);
    if line == -1
        break;
    end

    txt = strsplit(line);
    if txt{1} == '1'
        numPoints = str2double(txt{6});
        srfcs(i).c = [str2double(txt{3}) str2double(txt{4}) str2double(txt{5})];
        srfcs(i).material = txt{end};
        for j = 0:numPoints-1
            srfcs(i).points(j+1,1) = str2double(txt{6 + 3*j + 1})*0.001;
            srfcs(i).points(j+1,2) = str2double(txt{6 + 3*j + 2})*0.001;
            srfcs(i).points(j+1,3) = str2double(txt{6 + 3*j + 3})*0.001;
        end
    end
    i = i+1;
end
fclose(f);

% figure(plotHandle);
for i = 1:length(srfcs)
    fill3(srfcs(i).points(:,1), srfcs(i).points(:,2), srfcs(i).points(:,3), srfcs(i).c, 'FaceAlpha', 0.25);
    hold on;
end

renderSrcAndLst(plotHandle);

end
