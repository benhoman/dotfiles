function backup -d "Create backup of file as filename.bak" --argument filename
    cp $filename $filename.bak
end
