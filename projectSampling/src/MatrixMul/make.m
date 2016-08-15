mex ('-v','-largeArrayDims',...
    'CentralMatrix.cpp',...
    [src_path,'matrix.cpp'],['-I',ipath], ...
    '-outdir',bin_path);
mex ('-v','-largeArrayDims',...
    'ExhaustiveSearchMatrix.cpp',...
    [src_path,'matrix.cpp'],['-I',ipath], ...
    '-outdir',bin_path);
mex ('-v','-largeArrayDims',...
    'DiamondMatrix.cpp',...
    [src_path,'matrix.cpp'],['-I',ipath], ...
    '-outdir',bin_path);
mex ('-v','-largeArrayDims',...
    'WedgeMatrix.cpp',...
    [src_path,'matrix.cpp'],['-I',ipath], ...
    '-outdir',bin_path);
