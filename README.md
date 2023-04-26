<div align="center">
    <a href="#">
        <img alt="version" src="https://img.shields.io/static/v1.svg?label=Version&message=0.1.0&color=389ad5&labelColor=31c4f3&style=for-the-badge" />
    </a>
    <a href="#">
        <img alt="open source" src="https://img.shields.io/static/v1.svg?label=Open&message=Source&color=46a4b8&labelColor=3ac1d0&style=for-the-badge" />
    </a>
    <a href="#">
        <img alt="license" src="https://img.shields.io/static/v1.svg?label=License&message=MIT&color=ae68cc&labelColor=6e4a7e&style=for-the-badge" />
    </a>
    <a href="#">
        <img alt="code size" src="https://img.shields.io/github/languages/code-size/Totemi1324/qubo_embedder?label=Code%20size&style=for-the-badge" />
    </a>
    <a href="#">
        <img alt="issues" src="https://img.shields.io/github/issues/Totemi1324/Quantos?label=Issues&style=for-the-badge" />
    </a>

<p><br></p>

**An unofficial library to embed and send optimization (QUBO, Ising) problems to DWave System quantum annealing solvers.** A native Dart equivalent to the [Ocean SDK][dwave_ocean_ref].

</div>

<details>
<summary>TABLE OF CONTENTS</summary>

