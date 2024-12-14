function backup -d "Rename backup file.bak as file" --argument filename
    mv $filename (echo $filename | sed s/.bak//)
end
