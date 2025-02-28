#= print("MTTKRP Example:\n")

os.environ[sparse._ENV_VAR_NAME] = "Numba"
importlib.reload(sparse)

configs = [
    {"I_": 100, "J_": 25, "K_": 100, "L_": 10, "DENSITY": 0.001},
    {"I_": 100, "J_": 25, "K_": 100, "L_": 100, "DENSITY": 0.001},
    {"I_": 1000, "J_": 25, "K_": 100, "L_": 100, "DENSITY": 0.001},
    {"I_": 1000, "J_": 25, "K_": 1000, "L_": 100, "DENSITY": 0.001},
#    {"I_": 1000, "J_": 25, "K_": 1000, "L_": 1000, "DENSITY": 0.001},
]
#nonzeros = [100_000, 1_000_000, 10_000_000, 100_000_000, 1_000_000_000]
nonzeros = [100_000, 1_000_000, 10_000_000, 100_000_000]

if CI_MODE:
    configs = configs[:1]
    nonzeros = nonzeros[:1]

finch_times = []
numba_times = []
finch_galley_times = []

for config in configs:
    B_shape = (config["I_"], config["K_"], config["L_"])
    B_sps = sparse.random(B_shape, density=config["DENSITY"], random_state=rng)
    D_sps = rng.random((config["L_"], config["J_"]))
    C_sps = rng.random((config["K_"], config["J_"]))

    # ======= Finch =======
    os.environ[sparse._ENV_VAR_NAME] = "Finch"
    importlib.reload(sparse)

    B = sparse.asarray(B_sps.todense(), format="csf")
    D = sparse.asarray(np.array(D_sps, order="F"))
    C = sparse.asarray(np.array(C_sps, order="F"))

    @sparse.compiled(opt=sparse.DefaultScheduler())
    def mttkrp_finch(B, D, C):
        return sparse.sum(B[:, :, :, None] * D[None, None, :, :] * C[None, :, None, :], axis=(1, 2))

    # Compile
    result_finch = mttkrp_finch(B, D, C)
    # Benchmark
    time_finch = benchmark(mttkrp_finch, info="Finch", args=[B, D, C])

    # ======= Finch Galley =======
    os.environ[sparse._ENV_VAR_NAME] = "Finch"
    importlib.reload(sparse)

    B = sparse.asarray(B_sps.todense(), format="csf")
    D = sparse.asarray(np.array(D_sps, order="F"))
    C = sparse.asarray(np.array(C_sps, order="F"))

    @sparse.compiled(opt=sparse.GalleyScheduler(verbose=True))
    def mttkrp_finch_galley(B, D, C):
        return sparse.sum(B[:, :, :, None] * D[None, None, :, :] * C[None, :, None, :], axis=(1, 2))

    # Compile
    result_finch_galley = mttkrp_finch_galley(B, D, C)
    # Benchmark
    time_finch_galley = benchmark(mttkrp_finch_galley, info="Finch Galley", args=[B, D, C])

    # ======= Numba =======
    os.environ[sparse._ENV_VAR_NAME] = "Numba"
    importlib.reload(sparse)

    B = sparse.asarray(B_sps, format="gcxs")
    D = D_sps
    C = C_sps

    def mttkrp_numba(B, D, C):
        return sparse.sum(B[:, :, :, None] * D[None, None, :, :] * C[None, :, None, :], axis=(1, 2))

    # Compile
    result_numba = mttkrp_numba(B, D, C)
    # Benchmark
    time_numba = benchmark(mttkrp_numba, info="Numba", args=[B, D, C])

    np.testing.assert_allclose(result_finch.todense(), result_numba.todense())

    finch_times.append(time_finch)
    numba_times.append(time_numba)
    finch_galley_times.append(time_finch_galley) =#

using Finch

configs = [
    Dict("I_" => 100, "J_" => 25, "K_" => 100, "L_" => 10, "DENSITY" => 0.001),
    Dict("I_" => 100, "J_" => 25, "K_" => 100, "L_" => 100, "DENSITY" => 0.001),
    Dict("I_" => 1000, "J_" => 25, "K_" => 100, "L_" => 100, "DENSITY" => 0.001),
    Dict("I_" => 1000, "J_" => 25, "K_" => 1000, "L_" => 100, "DENSITY" => 0.001),
    Dict("I_" => 1000, "J_" => 25, "K_" => 1000, "L_" => 1000, "DENSITY" => 0.001),
]

function benchmark(f, args)
    avg_time = 0
    for iter in 0:5
        start_time = time()
        f(args...)
        if iter > 0
            avg_time += time() - start_time
        end
    end
    return avg_time / 5
end

for config in configs
    B_shape = (config["L_"], config["K_"], config["I_"])
    B_sps = lazy(
        Tensor(
            Dense(SparseList(SparseList(Element(0.0)))),
            fsprand(B_shape..., config["DENSITY"]),
        ),
    )
    D_sps = lazy(Tensor(rand(config["L_"], config["J_"])))
    C_sps = lazy(Tensor(rand(config["K_"], config["J_"])))
    function mttkrp_finch(B, D, C)
        return compute(
            sum(
                B[nothing, :, :, :] * D[:, :, nothing, nothing] * C[:, nothing, :, nothing];
                dims=(2, 3),
            );
            ctx=galley_scheduler(; verbose=false),
            tag=100,
        )
    end
    println(benchmark(mttkrp_finch, (B_sps, D_sps, C_sps)))
end
