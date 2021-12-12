%Manually overwrite probe info. Code copied from Nemin's file
%fix_Andi_data_N
function raw = updateProbeInfo(raw)
    probe=raw(1).probe;
    probe.link.type(1:2:end)=846;
    probe.link.type(2:2:end)=760;
    probe.optodes.X=probe.optodes.X*10;
    probe.optodes.Y=probe.optodes.Y*10;
    probe.optodes.Z=probe.optodes.Z*10;

    Name{1}='FpZ';
    xyz(1,:)=[-15 -54.623 0];
    Type{1}='FID-anchor';  % This is an anchor point
    Units{1}='mm';

    %Now let's add a few more
    Name{2}='Cz';
    xyz(2,:)=[150 -54.623 0];
    Type{2}='FID-attractor';  % This is an attractor
    Units{2}='mm';

    Name{3}='T7';
    xyz(3,:)=[0 -350 0];
    Type{3}='FID-attractor';  % This is an attractor
    Units{3}='mm';

    Name{4}='T8';
    xyz(4,:)=[0 350 0];
    Type{4}='FID-attractor';  % This is an attractor
    Units{4}='mm';

    fid=table(Name',xyz(:,1),xyz(:,2),xyz(:,3),Type',Units',...
        'VariableNames',{'Name','X','Y','Z','Type','Units'});
    probe.optodes=[probe.optodes; fid];

    probe1020=nirs.util.registerprobe1020(probe);

    lambda=[846 760];
    fwdBEM=nirs.registration.Colin27.BEM(lambda);
    fwdBEM.mesh(1).fiducials.Draw(:)=false;

    % Likewise, this will register a mesh onto your probe.  Note- the mesh is
    % the thing that is warped to mathc the head size (not the probe).  
    probe1020=probe1020.register_mesh2probe(fwdBEM.mesh);

    %rotate the probe so it plots better
    X=probe1020.optodes.X;
    Y=probe1020.optodes.Y;

    probe1020.optodes.X=Y;
    probe1020.optodes.Y=X;

    for i=1:length(raw)
        raw(i).probe=probe1020;
    end
end