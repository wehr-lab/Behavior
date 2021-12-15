function Notes2Text(nb,outputtextfilename)
for i = 1:size(nb.notes,1)
        if isequal(i,1)
            NotebookNotes = nb.notes(i,:);
        else
            NotebookNotes = strcat(NotebookNotes,'\n',nb.notes(i,:));
        end
end
fid = fopen(outputtextfilename,'wt');
fprintf(fid, NotebookNotes);
fclose(fid);
end