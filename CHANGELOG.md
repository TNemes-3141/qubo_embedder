## 0.2.0

* Implemented the DWave sampler, DWave API interface and pseudo-embedding algorithms to allow sending QUBO problems to real quantum annealers!
* Samplers now require the `Qubo` format instead of `Hamiltonian` objects as input, allowing for a more functional approach. To compensate, QUBO problems can now be created from Hamiltonians:
    ```
    final qubo = Qubo.fromHamiltonian(hamiltonian);
    ```
* New objects:
    * `DwaveApi` with `ApiParams` allows a low-level access to the DWave Solver REST API
    * `QpuSolverInfo`, `SolverGraphInfo`
    * `Embedder`
    * Abstract `Embedding` class with implementations in `PseudoEmbedding` and `MinorEmbedding`
    * `Encoder`, `Decoder`
    * `Constants`

## 0.1.0

* First prerelease containing the essential features and data structures
    * `Sampler`
    * `Qubo`
    * `Hamiltonian`
    * `SolutionVector`
    * `SolutionRecord` and `SolutionRecordEntry`
