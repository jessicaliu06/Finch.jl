struct Null end

FinchNotation.finch_leaf(x::Null) = literal(x)
unfurl_prehook(ctx, tns::Null, mode, protos) = tns