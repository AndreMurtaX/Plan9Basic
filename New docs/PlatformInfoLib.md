# Plan9Basic - PlatformInfoLib Documentation

## Platform Information Library Reference Manual

**Version:** 1.0  
**Date:** January 2026  
**Total Functions:** 10 (8 unique functions + 2 overloads)

---

## Table of Contents

1. [Overview](#overview)
2. [Platform Identification](#platform-identification)
3. [Version Information](#version-information)
4. [Version Checking](#version-checking)
5. [Service Pack Information](#service-pack-information)
6. [Complete Examples](#complete-examples)
7. [Quick Reference](#quick-reference)

---

## Overview

The PlatformInfoLib library provides functions to detect and query information about the operating system on which your Plan9Basic applet is running. This is useful for writing cross-platform applications that need to adapt their behavior based on the host system.

### Key Features

| Feature | Description |
|---------|-------------|
| **Cross-Platform** | Works on Windows, Linux, macOS, Android, and iOS |
| **Version Detection** | Get major, minor, and build version numbers |
| **Version Checking** | Verify minimum OS version requirements |
| **Architecture Detection** | Identify CPU architecture (x86, x64, ARM, etc.) |
| **Service Pack Info** | Query Windows service pack versions |

### Function Naming Convention

All functions in this library use the `os_` prefix:

| Suffix | Returns | Example |
|--------|---------|---------|
| `$` | String | `os_platform$()` |
| (none) | Number | `os_major()` |

---

## Platform Identification

### os_platform$()

Returns a complete description of the operating system, including name, version, and architecture.

**Signature:** `os_platform$@`

**Syntax:**
```basic
info$ = os_platform$()
```

**Returns:** Full platform description string

**Example Output by Platform:**

| Platform | Example Output |
|----------|----------------|
| Windows 11 | `Windows 11 (Version 23H2, Build 22631, 64-bit)` |
| Windows 10 | `Windows 10 (Version 21H2, Build 19044, 64-bit)` |
| macOS | `macOS 14.0 (Build 23A344)` |
| Linux | `Linux (Ubuntu 22.04)` |
| Android | `Android 13.0` |
| iOS | `iOS 17.0` |

**Example:**
```basic
println "Running on: "; os_platform$()
```

---

### os_name$()

Returns the operating system name without version details.

**Signature:** `os_name$@`

**Syntax:**
```basic
name$ = os_name$()
```

**Returns:** Operating system name

**Example Values:**

| Platform | Return Value |
|----------|--------------|
| Windows 11 | `Windows 11` |
| Windows 10 | `Windows 10` |
| macOS | `macOS Sonoma` |
| Linux | `Linux` |
| Android | `Android` |
| iOS | `iOS` |

**Example:**
```basic
name$ = os_name$()
println "Operating System: "; name$

if instr(name$, "Windows") >= 0 then
    println "Windows-specific code here"
else if instr(name$, "macOS") >= 0 then
    println "macOS-specific code here"
else if instr(name$, "Linux") >= 0 then
    println "Linux-specific code here"
endif
```

---

### os_architecture$()

Returns the CPU architecture of the system.

**Signature:** `os_architecture$@`

**Syntax:**
```basic
arch$ = os_architecture$()
```

**Returns:** Architecture name string

**Possible Values:**

| Value | Description |
|-------|-------------|
| `IntelX86` | 32-bit Intel/AMD processor |
| `IntelX64` | 64-bit Intel/AMD processor |
| `ARM32` | 32-bit ARM processor |
| `ARM64` | 64-bit ARM processor (Apple Silicon, etc.) |

**Example:**
```basic
arch$ = os_architecture$()
println "CPU Architecture: "; arch$

if arch$ = "ARM64" then
    println "Running on ARM64 (Apple Silicon or similar)"
else if arch$ = "IntelX64" then
    println "Running on 64-bit Intel/AMD"
else if arch$ = "IntelX86" then
    println "Running on 32-bit Intel/AMD"
endif
```

---

## Version Information

### os_major()

Returns the major version number of the operating system.

**Signature:** `os_major@`

**Syntax:**
```basic
major = os_major()
```

**Returns:** Major version number

**Example Values:**

| Platform | Major Version |
|----------|---------------|
| Windows 11 | 10 (internally still 10.x) |
| Windows 10 | 10 |
| macOS Sonoma (14) | 14 |
| macOS Ventura (13) | 13 |
| Android 13 | 13 |
| iOS 17 | 17 |

**Example:**
```basic
println "OS Major Version: "; os_major()
```

---

### os_minor()

Returns the minor version number of the operating system.

**Signature:** `os_minor@`

**Syntax:**
```basic
minor = os_minor()
```

**Returns:** Minor version number

**Example:**
```basic
println "OS Version: "; os_major(); "."; os_minor()
```

---

### os_build()

Returns the build number of the operating system.

**Signature:** `os_build@`

**Syntax:**
```basic
build = os_build()
```

**Returns:** Build number

**Notes:**
- On Windows, this is the detailed build number (e.g., 22631 for Windows 11 23H2)
- On macOS/iOS, this corresponds to the build identifier
- May not be meaningful on all platforms

**Example:**
```basic
println "Build: "; os_build()

' Windows 11 detection using build number
if os_major() = 10 then
    if os_build() >= 22000 then
        println "Windows 11 detected"
    else
        println "Windows 10 detected"
    endif
endif
```

---

## Version Checking

### os_check() - Two Parameters

Checks if the operating system version is at least the specified major and minor version.

**Signature:** `os_check@nn`

**Syntax:**
```basic
result = os_check(major, minor)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `major` | Number | Required major version |
| `minor` | Number | Required minor version |

**Returns:** 1 if OS version is >= specified version, 0 otherwise

**Example:**
```basic
' Check for Windows 10 or later
if os_check(10, 0) = 1 then
    println "Windows 10 or later detected"
else
    println "Older Windows version"
endif

' Check for macOS Monterey (12.0) or later
if os_check(12, 0) = 1 then
    println "macOS Monterey or later"
endif
```

---

### os_check() - Three Parameters

Checks if the operating system version is at least the specified major, minor, and service pack version.

**Signature:** `os_check@nnn`

**Syntax:**
```basic
result = os_check(major, minor, servicepack)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `major` | Number | Required major version |
| `minor` | Number | Required minor version |
| `servicepack` | Number | Required service pack version |

**Returns:** 1 if OS version meets requirements, 0 otherwise

**Note:** The service pack parameter is primarily useful for older Windows versions. Modern operating systems (Windows 10+, macOS, Linux, mobile) typically don't use service packs.

**Example:**
```basic
' Check for Windows 7 SP1 or later (legacy check)
if os_check(6, 1, 1) = 1 then
    println "Windows 7 SP1 or later"
endif
```

---

## Service Pack Information

### os_spmajor()

Returns the major service pack version number.

**Signature:** `os_spmajor@`

**Syntax:**
```basic
spMajor = os_spmajor()
```

**Returns:** Service pack major version (0 if no service pack or not applicable)

**Note:** Service packs are primarily a Windows concept. On modern systems (Windows 10+, macOS, Linux, mobile), this typically returns 0.

**Example:**
```basic
sp = os_spmajor()
if sp > 0 then
    println "Service Pack "; sp; " installed"
else
    println "No service pack (or not applicable)"
endif
```

---

### os_spminor()

Returns the minor service pack version number.

**Signature:** `os_spminor@`

**Syntax:**
```basic
spMinor = os_spminor()
```

**Returns:** Service pack minor version (usually 0)

**Example:**
```basic
println "Service Pack: "; os_spmajor(); "."; os_spminor()
```

---

## Complete Examples

### Example 1: System Information Display

```basic
' Display complete system information
println "=== System Information ==="
println ""
println "Platform: "; os_platform$()
println "OS Name: "; os_name$()
println "Architecture: "; os_architecture$()
println ""
println "Version Details:"
println "  Major: "; os_major()
println "  Minor: "; os_minor()
println "  Build: "; os_build()
println ""
println "Service Pack:"
println "  Major: "; os_spmajor()
println "  Minor: "; os_spminor()
```

---

### Example 2: Platform-Specific Code

```basic
' Execute platform-specific code
println "=== Platform Detection ==="
println ""

name$ = os_name$()

if instr(name$, "Windows") >= 0 then
    println "Running on Windows"
    
    ' Check Windows version
    if os_build() >= 22000 then
        println "  Windows 11 detected"
    else if os_major() >= 10 then
        println "  Windows 10 detected"
    else
        println "  Older Windows version"
    endif
    
else if instr(name$, "macOS") >= 0 then
    println "Running on macOS"
    println "  Version: "; os_major(); "."; os_minor()
    
else if instr(name$, "Linux") >= 0 then
    println "Running on Linux"
    
else if instr(name$, "Android") >= 0 then
    println "Running on Android"
    println "  API Level approximately: "; os_major()
    
else if instr(name$, "iOS") >= 0 then
    println "Running on iOS"
    println "  Version: "; os_major(); "."; os_minor()
    
else
    println "Unknown platform: "; name$
endif
```

---

### Example 3: Minimum Version Requirements

```basic
' Check minimum system requirements
println "=== System Requirements Check ==="
println ""

allOk = 1

' Define minimum requirements
println "Checking system requirements..."
println ""

' Check architecture
arch$ = os_architecture$()
println "Architecture: "; arch$
if arch$ = "IntelX86" then
    println "  WARNING: 32-bit system - some features may be limited"
else
    println "  OK: 64-bit system"
endif
println ""

' Platform-specific version checks
name$ = os_name$()

if instr(name$, "Windows") >= 0 then
    ' Require Windows 10 or later
    if os_check(10, 0) = 1 then
        println "Windows Version: OK (10 or later)"
    else
        println "Windows Version: FAIL (requires Windows 10+)"
        allOk = 0
    endif
    
else if instr(name$, "macOS") >= 0 then
    ' Require macOS 11 (Big Sur) or later
    if os_check(11, 0) = 1 then
        println "macOS Version: OK (11.0 or later)"
    else
        println "macOS Version: FAIL (requires macOS 11+)"
        allOk = 0
    endif
    
else if instr(name$, "Android") >= 0 then
    ' Require Android 10 or later
    if os_check(10, 0) = 1 then
        println "Android Version: OK (10 or later)"
    else
        println "Android Version: FAIL (requires Android 10+)"
        allOk = 0
    endif
    
else if instr(name$, "iOS") >= 0 then
    ' Require iOS 14 or later
    if os_check(14, 0) = 1 then
        println "iOS Version: OK (14 or later)"
    else
        println "iOS Version: FAIL (requires iOS 14+)"
        allOk = 0
    endif
endif

println ""
if allOk = 1 then
    println "All requirements met!"
else
    println "Some requirements not met. App may not work correctly."
endif
```

---

### Example 4: Architecture-Based Feature Selection

```basic
' Select features based on architecture
println "=== Feature Selection ==="
println ""

arch$ = os_architecture$()
println "Detected architecture: "; arch$
println ""

if arch$ = "ARM64" then
    println "ARM64 optimizations available:"
    println "  - NEON SIMD instructions"
    println "  - Energy-efficient processing"
    println "  - Native Apple Silicon support"
    
else if arch$ = "IntelX64" then
    println "x64 optimizations available:"
    println "  - SSE/AVX instructions"
    println "  - Large memory addressing"
    println "  - Full desktop performance"
    
else if arch$ = "IntelX86" then
    println "x86 compatibility mode:"
    println "  - Limited to 4GB RAM"
    println "  - Basic instruction set only"
    println "  - Consider upgrading to 64-bit"
    
else if arch$ = "ARM32" then
    println "ARM32 compatibility mode:"
    println "  - Mobile-optimized"
    println "  - Limited memory"
    println "  - Older device support"
endif
```

---

### Example 5: Generating System Report

```basic
' Generate a system report string
println "=== System Report Generator ==="
println ""

' Build report
report$ = "SYSTEM REPORT" + chr$(10)
report$ = report$ + "=============" + chr$(10)
report$ = report$ + chr$(10)
report$ = report$ + "Platform: " + os_platform$() + chr$(10)
report$ = report$ + "OS Name: " + os_name$() + chr$(10)
report$ = report$ + "Architecture: " + os_architecture$() + chr$(10)
report$ = report$ + "Version: " + stri$(os_major(), 0) + "." + stri$(os_minor(), 0) + chr$(10)
report$ = report$ + "Build: " + stri$(os_build(), 0) + chr$(10)

' Add service pack info if applicable
if os_spmajor() > 0 then
    report$ = report$ + "Service Pack: " + stri$(os_spmajor(), 0) + "." + stri$(os_spminor(), 0) + chr$(10)
endif

println report$

' This report could be saved to a file or sent for diagnostics
```

---

## Quick Reference

### Platform Identification
```basic
os_platform$()       ' Full platform description
os_name$()           ' OS name only
os_architecture$()   ' CPU architecture (IntelX86, IntelX64, ARM32, ARM64)
```

### Version Information
```basic
os_major()           ' Major version number
os_minor()           ' Minor version number
os_build()           ' Build number
```

### Version Checking
```basic
os_check(major, minor)              ' Check minimum version
os_check(major, minor, servicepack) ' Check with service pack
```

### Service Pack Information
```basic
os_spmajor()         ' Service pack major version
os_spminor()         ' Service pack minor version
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `os_architecture$` | `os_architecture$@` | Get CPU architecture |
| `os_build` | `os_build@` | Get OS build number |
| `os_check` | `os_check@nn` | Check minimum OS version |
| `os_check` | `os_check@nnn` | Check version with service pack |
| `os_major` | `os_major@` | Get major version number |
| `os_minor` | `os_minor@` | Get minor version number |
| `os_name$` | `os_name$@` | Get OS name |
| `os_platform$` | `os_platform$@` | Get full platform description |
| `os_spmajor` | `os_spmajor@` | Get service pack major version |
| `os_spminor` | `os_spminor@` | Get service pack minor version |

---

## Platform-Specific Notes

### Windows

- `os_major()` returns 10 for both Windows 10 and Windows 11
- Use `os_build()` to distinguish: Build >= 22000 indicates Windows 11
- Service pack functions return meaningful values for older Windows versions (7, 8)
- Modern Windows 10/11 don't use service packs (returns 0)

### macOS

- `os_major()` directly corresponds to macOS version (14 = Sonoma, 13 = Ventura, etc.)
- `os_architecture$()` returns `ARM64` on Apple Silicon Macs, `IntelX64` on Intel Macs
- Service pack functions return 0 (not applicable)

### Linux

- Version information depends on the distribution and kernel
- `os_architecture$()` accurately reflects the CPU architecture
- Service pack functions return 0 (not applicable)

### Android

- `os_major()` corresponds to Android version number
- `os_architecture$()` typically returns `ARM64` or `ARM32`
- Service pack functions return 0 (not applicable)

### iOS

- `os_major()` directly corresponds to iOS version (17, 16, etc.)
- `os_architecture$()` returns `ARM64` on modern devices
- Service pack functions return 0 (not applicable)

---

*End of PlatformInfoLib Documentation*
