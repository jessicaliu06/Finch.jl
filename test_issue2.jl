using Finch
using Profile

config = (
    (100, 25, 100, 10, 0.001),
    (100, 25, 100, 100, 0.001),
    (1000, 25, 100, 100, 0.001),
    (1000, 25, 1000, 100, 0.001),
    (1000, 25, 1000, 1000, 0.001),
)

for (I, J, K, L, DENSITY) in config
    B_shape = (I, K, L)
    B_tensor = fsprand(Float64, I, K, L, DENSITY)
    D_tensor = rand(L, J)
    C_tensor = rand(K, J)

    B_lazy = lazy(swizzle(B_tensor, 1, 2, 3))
    D_lazy = lazy(swizzle(Tensor(D_tensor), 1, 2))
    C_lazy = lazy(swizzle(Tensor(C_tensor), 1, 2))

    plan = sum(
        permutedims(
            broadcast(*,
                permutedims(
                    permutedims(
                        broadcast(*,
                            permutedims(B_lazy[:, :, :, nothing], (4, 3, 2, 1)),
                            permutedims(D_lazy[nothing, nothing, :, :], (4, 3, 2, 1)),
                        ),
                        (4, 3, 2, 1),
                    ),
                    (4, 3, 2, 1),
                ),
                permutedims(C_lazy[nothing, :, nothing, :], (4, 3, 2, 1)),
            ),
            (4, 3, 2, 1),
        );
        dims=(2, 3),
    )

    scheduler = Finch.default_scheduler()
    result = compute(plan; ctx=scheduler)
    t0 = time()
    result = compute(plan; ctx=scheduler)
    t1 = time()
    print("Default - Elapsed: ", t1 - t0, "\n")

    scheduler = Finch.galley_scheduler(; verbose=false)
    result = compute(plan; ctx=scheduler, tag=sum(B_shape))
    t0 = time()
    result = compute(plan; ctx=scheduler, tag=sum(B_shape))
    t1 = time()
    print("Galley - Elapsed: ", t1 - t0, "\n\n")
end
