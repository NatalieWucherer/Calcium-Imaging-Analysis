function [F,coords,fileName,outFolder] = LoadData(filePath)

if nargin<1

    [file,path]=uigetfile('*.mat');

    if isequal(file,0)

        error("No file selected")

    end

    filePath=fullfile(path,file);

end

S=load(filePath);

if ~isfield(S,'exStruct')

    error('No exStruct found.')

end

ex=S.exStruct;

F=ex.cells.dF;

F(isnan(F))=0;

coords=[];

if isfield(ex.cells,'xPos') && isfield(ex.cells,'yPos')

    coords=[ex.cells.xPos(:),ex.cells.yPos(:)];

end

[fileFolder,fileName]=fileparts(filePath);

outFolder=fileFolder;

end