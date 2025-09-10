using Finch

function is_bipartite(edges)
    # Verify that the input adjacency matrix is square.
    (n, m) = size(edges)    
    @assert n == m

    edges = pattern!(edges)

    # Graph coloring
    # -1: Unvisited
    # 0/1: Colors
    C = Tensor(Dense(Element(-1)), n)

    # Record any coloring conflicts
    conflict = Tensor(Dense(Element(false)), 1)

    for source in 1:n
        if C[source] == -1
            # Color source vertex with color 0
            @finch C[source] = 0
            
            # Frontier
            F = Tensor(SparseByteMap(Pattern()), n)
            @finch F[source] = true     # Add source vertex to frontier                       
            F_nnz = 1                   # Count number of non-zero entries in frontier, i.e., number of vertices in frontier
            
            # Next frontier
            _F = Tensor(SparseByteMap(Pattern()), n)
            
            # Explore the connected component starting from the source vertex.
            while F_nnz > 0
                new_colors = Tensor(Dense(Element(-1)), n)
                @finch new_colors .= -1

                @finch begin
                    _F .= false         # Clear the next frontier.

                    for u in _, v in _
                        if F[u] && edges[v, u]
                            # The correct color should be the opposite color from the parent.
                            let correct_color = 1 - C[u]
                                # If the vertex has already been visited and colored the wrong color, this graph cannot be bipartite.
                                conflict[1] |= (C[v] != -1 && C[v] != correct_color)

                                # If the vertex has not yet been visited, color it the correct color and add it to the frontier.
                                if C[v] == -1
                                    new_colors[v] = correct_color
                                    _F[v] |= true
                                end
                            end
                        end
                    end
                end

                @finch begin
                    for v in _
                        if new_colors[v] != -1
                            C[v] = new_colors[v]
                        end
                    end
                end

                # Count the number of vertices in the new frontier
                num_vertices = Scalar(0)
                @finch begin
                    for v in _
                        num_vertices[] += _F[v]
                    end
                end
                
                (F, _F) = (_F, F)
                F_nnz = num_vertices[]
            end
        end
    end

    if conflict[1]
        return false
    end    
    return true
end

edges = Tensor(CSCFormat(), [0 1 0 1;
                             1 0 1 0;
                             0 1 0 1;
                             1 0 1 0])
println(string("C_4: ", is_bipartite(edges)))

edges = Tensor(CSCFormat(), [0 1 1;
                             1 0 1;
                             1 1 0])
println(string("C_3: ", is_bipartite(edges)))                             

edges = Tensor(CSCFormat(), [0 1 0 0;
                             1 0 0 0;
                             0 0 0 1;
                             0 0 1 0])
println(string("Disconnected bipartite (P_1 + P_1): ", is_bipartite(edges)))  

edges = Tensor(CSCFormat(), [0 1 0 0 0;
                             1 0 0 0 0;
                             0 0 0 1 1;
                             0 0 1 0 1;
                             0 0 1 1 0])
println(string("Disconnected not bipartite (P_1 + C_3): ", is_bipartite(edges)))  

edges = Tensor(CSCFormat(), [0 1 0 0 1 1 0 0 0 0;
                             1 0 1 0 0 0 1 0 0 0;
                             0 1 0 1 0 0 0 1 0 0;
                             0 0 1 0 1 0 0 0 1 0;
                             1 0 0 1 0 0 0 0 0 1;
                             1 0 0 0 0 0 0 1 1 0;
                             0 1 0 0 0 0 0 0 1 1;
                             0 0 1 0 0 1 0 0 0 1;
                             0 0 0 1 0 1 1 0 0 0;
                             0 0 0 0 1 0 1 1 0 0])
println(string("Petersen graph: ", is_bipartite(edges)))  

edges = Tensor(CSCFormat(), [0 0 0 0 1 1 1 1;
                             0 0 0 0 1 1 1 1;
                             0 0 0 0 1 1 1 1;
                             0 0 0 0 1 1 1 1;
                             1 1 1 1 0 0 0 0;
                             1 1 1 1 0 0 0 0;
                             1 1 1 1 0 0 0 0;
                             1 1 1 1 0 0 0 0])
println(string("K_{4,4}: ", is_bipartite(edges))) 