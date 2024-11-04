struct Null end

FinchNotation.finch_leaf(x::Null) = literal(x)
unwrap_outer(ctx, tns::Null, mode, protos) = tns