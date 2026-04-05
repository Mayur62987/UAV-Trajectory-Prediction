function h = prunedata(b)

Num_data = length(b)
for i = 1:Num_data
    N = length(b(i))
    indx = 0
    for j = 1:N
        if b(i(j)).validposition & b(i(j)).validtrack
            indx = indx+1
            h(indx) = b(i(j))
        end
    end
end
        