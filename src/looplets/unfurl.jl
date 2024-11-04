truncate(ctx, node, ext, ext_2) = node

@kwdef struct Furlable
    body
end

FinchNotation.finch_leaf(x::Furlable) = virtual(x)

#Base.show(io::IO, ex::Furlable) = Base.show(io, MIME"text/plain"(), ex)
#function Base.show(io::IO, mime::MIME"text/plain", ex::Furlable)
#    print(io, "Furlable()")
#end


"""
    unfurl(ctx, tns, ext, proto)

Return an array object (usually a looplet nest) for lowering the virtual tensor
`tns`. `ext` is the extent of the looplet. `proto` is the protocol that should
be used for this index.
"""
function unfurl(ctx, tns::Furlable, ext, mode, proto)
    tns = tns.body(ctx, ext)
    return tns
end
unfurl(ctx, tns, ext, mode, proto) = error(sprint(dump, tns))

instantiate(ctx, tns::Furlable, mode, protos) = tns
is_injective(ctx, tns::Furlable) = is_injective(ctx, tns.body)
is_atomic(ctx, tns::Furlable) = is_atomic(ctx, tns.body)
is_concurrent(ctx, tns::Furlable) = is_concurrent(ctx, tns.body)