- [Usage](#usage)
    - [Send to remote DWave annealer solver](#send-to-remote-dwave-annealer-solver)
    - [Sample using local simulator](#sample-using-local-simulator)
- [Data structures](#data-structures)
    - [Qubo](#qubo)
    - [Hamiltonian](#hamiltonian)
    - [SolutionVector](#solutionvector)
    - [SolutionRecord](#solutionrecord)
- [DWave API](#data-structures)
    - [Interact with the API manually](#interact-with-the-api-manually)
    - [Embedding types and algorithms](#embedding-types-and-algorithms)
    - [Encoding and decoding](#encoding-and-decoding)
</details>

---

## Usage

Solving QUBO problems is handled by the `Solver` class which has different modes. Assuming you have your data prepared, it's relatively easy to get your solutions:

### Send to remote DWave annealer solver

```
await Solver.dwaveSampler(
        region='eu-central-1'
        solver='Advantage_system5.3',
        token='[YOUR_API_TOKEN]',
    ).sampleQubo(
        qubo,
    )
```

This takes care of the embedding, API calls etc. automatically.

### Sample using local simulator

```
Solver.simulator().sampleQubo(
    qubo,
    record_length=5,
)
```

## Data structures

You can format your problems using built-in data types. These use [the ml_linalg package][ml_linalg_ref] internally to provide fast and efficient handling of linear algebra types and operations, especially in the `Solver.simulator()` solver.

### Qubo

Add the coefficients of your QUBO-problems using the indices of the affected variables (beginning at 0).

```
import 'package:qubo_embedder/qubo_embedder.dart';

void main() {
    var qubo = Qubo(size: 2);

    qubo.addEntry(0, 0, value: 2.0);
    qubo.addEntry(1, 1, value: 2.0);
    qubo.addEntry(0, 1, value: -2.0);
    // qubo.addEntry(1, 0, value: 2.0) throws an InvalidOperationException

    print(qubo.getEntry(0, 1)); // -2.0
    print(qubo); // [qubits: 2] {(0, 0): 2.0, (0, 1): -2.0, (1, 1): 2.0}
}
```

### Hamiltonian

If you're done, you can transform `Qubo` objects to `Hamiltonian` which the samplers take as an input.

```
import 'package:qubo_embedder/qubo_embedder.dart';

void main() {
    var hamiltonian = Hamiltonian.fromQubo(qubo);

    print(hamiltonian.matrix) // [[2.0, -2.0], [0.0, 2.0]]
}
```

### SolutionVector

This type you seldom have to create for yourself, but is used by the solvers to return the solutions to a QUBO problem. A solution vector is immutable, but can be transformed into a regular list.

```
import 'package:qubo_embedder/qubo_embedder.dart';

void main() {
    var solutionVector = SolutionVector.fromList([0, 1]);

    print(solutionVector.vector); // [0, 1]
    print(solutionVector); // [q0: 0, q1: 1]
}
```

### SolutionRecord

Sampler store their solutions as entries in this record, which you can get by `entries()` and iterate over for solution details. When returned by a sampler, the entries are sorted by energy in ascending order.

```
import 'package:qubo_embedder/qubo_embedder.dart';

void main() {
    ...

    for (var entry in solutionRecord.entries()) {
        print("E=${entry.energy}\t${entry.solutionVector}\t${entry.numOccurrences}x")
    } // E=-2.0	[q0: 0, q1: 1, q2: 1, q3: 0, ]	x142

    print(solutionRecord);
    //   energy	sample	occurrences
    //(1) -2.0	[q0: 0, q1: 1, q2: 1, q3: 0, ]	x142
    
}
```

## DWave API

Sometimes, pre-defined samplers aren't enough. For specific operations and scenarios not covered by `Solver`, you can use the `DwaveApi` class to gain low-level access to the [DWave REST Solver API][dwave_sapi_ref], sending and managing requests directly. 

### Interact with the API manually

Here, a list of currently available solvers is requested:

```
import 'package:qubo_embedder/qubo_embedder.dart';

final _params = ApiParams(apiRegion: 'eu-central-1', apiToken: '[YOUR_API_TOKEN]');

Future<void> main() async {
    List<QpuSolverInfo> solvers = await DwaveApi.getAvailableQpuSolvers(_params);

    print(solvers[0].name) //Advantage_system3.5
    print(solvers[0].numQubits) //5616
}
```

You can go from there and, for example, select the solver with the highest count of qubits available and supply it to `DwaveSampler`. Keep in mind that `DwaveApi` only offers static wrappers to selected API requests, returning an awaitable `Future`. Encoding and decoding of body properties is done automatically (see [Encoding and decoding](#encoding-and-decoding)).

### Embedding types and algorithms

If needed, embeddings can also be intercepted by creating it yourself. Currently supported are `PseudoEmbedding` (faster, but will only work for a problem size up to 4) and `MinorEmbedding` (slower, but works on all problems as long as the physical qubits are not exhausted), which both are descendants of the `Embedding` superclass. Embeddings can't be instantiated directly but have to be created by `Embedder`, depending on the supplied algorithm.

```
Embedder.embedQubo(
    qubo: qubo,
    graphInfo: graphInfo, //Retrieved from the DWave API
    type: EmbeddingAlgorithm.pseudo,
);
```

An embedding consists of a map of physical qubit IDs with their respective bias and a map of couplers with their respective bias.

### Encoding and decoding

This utility class is used by `DwaveApi` internally, but can be accessed directly as well if needed. The DWave Rest Solver API accepts and returns problem data only in bit-packed, base64-encoded form, for which the `Encoder` and `Decoder` classes offer conversion methods that utilize [the binary package][binary_ref] for performance.

| _SAPI body parameter_     | _Codec_                                                                           | _Corresponding method_    |
|---------------------------|-----------------------------------------------------------------------------------|---------------------------|
| **Submission**            |                                                                                   |                           |
| `data.lin`                | Base64-encoded, little-endian 8-byte floating point numbers                       | `Encoder.encodeDoubles()` |
| `data.quad`               | Base64-encoded, little-endian 8-byte floating point numbers                       | `Encoder.encodeDoubles()` |
| **Retreival**             |                                                                                   |                           |
| `answer.solutions`        | Base64-encoded bits in little-endian order, each padded to end on a byte boundary | `Decoder.decodeBinary()`  |
| `answer.energies`         | Base64-encoded, little-endian 8-byte floating point numbers                       | `Decoder.decodeDoubles()` |
| `answer.num_occurrences`  | Base64-encoded, little-endian 4-byte integers                                     | `Decoder.decodeInts()`    |
| `answer.active_variables` | Base64-encoded, little-endian 4-byte integers                                     | `Decoder.decodeInts()`    |

[dwave_ocean_ref]: https://docs.ocean.dwavesys.com/en/stable/
[ml_linalg_ref]: https://pub.dev/packages/ml_linalg
[dwave_sapi_ref]: https://docs.dwavesys.com/docs/latest/doc_rest_api.html
[binary_ref]: https://pub.dev/packages/binary