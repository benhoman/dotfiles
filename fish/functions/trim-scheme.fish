function trim-scheme -d "Trim scheme from text"
    sed -r 's|.+://||'
end
