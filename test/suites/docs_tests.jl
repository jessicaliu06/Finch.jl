@testitem "docs" skip=(Sys.WORD_SIZE != 64) begin
    using ..Main: parsed_args

    if parsed_args["overwrite"]
        include("../../docs/fix.jl")
    else
        include("../../docs/test.jl")
    end
end