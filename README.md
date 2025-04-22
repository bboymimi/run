# QEMU VM Runner

A bash script for running QEMU virtual machines with configurable CPU, memory, and networking options.

## Prerequisites

- QEMU (qemu-system-x86_64)
- KVM enabled
- VM image file (e.g., ubuntu-noble.img)
- Linux kernel image (bzImage)

## Usage

```bash
./run.sh [options]
```

### Options

- `-m, --memory`: Memory size (default: 2G)
- `-s, --cpu-sockets`: Number of CPU sockets (default: 2)
- `-c, --cpu-cores`: Number of CPU cores per socket (default: 1)
- `-p, --host-port`: Host port for SSH forwarding (default: 10022)
- `-i, --image`: VM image file path
- `-k, --kernel`: Kernel path
- `-hp, --hugepages`: Use default hugepages (/dev/hugepages) with preallocation
- `-mp, --mem-path`: Custom memory path with preallocation
- `-d, --debug`: Enable debug mode (-s -S options)
- `-h, --help`: Show help message

### Examples

1. Basic usage with required options:
```bash
./run.sh -i ubuntu-noble.img -k path/to/bzImage
```

2. Custom memory and CPU configuration:
```bash
./run.sh -i ubuntu-noble.img -k path/to/bzImage -m 4G -s 4 -c 2
```

3. Using hugepages:
```bash
./run.sh -i ubuntu-noble.img -k path/to/bzImage --hugepages
```

4. Custom memory path:
```bash
./run.sh -i ubuntu-noble.img -k path/to/bzImage --mem-path /path/to/hugepages
```

5. Debug mode:
```bash
./run.sh -i ubuntu-noble.img -k path/to/bzImage --debug
```

## Memory Management

The script supports two memory configurations:

1. Default memory allocation
2. Hugepages with preallocation (either using default path or custom path)

When using hugepages:
- The memory path must exist
- Memory preallocation is automatically enabled
- For default hugepages, use `-hp` or `--hugepages`
- For custom path, use `-mp` or `--mem-path`

## Networking

The script sets up networking with:
- e1000 NIC model
- User-mode networking
- SSH port forwarding (default host port: 10022)

## Debugging

Debug mode enables QEMU's `-s -S` options for GDB debugging:
- `-s`: Opens port 1234 for GDB connection
- `-S`: Halts CPU at startup (continue with GDB) 