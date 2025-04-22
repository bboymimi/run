#!/bin/bash

# Default values
MEMORY="2G"
CPU_SOCKETS=2
CPU_CORES=1
HOST_FORWARD_PORT=10022
GUEST_PORT=22
IMAGE_FILE=""
KERNEL_PATH=""
MEM_PATH=""
MEM_PREALLOC=false
DEBUG_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --memory|-m)
            MEMORY="$2"
            shift 2
            ;;
        --cpu-sockets|-s)
            CPU_SOCKETS="$2"
            shift 2
            ;;
        --cpu-cores|-c)
            CPU_CORES="$2"
            shift 2
            ;;
        --host-port|-p)
            HOST_FORWARD_PORT="$2"
            shift 2
            ;;
        --image|-i)
            IMAGE_FILE="$2"
            shift 2
            ;;
        --kernel|-k)
            KERNEL_PATH="$2"
            shift 2
            ;;
        --hugepages|-hp)
            MEM_PATH="/dev/hugepages"
            MEM_PREALLOC=true
            shift
            ;;
        --mem-path|-mp)
            MEM_PATH="$2"
            MEM_PREALLOC=true
            shift 2
            ;;
        --debug|-d)
            DEBUG_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  -m, --memory      Memory size (default: 2G)"
            echo "  -s, --cpu-sockets Number of CPU sockets (default: 2)"
            echo "  -c, --cpu-cores   Number of CPU cores per socket (default: 1)"
            echo "  -p, --host-port   Host port for SSH forwarding (default: 10022)"
            echo "  -i, --image       VM image file (where your ubuntu-noble.img is)"
            echo "  -k, --kernel      Kernel path (where your bzImage is)"
            echo "  -hp, --hugepages  Use default hugepages (/dev/hugepages) with preallocation"
            echo "  -mp, --mem-path   Custom memory path with preallocation (e.g., /path/to/hugepages)"
            echo "  -d, --debug       Enable debug mode (-s -S options)"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# Validate memory path if specified
if [ -n "$MEM_PATH" ]; then
    if [ ! -d "$MEM_PATH" ]; then
        echo "Error: Memory path '$MEM_PATH' does not exist"
        exit 1
    fi
fi

# Build QEMU command
QEMU_CMD="qemu-system-x86_64 \
    -enable-kvm \
    -m \"$MEMORY\" \
    -smp \"$CPU_SOCKETS,sockets=$CPU_SOCKETS,cores=$CPU_CORES\" \
    -mem-path \"$MEM_PATH\""

# Add memory preallocation if enabled
if [ "$MEM_PREALLOC" = true ]; then
    QEMU_CMD="$QEMU_CMD -mem-prealloc"
fi

# Add remaining fixed options
QEMU_CMD="$QEMU_CMD \
    -nographic \
    -machine pc-q35-7.1 \
    -net nic,model=e1000 \
    -net user,hostfwd=tcp::$HOST_FORWARD_PORT-:$GUEST_PORT \
    -append \"root=/dev/sda console=ttyS0 rw sysctl.vm.dirty_bytes=2147483647 panic=10 io_delay=0xed libata.allow_tpm=1 nmi_watchdog=panic tco_start=1 slab_nomerge fb_tunnels=none firmware_class.path=/var/google/session net.ifnames=0 sysctl.kernel.hung_task_all_cpu_backtrace=1 ima_policy=tcb nf-conntrack-ftp.ports=20000 nf-conntrack-tftp.ports=20000 nf-conntrack-sip.ports=20000 nf-conntrack-irc.ports=20000 nf-conntrack-sane.ports=20000 binder.debug_mask=0 rcupdate.rcu_expedited=1 rcupdate.rcu_cpu_stall_cputime=1 no_hash_pointers page_owner=on sysctl.vm.nr_hugepages=4 sysctl.vm.nr_overcommit_hugepages=4 secretmem.enable=1 sysctl.max_rcu_stall_to_panic=1 msr.allow_writes=off coredump_filter=0xffff mitigations=off mce=print_all acpi_enforce_resources=lax video=efifb:off hest_disable=1 erst_disable=1 bert_disable=1 retbleed=off spec_rstack_overflow=off eagerfpu=on kvm_amd.nested=0 ccp.init_ex_path=/var/google/persistent/bios/psp_nv_data ccp.psp_init_on_probe=0 console=ttyS0 vsyscall=native kvm-intel.nested=1 spec_store_bypass_disable=prctl nopcid vivid.n_devs=16 vivid.multiplanar=1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2 netrom.nr_ndevs=16 rose.rose_ndevs=16 smp.csd_lock_timeout=100000 watchdog_thresh=55 workqueue.watchdog_thresh=140 sysctl.net.core.netdev_unregister_timeout_secs=140 dummy_hcd.num=8 resched_latency_warn_ms=0 intel_iommu=optin pcie_port_pm=off pm80xx.link_rate=0x2 pm80xx.spinup_group=5 pm80xx.spinup_interval_ms=10000 pm80xx.spinup_group_decrease=1 scsi_mod.scan=async scsi_mod.force_queue_depth=1,512:0\" \
    -hda \"$IMAGE_FILE\" \
    -kernel \"$KERNEL_PATH\""

# Add debug options if enabled
if [ "$DEBUG_MODE" = true ]; then
    QEMU_CMD="$QEMU_CMD -s -S"
fi

# Execute QEMU command
eval "$QEMU_CMD"