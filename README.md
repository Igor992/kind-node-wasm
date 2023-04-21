# Run WebAssembly with Kind

## What is [WebAssembly](https://webassembly.org/)?

WebAssembly a.k.a. `wasm` is a binary instruction format and virtual machine that brings near-native performance to web browser applications, and allows developers to build high-speed web apps in the language of their choice.

---

## [WasmEdge](https://wasmedge.org/) runtime

WasmEdge is a lightweight, high-performance, and extensible WebAssembly runtime for cloud native, edge, and decentralized applications. It powers serverless apps, embedded functions, microservices, smart contracts, and IoT devices.

> WasmEdge Runtime was accepted to [CNCF](https://www.cncf.io/projects/wasmedge-runtime/) on `April 28, 2021` and is at the **Sandbox** project maturity level.
---

## Prepare Kubernetes for this workload

> I assume that the person who reads this repository knows the Kubernetes part well

To run wasm inside the kind cluster, we need to perform a change at the node side where this workload will be scheduled.

Kind node images yet don't support wasm workloads out of the box. I hope that this will be added soon to support an option for mixed workload types. Kind [releases](https://github.com/kubernetes-sigs/kind/releases) page is well documented and I advise you to check it out.

The game changer in this topic is [runwasi](https://github.com/containerd/runwasi) from the [containerd](https://containerd.io/)

What this does is let you to change behaviour of the low-level container runtime [runc](https://github.com/opencontainers/runc), to support new containerd [shim](https://iximiuz.com/en/posts/implementing-container-runtime-shim/) which runs wasm workloads.

To support this we need to build custom node [image](kind-wasm/image/node/Dockerfile) with [crun](https://github.com/containers/crun). There is couple changes that we need to perfrom in order to containerd starts work with WasmEdge [workload](https://github.com/containerd/runwasi#:~:text=build%20shim%20with%20wasmedge%20we%20need%20install%20library%20first). There is setup for the containerd [here](kind/image/node/containerd/config.toml) which will be used for our [runtimeclass](kind/runtime.yaml) that we use. One important thing as we use crun here, is to use [annotaiton](https://github.com/containers/crun/blob/main/docs/wasm-wasi-on-kubernetes.md#running-wasi-workload-natively-on-kubernetes-using-crun), in our case that is [here](kind/image/node/containerd/annotations.json).

Now we have prepared continerd to use new shim in order to manages container lifecycle events for wasm workload.

## Let's test it?

You can use this simple [Makefile](Makefile)

```console
Usage:
  make [ COMMAND ]

Commands:
  all               Build cluster and run the example workload
  node-image        Build the custom kind node image
  cluster           Create the cluster
  crun-workload     Build a wasm workload image and load it into kind
  crun-test         Deploy a test job with mixed workloads and print their logs
  clean             Delete the kind cluster
  docker            Clear all from machine
```

> To goes over complete flow use `make all`

---

## Documentation & Videos

- [WasmEdge in Kubernetes](https://wasmedge.org/book/en/use_cases/kubernetes.html)
- [CNCF WebAssembly](https://www.cncf.io/online-programs/cncf-live-webinar-geeking-out-with-webassembly-and-kubernetes-using-containerd-shims/)

---

## Blogs

> Check Ivan's other great explanations for containers, below is just one of the great examples!

- [Ivan Velichko](https://iximiuz.com/en/)
    - [container-runtime-shim](https://iximiuz.com/en/posts/implementing-container-runtime-shim/)
- [Nigel Poulton](https://nigelpoulton.com/)
    - [what-is-runwasi](https://nigelpoulton.com/what-is-runwasi/)
    - [webassembly-on-kubernetes](https://nigelpoulton.com/webassembly-on-kubernetes-everything-you-need-to-know/)

---