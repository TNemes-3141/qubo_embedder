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

**An unofficial library to embed and send QUBO (quadratic unconstrained binary optimization) problems to DWave System quantum annealing solvers.** A native Dart equivalent to the [Ocean SDK][dwave_ocean_ref].

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
</details>

---

## Usage

Solving QUBO problems is handled by the `Solver` class which has different modes. Assuming you have your data prepared, it's relatively easy to get your solutions:

### Send to remote DWave annealer solver

```
await Solver.dwave_sampler(
    token='[YOUR_API_TOKEN]',
    solver='Advantage_system5.1',
    ).sample(
        hamiltonian,
        record_length=5,
    )
```

This takes care of the minor-embedding, API calls etc. automatically.

### Sample using local simulator

```
Solver.simulator().sample(
    hamiltonian,
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

[dwave_ocean_ref]: https://docs.ocean.dwavesys.com/en/stable/
[ml_linalg_ref]: https://pub.dev/packages/ml_linalg